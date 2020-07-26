function y = pilotRemove(pilotInsertedSymbols)


pilotRemovedSymbols = zeros(48,1);

pilotRemovedSymbols(1:5,1) = pilotInsertedSymbols(1:5,1);
pilotRemovedSymbols(6:18,1) = pilotInsertedSymbols(7:19,1);
pilotRemovedSymbols(19:24,1) = pilotInsertedSymbols(21:26,1);
pilotRemovedSymbols(25:30,1) = pilotInsertedSymbols(28:33,1);
pilotRemovedSymbols(31:43,1) = pilotInsertedSymbols(35:47,1);
pilotRemovedSymbols(44:48,1) = pilotInsertedSymbols(49:53,1);

y = pilotRemovedSymbols;
end