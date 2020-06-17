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
Lenghts = randi(4095,1,numOfSamples);
bitRates = zeros(1,numOfSamples);
PSDUs = {};
for i = 1:1:numOfSamples
    bitRates(1,i) = RateSelect(bitRateSelectors(1,i));
    PSDUs{i} = randi([0 1],1,8*Lenghts(i));
end

%% ------------------------------------ Section 1.2: Generating SIGNAL and DATA fields for the samples ------------------------------------ %%
SIGNALS = {1,numOfSamples};
DATA_FIELDS = {1,numOfSamples};
for i = 1:1:numOfSamples
   SIGNALS{i} = signal(bitRates(1,i), Lenghts(1,i)); 
   DATA_FIELDS{i} = dataField(bitRates(1,i), Lenghts(1,i), PSDUs{i}');
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
checkBits = zeros(1,numOfSamples);
for i = 1:1:numOfSamples
   if (isequal(DATA_FIELDS_DESCRAMBLED,DATA_FIELDS_CONCATENATED))
        checkBits(1,i) = 1;
   end
end
fprintf("The sum of all checkBits should be equal to the numOfSamples if the scrambler work correct\nTheir sum is: %d\n", sum(checkBits));

%% -------- Section 1.6: Writing PSDUs, DATA_Fields, Scrambled data, Descrambled data, and bitRates to txt files for the use of HDL -------- %%
% PSDU
fileID_PSDU = fopen('PSDU.txt', 'wt');
for i = 1:1:numOfSamples 
   fprintf(fileID_PSDU, '%d', PSDUs{1,i});
   fprintf(fileID_PSDU, '\n');
end
fclose(fileID_PSDU);
% DATA_Fields. NOTE that all bits are serially written in ONE column.
fileID_DATA = fopen('test_vectors.txt', 'wt');

fprintf(fileID_DATA, '%d\n', DATA_FIELDS_CONCATENATED);
fclose(fileID_DATA);

% Scrambled Data
fileID_ScrambledData = fopen('golden_scrambler_outputs_m.txt', 'wt');
fprintf(fileID_ScrambledData, '%d\n', DATA_FIELDS_SCRAMBLED);
fclose(fileID_ScrambledData);

% Descrambled Data
fileID_DeScrambledData = fopen('golden_outputs_m.txt', 'wt');
fprintf(fileID_DeScrambledData, '%d\n', DATA_FIELDS_DESCRAMBLED);
fclose(fileID_DeScrambledData);

% bitRates
fileID_bitRates = fopen('BitRates.txt', 'wt');
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
save('Message_bin.mat','Message_bin1');
% This is used for the verification of dataField module in Verilog
message = reshape(Message_bin,[8,100]);
fID = fopen('sampleMessage.txt', 'wt');
for i = 1:1:100
   fprintf(fID, '%d\n', message(:,i));
%    fprintf(fID, '\n');
end

%% ------------------------------------------ Section 1.8: 
% This result illustrates that our Data field works properly according to
% the standard. (
sampleMessageDATA_FIELD = dataField(36, 100, Message_bin'); % Note that the order of hex 
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

fileID_ScrambledDataSampleMessage = fopen('sm_golden_scrambler_outputs_m.txt', 'wt');
fprintf(fileID_ScrambledDataSampleMessage, '%d\n', SM_DATA_FIELDS_SCRAMBLED);
fclose(fileID_ScrambledDataSampleMessage);
% Descrambled Data
SM_DATA_FIELDS_DESCRAMBLED = scramble(SM_DATA_FIELDS_SCRAMBLED, scramInit');
SM_fileID_DeScrambledData = fopen('sm_golden_outputs_m.txt', 'wt');
fprintf(SM_fileID_DeScrambledData, '%d\n', SM_DATA_FIELDS_DESCRAMBLED);
fclose(SM_fileID_DeScrambledData);
%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 2----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%%



%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 3----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%%




%% --------------------------------------------------------------------------------------------------------------------------- %%
  % ------------------------------------------------------------------------------------------------------------------------- %
         % ------------------------------------------------------PHASE 4----------------------------------------------- %
  % ------------------------------------------------------------------------------------------------------------------------- %  
%  --------------------------------------------------------------------------------------------------------------------------- %  

%%



