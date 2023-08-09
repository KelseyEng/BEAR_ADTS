% KabLab
% Author: Kelsey Snapp
% Date  : 9/27/21
% Description: Computes height of sample

function maxD = calcMaxDisplacement(FDT)
   
    [D,~,~,~] = processFDT(FDT,1); %mm and N and mm
    
    if isempty(D)
        maxD = 0;
    else
        maxD = max(D);
    end
    
end