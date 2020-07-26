function output = receiverSignal(channelSIGNAL, stage, trellis, predecessors)

N_col = 16;

if(stage ~= "scrambler") % preventing waste of time
    
    if(stage ~= "encoder") % preventing waste of time
        
        if(stage ~= "interleaver") % preventing waste of time
            
            if(stage ~= "mapper") % preventing waste of time
            
                    % ---------------------------------------- Pilot Removal ------------------------------------- %


                signalFieldPilotRemoved = {};

                if(stage == "pilot inserter")
                    SIGNAL_FIELDS_PILOT_INSERTED = channelSIGNAL;
                    numOfSamples = length(channelSIGNAL);
                    for i = 1:1:numOfSamples
                        signalFieldPilotRemoved{i,1} = pilotRemove(SIGNAL_FIELDS_PILOT_INSERTED{i,1});          
                    end

                end

                
            end
                     % ---------------------------------------- Symbol Demapping ------------------------------------- %

            

            signalFieldDemapped = {};

            if(stage == "mapper")
                SIGNAL_FIELDS_MAPPED = channelSIGNAL;
                numOfSamples = length(channelSIGNAL);
            else
                SIGNAL_FIELDS_MAPPED = signalFieldPilotRemoved;
            end
            for i = 1:1:numOfSamples
                signalFieldDemapped{i,1} = demapper(SIGNAL_FIELDS_MAPPED{i,1}, 'BPSK', false);   
            end

        end
             % ---------------------------------------- De-Interleaving ------------------------------------- %



        dataFieldDeinterleaved = {};

        if(stage == "interleaver")
            SIGNAL_FIELDS_INTERLEAVED = channelSIGNAL;
            numOfSamples = length(channelSIGNAL);
        else
            SIGNAL_FIELDS_INTERLEAVED = signalFieldDemapped;
            numOfSamples = length(signalFieldDemapped);
        end
        for i = 1:1:numOfSamples
            % Signal field de-interleaving
            signalFieldDeinterleaved{i,1} = interleaveDeinterleave(SIGNAL_FIELDS_INTERLEAVED{i,1}, 1, 48, N_col, 48/16, 'BPSK'); % These are fixed for SIGNAL FIELD
        end
    end
         % ---------------------------------------- Viterbi Decoding ------------------------------------- %


    if(stage == "encoder")
        SIGNAL_FIELDS_CONV_ENCODED = channelSIGNAL;
        numOfSamples = length(channelSIGNAL);
    else
        SIGNAL_FIELDS_CONV_ENCODED = signalFieldDeinterleaved;
        numOfSamples = length(signalFieldDeinterleaved);
    end
    
    for i = 1:1:numOfSamples % channel will be a cell array 1xnumOfSamples
        
        % Since SIGNAL was encoded with a 1/2 rate, no puncturing, hence no dummy
        % insertion is required. Its length is always 24 fixed. (its encoded
        % version is 48 bits.)
        SIGNAL_FIELD_VIT_DECODED{i,1} = viterbiDecode(SIGNAL_FIELDS_CONV_ENCODED{i,1}, trellis, predecessors, ...
            1, ones(48,1)); 
    end
    
end

     % ---------------------------------------- Descrambler ------------------------------------- %
     
% Scrambler: SIGNAL Fields is NOT descrambled.
% Only DATA FIELD is descrambled.

if(stage == "scrambler")
    % We should do nothing
    output = channelSIGNAL';
else % its input comes from higher level modules.      
    output = SIGNAL_FIELD_VIT_DECODED;
end

end