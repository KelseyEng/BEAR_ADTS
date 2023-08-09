%Kelsey Snapp
%Kab Lab
%10/04/21
% processes FDT data into separate components in standardized way

function [D,F,PS,FDT2] = processFDT(FDT,THRESH)
    fThresh = 0.3; %N

    %Exclude Tap Data
    diffD = diff(FDT(:,2));
    [minD,latchOne] = min(diffD);
    if latchOne > 1 && minD < -5
        FDT2 = FDT(latchOne+1:end,:);
        FDT = FDT(1:latchOne,:);
    else
        FDT2 = [];
    end    
    
    % Separate Data into Force and Displacement
    D = FDT(:,2) - min(FDT(:,2)); %mm
    F = FDT(:,3) * 1000; %N
    
    % Remove force data below threshold
    if THRESH
        Ftrail = movmedian(F,[0,19]);
        idxContact = find(Ftrail > fThresh,1); 
        idxContact2 = find(F(idxContact:end) > fThresh,1);
        idxContact = idxContact + idxContact2;
        D = D(idxContact:end); %1 N threshold
        F = F(idxContact:end);    
        D = D - min(D); 
    end
    
    PS = 223.1 - FDT(:,2);
    if THRESH
        PS = PS(idxContact:end);
    end
    
end