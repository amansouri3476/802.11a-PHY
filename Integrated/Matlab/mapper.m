function y = mapper(data, mapMode, Kmod)

L = length(data);

switch mapMode
    case 'BPSK'
        N_BPSC = 1;
        mappedData = zeros(L,1);
        for i = 1:N_BPSC:L
            tempBits = data(i,1); 
            if(tempBits == 0)
                mappedData(i,1) = -1;
            else
                mappedData(i,1) = 1;
            end
        end
    case 'QPSK'
        N_BPSC = 2;
        mappedData = zeros(L/N_BPSC,1);
        for i = 1:N_BPSC:L
            tempBits = data(i:i+N_BPSC-1,1);
            if(tempBits(1,1) == 0)
                Real = -1;
            else
                Real = 1;
            end
            
            if(tempBits(2,1) == 0)
                Imag = -1;
            else
                Imag = 1;
            end
            
            if(Kmod ~= true)
                mappedData((i+N_BPSC-1)/N_BPSC,1) = Real + 1i*Imag;
            else
                mappedData((i+N_BPSC-1)/N_BPSC,1) = (Real + 1i*Imag)/sqrt(2);
            end
        end
        
    case '16QAM'
        N_BPSC = 4;
        mappedData = zeros(L/N_BPSC,1);
        for i = 1:N_BPSC:L
            tempBits = data(i:i+N_BPSC-1,1);
            if(isequal(tempBits(1:2,1),[0;0]))
                Real = -3;
            end
            if(isequal(tempBits(1:2,1),[0;1]))
                Real = -1;
            end
            if(isequal(tempBits(1:2,1),[1;1]))
                Real = 1;
            end
            if(isequal(tempBits(1:2,1),[1;0]))
                Real = 3;
            end
            
            
            
            if(isequal(tempBits(3:4,1),[0;0]))
                Imag = -3;
            end
            if(isequal(tempBits(3:4,1),[0;1]))
                Imag = -1;
            end
            if(isequal(tempBits(3:4,1),[1;1]))
                Imag = 1;
            end
            if(isequal(tempBits(3:4,1),[1;0]))
                Imag = 3;
            end
            
            if(Kmod ~= true)
                mappedData((i+N_BPSC-1)/N_BPSC,1) = Real + 1i*Imag;
            else
                mappedData((i+N_BPSC-1)/N_BPSC,1) = (Real + 1i*Imag)/sqrt(10);
            end
            
        end
        
    case '64QAM'
        N_BPSC = 6;
        mappedData = zeros(L/N_BPSC,1);
        for i = 1:N_BPSC:L
            tempBits = data(i:i+N_BPSC-1,1);
            if(isequal(tempBits(1:3,1),[0;0;0]))
                Real = -7;
            end
            if(isequal(tempBits(1:3,1),[0;0;1]))
                Real = -5;
            end
            if(isequal(tempBits(1:3,1),[0;1;1]))
                Real = -3;
            end
            if(isequal(tempBits(1:3,1),[0;1;0]))
                Real = -1;
            end
            if(isequal(tempBits(1:3,1),[1;1;0]))
                Real = 1;
            end
            if(isequal(tempBits(1:3,1),[1;1;1]))
                Real = 3;
            end
            if(isequal(tempBits(1:3,1),[1;0;1]))
                Real = 5;
            end
            if(isequal(tempBits(1:3,1),[1;0;0]))
                Real = 7;
            end
            
            
           
            
            if(isequal(tempBits(4:6,1),[0;0;0]))
                Imag = -7;
            end
            if(isequal(tempBits(4:6,1),[0;0;1]))
                Imag = -5;
            end
            if(isequal(tempBits(4:6,1),[0;1;1]))
                Imag = -3;
            end
            if(isequal(tempBits(4:6,1),[0;1;0]))
                Imag = -1;
            end
            if(isequal(tempBits(4:6,1),[1;1;0]))
                Imag = 1;
            end
            if(isequal(tempBits(4:6,1),[1;1;1]))
                Imag = 3;
            end
            if(isequal(tempBits(4:6,1),[1;0;1]))
                Imag = 5;
            end
            if(isequal(tempBits(4:6,1),[1;0;0]))
                Imag = 7;
            end
            
            if(Kmod ~= true)
                mappedData((i+N_BPSC-1)/N_BPSC,1) = Real + 1i*Imag;
            else
                mappedData((i+N_BPSC-1)/N_BPSC,1) = (Real + 1i*Imag)/sqrt(42);
            end
            
        end
end

y = mappedData;

end