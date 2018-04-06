%% Workshop "Combining Eye-Tracking & EEG: An Introduction"
% by Olaf Dimigen
% olaf.dimigen@hu-berlin.de, August 19, Wuppertal
%
% Please DO NOT use data from these tutorials without permission. Feel free
% to adapt or use code for teaching, research, etc. If possible, please
% acknowledge relevant publications introducing different components of
% these methods (Dimigen et al., 2009, J Neurosci, Dimigen et al., 2011,
% JEP:GEN, Dimigen et al., 2012, Neuroimage, Kornrumpf et al., 2016,
% Psychophysiology, Plöchl et al., 2012, Frontiers)
%
% HANDS-ON TUTORIAL #3: EYE-Tracker-Guided ICA & FRPs
%
% Saccade and fixation events in the data (EEG.event):
% ----------------------------------------------------
% sac-scene: saccade onset (in scene)
% fix-scene: fixation onset (in scene)
% sac-dark:  saccade onset (in total darkness)
% fix-dark:  fixation onset (in total darkness)
% ----------------------------------------------------
%
% You can execute each cell (%%) of the script with:
% Windows: CNTRL-SHIFT-ENTER
% Mac:     APPLE-SHIFT-ENTER

clear

%% Enter the path to eeglab and the workshop material
% On Windows you can find the folder in the explorer, click in
% the adress bar and copy the path.

% -------------------------------------------------------------------------
% Folder path to your EEGLAB directory:
path_to_eeglab = 'C:/Users/leh83zj/Documents/UniWü/EEG/eeglab14_1_1_1b/';
% Folder path to workshop folder
path_to_workshop_material = 'C:\Users\leh83zj\Documents\UniWü\EEG\Workshop\tutorials\';
% -------------------------------------------------------------------------

%% add eeglab to path and start eeglab
addpath(path_to_eeglab)
eeglab

%% load integrated EEGLAB dataset of scene viewing experiment
EEG = pop_loadset('filename','freeviewing_250hz.set','filepath', path_to_workshop_material);
eeglab redraw % refresh EEGLAB window

%% 1. Let's plot some eye movement properties first
% In this dataset, saccades and fixations were already detected
% Let's use EYE-EEG function "pop_ploteyemovements" to plot their properties

% visualize eye movements properties in scene condition...
pop_ploteyemovements(EEG,'sac-scene','fix-scene','degree') % scenes
% pop_ploteyemovements(EEG,'sac-dark','fix-dark','degree') % darkness


%% 2. Let's look at the raw data with ocular artifacts
pop_eegplot(EEG,1,1,1);


%% 3. Let's look at the ICA scalp maps
% An (optimized) ICA was already computed for this dataset,
% Let's plot the ICA scalp maps...
N_COMP2PLOT = 1:16; % max 42 components
pop_topoplot(EEG,0,N_COMP2PLOT,'First 16 ICA components',[4 4] ,0,'electrodes','on');

%% 4. Plot the ICA activations (=time courses) of the components...
pop_eegplot( EEG, 0, 1, 1);


%% 5. Plot properties of some of the components in detail
% For this subject, the independent components (ICs) seem to reflect the
% following:
%
% IC 1: eyelid/upwards saccade
% IC 2: horizontal saccade
% IC 3: (mostly) spike potential
% IC 4: (mostly) spike potential
% IC 5: 50 Hz electromagnetic line noise artifact (from eye-tracker)
% ...
COMP2PLOT = 5;
pop_prop(EEG, 0, COMP2PLOT, NaN, {'freqrange' [2 55]});


%% 6. Let's identify ocular ICA components by the variance ratio criterion
THRESHOLD = 1.1; % variance ratio threshold
[EEG vartable] = pop_eyetrackerica(EEG,'sac-scene','fix-scene',[5 0] ,THRESHOLD,3,1,2);


%% 7. Remove activity of the flagged ocular components
EEG_uncorr = EEG; % store copy of uncorrected data
EEG = pop_subcomp(EEG,[find(EEG.reject.gcompreject)],0);


%% 8. Plot raw and cleaned datasets in overlay
eegplot(EEG.data,'srate',EEG.srate,'data2',EEG_uncorr.data,'winlength',3);


%% 9. Let's look at the fixation-related potential in the "scene" condition
% first we cut epochs around fixation onsets
EEG = pop_epoch( EEG,{'fix-scene'},[-0.5 1.2],'newname','fix-locked epochs (scenes)', 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'gui','off');
eeglab redraw % refresh EEGLAB window

% remove "baseline" activity in -200 to 0 ms interval before fixation
EEG = pop_rmbase(EEG,[-200 0]);

% Plot the average fixation-related potential (FRP)
NCHANS_EEG = 1:46;
EEG = applytochannels(EEG,NCHANS_EEG,'figure; pop_timtopo(EEG, [-200 800], [90 150],''FRP with scalp maps (scenes)'');');


%% If you want, you could try the following exercises...

%% intermediate users: compute FRP for total darkness
% Using the menu "Datasets", go back to the continuous data
% Compute an averaged SRP or FRP for the total darkness condition
% The relevant onset events here are called: "sac-dark" and "fix-dark"
% Is there any EEG activity in total darkness, e.g. related to saccadic suppression,
% saccadic enhancement, or remapping/space constancy?

%% advanced users: do time-frequency analysis
% Instead of an average, try to do a time-frequency analysis of the
% fixation-related EEG epochs, for example at channel Oz (42)
% EEGLAB menu: Plot > time frequency transforms > Channel time frequency
% Function: pop_newtimef