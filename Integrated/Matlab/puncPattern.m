function [pattern, coeff] = puncPattern(Rate)

switch Rate
    case {6,12,24} % Rate = 1/2
        pattern = [1,1]';
        coeff = 1;
    case {9,18,36,54} % Rate = 3/4
        pattern = [1,1,1,0,0,1]';
        coeff = 3/2;
    case 48 % Rate = 2/3
        pattern = [1,1,1,0]';
        coeff = 4/3;
end


end