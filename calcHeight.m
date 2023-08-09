% KabLab
% Author: Kelsey Snapp
% Date  : 9/27/21
% Description: Computes height of sample

function height = calcHeight(FDT)

    [~,~,PS,~] = processFDT(FDT,1);
   
    if isempty(PS)
        height = 0;
    else
        height = PS(1);
    end
    
end