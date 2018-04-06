%% Analysis of the EEG ET Freeviewing Data using EYE-EEG
% Lea Hildebrandt (using Olaf Dimigens EYE-EEG)

% clear all variables for a fresh start :)
clear

%% Parameters
% specify certain parameters that might change for the analysis

monitorSize = [1920 1080 1920 1080];
ETchans = [39:42];
showPlots=true; % do you want to see all plots and continue w/ key press? Pressing 'n' for "bad" files

%% Start EEGLAB
% Folder path to your EEGLAB directory:
path_to_eeglab = 'C:\Users\leh83zj\Desktop\eeglab\eeglab14_1_1b\';%'C:\Users\leh83zj\Desktop\Lea\eeglab14_1_1b\';%'C:/Users/leh83zj/Documents/UniWü/EEG/eeglab14_1_1b/';
path2scripts ='C:\Users\leh83zj\Desktop\Lea\scripts\';

addpath(path_to_eeglab)
addpath(path2scripts);

eeglab

%% Where are data stored?
% CHANGE to folder structure on NAS?

% input: raw EEG and SMI transformed ET data:
path2EEG = 'C:\Users\leh83zj\Desktop\Lea\Daten\EEG\';%'Y:\\Freeviewing_EEG_ET\\Daten\\EEG\\raw\\';
path2ET = 'C:\Users\leh83zj\Desktop\Lea\Daten\ET\';%'Y:\\Freeviewing_EEG_ET\\Daten\\ET\\smi_tr_eeg\\';

% intermediate output:
pathParsedET = 'C:\Users\leh83zj\Desktop\Lea\Daten\EEG\';%'Y:\\Freeviewing_EEG_ET\\Daten\\EEG\\combineET\\';
preprocpath = 'C:\\Users\\leh83zj\\Desktop\\Lea\\Daten\\Preprocessed\\';

% get list of available EEG files
EEGfiles = dir([path2EEG, '*.vhdr']);
EEGfilnames = {EEGfiles.name};


%% Load EEG raw data

