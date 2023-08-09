% KAB Lab
% Kelsey Snapp
% 3/18/22
% Finds Pareto Front


function [pList,idxOut] = paretoFront(x,y,dirX,dirY)
    % Set modVal which will make equality work towards end
    if dirX < 0
        modVal = -1;
    else
        modVal = 1;
    end
    
    % sort arrays according to dirY direction
    if dirY < 0
        [yNew,idxSort] = sort(y);
    else
        [yNew,idxSort] = sort(y,'descend');
    end
    
    xNew = x(idxSort);  
    
    % Find Pareto front by going through yNew and seeing if xNew is better
    xRef = xNew(1);
    pList = [xNew(1),yNew(1)];
    idxOut = [1];
    for i = 2:length(yNew)
        xTemp = xNew(i);
        if xTemp * modVal > xRef * modVal
            pList = [pList; xNew(i),yNew(i)];
            xRef = xNew(i);
            idxOut(end+1) = i;
        end
    end
    
    idxOut = idxSort(idxOut);
end