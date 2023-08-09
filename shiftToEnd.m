%Kelsey Snapp
%Kab Lab
%3/18/21
% Takes a List and shift the targetValue to the end.
% Used to change priority of printers

function list = shiftToEnd(list,targetValue)

    list = [list(list~=targetValue), targetValue];
    
end