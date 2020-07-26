function y = scramble(x,scramInit)
% x is the input and scramInit is the initial state of the scrambler
% scramInit has to be either in the range [1,127] or be a binary column of 
% size 7x1

inputClass = class(x);
y = zeros(size(x),inputClass);

if isempty(x)
    return;
end

% Validate scrambler initialization input
if isscalar(scramInit)
    % Index scramInit for codegen
    coder.internal.errorIf((scramInit(1)<1 | scramInit(1)>127),'wlan:wlanScramble:InvalidScramInit');
    scramblerInitBits = de2bi(scramInit,7,'left-msb').';
elseif iscolumn(scramInit)
    scramblerInitBits = scramInit;
end

buffSize = min(127,size(x,1));
I = zeros(buffSize,1,'int8');

% Scrambling sequence generated using generator polynomial
for d = 1:buffSize
    I(d) = xor(scramblerInitBits(1),scramblerInitBits(4)); % x7 xor x4
    scramblerInitBits(1:end-1) = scramblerInitBits(2:end); % Left-shift
    scramblerInitBits(7) = I(d);                           % Update x1
end

% Generate a periodic sequence from I to be xor-ed with the input
scramblerSequence = repmat(I,ceil(size(x,1)/buffSize),1);
y = cast(xor(x,scramblerSequence(1:size(x,1))),inputClass);

end
