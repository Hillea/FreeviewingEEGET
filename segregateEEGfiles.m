function nEEG = segregateEEGfiles(EEG, startmarker, endmarker)

    %% This script separates the EEG files into four files, one per block
    % This is necessary for the EYE-EEG analyses, because the Eyetracking data
    % are in four separate files (due to the recalibrations between blocks) and
    % otherwise the triggers don't align.

    %%

   % startmarker = 'S  1';
   % endmarker = 'S128';
    %% load data (start loop through participants' files)

    VPn = strsplit(EEG.comments, '\');
    VPn = VPn{end}(end-8:end-5);

    %% find indeces of start (1) and end (128) markers, there's one per block
    % (but possibly a start marker too much at the end)

    % find indeces and closest time points (to subset data, markers likely
    % between data points)
    startidx = find(strcmpi(startmarker, {EEG.event.type}));
    endidx = find(strcmpi(endmarker, {EEG.event.type}));

    startsample = {EEG.event(startidx).latency};
    endsample = {EEG.event(endidx).latency};

    % find correct markers?            
    cou = 1;
    while length(startidx) ~= length(endidx)
        if startidx(cou) > endidx(end) || startidx(cou+1) < endidx(cou) 
            startidx(cou) = [];
        else
            cou = cou+1;
        end
    end


    %% segregate EEG data into four files, one per block, and save
    % backup original EEG data (needs to be reloaded frequently)
    %oEEG = EEG; % also in ALLEEG(1)!



    %%
    for idx=1:length(endidx)

%         % make a new dataset for each block
%         [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, idx,'setname',[VPn, '_Block_', num2str(idx)],'gui','off'); 
%         EEG = eeg_checkset( EEG );
%         %eeglab redraw;
        nEEG = EEG;
        
        % get the closest data point to marker
%         [~,startidc] = min(abs([1:length(EEG.times)] - startsample{idx}));
%         [~,endidc] = min(abs(EEG.times - endsample{idx}));


        nEEG.data = EEG.data(:,startsample{idx}:endsample{idx});
        nEEG.times = EEG.times(:,startsample{idx}:endsample{idx});
        nEEG.event = EEG.event(startidx(idx):endidx(idx));
%         nEEG.event.origlatency = EEG.event.latency;
        tmp = [nEEG.event.latency] - min([nEEG.event(1:end).latency]) +1;
        % don't know how to avoid loop, wasted too much time already
        for i=1:length(tmp)
            nEEG.event(i).latency = tmp(i);
        end
        nEEG.subject = nEEG.setname;  % change to get it from path
        nEEG.session = idx;
        nEEG.pnts = length(nEEG.times);

%         [ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); 

        % save as .mat file (if readable by EEGlab)
        % save(['Y:\Freeviewing_EEG_ET\Daten\EEG\separated\', VPn, '_Block', num2str(idx), '.mat'],'EEG');
%         pop_saveset( EEG, 'filename', [VPn, '_Block_', num2str(idx)], 'filepath', 'Y:\Freeviewing_EEG_ET\Daten\EEG\separated\', 'check', 'off', 'savemode', 'onefile');
% 
%         % clearvars startidc endidc EEG
% 
%         EEG = ALLEEG(1); %oEEG;

    end
end


