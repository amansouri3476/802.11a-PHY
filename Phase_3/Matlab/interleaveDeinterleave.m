function [y, indexes] = interleaveDeinterleave(x, mode, N_CBPS, ncol, nrow, mapmode)

blockSize = N_CBPS;
if(mode == 0)
    L = length(x);
end
if(mode == 1)
    L = blockSize;
end

N_col = ncol;
N_row = nrow;
mapMode = mapmode;

for i = 1:1:L

    rowCnt = idivide(int16(i-1),int16(N_col));
    colCnt = mod(i-1,N_col);
    
    cnt = rowCnt;
    
    % Upper Mux
    if(colCnt<=0)
        identical = cnt;
    else
        identical = identical + N_row;
    end
    
    % Lower Muxes, IMPORTANT: avoiding priority logic
   
    rowFlag16 = mod(rowCnt,2);
    colFlag16 = mod(colCnt,2);
    rowFlag64 = mod(rowCnt,3);
    colFlag64 = mod(colCnt,3);
    
    % 64QAM
    switch strcat(int2str(rowFlag64), int2str(colFlag64))
    case '00'
        qam64 = 0;
    case '01'
        qam64 = 2;
    case '02'
        qam64 = 1;
    case '10'
        qam64 = 0;
    case '11'
        qam64 = -1;
    case '12'
        qam64 = 1;
    case '20'
        qam64 = 0;
    case '21'
        qam64 = -1;
    case '22'
        qam64 = -2;
    end
    
    % 16QAM
    switch strcat(int2str(rowFlag16), int2str(colFlag16))
    case '00'
        qam16 = 0;
    case '01'
        qam16 = 1;
    case '10'
        qam16 = 0;
    case '11'
        qam16 = -1;
    end
    
    if(mapMode == "64QAM")
       offset = qam64;
    end
    if(mapMode == "16QAM")
       offset = qam16;    
    end
    if(mapMode == "BPSK" || mapMode == "QPSK")
       offset = 0;    
    end
    
    
    destinationIndex = identical + offset;
    indexes(i,1) = destinationIndex;
%     disp(destinationIndex+1);
    if(mode == 0)
        interleavedData(destinationIndex+1,1) = x(i,1);
    end
    if(mode == 1)
        deInterleavedData(i,1) = x(destinationIndex+1,1);
    end
end
    if(mode == 0)
        y = interleavedData;
    end
    if(mode == 1)
        y = deInterleavedData;
    end
    
end