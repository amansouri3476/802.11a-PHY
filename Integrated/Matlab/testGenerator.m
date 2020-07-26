function [DATA_FIELDS, SIGNALS, PSDUs, Lenghts, bitRates] = testGenerator(numOfSamples, MaximumLength)

    bitRateSelectors = randi(8,1,numOfSamples);
    Lenghts = randi(MaximumLength,numOfSamples,1);
    bitRates = zeros(numOfSamples,1);
    PSDUs = {};

    for i = 1:1:numOfSamples
        bitRates(i,1) = RateSelect(bitRateSelectors(1,i));
        PSDUs{1,i} = randi([0 1],1,8*Lenghts(i));
    end


    SIGNALS = {};
    DATA_FIELDS = {};

    for i = 1:1:numOfSamples
       SIGNALS{1,i} = signal(bitRates(i,1), Lenghts(i,1));
       DATA_FIELDS{1,i} = dataField(bitRates(i,1), Lenghts(i,1), PSDUs{i}');
    end

end