% loop through EEG files
% for filnr=1:length(EEGfilnames)
    filnr = 5;
    
    % Get the VP number to load and save data
    VPn = EEGfilnames{filnr}(end-6:end-5);
    disp(['Current VP: ', VPn])
    
    
    % load file into eeglab with name VPn
    % "File" > "Import data" > File I/O > select .vdhr file
    EEG = pop_fileio( [path2EEG, EEGfilnames{filnr}]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',VPn,'gui','off');
    EEG = eeg_checkset( EEG );
    
    %% Plot continuous EEG data
    % possibly plot every raw data set once to check and continue with
    % button press?
    
    if showPlots
        pop_eegplot( EEG, 1, 1, 1);
        closeFigButtonPress();
    end
    
    %% Fix markers (Pilot Study)
    % old files have several "S  1" and "S128" markers for the block
    % starts and ends. Later files have distinct markers (1-4 and
    % 11-14).
        
    
    if sum(strcmpi("S  2", {EEG.event.type})) == 0
        disp(["Fixing markers..."])
        
        % Two files have S100 as start markers but correct end markers! (Pilot)    
        if sum(strcmpi("S100", {EEG.event.type})) > 1
            startmarker = 'S100';
            endmarker = [];
            EEG = selectBlockRenameMarkers(EEG, startmarker, endmarker); 
        else
            % old markers (at least 4 of each in every EEG file)
            startmarker = 'S  1';
            endmarker = 'S128'; %'S 11';          
            EEG = selectBlockRenameMarkers(EEG, startmarker, endmarker);  
        end
    end
    
 
        
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
        
        % calling subscript w/ EEG preprocessing pipeline
        if exist([VPn, '_Block' num2str(bl), '_ICA.set'], 'file') ~= 2
            disp(['Preprocessing EEG of VP: ', VPn, ', Block ', num2str(bl), '....'])
            
            EEG = PreprocEEG(EEG, ALLEEG, VPn, bl);
        
            %  Save       
            EEG = pop_saveset(EEG, 'filename',[VPn, '_Block' num2str(bl), '_ICA.set'],'filepath', preprocpath);
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
        
    % end loops to save all intermediate files (post_ICA)    
%     end % of block
% end % of participant loop 
        
   %% loop through blocks 
    % Preprocessing EEG
%     for bl = 1:4
        bl = 1;
        
        %% cut EEG data to block   
        % necessary for EEG preprocessing (esp. deletion of bad channels?)
        % and ET synchronization
        
        % select the start and end marker of the current block 
        em = 10+bl;
        startmarker = ['S  ', num2str(bl)];
        endmarker = ['S ', num2str(em)];
        
        % cut file into data of current block
        EEG = segregateEEGfiles(EEG, startmarker, endmarker);
        
        % save as new EEG dataset in eeglab (not on disk! It is not save yet!)
        EEG.setname = [ VPn, '_B', num2str(bl)];
        [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);
        
    %% %%%%%%%%%%%%%%%%%%
    %   Eye-Tracking    %
    %%%%%%%%%%%%%%%%%%%%%

    % To calculate Fixation-Related Potentials, the Eye-Tracking data
    % needs to be synchronized with the EEG data. This is done using
    % the EYE-EEG toolbox:

    % 1. Parse the SMI data (ALREADY CONVERTED TO A .txt FILE USING SMI IDF Converter w/ the specific settings from the EYE-EEG website!!)
    %   to a .mat file
    % 2. Synchronize the EEG and ET data
    % 3. Highlight unusable data (due to bad ET/signal dropout/blinks)
    % 4. Possibly check whether ET data corresponds to the EOG data, as a quality check
    % 5. Detect saccades and fixations
    % 6. remove bad ICA (see EEG - step 6) components(i.e. eye movements) based on ET
    
        
% for filnr=1:length(EEGfilnames)
    % for bl = 1:4
        % select the start and end marker of the current block 
%         em = 10+bl;
%         startmarker = ['S  ', num2str(bl)];
%         endmarker = ['S ', num2str(em)];
        
        %% Load preprocessed EEG data
        
        EEG = pop_loadset('filename',[VPn, '_Block' num2str(bl), '_ICA.set'],'filepath',preprocpath);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );


        %% Convert eye-tracking data
        % "Eyetracker" > "Parse Eye Tracker raw data" > "text file from Eyelink"
        % Specify text file
        % Specify an output filename with ending .mat (=MATLAB format)
        
        % Mark the box: Special messages (keyword + number) were sent
        % Enter the following keyword: MYKEYWORD
        % Click "OK" --> Matlab now convertes the text data to MATLAB
        
        % check whether file already exists? could be wrong version...
        parsedFileName = [pathParsedET, VPn, '_', num2str(bl), '.mat'];
        
        if exist(parsedFileName, 'file') ~= 2
            disp(["Parsing ET of VP: ", VPn, ', Block ', num2str(bl) "...."])
            % search for file of that VP & Block
            inET = dir([path2ET, VPn, '*_', num2str(bl), ' Samples.txt']);
            ET = parsesmi([path2ET,inET.name], parsedFileName,'KEYWORD');
        end
        
        
        %% Eyetracker > Import & Synchronize ET
        % Select .mat file created in step above
        % Next menu: Select events for synchronization:  1 (2, 3, 4 --> blocknumber) (start) and 11 (10 + blocknumber) (end)
        % Choose some or all of the columns to import (but include those with “GAZE”)
        % Check box: Import eye movement events from raw data (yes)
        % Click "OK" in the window that pops up
        
        % import and save in new dataset
        EEG = pop_importeyetracker(EEG,parsedFileName,[bl em], [1:11] ,{'Time' 'Trial' 'L-Dia-X-(px)' 'L-Dia-Y-(px)' 'R-Dia-X-(px)' 'R-Dia-Y-(px)' 'L-POR-X-(px)' 'L-POR-Y-(px)' 'R-POR-X-(px)' 'R-POR-Y-(px)' 'Trigger'},0,1,0,showPlots,4);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[ VPn, '_', num2str(bl), '_ET'],'gui','off');
        if showPlots
            closeFigButtonPress();
        end
        
        %% reject cont data based on ET
        
        keepBadEpochs = 2; % 1 = delete, 2 = keep and mark
        WindowAroundBadEpochs = 10; % ms before and after bad epochs
        
        EEG = pop_rej_eyecontin(EEG, ETchans, [1 1 1 1], monitorSize, WindowAroundBadEpochs, keepBadEpochs);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[ VPn, '_', num2str(bl), '_ET_rm'],'gui','off');
        
        if showPlots
            pop_eegplot( EEG, 1, 1, 0);
            closeFigButtonPress();
        end
        
        %% Check synchronization accuracy --> need to horizontal EOG electrodes!
        % Click "Eyetracker" > "Evaluate synchronization (cross.-corr)"
        % Select horizontal ET channel of one eye (e.g. L-GAZE X)
        % Select EOG electrodes:
        % LO1 (channel 67)
        % LO2 (channel 68)
        % Click "OK" and look at cross-correlation plot
        
        EEG = pop_checksync(EEG,39,32,32,showPlots);  % which one is the EOG channel???
        % EEG = pop_checksync(EEG,39,26,25,showPlots)  % with F9/F10 as horizEOG
