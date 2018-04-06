function newvec = smoothMoveAvg(datavec, span)


% smooth the data without the curve fitting toolbox
hspan = (span-1)/2;
for x=1:length(datavec)
    % beginning of vector
    if x <= hspan
        if x == 1
            newvec(x) = datavec(x);
        else
            newvec(x) = sum(datavec(x-(x-1):x+(x-1)))/length(x-(x-1):x+(x-1));
        end
    % end of vector
    elseif x >= length(datavec)-hspan
        if x == length(datavec)
            newvec(x) = datavec(x);
        else
            newvec(x) = sum(datavec(x-(length(datavec)-x):x+(length(datavec)-x)))/length(x-(length(datavec)-x):x+(length(datavec)-x));
        end
    % normal data in the middle (fully smoothed across span)        
    else
        newvec(x) = sum(datavec(x-hspan:x+hspan))/span; 
    end
end
end