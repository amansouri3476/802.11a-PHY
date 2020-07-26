function [trellis, predecessors] = viterbiSetup()

    trellis = poly2trellis(7, [133, 171]);
    trellis_temp = struct('numInputSymbols',trellis.numInputSymbols,'numOutputSymbols',trellis.numOutputSymbols,...
    'numStates',trellis.numStates,'nextStates',trellis.nextStates+1,...
    'outputs',trellis.outputs);
    trellis = trellis_temp;
    predecessors = cell(64,1);
    for i=1:64
       [rows,columns] = find(trellis.nextStates==(i));
       predecessors{i,1} = [rows,columns];
    end

end