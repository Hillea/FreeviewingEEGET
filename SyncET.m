function EEG = SyncET(EEG, VPn, bl, em,  WindowAroundBadEpochs, keepBadEpochs,


        keepBadEpochs = 2; % 1 = delete, 2 = keep and mark
        WindowAroundBadEpochs = 10; % ms before and after bad epochs
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
        % Next menu: Select events for synchronization: 3 (start) and 3 (end)
        % Choose some or all of the columns to import (but include those with “GAZE”)
        % Check box: Import eye movement events from raw data (yes)
        % Click "OK" in the window that pops up
        
        % import and save in new dataset
        EEG = pop_importeyetracker(EEG,parsedFileName,[bl em], [1:11] ,{'Time' 'Trial' 'L-Dia-X-(px)' 'L-Dia-Y-(px)' 'R-Dia-X-(px)' 'R-Dia-Y-(px)' 'L-POR-X-(px)' 'L-POR-Y-(px)' 'R-POR-X-(px)' 'R-POR-Y-(px)' 'Trigger'},0,1,0,showPlots,4);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',[ VPn, '_', num2str(bl), '_ET'],'gui','off');
        if showPlots
            closeFigButtonPress(VPn, bl);
        end
        
        %% reject cont data based on ET
        
%         keepBadEpochs = 2; % 1 = delete, 2 = keep and mark
%         WindowAroundBadEpochs = 10; % ms before and after bad epochs
        
        EEG = pop_rej_eyecontin(EEG, ETchans, [1 1 1 1], monitorSize, WindowAroundBadEpochs, keepBadEpochs);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[ VPn, '_', num2str(bl), '_ET_rm'],'gui','off');
        
        if showPlots
            pop_eegplot( EEG, 1, 1, 1);
            closeFigButtonPress(VPn, bl);
        end
        
        %% Check synchronization accuracy --> need to horizontal EOG electrodes!
        % Click "Eyetracker" > "Evaluate synchronization (cross.-corr)"
        % Select horizontal ET channel of one eye (e.g. L-GAZE X)
        % Select EOG electrodes:
        % LO1 (channel 67)
        % LO2 (channel 68)
        % Click "OK" and look at cross-correlation plot
        
        EEG = pop_checksync(EEG,39,32,32,showPlots);  % which one is the EOG channel???
        if showPlots
            closeFigButtonPress(VPn, bl);
        end
        %% Detect eye movements
        
        % parameters
        lambd = 6; % SD; velocity factor/threshold for saccade detection  (cf. Engbert & Mergenthaler, 2006)
        midu = 4; % minimum duration of saccades (in samples, of EEG,upsampled? i.e. 4msec)
        visdeg = .022; % visual angle of one screen pixel, can be left empty [], then output in pixels
        smoo = 0; %  if set to 1, the raw data is smoothed over a 5-sample window to suppress noise (if high SR)
        gthresh = 0; % Use the same thresholds for all epochs, then 1? (doesnt matter for cont data)
        cdist = 25; % min fix duration in samples (if too close = cluster)
        cmode = 1; % What to do w/ cluster? 1-4, check help detecteyemovements
        removeBadFixs = false;
        
        % to check, does not save in EEG, press 'n' to NOT save the eye
        % movements as events
        EEG = pop_detecteyemovements(EEG,ETchans([1 2]),ETchans([3 4]),lambd,midu,visdeg,smoo,gthresh,cdist,cmode,1,0,0, removeBadFixs);
        buttonPressed = closeFigButtonPress(VPn, bl);
        % in case we accidentally close window w/ X
        if isempty(buttonPressed); buttonPressed = 'y'; end
        
        % continue to save if another key than 'n' was pressed
        if buttonPressed ~= 'n' %~strcmpi(buttonPressed, 'n')
            EEG = pop_detecteyemovements(EEG,ETchans([1 2]),ETchans([3 4]),lambd,midu,visdeg,smoo,gthresh,cdist,cmode,showPlots,1,1, removeBadFixs);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4,'gui','off');
            if showPlots    % possibly not necessary to plot again!
                closeFigButtonPress(VPn, bl);
            end
        end
        
        %% Remove ICA components
        
        % Look at the ICA scalp maps
        if showPlots 
            N_COMP2PLOT = 1:16; % max 42 components
            pop_topoplot(EEG,0,N_COMP2PLOT,'First 16 ICA components',[4 4] ,0,'electrodes','on');
            closeFigButtonPress(VPn, bl);
       
        % Plot the ICA activations (=time courses) of the components...
            pop_eegplot( EEG, 0, 1, 1);
            closeFigButtonPress(VPn, bl);

        % Plot properties of some of the components in detail
        % ICs could reflect:
        % - eyelid/upwards saccade
        % - horizontal saccade
        % - spike potential
        % - 50 Hz electromagnetic line noise artifact (from eye-tracker)
        % ...
            COMP2PLOT = 5;
            pop_prop(EEG, 0, COMP2PLOT, NaN, {'freqrange' [2 55]});
            closeFigButtonPress(VPn, bl);
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
