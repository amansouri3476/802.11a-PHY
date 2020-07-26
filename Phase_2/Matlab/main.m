%%
clc;
clear;
close('all');
%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 1----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  
%% ------------------------------------------ Section 1.1: Generating samples ------------------------------------------ %%
numOfSamples = 5;
bitRateSelectors = randi(8,1,numOfSamples);
lengths = randi(4095,1,numOfSamples);
bitRates = zeros(1,numOfSamples);
PSDUs = {};
for i = 1:1:numOfSamples
    bitRates(1,i) = RateSelect(bitRateSelectors(1,i));
    PSDUs{i} = randi([0 1],1,8*lengths(i));
end

%% ------------------------------------ Section 1.2: Generating SIGNAL and DATA fields for the samples ------------------------------------ %%
SIGNALS = {1,numOfSamples};
DATA_FIELDS = {1,numOfSamples};
for i = 1:1:numOfSamples
   SIGNALS{i} = signal(bitRates(1,i), lengths(1,i));
   DATA_FIELDS{i} = dataField(bitRates(1,i), lengths(1,i), PSDUs{i}');
end

%% ------------------------------------------ Section 1.3: Scrambling the DATA_FIELDS ------------------------------------------ %%
% MORE THAN ONE PACKET BUGGGGG! scramInit the same.
scramInit = randi([0 1], 1, 7);
DATA_FIELDS_CONCATENATED = [];
for i = 1:1:numOfSamples
   DATA_FIELDS_CONCATENATED = [DATA_FIELDS_CONCATENATED;DATA_FIELDS{i}];
end

DATA_FIELDS_SCRAMBLED = scramble(DATA_FIELDS_CONCATENATED, scramInit');


%% ------------------------------------------ Section 1.4: Descrambling the DATA_FIELDS_SCRAMBLED ------------------------------------------ %%
DATA_FIELDS_DESCRAMBLED = scramble(DATA_FIELDS_SCRAMBLED, scramInit');
%% ----------------------------- Section 1.5: Checking if the descrambled data is the same as original data ----------------------------- %%
disp("BER for random data after scrambling and descrambling");
disp(sum(xor(DATA_FIELDS_DESCRAMBLED,DATA_FIELDS_CONCATENATED)));
%% -------- Section 1.6: Writing PSDUs, DATA_Fields, Scrambled data, Descrambled data, and bitRates to txt files for the use of HDL -------- %%

if ~exist('Phase 1 txt files', 'dir')
    mkdir('Phase 1 txt files');
end

% PSDU
fileID_PSDU = fopen(fullfile([pwd '\Phase 1 txt files'],'PSDU.txt'), 'wt');
for i = 1:1:numOfSamples 
   fprintf(fileID_PSDU, '%d', PSDUs{1,i});
   fprintf(fileID_PSDU, '\n');
end
fclose(fileID_PSDU);
% DATA_Fields. NOTE that all bits are serially written in ONE column.
fileID_DATA = fopen(fullfile([pwd '\Phase 1 txt files'],'test_vectors.txt'), 'wt');

fprintf(fileID_DATA, '%d\n', DATA_FIELDS_CONCATENATED);
fclose(fileID_DATA);

% Scrambled Data
fileID_ScrambledData = fopen(fullfile([pwd '\Phase 1 txt files'],'golden_scrambler_outputs_m.txt'), 'wt');
fprintf(fileID_ScrambledData, '%d\n', DATA_FIELDS_SCRAMBLED);
fclose(fileID_ScrambledData);

% Descrambled Data
fileID_DeScrambledData = fopen(fullfile([pwd '\Phase 1 txt files'],'golden_outputs_m.txt'), 'wt');
fprintf(fileID_DeScrambledData, '%d\n', DATA_FIELDS_DESCRAMBLED);
fclose(fileID_DeScrambledData);

% bitRates
fileID_bitRates = fopen(fullfile([pwd '\Phase 1 txt files'],'BitRates.txt'), 'wt');
for i = 1:1:numOfSamples
   fprintf(fileID_bitRates, '%d\n', bitRates(1,i));
end
fclose(fileID_bitRates);
%% ------------------------------------------ Section 1.7: Generating standard's example message ------------------------------------------ %%
Message = [
    '04','02','00','2e','00',...
    '60','08','cd','37','a6',...
    '00','20','d6','01','3c',...
    'f1','00','60','08','ad',...
    '3b','af','00','00','4a',...
    '6f','79','2c','20','62',...
    '72','69','67','68','74',...
    '20','73','70','61','72',...
    '6b','20','6f','66','20',...
    '64','69','76','69','6e',...
    '69','74','79','2c','0a',...
    '44','61','75','67','68',...
    '74','65','72','20','6f',...
    '66','20','45','6c','79',...
    '73','69','75','6d','2c',...
    '0a','46','69','72','65',...
    '2d','69','6e','73','69',...
    '72','65','64','20','77',...
    '65','20','74','72','65',...
    '61','da','57','99','ed'];

Message_bin = zeros(1,800);
for i = 1 : length(Message)/2
    char = [Message(1,2*i-1),Message(1,2*i)];
    char_bin = dec2bin(hex2dec(char),8);
    char_bin = char_bin(end:-1:1);
    for j = 1 : 8
        Message_bin(8*i-8+j) = str2double(char_bin(j));
    end
end
Message_bin1 = [0,Message_bin];

if ~exist('Standard''s example data', 'dir')
    mkdir('Standard''s example data');
end

save(fullfile([pwd '\Standard''s example data'],'Message_bin.mat'),'Message_bin1');
% This is used for the verification of dataField module in Verilog
message = reshape(Message_bin,[8,100]);
fID = fopen(fullfile([pwd '\Standard''s example data'],'sampleMessage.txt'), 'wt');
for i = 1:1:100
   fprintf(fID, '%d\n', message(:,i));
%    fprintf(fID, '\n');
end
Message_bin = Message_bin';
%% ------------------------------------------ Section 1.8 ------------------------------------------ %%
% This result illustrates that our Data field works properly according to
% the standard. (
sampleMessageDATA_FIELD = dataField(36, 100, Message_bin); % Note that the order of hex 
                                           % digits is reversed in this 
                                           % message_bin, i.e. each entry
                                           % of table G.1 is reversed ('04'
                                           % is transformed to '40'. This
                                           % convention is meaningful since
                                           % this way, bytes are organized
                                           % in ascending order (lsb first,
                                           % msb last).

scramInit = [1, 0, 1, 1, 1, 0, 1]; % according to the standard's example seed
SM_DATA_FIELDS_SCRAMBLED = scramble(sampleMessageDATA_FIELD, scramInit');

fileID_ScrambledDataSampleMessage = fopen(fullfile([pwd '\Standard''s example data'],'sm_golden_scrambler_outputs_m.txt'), 'wt');
fprintf(fileID_ScrambledDataSampleMessage, '%d\n', SM_DATA_FIELDS_SCRAMBLED);
fclose(fileID_ScrambledDataSampleMessage);
% Descrambled Data
SM_DATA_FIELDS_DESCRAMBLED = scramble(SM_DATA_FIELDS_SCRAMBLED, scramInit');
SM_fileID_DeScrambledData = fopen(fullfile([pwd '\Standard''s example data'],'sm_golden_outputs_m.txt'), 'wt');
fprintf(SM_fileID_DeScrambledData, '%d\n', SM_DATA_FIELDS_DESCRAMBLED);
fclose(SM_fileID_DeScrambledData);

disp("BER for standard's example after scrambling and descrambling");
disp(sum(xor(SM_DATA_FIELDS_DESCRAMBLED,sampleMessageDATA_FIELD)));

%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 2----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%% ------------------------------------------ Section 2.1: Preprocessing ------------------------------------------ %%
clc

% NOTE: 6 bit for tail has to become zero after scrambling. Keep that in
% mind to adjust accordingly.

% These generator polynomials are according to the conv encoder introduced 
% by the IEEE standard for 802.11a-1999, section 17.3.5.5 (page 16) 
trellis = poly2trellis(7, [133, 171]);

% Since trellis.nextStates is not Matlab friendly (0 to 63) we use the
% above trellis and adjust it by adding 1 to its nextStates.(1 to 64)
trellis_temp = struct('numInputSymbols',trellis.numInputSymbols,'numOutputSymbols',trellis.numOutputSymbols,...
'numStates',trellis.numStates,'nextStates',trellis.nextStates+1,...
'outputs',trellis.outputs);

% Now we put it back to our trellis which shall be used through out the
% process of encoding and decoding.
trellis = trellis_temp;

% Each state has two and only two predecessor which we require when
% calculating the path metrics. Here we obtain such matrix using
% trellis.nextStates. Each cell of predecessors contains a 2x2 matrix. For
% instance, predecessors{33,1}(1,1) is the state of first predecessor of
% state 33, and predecessors{33,1}(1,2) shows the input for which we
% transit to state 33 from its first predecessor. The same goes for the
% second row of predecessors{33,1}.
predecessors = cell(64,1);
for i=1:64
   [rows,columns] = find(trellis.nextStates==(i));
   predecessors{i,1} = [rows,columns];
end

%%
% This line, produces the coded version of standard's example for
% DATA_FIELD which can be observed in table G.18 of the standard. (page 71)
% codedData = convenc(SM_DATA_FIELDS_SCRAMBLED, trellis, [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1]);

% This line encodes the example message of standard using our code and
% compares it to the golden output of convenc to see if our code works
% properly.
% b = convolutionalEncode(SM_DATA_FIELDS_SCRAMBLED, [0, 0, 0, 0, 0, 0]', [1, 1, 1, 0, 0, 1]');
% disp(sum(xor(b,codedData)));

%% ---------------------------------- Section 2.2: Convolutional Encoding and Decoding ---------------------------------- %%
clc
Length = 100; 
data = randi([0 1], 1, Length*8)';

% Rate = RateSelect(randi(8,1));
Rate = 48;

datafield = dataField(Rate, Length, data);
[puncturePattern,coeff] = puncPattern(Rate);

dataChunk = convolutionalEncode(datafield, [0, 0, 0, 0, 0, 0]', puncturePattern);

initCurrState = 1;

% Dummy bits should be inserted according to the puncturing pattern for
% Rates higher than 1/2.
dummyInsertedDataChunk = zeros(length(dataChunk)*coeff,1);

puncpatrepeated = repmat(puncturePattern, ceil(size(dummyInsertedDataChunk,1)/size(puncturePattern,1)), 1);
puncpatextended = puncpatrepeated(1:size(dummyInsertedDataChunk,1),1);


dummyInsertedDataChunk(puncpatextended == 1) = dataChunk;
eraseMarks = puncpatextended;

TotalDecodedData = [];
for i = 1:24:length(dummyInsertedDataChunk)
    [decodedData,finalCurrState] = viterbiDecode(dummyInsertedDataChunk(i:i+23,1), trellis, predecessors, ...
    initCurrState, eraseMarks(i:i+23,1));
    initCurrState = finalCurrState;
    TotalDecodedData = [TotalDecodedData;decodedData];
end



FinalBER = sum(xor(TotalDecodedData,datafield))/length(datafield);
disp(FinalBER);

%% -------- Section 2.3: Writing the original Data, Encoded data, and Decoded data to txt files for the use of HDL -------- %%
clc
% NOTE that all bits are serially written in ONE column.
% Encoder input data
if ~exist('Encoder Vectors', 'dir')
    mkdir('Encoder Vectors');
end
fileID_encoderData = fopen(fullfile([pwd '\Encoder Vectors'],'encDec_test_vectors.txt'), 'wt');
for i = 1:1:length(datafield) 
   fprintf(fileID_encoderData, '%d', datafield(i,1));
   fprintf(fileID_encoderData, '\n');
end
fclose(fileID_encoderData);

% Encoded data
fileID_encodedData = fopen(fullfile([pwd '\Encoder Vectors'],'golden_encoder_outputs_m.txt'), 'wt');
fprintf(fileID_encodedData, '%d%d\n', dataChunk);
fclose(fileID_encodedData);

% Decoded Data
fileID_DecodedData = fopen(fullfile([pwd '\Encoder Vectors'],'golden_decoder_outputs_m.txt'), 'wt');
fprintf(fileID_DecodedData, '%d\n', TotalDecodedData);
fclose(fileID_DecodedData);
%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 3----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%% -------------------------------- Section 3.1: Interleaving and Deinterleaving -------------------------------- %%
clear all
clc

% These two should be consistent according to the RATE: mapMode, N_CBPS
Rate = 48;
[mapMode, ~, N_CBPS, ~] = rateDependents(Rate);
% N_CBPS Depends on RATE. Could be either 48,96,192,288. Try any of 
% these and you'll see the function works in all cases
% correctly. Remember that mapMode also changes according to Rate.

L = N_CBPS*100; % 100 is arbitrary, change it if you wish.
data = randi([0 1], 1, L)';
N_col = 16; % According to the standard
N_row = N_CBPS/16;

FinalBER = 0;
for i = 1:N_CBPS:L
    dataBlock = data(i:i+N_CBPS-1,1);
    % interleave
    interleavedData = interleaveDeinterleave(dataBlock, 0, N_CBPS, N_col, N_row, mapMode);

    % deinterleave
    deInterleavedData = interleaveDeinterleave(interleavedData, 1, N_CBPS, N_col, N_row, mapMode);
    
    BER = sum(xor(deInterleavedData,dataBlock));
    FinalBER = FinalBER + BER;
end


disp(FinalBER);

%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 4----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%% -------------------------------- Section 4.1: Symbol Mapper and demapper -------------------------------- %%

% Refer to page 19 (27 of the pdf) of standard for the description of this
% operation.

clear all
clc

[mapMode, ~, N_CBPS, ~] = rateDependents(48);
L = N_CBPS*100;
data = randi([0 1], 1, L)';

mappedData = mapper(data, mapMode, false);
demappedData = demapper(mappedData, mapMode, false);



BER = sum(xor(data,demappedData));
disp(BER);
%% -------------------------------- Section 4.2: Pilot Insertion and removal -------------------------------- %%
clc

scramInit = ones(7,1);
pseudoRandomSeq = scramble(zeros(127,1), scramInit);
normalized_array = normalize(pseudoRandomSeq,'range',[-1 1]);
pseudoRandomSeq = normalized_array*-1;

PilotInsertedData = [];
PilotRemovedData = [];

FinalBER = 0;
for i = 1:48:length(mappedData)
    symbolBlock = mappedData(i:i+47,1); % 48 subcarriers (+ 4 pilot)
    blockID = (i+47)/48;
    % pilot insertion
    pilotInsertedSymbols = pilotInsert(symbolBlock, blockID, pseudoRandomSeq);
    PilotInsertedData = [PilotInsertedData;pilotInsertedSymbols];
end

for i = 1:53:length(PilotInsertedData)
    symbolBlock = PilotInsertedData(i:i+52,1); 
    
    k = 1 + (i-1)*48/53;
    PilotRemovedData(k:k+48-1,1) = pilotRemove(symbolBlock);
end

disp(isequal(PilotRemovedData,mappedData));

%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % -------------------------------------------- Integration and Matching ------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%% ------------------------------------------ Section 5.1: Standard's example ------------------------------------------ %%
clc
% Please run section 1.7 before proceeding.
% In code section 1.7, standard's example was created and
% processed. We're going to continue from there.
     % ---------------------------------------------------------------------------------------- %
% -------------------------------------------- Transmitter -------------------------------------------- %%
     % ---------------------------------------------------------------------------------------- %
     
     
     
     % ---------------------------------------- Scrambler ------------------------------------- %
     
% Scrambler: Note that PLCP Header and SIGNAL Fields are NOT scrambled.
% Only DATA FIELD is scrambled.

sampleMessageDATA_FIELD = dataField(36, 100, Message_bin); % Note that the order of hex 
                                           % digits is reversed in this 
                                           % message_bin, i.e. each entry
                                           % of table G.1 is reversed ('04'
                                           % is transformed to '40'. This
                                           % convention is meaningful since
                                           % this way, bytes are organized
                                           % in ascending order (lsb first,
                                           % msb last).

scramInit = [1, 0, 1, 1, 1, 0, 1]; % according to the standard's example seed
SM_DATA_FIELDS_SCRAMBLED = scramble(sampleMessageDATA_FIELD, scramInit'); % SM refers to sample message

% CRITICAL for convolutional encoder: DATA FIELD is arranged in this order 
% -> [SERVICE;PSDU;TAIL;PAD]. After this field is scrambled, 6 zero bits in
% TAIL are changed and should be reset to 0 again to return the convolutional 
% encoder to the "zero state".
% Since length(SERVICE+PSDU)= 16 + 8*PacketLength, in this example we
% should change scrambledBits of index (16+800+1:16+800+1+6) to zero.
SM_DATA_FIELDS_SCRAMBLED(16+800+1:16+800+6) = 0;


     % ---------------------------------------- Convolutional Encoding ------------------------------------- %


% Convolutional Encoder: Note that BOTH SIGNAL and DATA Fields ARE encoded.
% But the SIGNAL FIELD encoding does NOT depend on RATE, it is encoded BPSK
% and the rate is 1/2.

% In standard's example Data Rate is 36Mb/s for which we have:
% Modulation: 16-QAM
% Coding Rate: 3/4
% Coded bits per subcarrier (N_BPSC) = 4
% Coded bits per OFDM Symbol (N_CBPS) = 192
% Coded bits per subcarrier (N_DBPS) = 144

% since coding rate is 3/4, puncture pattern is [1,1,1,0,0,1] according to
% page 18 of standard (page 26 of pdf)
[puncturePattern,coeff] = puncPattern(36);
SM_DATA_FIELDS_CONV_ENCODED = convolutionalEncode(SM_DATA_FIELDS_SCRAMBLED, [0, 0, 0, 0, 0, 0]', puncturePattern);

SMsignalField = signal(36, 100);

SM_SIGNAL_FIELD_CONV_ENCODED = convolutionalEncode(SMsignalField, [0, 0, 0, 0, 0, 0]', [1,1]'); % puncture pattern for 1/2 rate is [1,1]

% To verify the result, check the result of the following with the Tables
% G.8 and G.18 of the standard (pages 62 and 71 (70 and 79 pdf)).
TableG8 = reshape(SM_SIGNAL_FIELD_CONV_ENCODED,[8 6]);
TableG18 = reshape(SM_DATA_FIELDS_CONV_ENCODED(1:192),[32 6]);


     % ---------------------------------------- Interleaving ------------------------------------- %


% Interleaver: Note that BOTH SIGNAL and DATA Fields ARE encoded.
% But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
% interleaved with a block interleaver of constant size = 48. (Because the
% SIGNAL FIELD is always 24 bits, its encoded version is always 48 bits
% because the encoding rate is also fixed for this FIELD.)

% These two should be consistent according to the RATE.
N_CBPS = 192; % for this example
mapMode = "16QAM"; % for this example

N_col = 16; % According to the standard
N_row = N_CBPS/16;

SMdataFieldinterleaved = zeros(length(SM_DATA_FIELDS_CONV_ENCODED),1);

% Data field interleaving
for i = 1:N_CBPS:length(SM_DATA_FIELDS_CONV_ENCODED)
    dataBlock = SM_DATA_FIELDS_CONV_ENCODED(i:i+N_CBPS-1,1);
    % interleave
    SMdataFieldinterleaved(i:i+N_CBPS-1,1) = interleaveDeinterleave(dataBlock, 0, N_CBPS, N_col, N_row, mapMode);
end

% Signal field interleaving
SMsignalFieldinterleaved = interleaveDeinterleave(SM_SIGNAL_FIELD_CONV_ENCODED, 0, 48, N_col, 48/16, 'BPSK'); % These are fixed for SIGNAL FIELD

% To verify the result, check the result of the following with the Tables
% G.9 and G.21 of the standard (pages 62 and 74 (70 and 82 pdf))
TableG9 = reshape(SMsignalFieldinterleaved,[8 6]);
TableG21 = reshape(SMdataFieldinterleaved(1:192),[32 6]);

     % ---------------------------------------- Symbol Mapping ------------------------------------- %
     

     
% Symbol Mapper: Note that BOTH SIGNAL and DATA Fields ARE mapped.
% But the SIGNAL FIELD interleaving does NOT depend on RATE, it is 
% mapped with argument 'BPSK'.

SMmappedData = mapper(SMdataFieldinterleaved, mapMode, true);
SMmappedSignal = mapper(SMsignalFieldinterleaved, 'BPSK', true);

% To verify the result, check the result of the following with the Tables
% G.10 and G.22 of the standard (pages 63 and 75 (71 and 83 pdf))
TableG10 = reshape(SMmappedSignal,[16 3]); % Ignore X and 0s in table G.10 
                                           % of standard and you'll see 
                                           % that they match with this result.
TableG22 = reshape(SMmappedData(1:64),[16 4]); % Ignore pilots at -21,-7,7,21 
                                           % and 0 in the middle in table G.22 
                                           % of standard and you'll see 
                                           % that they match with this result.
                                           % These will be added below with
                                           % the pilots.

                                           
    % ---------------------------------------- Pilot Insertion ------------------------------------- %


    
% Pilot Insertion: Note that BOTH SIGNAL and DATA Fields ARE pilot inserted.


pseudoRandomSeq = scramble(zeros(127,1), ones(7,1));
normalized_array = normalize(pseudoRandomSeq,'range',[-1 1]);
pseudoRandomSeq = normalized_array*-1;

% SMdataFieldPilotInserted = zeros(length(SMmappedData)*53/48,1);
SMdataFieldPilotInserted = [];

% blockID for this should be 1.
SMsignalFieldPilotInserted = pilotInsert(SMmappedSignal, 1, pseudoRandomSeq);

for i = 1:48:length(SMmappedData)
    symbolBlock = SMmappedData(i:i+47,1); % 48 subcarriers (+ 4 pilot)
    blockID = ((i+47)/48) + 1; % +1 is CRITICAL because first element of 
                               % the sequence determines pilot polarity of
                               % SIGNAL FIELD's pilots.
    % pilot insertion
%     SMdataFieldPilotInserted(i:i+53-1,1) = pilotInsert(symbolBlock, blockID, pseudoRandomSeq);
    SMdataFieldPilotInserted = [SMdataFieldPilotInserted;pilotInsert(symbolBlock, blockID, pseudoRandomSeq)];
    
end





     % ---------------------------------------------------------------------------------------- %
% -------------------------------------------- Receiver -------------------------------------------- %%
     % ---------------------------------------------------------------------------------------- %


    % ---------------------------------------- Pilot Removal ------------------------------------- %



% SMdataFieldPilotRemoved = zeros(length(SMdataFieldPilotInserted)*48/53,1);
SMdataFieldPilotRemoved = [];

SMsignalFieldPilotRemoved = pilotRemove(SMsignalFieldPilotInserted);

for i = 1:53:length(SMdataFieldPilotInserted)
    symbolBlock = SMdataFieldPilotInserted(i:i+52,1); 
    
    k = 1 + (i-1)*48/53;
%     SMdataFieldPilotRemoved(k:k+48-1,1) = pilotRemove(symbolBlock);
    SMdataFieldPilotRemoved = [SMdataFieldPilotRemoved;pilotRemove(symbolBlock)];
end

disp("DATA: BER for the output of Pilot Remover");
disp(~isequal(SMdataFieldPilotRemoved,SMmappedData));
disp("SIGNAL: BER for the output of Pilot Remover");
disp(~isequal(SMsignalFieldPilotRemoved,SMmappedSignal));



     % ---------------------------------------- Symbol Demapping ------------------------------------- %
     


SMdeMappedData = demapper(SMdataFieldPilotRemoved, mapMode, true);
SMdeMappedSignal = demapper(SMsignalFieldPilotRemoved, 'BPSK', true);

disp("DATA: BER for the output of Demapper");
disp(sum(xor(SMdeMappedData,SMdataFieldinterleaved))/length(SMdeMappedData));
disp("SIGNAL: BER for the output of Demapper");
disp(sum(xor(SMdeMappedSignal,SMsignalFieldinterleaved))/length(SMdeMappedSignal));

     % ---------------------------------------- De-Interleaving ------------------------------------- %



SMdataFieldDeinterleaved = zeros(length(SMdeMappedData),1);

% Data field de-interleaving
for i = 1:N_CBPS:length(SMdeMappedData)
    dataBlock = SMdeMappedData(i:i+N_CBPS-1,1);
    % de-interleave
    SMdataFieldDeinterleaved(i:i+N_CBPS-1,1) = interleaveDeinterleave(dataBlock, 1, N_CBPS, N_col, N_row, mapMode);
end

% Signal field de-interleaving
SMsignalFieldDeinterleaved = interleaveDeinterleave(SMdeMappedSignal, 1, 48, N_col, 48/16, 'BPSK'); % These are fixed for SIGNAL FIELD

disp("DATA: BER for the output of De-Interleaver");
disp(sum(xor(SMdataFieldDeinterleaved,SM_DATA_FIELDS_CONV_ENCODED))/length(SM_DATA_FIELDS_CONV_ENCODED));
disp("SIGNAL: BER for the output of De-Interleaver");
disp(sum(xor(SMsignalFieldDeinterleaved,SM_SIGNAL_FIELD_CONV_ENCODED))/length(SM_SIGNAL_FIELD_CONV_ENCODED));


     % ---------------------------------------- Viterbi Decoding ------------------------------------- %


     
[trellis, predecessors] = viterbiSetup();

initCurrState = 1;

% Dummy bits should be inserted according to the puncturing pattern for
% Rates higher than 1/2.
dummyInsertedDataChunk = zeros(length(SM_DATA_FIELDS_CONV_ENCODED)*coeff,1);

puncpatrepeated = repmat(puncturePattern, ceil(size(dummyInsertedDataChunk,1)/size(puncturePattern,1)), 1);
puncpatextended = puncpatrepeated(1:size(dummyInsertedDataChunk,1),1);


dummyInsertedDataChunk(puncpatextended == 1) = SM_DATA_FIELDS_CONV_ENCODED;
eraseMarks = puncpatextended;

% [decodedData,finalCurrState] = viterbiDecode(dummyInsertedDataChunk, trellis, predecessors, ...
%     initCurrState, eraseMarks);
SM_DATA_FIELDS_VIT_DECODED = [];
for i = 1:24:length(dummyInsertedDataChunk)
    [decodedData,finalCurrState] = viterbiDecode(dummyInsertedDataChunk(i:i+23,1), trellis, predecessors, ...
    initCurrState, eraseMarks(i:i+23,1));
    initCurrState = finalCurrState;
    SM_DATA_FIELDS_VIT_DECODED = [SM_DATA_FIELDS_VIT_DECODED;decodedData];
end

% Since SIGNAL was encoded with a 1/2 rate, no puncturing, hence no dummy
% insertion is required. Its length is always 24 fixed. (its encoded
% version is 48 bits.)
SM_SIGNAL_FIELD_VIT_DECODED = viterbiDecode(SMsignalFieldDeinterleaved, trellis, predecessors, ...
    1, ones(48,1));

disp("DATA: BER for the output of Viterbi Decoder");
disp(sum(xor(SM_DATA_FIELDS_VIT_DECODED,SM_DATA_FIELDS_SCRAMBLED))/length(SM_DATA_FIELDS_SCRAMBLED));
disp("SIGNAL: BER for the output of Viterbi Decoder");
disp(sum(xor(SM_SIGNAL_FIELD_VIT_DECODED,SMsignalField))/24);

     % ---------------------------------------- Descrambler ------------------------------------- %
     
% Scrambler: SIGNAL Fields is NOT descrambled.
% Only DATA FIELD is descrambled.

scramInit = [1, 0, 1, 1, 1, 0, 1]; % according to the standard's example seed

SM_DATA_FIELDS_DESCRAMBLED = scramble(SM_DATA_FIELDS_VIT_DECODED, scramInit'); % SM refers to sample message

% CRITICAL: Since 6 bits were set to 0 after scrambling, it is nonesense to
% expect the descrambler to have 0 BER with respect to scrambler's input.
% Hence we should check only the resulting PSDU with the original PSDU we
% passed to the transmitter.
disp("DATA: BER for the output for PSDU");
disp(sum(xor(SM_DATA_FIELDS_DESCRAMBLED(17:16+800),Message_bin))/length(Message_bin));
disp("SIGNAL: BER for the output of descrambler");
disp(sum(xor(SM_SIGNAL_FIELD_VIT_DECODED,SMsignalField))/24);

disp("It seems that TX/RX is working fine for standard's example :)");

%% ------------------------------------------ Section 5.2: Random Data ------------------------------------------ %%
clc
clear all

% You may modify these three parameters to check whatever you wish:
numOfSamples = 10;
% stage could be either: "scrambler", "encoder", "interleaver", "mapper", "pilot inserter"
stage = "pilot inserter";
MaximumLength = 400; % According to the standard it should be 4095 but it takes a lot of time when numOfSamples exceeds 3 or 4.
                    % It'd be better to set it to lower numbers to speed up
                    % verification.

% function "testGenerator" summarized sections 1.1 and 1.2
[DATA_FIELDS, SIGNALS, PSDUs, Lengths, dataRates] = testGenerator(numOfSamples, MaximumLength);

[trellis, predecessors] = viterbiSetup();

% First, SIGNAL FIELD should be transmitted and received to obtain rates
% and lengths in the receiver to be able to continue the decoding process
% in the receiver.
[channelSIGNAL] = trasmitterSignal(SIGNALS, stage);
recvSIGNAL = receiverSignal(channelSIGNAL, stage, trellis, predecessors);
correctnessCheck(PSDUs, SIGNALS, recvSIGNAL, stage, false); 


[channelDATA, scramInit] = transmitter(DATA_FIELDS, dataRates, Lengths, stage);

[recvStream] = receiver(channelDATA, recvSIGNAL, stage, scramInit, trellis, predecessors);


correctnessCheck(PSDUs, DATA_FIELDS, recvStream, stage, true);
%% ------------------------------------------ Section 5.3: Writing txt files for HDL Verification ------------------------------------------ %%
if ~exist('Integration', 'dir')
    mkdir('Integration');
end

Length = randi(4095,1);
PSDU = randi([0 1],1,8*Length);
DATA_FIELD = dataField(12, Length, PSDU'); % replace 12 with either 6, or 24 if you wish

fileID_phyDATA = fopen(fullfile([pwd '\Integration'],'phy_in.txt'), 'wt');
for i = 1:1:length(DATA_FIELD)
   fprintf(fileID_phyDATA, '%d', DATA_FIELD(i,1));
   fprintf(fileID_phyDATA, '\n');
end

fileID_phyDATAgolden = fopen(fullfile([pwd '\Integration'],'phy_golden_outputs_m.txt'), 'wt');
for i = 1:1:length(DATA_FIELD) 
   fprintf(fileID_phyDATAgolden, '%d', DATA_FIELD(i,1));
   fprintf(fileID_phyDATAgolden, '\n');
end


