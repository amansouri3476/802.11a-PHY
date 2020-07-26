function [output] = receiver(channelDATA, recvSIGNAL, stage, scramInit, trellis, predecessors)
% function [output,dataFieldDemapped,dataFieldDeinterleaved,DATA_FIELDS_VIT_DECODED] = receiver(channelDATA, recvSIGNAL, stage, scramInit, trellis, predecessors)

numOfSamples = length(recvSIGNAL);
for i = 1:1:numOfSamples
    Lengths(i,1) = bi2de(recvSIGNAL{i,1}(6:17)');
    dataRates(i,1) = codedRate2dataRate(recvSIGNAL{i,1}(1:4,1)');
end
if(stage ~= "scrambler") % preventing waste of time
    
    if(stage ~= "encoder") % preventing waste of time
        
        if(stage ~= "interleaver") % preventing waste of time
            
            if(stage ~= "mapper") % preventing waste of time
            
                    % ---------------------------------------- Pilot Removal ------------------------------------- %


                dataFieldPilotRemoved = {};

                if(stage == "pilot inserter")
                    DATA_FIELDS_PILOT_INSERTED = channelDATA;
                    numOfSamples = length(channelDATA);
                    for i = 1:1:numOfSamples
                        dataFieldPilotRemoved{i,1} = [];
                        for j = 1:53:length(DATA_FIELDS_PILOT_INSERTED{i,1})
                            symbolBlock = DATA_FIELDS_PILOT_INSERTED{i,1}(j:j+52,1); 
                            dataFieldPilotRemoved{i,1} = [dataFieldPilotRemoved{i,1};pilotRemove(symbolBlock)];
                        end           
                    end

                end

                
            end
                     % ---------------------------------------- Symbol Demapping ------------------------------------- %

            

            dataFieldDemapped = {};

            if(stage == "mapper")
                DATA_FIELDS_MAPPED = channelDATA;
                numOfSamples = length(channelDATA);
            else
                DATA_FIELDS_MAPPED = dataFieldPilotRemoved;
                numOfSamples = length(dataFieldPilotRemoved);
            end
            for i = 1:1:numOfSamples    
                [mapMode, ~, ~, ~] = rateDependents(dataRates(i,1));
                dataFieldDemapped{i,1} = demapper(DATA_FIELDS_MAPPED{i,1}, mapMode, false);            
            end

        end
             % ---------------------------------------- De-Interleaving ------------------------------------- %



        dataFieldDeinterleaved = {};

        if(stage == "interleaver")
            DATA_FIELDS_INTERLEAVED = channelDATA;
            numOfSamples = length(channelDATA);
        else
            DATA_FIELDS_INTERLEAVED = dataFieldDemapped;
            numOfSamples = length(dataFieldDemapped);
        end
        for i = 1:1:numOfSamples

            [mapMode, ~, N_CBPS, ~] = rateDependents(dataRates(i,1));
            N_col = 16; % According to the standard
            N_row = N_CBPS/16;

            % Data field de-interleaving
            for j = 1:N_CBPS:length(DATA_FIELDS_INTERLEAVED{i,1})
                dataBlock = DATA_FIELDS_INTERLEAVED{i,1}(j:j+N_CBPS-1,1);
                % de-interleave
                dataFieldDeinterleaved{i,1}(j:j+N_CBPS-1,1) = interleaveDeinterleave(dataBlock, 1, N_CBPS, N_col, N_row, mapMode);
            end

        end
    end
         % ---------------------------------------- Viterbi Decoding ------------------------------------- %

    % If you're not checking scrambler stage, please note:
    % CRITICAL: Since 6 bits were set to 0 after scrambling, it is nonesense to
    % expect the descrambler to have 0 BER with respect to scrambler's input.
    % Hence we should check only the resulting PSDU with the original PSDU we
    % passed to the transmitter.

    if(stage == "encoder")
        DATA_FIELDS_CONV_ENCODED = channelDATA;
        numOfSamples = length(channelDATA);
    else
        DATA_FIELDS_CONV_ENCODED = dataFieldDeinterleaved;
        numOfSamples = length(dataFieldDeinterleaved);
    end
    
    DATA_FIELDS_VIT_DECODED = {};
    for i = 1:1:numOfSamples % channel will be a cell array 1xnumOfSamples

        [puncturePattern,coeff] = puncPattern(dataRates(i,1));    

        initCurrState = 1;

        % Dummy bits should be inserted according to the puncturing pattern for
        % Rates higher than 1/2.
        dummyInsertedDataChunk = zeros(length(DATA_FIELDS_CONV_ENCODED{i,1})*coeff,1);

        puncpatrepeated = repmat(puncturePattern, ceil(size(dummyInsertedDataChunk,1)/size(puncturePattern,1)), 1);
        puncpatextended = puncpatrepeated(1:size(dummyInsertedDataChunk,1),1);

        dummyInsertedDataChunk(puncpatextended == 1) = DATA_FIELDS_CONV_ENCODED{i,1};

        eraseMarks = puncpatextended;

        DATA_FIELDS_VIT_DECODED{i,1} = [];
        for j = 1:24:length(dummyInsertedDataChunk)
            [decodedData,finalCurrState] = viterbiDecode(dummyInsertedDataChunk(j:j+23,1), trellis, predecessors, ...
            initCurrState, eraseMarks(j:j+23,1));
            initCurrState = finalCurrState;
            DATA_FIELDS_VIT_DECODED{i,1} = [DATA_FIELDS_VIT_DECODED{i,1};decodedData];
        end
    end
    
end

     % ---------------------------------------- Descrambler ------------------------------------- %
     
% Scrambler: SIGNAL Fields is NOT descrambled.
% Only DATA FIELD is descrambled.

if(stage == "scrambler")
    DATA_FIELDS_SCRAMBLED = channelDATA;
    DATA_FIELDS_DESCRAMBLED = scramble(DATA_FIELDS_SCRAMBLED, scramInit');
    output = DATA_FIELDS_DESCRAMBLED;
else % its input comes from higher level modules.    
    % in this case concatenation is necessary.
    DATA_FIELDS_VIT_DECODED_CONCATENATED = [];
    for i = 1:1:numOfSamples
        DATA_FIELDS_VIT_DECODED_CONCATENATED = [DATA_FIELDS_VIT_DECODED_CONCATENATED;DATA_FIELDS_VIT_DECODED{i,1}];
    end
    DATA_FIELDS_DESCRAMBLED = scramble(DATA_FIELDS_VIT_DECODED_CONCATENATED, scramInit');
    
    % for checking with the tx PSDUs, we need separated version of these.
    offsetIndex = 1;
    DATA_FIELDS_DESCRAMBLED_NOTCONCAT = {};
    for i = 1:1:numOfSamples
        DATA_FIELDS_DESCRAMBLED_NOTCONCAT{i,1} = DATA_FIELDS_DESCRAMBLED(offsetIndex:offsetIndex-1+length(DATA_FIELDS_VIT_DECODED{i,1}),1);
        offsetIndex = offsetIndex + length(DATA_FIELDS_VIT_DECODED{i,1});
    end

    EXTRACTED_PSDUs = {};
    for i = 1:1:numOfSamples
        EXTRACTED_PSDUs{i,1} = DATA_FIELDS_DESCRAMBLED_NOTCONCAT{i,1}(17:16+8*Lengths(i,1));
    end
    
    output = EXTRACTED_PSDUs;
end



end