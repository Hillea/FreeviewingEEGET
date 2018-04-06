%% Visual data check of the EEG Freeviewing Data 
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


%% Check out data quality 
badData = {};
for filnr=1:length(EEGfilnames)
 
    
    % Get the VP number to load and save data
    VPn = EEGfilnames{filnr}(end-6:end-5);
    disp(['Current VP: ', VPn])
    
    % load file into eeglab with name VPn
    % "File" > "Import data" > File I/O > select .vdhr file
    EEG = pop_fileio( [path2EEG, EEGfilnames{filnr}]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',VPn,'gui','off');
    EEG = eeg_checkset( EEG );
    
    % Plot continuous EEG data   
    if showPlots
        pop_eegplot( EEG, 1, 1, 1);
        curChar = closeFigButtonPress();
        if curChar == 'n'
            badData{length(badData)+1} = VPn;
            disp(['*******Bad data quality in ' VPn '********'])
        end
    end
    
    EEG = [];
end