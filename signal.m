function SIGNAL = signal(RATE, LENGTH)

    switch RATE % i.e. for 6 MB/s, R4-R1 are 1101 so RATE should be 1011. 
                % NOTE that the order is reversed
        case 6
            % RATE = [1, 0, 1, 1];
            RATE = [1, 1, 0, 1];
        case 9
            % RATE = [1, 1, 1, 1];
            RATE = [1, 1, 1, 1];
        case 12
            % RATE = [1, 0, 1, 0];
            RATE = [0, 1, 0, 1];
        case 18
            % RATE = [1, 1, 1, 0];
            RATE = [0, 1, 1, 1];
        case 24
            % RATE = [1, 0, 0, 1];
            RATE = [1, 0, 0, 1];
        case 36
            % RATE = [1, 1, 0, 1];
            RATE = [1, 0, 1, 1];
        case 48
            % RATE = [1, 0, 0, 0];
            RATE = [0, 0, 0, 1];
        case 54
            % RATE = [1, 1, 0, 0];
            RATE = [0, 0, 1, 1];
    end
    
    RATE = RATE';
    RESERVED = 0;
    LENGTH_BITS = de2bi(LENGTH, 12, 'left-msb'); % NOTE the normal behavior 
                                                 % of de2bi
    LENGTH_BITS = LENGTH_BITS(end:-1:1)'; % reversing the order of bits 
                                         % because the LSB should be 
                                         % transmitted first
    
                                         
    % Parity should be the XOR of first 17 bits. If there is an odd number 
    % of ones, then this bit is set to one, o.w. it's set to zero. We first
    % need to XOR the bits of RATE, then XOR the bits of LENGTH, then XOR
    % these results together with the RESERVED bit. This result is the
    % Parity bit. NOTE that since the output is of type 'logic' we need to
    % cast it to type double so that it can be used in accordance with the
    % rest of the bits.
    Parity = mod(sum(RATE) + sum(LENGTH_BITS),2); % if there is an odd 
                                                  % number of ones in the 
                                                  % first 17 bits, the 
                                                  % summation is odd and 
                                                  % the resulting mod is 1 
                                                  % too.
                                                  
    TAIL = zeros(6, 1);
    
    SIGNAL = [RATE;RESERVED;LENGTH_BITS;Parity;TAIL];
end