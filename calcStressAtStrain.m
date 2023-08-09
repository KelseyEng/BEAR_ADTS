% KAB Lab
% Kelsey Snapp
% 3/10/22
% Calculates stress at given strain

function [stress] = calcStressAtStrain(FDT,dataT,ID,strainTarget)
    
    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    
    % Calculate area and volume
    height = dataT.Height(ID); %mm
    
    area = dataT.EffectiveArea(ID); %mm^2
    area = area /1e6; %m^2

    % stress vs strain

    stress = (F)./area; %N/m^2

    strain = (D)./height; %mm/mm
    
    % Find 
    
    idx = find(strain>strainTarget,1);
    if isempty(idx)
        stress = 0;
    else
        stress = stress(idx)./1e6; %MPa
    end
    
    

end