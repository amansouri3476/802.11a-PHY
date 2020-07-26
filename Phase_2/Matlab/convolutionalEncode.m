function convolvedData = convolutionalEncode(x, initState, puncturePattern)

% x is the input (either a single bit or a large column of bits) and 
% initState is the initial state of the conv encoder initState has to be a 
% binary column of size 6x1

inputClass = class(x);
y = zeros(2*size(x,1), 1,inputClass);

encoderState = initState;
puncpatrepeated = repmat(puncturePattern, ceil(size(y,1)/size(puncturePattern,1)), 1);
puncpatextended = puncpatrepeated(1:size(y,1),1);
% Encoding sequence generated using generator polynomial
for d = 1:2:2*size(x,1)
    y(d) = cast(xor(x((d+1)/2),xor(xor(encoderState(2),encoderState(3)), xor(encoderState(5),encoderState(6)))),inputClass);
    y(d+1) = cast(xor(x((d+1)/2),xor(xor(encoderState(1),encoderState(2)), xor(encoderState(3),encoderState(6)))),inputClass);
    encoderState(2:end) = encoderState(1:end-1); % Right-shift
    encoderState(1) = x((d+1)/2);
end

convolvedData = y(puncpatextended == 1);

end