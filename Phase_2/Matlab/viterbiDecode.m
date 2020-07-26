function [decodedData,finalCurrState] = viterbiDecode(dataChunk, trellis, predecessors, ...
    initCurrState, EraseMarks)

% dataChunk is supposed to be chunkLengthx1 and is read two-bits two-bits.

chunkLength = size(dataChunk,1);
numOfStates = 64;

PathMetrics = zeros(numOfStates, 1+chunkLength/2);
BranchMetrics = zeros(numOfStates, 2); % each branch (result of either 0 or
% 1 input bit) of each state has an associated branch metric (or hamming distance)
traversedPath = cell(numOfStates, chunkLength/2); % for each state and 
% timestamp, we need to keep the pair of prev. input and prev. state with 
% minimum path metric which resulted in this current state at this time.

% initialization
PathMetrics(:,1) = Inf;
PathMetrics(initCurrState,1) = 0;

for i = 1:chunkLength/2
    tempBits = dataChunk(2*i-1:2*i,1);
%     disp(tempBits');

    % Calculating Branch Metrics
    if(EraseMarks(2*i-1:2*i,1) == [1,1]')
        % Branch metric of all states when their input has been zero
        BranchMetrics(:,1) = sum(xor(repmat(tempBits',numOfStates,1),de2bi(trellis.outputs(:,1),2,'left-msb')),2);
        % Branch metric of all states when their input has been one
        BranchMetrics(:,2) = sum(xor(repmat(tempBits',numOfStates,1),de2bi(trellis.outputs(:,2),2,'left-msb')),2);
    end
    if(EraseMarks(2*i-1:2*i,1) == [1,0]') % second bit is dummy. Shall not be used for BM calculation.
        % Branch metric of all states when their input has been zero
        temp = de2bi(trellis.outputs(:,1),2,'left-msb');
        BranchMetrics(:,1) = sum(xor(repmat(tempBits(1,1)',numOfStates,1),temp(:,1)),2);
        % Branch metric of all states when their input has been one
        temp = de2bi(trellis.outputs(:,2),2,'left-msb');
        BranchMetrics(:,2) = sum(xor(repmat(tempBits(1,1)',numOfStates,1),temp(:,1)),2);
    end
    if(EraseMarks(2*i-1:2*i,1) == [0,1]') % first bit is dummy. Shall not be used for BM calculation.
        % Branch metric of all states when their input has been zero
        temp = de2bi(trellis.outputs(:,1),2,'left-msb');
        BranchMetrics(:,1) = sum(xor(repmat(tempBits(2,1)',numOfStates,1),temp(:,2)),2);
        % Branch metric of all states when their input has been one
        temp = de2bi(trellis.outputs(:,2),2,'left-msb');
        BranchMetrics(:,2) = sum(xor(repmat(tempBits(2,1)',numOfStates,1),temp(:,2)),2);
    end
    if(EraseMarks(2*i-1:2*i,1) == [0,0]') % both bits are dummy, no BM calculation is allowed. Both BMs are 0.
        % Branch metric of all states when their input has been zero
        BranchMetrics(:,1) = 0;
        % Branch metric of all states when their input has been one
        BranchMetrics(:,2) = 0;
    end
    
%     disp(BranchMetrics);
%     Calculating Path Metrics and choosing the minimum
    for j = 1:numOfStates
        PathMetrics(j,i+1) = min((PathMetrics(predecessors{j,1}(1,1),i)+...
        BranchMetrics(predecessors{j,1}(1,1),predecessors{j,1}(1,2))),...
        (PathMetrics(predecessors{j,1}(2,1),i)+...
        BranchMetrics(predecessors{j,1}(2,1),predecessors{j,1}(2,2))));
%         fprintf('time %d, state %d, branch metric for predecessor 1,2: %d,%d\n', i+1, j, BranchMetrics(predecessors{j,1}(1,1),predecessors{j,1}(1,2)),BranchMetrics(predecessors{j,1}(2,1),predecessors{j,1}(2,2)));
%         fprintf('time %d, state %d, path metric for predecessor 1,2: %d,%d\n', i+1, j, PathMetrics(predecessors{j,1}(1,1),i),PathMetrics(predecessors{j,1}(2,1),i));
%         fprintf('time %d, state %d, path metric is: %d\n\n', i+1, j, PathMetrics(j,i+1));
        if (PathMetrics(j,i+1) == (PathMetrics(predecessors{j,1}(1,1),i)+...
        BranchMetrics(predecessors{j,1}(1,1),predecessors{j,1}(1,2))))
            traversedPath{j,i+1} = [predecessors{j,1}(1,1),predecessors{j,1}(1,2)];
        else
            traversedPath{j,i+1} = [predecessors{j,1}(2,1),predecessors{j,1}(2,2)];
        end
    end
end

[BER, state] = min(PathMetrics(:,end));
finalCurrState = state;
decodedData = zeros(chunkLength/2,1);
currentState = state;
for i = chunkLength/2+1:-1:2
    decodedData(i-1,1) = traversedPath{currentState,i}(1,2)-1;
%     fprintf('time %f, state %d, message %d\n', i,currentState,decodedMessage(i-1,1));
    currentState = traversedPath{currentState,i}(1,1);   
    
end


end