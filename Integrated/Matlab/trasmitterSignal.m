function [channelSIGNAL] = trasmitterSignal(SIGNALS, stage)


numOfSamples = length(SIGNALS);
N_col = 16;
     % ---------------------------------------- Scrambler ------------------------------------- %

% Scrambler: Note that PLCP Header and SIGNAL Fields are NOT scrambled.
% Only DATA FIELD is scrambled. So we do nothing here.


if(stage == "scrambler")
    channelSIGNAL = SIGNALS; % No scrambling for SIGNAL FIELD in this case.
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
       % SIGNAL FIELD encoding
       SIGNAL_FIELD_CONV_ENCODED{i,1} = convolutionalEncode(SIGNALS{1,i}, [0, 0, 0, 0, 0, 0]', [1,1]'); % puncture pattern for 1/2 rate is [1,1]
    end

    if(stage == "encoder")
        channelSIGNAL = SIGNAL_FIELD_CONV_ENCODED;
    end

    if(stage ~= "encoder") % preventing waste of time
             % ---------------------------------------- Interleaving ------------------------------------- %


        % Interleaver: Note that BOTH SIGNAL and DATA Fields ARE encoded.
        % But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
        % interleaved with a block interleaver of constant size = 48. (Because the
        % SIGNAL FIELD is always 24 bits, its encoded version is always 48 bits
        % because the encoding rate is also fixed for this FIELD.)



        signalFieldinterleaved = {};

        for i = 1:1:numOfSamples
            
            % Signal field interleaving
            signalFieldinterleaved{i,1} = interleaveDeinterleave(SIGNAL_FIELD_CONV_ENCODED{i,1}, 0, 48, N_col, 48/16, 'BPSK'); % These are fixed for SIGNAL FIELD 
            
        end

        if(stage == "interleaver")
            channelSIGNAL = signalFieldinterleaved;
        end

        if(stage ~= "interleaver") % preventing waste of time
                 % ---------------------------------------- Symbol Mapping ------------------------------------- %



                % Symbol Mapper: Note that BOTH SIGNAL and DATA Fields ARE mapped.
                % But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
                % mapped with argument 'BPSK'.

                signalFieldmapped = {};

                for i = 1:1:numOfSamples
                    signalFieldmapped{i,1} = mapper(signalFieldinterleaved{i,1}, 'BPSK', false);                  
                end

                if(stage == "mapper")
                    channelSIGNAL = signalFieldmapped;
                end


            if(stage ~= "mapper") % preventing waste of time
                % ---------------------------------------- Pilot Insertion ------------------------------------- %

                % Pilot Insertion: Note that BOTH SIGNAL and DATA Fields ARE pilot inserted.


                pseudoRandomSeq = scramble(zeros(127,1), ones(7,1));
                normalized_array = normalize(pseudoRandomSeq,'range',[-1 1]);
                pseudoRandomSeq = normalized_array*-1;

                signalFieldPilotInserted = {};

                for i = 1:1:numOfSamples
                    signalFieldPilotInserted{i,1} = pilotInsert(signalFieldmapped{i,1}, 1, pseudoRandomSeq);

                    if(stage == "pilot inserter")
                        channelSIGNAL = signalFieldPilotInserted;
                    end

                end

            end
        
        end
        
    end
     
end

end