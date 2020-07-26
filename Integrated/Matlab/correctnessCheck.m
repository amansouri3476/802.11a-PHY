function [] = correctnessCheck(PSDUs, txStream, rxStream, stage, isDATA)
if(isDATA)
    if(stage == "scrambler")

        numOfSamples = length(txStream);
        DATA_FIELDS_CONCATENATED = [];
        for i = 1:1:numOfSamples
           DATA_FIELDS_CONCATENATED = [DATA_FIELDS_CONCATENATED;txStream{i}];
        end
        txStream = DATA_FIELDS_CONCATENATED;

        BER = sum(xor(txStream,rxStream));

        disp("BER for scrambler/descrambler is:");
        disp(BER);
    end

    if(stage ~= "scrambler")

        numOfSamples = length(PSDUs);

        BER = [];
        for i = 1:1:numOfSamples
           BER(i,1) = sum(xor(rxStream{i,1},PSDUs{1,i}'))/length(PSDUs{1,i});
        end

        FinalBER = sum(BER);

        disp("DATA: BER for the output for all of PSDUs");
        disp(FinalBER);
    end
else % Correction check for SIGNAL FIELDS
    numOfSamples = length(txStream);
    for i = 1:1:numOfSamples
       BER(i,1) = sum(xor(txStream{1,i},rxStream{i,1}));
    end

    FinalBER = sum(BER);

    disp("BER for SIGNAL transmission is:");
    disp(FinalBER);
end
    

end