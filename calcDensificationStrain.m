%Kelsey Snapp
%Kab Lab
%7/19/22
% Finds densification strain based on peak efficiency

function densificationStrain = calcDensificationStrain(FDT,dataT,ID)
    
    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    
    % Calculate area and critical force
    height = dataT.Height(ID); %mm
    area = dataT.EffectiveArea(ID); %mm^2
    criticalForce = dataT.CriticalStress(ID) * area; %N
    
    
    % Find displacement
    idx = find(F > criticalForce,1) -1;
    if isempty(idx)
        densificationStrain = 0;
    else
        densificationStrain = D(idx)/height; %unitless
    end

end