function DATA = dataField(RATE, LENGTH, PSDU)
% Rate should be an integer from the set {6, 9, 12, 18, 24, 36, 48, 54}    
% LENGTH should be an integer and gives the number of data bytes in PSDU
% PSDU should be a binary column vector. For the code to work properly,
% PSDU should be organized accordingly. For instance if the message is: 
% ['04','02','0a'] in hex, the input PSD should be ['40','20','a0'] in hex
% or ['0100 0000','0010 0000','1010 0000'] in binary. Keep this in mind
% when passing input to this function.
    
    SERVICE = zeros(16,1);
    TAIL = zeros(6,1);
    
    switch RATE
        case 6
            N_BPSC = 1;
            N_CBPS = 48;
            N_DBPS = 24;
        case 9
            N_BPSC = 1;
            N_CBPS = 48;
            N_DBPS = 36;
        case 12
            N_BPSC = 2;
            N_CBPS = 96;
            N_DBPS = 48;
        case 18
            N_BPSC = 2;
            N_CBPS = 96;
            N_DBPS = 72;
        case 24
            N_BPSC = 4;
            N_CBPS = 192;
            N_DBPS = 96;
        case 36
            N_BPSC = 4;
            N_CBPS = 192;
            N_DBPS = 144;
        case 48
            N_BPSC = 6;
            N_CBPS = 288;
            N_DBPS = 192;
        case 54
            N_BPSC = 6;
            N_CBPS = 288;
            N_DBPS = 216;
        
    end
    
    N_SYM = ceil((16 + LENGTH*8 + 6)/N_DBPS);
    N_DATA = N_SYM * N_DBPS;
    N_PAD = N_DATA - (16 + LENGTH*8 + 6);
    
    PAD = zeros(N_PAD, 1);
    
    DATA = [SERVICE;PSDU;TAIL;PAD];

end