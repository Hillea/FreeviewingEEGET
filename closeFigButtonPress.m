function curChar = closeFigButtonPress()

%badData = {};
curChar = 's';
% try   
    while ~(curChar == 'n' | curChar == 'y')
        set(gcf,'KeyPressFcn',@(fig_obj,eventDat) 0);
        waitfor(gcf,'CurrentCharacter');
        curChar=get(gcf,'CurrentCharacter'); %uint8(get(gcf,'CurrentCharacter'));
        %disp(curChar)
        %drawnow
    end
    
    close gcf
    
    %     if curChar == 'n'
    %         badData{length(badData)+1} = [VPn '_' num2str(bl)];
    %         disp(['Bad data quality in ' VPn '_' num2str(bl)])
    %         close gcf
    %     elseif curChar == 'y'
    %         close gcf
    % %     else
    % %         pause
    %     end
    
% catch ME  % if window is closed => assumed to be good data
%     curChar = 'y';   
    
    
    % close gcf
    
end