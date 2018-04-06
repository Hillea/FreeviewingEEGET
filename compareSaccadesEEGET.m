%% check saccade lag between ET and EEG

% We know that there is a lag after the co-registration of the EEG and ET data (using
% EYE-EEG). This lag is visible because saccades in the ET occur later (?)
% than in the EEG data, when the trigger are aligned.

%% Get test data
% use co-registered data (not too much preproc)

chansEEG = {'F9', 'F10', 'F7', 'F8', 'FP1', 'FP2'};
chansET = {'L-POR-X-(px)', 'L-POR-Y-(px)', 'R-POR-X-(px)', 'R-POR-Y-(px)'};

testEEG = EEG.data(strcmpi(chansEEG{1},{EEG.chanlocs.labels}),:);
testET = EEG.data(strcmpi(chansET{1},{EEG.chanlocs.labels}),:);

smoothEEG=smoothMoveAvg(testEEG,5);
smoothET=smoothMoveAvg(testET,5);

threshEEG = 5;
threshET = 10;


%% get saccades in EEG data

differEEG = diff(smoothEEG);
differET = diff(smoothET);

artefxEEG = differEEG > threshEEG | differEEG < -threshEEG;
artefxET = differET > threshET | differET < -threshET;

subplot 221
plot(smoothET(2000:4000))
subplot 223
plot(artefxET(2000:4000))

subplot 222
plot(smoothEEG(2000:4000))
subplot 224
plot(artefxEEG(2000:4000))

figure
hold on
plot(smoothET(2000:4000))
plot(artefxET(2000:4000)*600)
plot(smoothEEG(2000:4000)+1000)
plot(artefxEEG(2000:4000)*100-100)

q = diff([0 artefxET 0]);
startstreak = find(q==1);
endstreak = find(q==-1);
v = endstreak - startstreak;

numArtefacts{1,1} = length(v);           % number of artefacts, accounting for streaks
numArtefacts{1,2} = sum(artefx);           % total number of artefact samples (not accounting for streaks)
numArtefacts{1,3} = length(v(v>1));      % number of streaks longer than 1 sample
    

%% raw ET
et=load('C:\Users\leh83zj\Desktop\Lea\Daten\Preprocessed\teegeteeg.mat');

ETev = et.event;
EEGev = EEG.event;

startidxEEG = find(strcmpi("S 50", {EEG.event.type}));
endidxEEG = find(strcmpi("S 99", {EEG.event.type}));

startlatEEG = cell2mat({EEG.event(startidxEEG).latency});
endlatEEG = cell2mat({EEG.event(endidxEEG).latency});

startlatEEG = startlatEEG - startlatEEG(1);
endlatEEG = endlatEEG - endlatEEG(1);


startidxET = find(ETev(:,2) == 50);
endidxET = find(ETev(:,2) == 99);

startlatET = ETev(startidxET, 1);
endlatET = ETev(endidxET, 1);

startlatET = (startlatET - startlatET(1))/1000;
endlatET = (endlatET - endlatET(1))/1000;

[startlatET/2, startlatEEG']
