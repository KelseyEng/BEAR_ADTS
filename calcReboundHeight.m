% KabLab
% Author: Kelsey Snapp
% Date  : 1/7/2023
% Description: Computes Rebound Height after 60 second rest


function reboundHeight = calcReboundHeight(FDT)

    [~,~,~,FDT2] = processFDT(FDT,0);
    if isempty(FDT2)
        reboundHeight = 0;
    else
        [~,~,PS2,~] = processFDT(FDT2,0);
        reboundHeight = min(PS2);
    end

end

