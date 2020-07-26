function [Modulation, N_BPSC, N_CBPS, N_DBPS] = rateDependents(dataRate)

    switch dataRate
        case 6
            output = ["BPSK",1,48,24];
        case 9
            output = ["BPSK",1,48,36];
        case 12
            output = ["QPSK",2,96,48];
        case 18
            output = ["QPSK",2,96,72];
        case 24
            output = ["16QAM",4,192,96];
        case 36
            output = ["16QAM",4,192,144];
        case 48
            output = ["64QAM",6,288,192];
        case 54
            output = ["64QAM",6,288,216];
        
    end
    
    Modulation = output(1,1);
    N_BPSC = str2double(output(1,2));
    N_CBPS = str2double(output(1,3));
    N_DBPS = str2double(output(1,4));

end