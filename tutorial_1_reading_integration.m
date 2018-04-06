%% Workshop "Combining Eye-Tracking & EEG: An Introduction"
% by Olaf Dimigen
% olaf.dimigen@hu-berlin.de, August 19, Wuppertal
%
% Please DO NOT use data from these tutorials without permission. Feel free
% to adapt or use code for teaching, research, etc. If possible, please
% acknowledge relevant publications introducing different components of 
% these methods (e.g. Dimigen et al., 2009, J Neurosci, Dimigen et al., 
% 2011, JEP:GEN, Meyberg et al., 2017, Neuropsychologia)
%
% HANDS-ON MINI-TUTORIAL #1: DATA INTEGRATION
% In this simple tutorial, we'll just mindlessly mouse-click through EEGLAB/EYE-EEG menus

clear

%% Enter the path to eeglab and the workshop material
% On Windows you can find the folder in the explorer, click in 
% the adress bar and copy the path.

%% Enter the path to eeglab and the workshop material
% -------------------------------------------------------------------------
% Folder path to your EEGLAB directory:
path_to_eeglab = 'C:/Users/leh83zj/Documents/UniWü/EEG/eeglab14_1_1b/';
% Folder path to workshop folder
path_to_workshop_material = 'C:/Users/leh83zj/Documents/UniWü/EEG/Workshop/tutorials/';
% -------------------------------------------------------------------------

clear

%% Start MATLAB
 % Quick look at MATLAB: command window & editor
 
%% Start EEGLAB
 % Add EEGLAB folder to MATLAB path (addpath)
 % Start EEGLAB by typing: eeglab
 addpath(path_to_eeglab)
 eeglab
 
%% Load EEG raw data
 % "File" > "Load existing dataset" > reading_eeg.set

%% Plot continuous EEG data
 % "Plot" > "Channel data (scroll)"

%% Convert eye-tracking data
% "Eyetracker" > "Parse Eye Tracker raw data" > "text file from Eyelink"
 % Specify text file
 % Specify an output filename with ending .mat (=MATLAB format)
 %
 % Mark the box: Special messages (keyword + number) were sent
 % Enter the following keyword: MYKEYWORD
 % Click "OK" --> Matlab now convertes the text data to MATLAB

%% Eyetracker > Import & Synchronize ET
 % Select .mat file created in step above
 % Next menu: Select events for synchronization: 3 (start) and 3 (end)
 % Choose some or all of the columns to import (but include those with “GAZE”)
 % Check box: Import eye movement events from raw data (yes)
 % Click "OK" in the window that pops up

%% Look at sync results
 % output in MATLAB command window (sync details)
 % figure with synchronization accuracy

%% Look at synchronized continuous data with saccade events: 
 % "Plot" > "Channel data (scroll)"

%% Double-check synchronization accuracy 
% Click "Eyetracker" > "Evaluate synchronization (cross.-corr)"
 % Select horizontal ET channel of one eye (e.g. L-GAZE X)
 % Select EOG electrodes:
    % LO1 (channel 67)
    % LO2 (channel 68)
 % Click "OK" and look at cross-correlation plot

%% Get command history to write a script (across participants)
  % In command window, type eegh
  % Look at MATLAB code for commands we just “clicked”
  % We could easily adapt in to loop the analysis across subjects

  
%% here are commands we just executed by clicking menus
% you have to adapt the file path from C:/somefolder to your location

eeglab
% load EEG
EEG = pop_loadset('filename','reading_eeg.set','filepath',path_to_workshop_material);
% plot EEG
pop_eegplot(EEG, 1, 1, 1);
% convert eye-track
ET = parseeyelink([path_to_workshop_material '/reading_eyelink.asc']',[path_to_workshop_material '/reading_eyelink.mat'],'MYKEYWORD');
% synchronize eye-track
EEG = pop_importeyetracker(EEG,[path_to_workshop_material '/reading_eyelink.mat'],[3 3],[1:8] ,{'TIME' 'L-GAZE-X' 'L-GAZE-Y' 'L-AREA' 'R-GAZE-X' 'R-GAZE-Y' 'R-AREA' 'INPUT'},1,1,0,1,4)
% plot EEG+ET
pop_eegplot(EEG, 1, 1, 1);
% check EOG-ET cross-correlation
EEG = pop_checksync(EEG,74,67,68,1)
% get command history
eegh
  