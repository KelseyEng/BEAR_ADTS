%Kelsey Snapp
%Kab Lab
%6/20/23
% Check that robot is clear of instron before starting

function clearStatus = checkClear()

    pos = getPosition();

    targetPos = [0.367298197261836,0.301935196325273,0.304357701213750,0.000536942514804548,0.000353638739865468,0.626191063151971];
    diffPos = pos-targetPos;
    
    if sum(abs(diffPos)) > .01 || any(abs(diffPos)>.1)
        clearStatus = 0;
    else
        clearStatus = 1;
    end
    
end