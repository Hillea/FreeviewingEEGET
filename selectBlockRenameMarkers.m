function EEG = selectBlockRenameMarkers(EEG, startmarker, endmarker) %cur_block

%startmarker = 'S  1';
%endmarker = 'S128';
% cur_block = 2;

startidx = find(strcmpi(startmarker, {EEG.event.type}));

% There should be endmarkers, but not necessary (then no comparison whether
% correct start markers!)
if ~isempty(endmarker)
    endidx = find(strcmpi(endmarker, {EEG.event.type}));
    
%    find correct markers? Rename the ones that are clearly wrong (due to
%    restarts of the program, there might be more start then end markers)
    cou = 1;
    while length(startidx) ~= length(endidx)
        if startidx(cou) > endidx(end) || startidx(cou+1) < endidx(cou)
            EEG.event(startidx(cou)).type = 'S  3';
            startidx(cou) = [];
        else
            cou = cou+1;
        end
    end
    
end


% rename the markers according to block

%%old version: just renaming the non-used ones in every block
% for mi=1:length(startidx)
%     if mi ~= cur_block
%         EEG.event(startidx(mi)).type = 'S  2';
%         EEG.event(endidx(mi)).type = 'S129';
%     end
% end

% new version --> distinct block markers
for mi=1:length(startidx)
    switch mi
        case 1
            EEG.event(startidx(mi)).type = 'S  1';
            if ~isempty(endmarker); EEG.event(endidx(mi)).type = 'S 11'; end
        case 2
            EEG.event(startidx(mi)).type = 'S  2';
            if ~isempty(endmarker); EEG.event(endidx(mi)).type = 'S 12'; end
        case 3
            EEG.event(startidx(mi)).type = 'S  3';
            if ~isempty(endmarker); EEG.event(endidx(mi)).type = 'S 13'; end
        case 4
            EEG.event(startidx(mi)).type = 'S  4';
            if ~isempty(endmarker); EEG.event(endidx(mi)).type = 'S 14'; end
    end
end

end