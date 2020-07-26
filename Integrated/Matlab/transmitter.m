function [channelDATA, scramInit] = transmitter(DATA_FIELDS, dataRates, Lengths, stage)
% function [channelDATA, scramInit, dataFieldinterleaved, DATA_FIELDS_CONV_ENCODED, DATA_FIELDS_SCRAMBLED_NOTCONCAT] = transmitter(DATA_FIELDS, dataRates, Lengths, stage)
     % ---------------------------------------- Scrambler ------------------------------------- %

% Scrambler: Note that PLCP Header and SIGNAL Fields are NOT scrambled.
% Only DATA FIELD is scrambled.

numOfSamples = length(DATA_FIELDS);
scramInit = randi([0 1], 1, 7);
DATA_FIELDS_CONCATENATED = [];
DATA_FIELDS_SCRAMBLED_NOTCONCAT = {};
for i = 1:1:numOfSamples
   DATA_FIELDS_CONCATENATED = [DATA_FIELDS_CONCATENATED;DATA_FIELDS{i}];
end

DATA_FIELDS_SCRAMBLED = scramble(DATA_FIELDS_CONCATENATED, scramInit');

if(stage == "scrambler")
    channelDATA = DATA_FIELDS_SCRAMBLED;
end

% for encoding, we need separated version of these.
offsetIndex = 1;
for i = 1:1:numOfSamples
    
    DATA_FIELDS_SCRAMBLED_NOTCONCAT{i,1} = DATA_FIELDS_SCRAMBLED(offsetIndex:offsetIndex-1+length(DATA_FIELDS{1,i}),1);
    offsetIndex = offsetIndex + length(DATA_FIELDS{1,i});
    % CRITICAL for convolutional encoder: DATA FIELD is arranged in this order 
    % -> [SERVICE;PSDU;TAIL;PAD]. After this field is scrambled, 6 zero bits in
    % TAIL are changed and should be reset to 0 again to return the convolutional 
    % encoder to the "zero state".
    % Since length(SERVICE+PSDU)= 16 + 8*PacketLength, we
    % should change scrambledBits of index (16+8*PacketLength+1:16+8*PacketLength+1+6) to zero.
    DATA_FIELDS_SCRAMBLED_NOTCONCAT{i,1}(16+8*Lengths(i,1)+1:16+8*Lengths(i,1)+1+6) = 0;
end


if(stage ~= "scrambler") % preventing waste of time

         % ---------------------------------------- Convolutional Encoding ------------------------------------- %


    % Convolutional Encoder: Note that BOTH SIGNAL and DATA Fields ARE encoded.
    % But the SIGNAL FIELD encoding does NOT depend on RATE, it is encoded BPSK
    % and the rate is 1/2.

    % We need:
    % Data Rate which determines:
    % Modulation: BPSK, QPSK, 16-QAM, 64-QAM
    % Coding Rate: 1/2, 3/4, 2/3
    % Coded bits per subcarrier (N_BPSC) = 1, 2, 4, 6
    % Coded bits per OFDM Symbol (N_CBPS) = 48, 96, 192, 288
    % Coded bits per subcarrier (N_DBPS) = 24, 36, 48, 72, 96, 144, 192, 216

    for i = 1:1:numOfSamples
       [puncturePattern,~] = puncPattern(dataRates(i,1));
       DATA_FIELDS_CONV_ENCODED{i,1} = convolutionalEncode(DATA_FIELDS_SCRAMBLED_NOTCONCAT{i,1}, [0, 0, 0, 0, 0, 0]', puncturePattern);
    end

    if(stage == "encoder")
        channelDATA = DATA_FIELDS_CONV_ENCODED;
    end

    if(stage ~= "encoder") % preventing waste of time
             % ---------------------------------------- Interleaving ------------------------------------- %


        % Interleaver: Note that BOTH SIGNAL and DATA Fields ARE encoded.
        % But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
        % interleaved with a block interleaver of constant size = 48. (Because the
        % SIGNAL FIELD is always 24 bits, its encoded version is always 48 bits
        % because the encoding rate is also fixed for this FIELD.)



        dataFieldinterleaved = {};

        for i = 1:1:numOfSamples

            [mapMode, ~, N_CBPS, ~] = rateDependents(dataRates(i,1));
            N_col = 16; % According to the standard
            N_row = N_CBPS/16;
            for j = 1:N_CBPS:length(DATA_FIELDS_CONV_ENCODED{i,1})
                dataBlock = DATA_FIELDS_CONV_ENCODED{i,1}(j:j+N_CBPS-1,1);
                % interleave
                dataFieldinterleaved{i,1}(j:j+N_CBPS-1,1) = interleaveDeinterleave(dataBlock, 0, N_CBPS, N_col, N_row, mapMode);
            end
            
        end

        if(stage == "interleaver")
            channelDATA = dataFieldinterleaved;
        end

        if(stage ~= "interleaver") % preventing waste of time
                 % ---------------------------------------- Symbol Mapping ------------------------------------- %



                % Symbol Mapper: Note that BOTH SIGNAL and DATA Fields ARE mapped.
                % But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
                % mapped with argument 'BPSK'.

                dataFieldmapped = {};

                for i = 1:1:numOfSamples
                    [mapMode, ~, ~, ~] = rateDependents(dataRates(i,1));
                    dataFieldmapped{i,1} = mapper(dataFieldinterleaved{i,1}, mapMode, false);
                end

                if(stage == "mapper")
                    channelDATA = dataFieldmapped;
                end


            if(stage ~= "mapper") % preventing waste of time
                % ---------------------------------------- Pilot Insertion ------------------------------------- %

                % Pilot Insertion: Note that BOTH SIGNAL and DATA Fields ARE pilot inserted.


                pseudoRandomSeq = scramble(zeros(127,1), ones(7,1));
                normalized_array = normalize(pseudoRandomSeq,'range',[-1 1]);
                pseudoRandomSeq = normalized_array*-1;

                dataFieldPilotInserted = {};

                for i = 1:1:numOfSamples
                    dataFieldPilotInserted{i,1} = [];
                    for j = 1:48:length(dataFieldmapped{i,1})
                        symbolBlock = dataFieldmapped{i,1}(j:j+47,1); % 48 subcarriers (+ 4 pilot)
                        blockID = ((j+47)/48) + 1; % +1 is CRITICAL because first element of 
                                                   % the sequence determines pilot polarity of
                                                   % SIGNAL FIELD's pilots.
                        % pilot insertion
                        dataFieldPilotInserted{i,1} = [dataFieldPilotInserted{i,1};pilotInsert(symbolBlock, blockID, pseudoRandomSeq)];
                    end

                    if(stage == "pilot inserter")
                        channelDATA = dataFieldPilotInserted;
                    end

                end

            end
        
        end
        
    end
     
end

end