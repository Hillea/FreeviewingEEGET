function EEG = PreprocEEG(EEG, ALLEEG, VPn, bl)

% Preprocessing pipeline for the EEG

% for the Freeviewing EEG & ET study
% 2018, Lea Hildebrandt

% In- and Output:
% EEG - EEGLAB EEG structure
% VPn - participant's number (string)
% bl  - number of current block of the experiment (data ist cut; double)


%% %%%%%%%%%%%%%%%%%%
% Preprocessing EEG %
%%%%%%%%%%%%%%%%%%%%%

% First, the block-wise EEG data is preprocessed in the following
% order:
% 1. Filtering to remove drifts below 1Hz (or 0.01? 1 better for ICA?) and line noise above 40Hz
% 2. Channel information is added - location of electrodes
% 3. Channels w/ bad signal are removed
% 4. The data of those channels are interpolated to have full rank data
% 5. The data are re-referenced to the average
% 6. Independent Component Analysis (ICA) is carried out on the data to eventually remove artefacts, such as eye blinks


%% 1. Filter
% use a bandpass filter between 1 and 40 Hz (drifts and line noise)

% it's not possible to plot results without signal processing toolbox!
% 1 = lower bound (0.1?); 40 = upper bound; 1650 = filter order?? filter length-1;
% 0 = bandpass; [] usefft, not relevant; 0 = dont plot
EEG = pop_eegfiltnew(EEG, 0.1,40,16500,0,[],0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[ VPn, '_B', num2str(bl), '_filt'],'gui','off');

%% 2. Add channel info/location

EEG=pop_chanedit(EEG, 'lookup','C:\\Users\\leh83zj\\Desktop\\eeglab\\eeglab14_1_1b\\plugins\\dipfit2.3\\standard_BESA\\standard-10-5-cap385.elp');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

%% 3. Remove bad channels

% Keep original EEG for interpolation
originalEEG = EEG;

%%%%%%%%% HOW??? %%%%%%%%%%%

% clean_raw..
% EEG = clean_rawdata(EEG, 5, [0.25 0.75], 0.8, 4, 5, 0.5);
% a lot of warnings???

% alternative:
% Tools -> automatic channel rejection

% OR: trim outlier --> needs to be done manually! write in loop
% upper_bound = 50;
% lower_bound = 20;
% EEG = trimOutlier(EEG, lower_bound, upper_bound, Inf, 0);
EEG = pop_trimOutlier(EEG);

%%%%%%%% IO is removed???? How to avoid that? %%%%%%%%%%%%

%% 4. Interpolate remaining channels
% Interpolate channels.
EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');


%% 5. Rereference to average

%%%%%%%%%%%%% CSD

% need to know channel of ref? edit --> channel locations... keep in dataset?
EEG = pop_reref( EEG, [],'exclude',32);

%% Remove line noise using CleanLine
% already filtered out in step 1.

%% evtl epochs

% smoothing
%% 6. Run ICA

EEG = pop_runica(EEG, 'extended',1,'interupt','on');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[ VPn, '_B', num2str(bl), '_ICA'],'gui','off');



end
