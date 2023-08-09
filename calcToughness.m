% KabLab
% Author: Aldair E. Gongora & Kelsey Snapp
% Date  : November 12, 2018  & 5/7/21
% Description: Function computes toughness (energy,J) from load force/displacement curve


function [toughness] = calcToughness(FDT)
    
    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    D = D ./ 1000; %m

    toughness = trapz(D,F); %J

end
