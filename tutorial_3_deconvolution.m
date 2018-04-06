%% Workshop "Combining Eye-Tracking & EEG: An Introduction"
% by Olaf Dimigen & Benedikt Ehinger
% olaf.dimigen@hu-berlin.de, behinger@uos.de, August 19, Wuppertal
%
% Please DO NOT use data from these tutorials without permission. Feel free
% to adapt or use code for teaching, research, etc. If possible, please
% acknowledge relevant publications introducing different components of
% these methods (e.g. Dimigen et al., 2009, J Neurosci, Dimigen et al.,
% 2011, JEP:GEN, Meyberg et al., 2017, Neuropsychologia)
run('../unfold/init_unfold.m')

%% Load the data
EEG = pop_loadset('filename','faces_saccades.set');
EEG = eeg_checkset(EEG);


%% define a design where we model the stimulus onsets  and the saccade onsets
% in addition we model for each saccade the sac_amplitude as a spline
cfgDesign = [];
% eventtype as in EEG.event.type
cfgDesign.eventtype = {'saccade',              {'S121','S122','S123'}};
% Formula y ~ 1 + EEG.event.fieldname
cfgDesign.formula =   {'y ~ 1+ sac_amplitude',   'y~1'}; % last part models the events (S121 etc.), first part saccades

% Generate the designmat
EEG = dc_designmat(EEG,cfgDesign);

% ## TASK 1 ##
% Inspect the structure `EEG.deconv`
% The most important field here is EEG.deconv.X - the designmatrix
% Inspect it using dc_plotDesignmat(EEG)
dc_plotDesignmat(EEG)
% 1.1 Can you explain what each column in the designmatrix represents?

%%% maybe intercept of saccade?, saccade, intercept of trial or so?

% 1.2 Replace the formula of the saccade-event by:
%                y ~ 1 + spl(sac_amplitude,10)

cfgDesign.formula =   {'y ~ 1+ spl(sac_amplitude,10)',   'y~1'};
EEG = dc_designmat(EEG,cfgDesign);

%     Plot the designmatrix again, why are there more columns now?
dc_plotDesignmat(EEG)
%%% for every spline

% Please continue with the spline-based formula of 1.2 from now on.


%% Timeexpanding the designmatrix using stick-functions
cfgTimeexpand = [];
cfgTimeexpand.timelimits = [-.5,0.8];  % how much overlap do I want, epoch size?? How to decide???

EEG = dc_timeexpandDesignmat(EEG,cfgTimeexpand);


% ## TASK 2 ##
% again inspect EEG.deconv
% The most important field here is EEG.deconv.dcX
%%% 

% 2.1 Why does dcX have the dimension it has? What represents the first dimension, what the
%     second one?
%%% first one is time,second one is betas?!

% 2.2 visualize it using dc_plotDesignmat(EEG,'timeexpand',1). You might
%     want to zoom in / move around ('hand'-tool). Do you understand why it
%     looks like it looks?
dc_plotDesignmat(EEG,'timeexpand',1)

%% Solve the y = Xb + e equation system for 'b'
% This might take a minute or two to solve
EEG = dc_glmfit(EEG);

% ## Task 3 ##
% have a look at EEG.deconv. There is a new field EEG.deconv.dcBeta
% These are your deconvolved parameter estimates.
% You could directly plot them / visualize them. Most likely only the first
% and the last will make much sense - don't worry we will have a better look
% at the model-fit after the next step


%% Calculate a Massive-Univariate Linear Model without deconvolution
% In order to compare deconvolution results & non-deconvolution results, we
% need to epoch our data & fit a LM for each timepoint/electrode separately
EEG_epoch = dc_epoch(EEG,'timelimits',cfgTimeexpand.timelimits);
EEG_epoch = dc_glmfit_nodc(EEG_epoch);



%% Extract and Plot
% We extract the betas and convert the spline-betas to actual values.
% if you inspect the variable 'unfold' you can see that we have many more
% betas now. These are representatives of many different
% saccade-amplitudes.
unfold = dc_beta2unfold(EEG_epoch);


cfg = [];
cfg.channel = 1;
% Define at which values we want to evaluate the splines of the sac amplitude
% (in this case from a sac-amp of 0.5° to 5.5° in 10 steps)
cfg.pred_value = {{'sac_amplitude',linspace(0.5,5,10)}};
% We add the intercept, e.g. the ERP to the average saccade-amplitude
cfg.add_intercept = 1;

% Plot it
dc_plotParam(unfold,cfg);

% ## TASK 4 ##
% 4.1 describe the differences between convoluted and deconvoluted ERPs
% 4.2 sometimes it is helpful to baseline correct.
%     Add above cfg.baseline = [-0.5 0]
%     Does this reduce the differences between convoluted/deconvoluted ERPs?
%
% 4.3 change add_intercept to 0. what happens and why?
%
% 4.4 (Bonus) We want to directly compare the ERP for the stimulus with and without
%     deconvolution in a single plot. To do so we manually extract the betas
%     from the unfold.beta structure. The beta of the stimulus is the last one,
%     i.e. in my case beta 1002. You could inspect unfold.epoch to find this out
%     Plot both unfold.beta against unfold.beta_nodc in the same plot (you could
%     use 'plot' and 'hold on' for this)
