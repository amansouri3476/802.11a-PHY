function y = pilotInsert(symbolBlock, blockID, pseudoRandomSeq)


if(pseudoRandomSeq(mod(blockID-1,127)+1,1) == 1) % These +1 and -1s are due to matlab indexes being started from 1.
    pilots = [1;1;1;-1];
else
    pilots = [-1;-1;-1;1];
end

pilotInsertedSymbols = zeros(53,1);

pilotInsertedSymbols(1:5,1) = symbolBlock(1:5,1);
pilotInsertedSymbols(6,1) = pilots(1,1);
pilotInsertedSymbols(7:19,1) = symbolBlock(6:18,1);
pilotInsertedSymbols(20,1) = pilots(2,1);
pilotInsertedSymbols(21:26,1) = symbolBlock(19:24,1);
pilotInsertedSymbols(27,1) = 0; % index zeros (-26,"0",26)
pilotInsertedSymbols(28:33,1) = symbolBlock(25:30,1);
pilotInsertedSymbols(34,1) = pilots(3,1);
pilotInsertedSymbols(35:47,1) = symbolBlock(31:43,1);
pilotInsertedSymbols(48,1) = pilots(4,1);
pilotInsertedSymbols(49:53,1) = symbolBlock(44:48,1);

y = pilotInsertedSymbols;
end