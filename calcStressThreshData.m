%Kelsey Snapp
%Kab Lab
%10/04/21
% Generates STLS to print


function stressThreshData = calcStressThreshData(FDT,stressThreshLimits,dataT,ID)
    
    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    
    % Calculate area and volume
    height = dataT.Height(ID); %mm
    area = dataT.EffectiveArea(ID); %mm^2
    volCLS = area * height; %mm^3
    
    % Calculate Threshold Data
    count = 1;
    toughness = zeros(1,size(stressThreshLimits,2));
    for thresh = stressThreshLimits.*area %N
        index = find(F > thresh,1) -1;
        if isempty(index)
            index = length(D);
        end
        if index < 2
            toughness(count) = 0;
        else
            toughness(count) = trapz(D(1:index),F(1:index))./1000; %J
        end
        count = count + 1;
    end

    stressThreshData = toughness./volCLS*1000; %MJ/m^3


end
