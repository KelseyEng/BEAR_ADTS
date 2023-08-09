%Kelsey Snapp
%Kab Lab
%10/04/21
% Generates STLS to print


function toughness = calcForceThreshData(FDT,forceThreshLimits)
    
    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    
    % Calculate Threshold Data
    count = 1;
    toughness = zeros(1,size(forceThreshLimits,2));
    for thresh = forceThreshLimits %N
        index = find(F > thresh,1) -1;
        if isempty(index)
            if count > 1
                toughness(count) = toughness(count-1);
            else
                toughness(count) = 0;
            end
        elseif index < 2
            toughness(count) = 0;
        else
            toughness(count) = trapz(D(1:index),F(1:index))./1000; %J
        end
        count = count + 1;
    end


end