%         if showPlots
            closeFigButtonPress(VPn, bl);
%         end
        %% Detect eye movements
        
        % parameters
        lambd = 4; % SD; velocity factor/threshold for saccade detection  (cf. Engbert & Mergenthaler, 2006)
        midu = 4; % minimum duration of saccades (in samples, of EEG,upsampled? i.e. 4msec)
        visdeg = [];%.022; % visual angle of one screen pixel, can be left empty [], then output in pixels
        smoo = 1; %  if set to 1, the raw data is smoothed over a 5-sample window to suppress noise (if high SR)
        gthresh = 0; % Use the same thresholds for all epochs, then 1? (doesnt matter for cont data)
        cdist = 25; % min fix duration in samples (if too close = cluster)
        cmode = 1; % What to do w/ cluster? 1-4, check help detecteyemovements
        removeBadFixs = false;
        
        % to check, does not save in EEG, press 'n' to NOT save the eye
        % movements as events
        buttonPressed = [];
        EEG = pop_detecteyemovements(EEG,ETchans([1 2]),ETchans([3 4]),lambd,midu,visdeg,smoo,gthresh,cdist,cmode,1,0,0, removeBadFixs);
        buttonPressed = closeFigButtonPress();
        % in case we accidentally close window w/ X
        if isempty(buttonPressed); buttonPressed = 'y'; end
        
        % continue to save if another key than 'n' was pressed
        if buttonPressed ~= 'n' %~strcmpi(buttonPressed, 'n')
            EEG = pop_detecteyemovements(EEG,ETchans([1 2]),ETchans([3 4]),lambd,midu,visdeg,smoo,gthresh,cdist,cmode,showPlots,1,1, removeBadFixs);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off');
            if showPlots    % possibly not necessary to plot again!
                closeFigButtonPress();
            end
        end
        
        %% Remove ICA components
        
        % Look at the ICA scalp maps
        if showPlots 
            N_COMP2PLOT = 1:16; % max 42 components
            pop_topoplot(EEG,0,N_COMP2PLOT,'First 16 ICA components',[4 4] ,0,'electrodes','on');
            closeFigButtonPress();
       
        % Plot the ICA activations (=time courses) of the components...
            pop_eegplot( EEG, 0, 1, 1);
            closeFigButtonPress();

        % Plot properties of some of the components in detail
        % ICs could reflect:
        % - eyelid/upwards saccade
        % - horizontal saccade
        % - spike potential
        % - 50 Hz electromagnetic line noise artifact (from eye-tracker)
        % ...
            COMP2PLOT = 1;
            pop_prop(EEG, 0, COMP2PLOT, NaN, {'freqrange' [2 55]});
            closeFigButtonPress();
        end

        % Identify ocular ICA components by the variance ratio criterion
        THRESHOLD = 1.1; % variance ratio threshold
        [EEG vartable] = pop_eyetrackerica(EEG,'saccade','fixation',[5 0] ,THRESHOLD,3,1,2);


        % Remove activity of the flagged ocular components
        EEG_uncorr = EEG; % store copy of uncorrected data
        EEG = pop_subcomp(EEG,[find(EEG.reject.gcompreject)],0);


        % Plot raw and cleaned datasets in overlay
        if showPlots 
            eegplot(EEG.data,'srate',EEG.srate,'data2',EEG_uncorr.data,'winlength',3);
            closeFigButtonPress(VPn, bl);
        end

        
        %% %%%%%%%%%%%%%%%
        %     Save       %
        %%%%%%%%%%%%%%%%%%
        
        EEG = pop_saveset(EEG, 'filename',[VPn, '_Block' num2str(bl), '_ETprep.set'],'filepath', preprocpath);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        
   % end % end block loop
 % end % end VP loop
 
 
 % for filnr=1:length(EEGfilnames)
    % for bl = 1:4
         
        oEEG = EEG;
        %% Fixation-Related Potentials
        
        % In order to calculate the FRPs, we first need to know whether a
        % fixation was on social or nonsocial!!!
        
        % compare with saliency maps etc.
        
        % cut epochs around fixation onsets
        EEG = pop_epoch( EEG,{'fixation'},[-0.5 1.2],'newname',[VPn, '_', num2str(bl), '_FRP'], 'epochinfo', 'yes');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off');
        eeglab redraw % refresh EEGLAB window

        % remove "baseline" activity in -200 to 0 ms interval before fixation
        EEG = pop_rmbase(EEG,[-300 -100]);

        % Plot the average fixation-related potential (FRP)
        NCHANS_EEG = 1:30;
        EEG = applytochannels(EEG,NCHANS_EEG,'figure; pop_timtopo(EEG, [-200 800], [90 150],''FRP with scalp maps (scenes)'');');

        
        %% (Pre-)Saccade-Related Potentials
        
         % cut epochs around fixation onsets
        EEG = oEEG; % reset to unepoched data
        
        % take 1.2 sek before saccade onset
        EEG = pop_epoch( EEG,{'saccade'},[-1.2 .5],'newname',[VPn, '_', num2str(bl), '_SRP'], 'epochinfo', 'yes');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off');
        eeglab redraw % refresh EEGLAB window

        % remove "baseline" activity, in this case after saccade onset
        EEG = pop_rmbase(EEG,[0 200]);

        % Plot the average fixation-related potential (FRP)
        NCHANS_EEG = 1:30;
        EEG = applytochannels(EEG,NCHANS_EEG,'figure; pop_timtopo(EEG, [-1500 800], [90 150],''FRP with scalp maps (scenes)'');');

        %% %%%%%%%%%%%%%%%
        %     Save       %
        %%%%%%%%%%%%%%%%%%
        
        EEG = pop_saveset(EEG, 'filename',[VPn, '_Block' num2str(bl), '_FRPs.set'],'filepath', preprocpath);
        [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

        %% advanced users: do time-frequency analysis
        % Instead of an average, try to do a time-frequency analysis of the
        % fixation-related EEG epochs, for example at channel Oz (42)
        % EEGLAB menu: Plot > time frequency transforms > Channel time frequency
        % Function: pop_newtimef
