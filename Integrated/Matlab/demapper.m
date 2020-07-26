function y = demapper(mappedData, mapMode, Kmod)

L = length(mappedData);

switch mapMode
    case 'BPSK'
        N_BPSC = 1;
        demappedData = zeros(L*N_BPSC,1);
        for i = 1:1:L
            tempData = mappedData(i,1); 
            if(tempData == -1)
                demappedData(i,1) = 0;
            else
                demappedData(i,1) = 1;
            end
        end
    case 'QPSK'
        N_BPSC = 2;
        demappedData = zeros(L*N_BPSC,1);
        for i = 1:N_BPSC:L*N_BPSC
            
            if(Kmod ~= true)
                tempData = mappedData((i+N_BPSC-1)/N_BPSC,1);
            else
                tempData = round(mappedData((i+N_BPSC-1)/N_BPSC,1)*sqrt(2)); % Rounding is EXTREMELY CRITICAL! Root cause of severe mismatch!
            end
            
            if(real(tempData) == -1)
                demappedData(i,1) = 0;
            else
                demappedData(i,1) = 1;
            end
            
            
            if(imag(tempData) == -1)
                demappedData(i+N_BPSC-1,1) = 0;
            else
                demappedData(i+N_BPSC-1,1) = 1;
            end
        end
        
    case '16QAM'
        N_BPSC = 4;
        demappedData = zeros(L*N_BPSC,1);
        for i = 1:N_BPSC:L*N_BPSC
            
            if(Kmod ~= true)
                tempData = mappedData((i+N_BPSC-1)/N_BPSC,1);
            else
                tempData = round(mappedData((i+N_BPSC-1)/N_BPSC,1)*sqrt(10));
            end
            
            if(real(tempData) == -3)
                demappedData(i:i+1,1) = [0;0];
            end
            if(real(tempData) == -1)
                demappedData(i:i+1,1) = [0;1];
            end
            if(real(tempData) == 1)
                demappedData(i:i+1,1) = [1;1];
            end
            if(real(tempData) == 3)
                demappedData(i:i+1,1) = [1;0];
            end
            
            
            
            if(imag(tempData) == -3)
                demappedData(i+2:i+3,1) = [0;0];
            end
            if(imag(tempData) == -1)
                demappedData(i+2:i+3,1) = [0;1];
            end
            if(imag(tempData) == 1)
                demappedData(i+2:i+3,1) = [1;1];
            end
            if(imag(tempData) == 3)
                demappedData(i+2:i+3,1) = [1;0];
            end
        end
        
    case '64QAM'
        N_BPSC = 6;
        demappedData = zeros(L*N_BPSC,1);
        for i = 1:N_BPSC:L*N_BPSC
            
            if(Kmod ~= true)
                tempData = mappedData((i+N_BPSC-1)/N_BPSC,1);
            else
                tempData = round(mappedData((i+N_BPSC-1)/N_BPSC,1)*sqrt(42));
            end
            
            if(real(tempData) == -7)
                demappedData(i:i+2,1) = [0;0;0];
            end
            if(real(tempData) == -5)
                demappedData(i:i+2,1) = [0;0;1];
            end
            if(real(tempData) == -3)
                demappedData(i:i+2,1) = [0;1;1];
            end
            if(real(tempData) == -1)
                demappedData(i:i+2,1) = [0;1;0];
            end
            if(real(tempData) == 1)
                demappedData(i:i+2,1) = [1;1;0];
            end
            if(real(tempData) == 3)
                demappedData(i:i+2,1) = [1;1;1];
            end
            if(real(tempData) == 5)
                demappedData(i:i+2,1) = [1;0;1];
            end
            if(real(tempData) == 7)
                demappedData(i:i+2,1) = [1;0;0];
            end

            
            
            
            if(imag(tempData) == -7)
                demappedData(i+3:i+5,1) = [0;0;0];
            end
            if(imag(tempData) == -5)
                demappedData(i+3:i+5,1) = [0;0;1];
            end
            if(imag(tempData) == -3)
                demappedData(i+3:i+5,1) = [0;1;1];
            end
            if(imag(tempData) == -1)
                demappedData(i+3:i+5,1) = [0;1;0];
            end
            if(imag(tempData) == 1)
                demappedData(i+3:i+5,1) = [1;1;0];
            end
            if(imag(tempData) == 3)
                demappedData(i+3:i+5,1) = [1;1;1];
            end
            if(imag(tempData) == 5)
                demappedData(i+3:i+5,1) = [1;0;1];
            end
            if(imag(tempData) == 7)
                demappedData(i+3:i+5,1) = [1;0;0];
            end
            
        end
end

y = demappedData;

end