%Kelsey Snapp
%Kab Lab
%6/24/21
% Clears simulated data when prints are abandoned

function [dataT, stressThreshData] = clearSimulatedData(dataT,selectedPrinter,stressThreshData)
    %Find Data
    indexPrinter = dataT.PrinterNumber == selectedPrinter;
    indexSimulated = dataT.SimulatedData == 1;
    indexCombined = indexPrinter & indexSimulated;
    
    % Clear Simulated Data from Failed Prints
    dataT.SimulatedData(indexCombined) = 0;
    dataT.Toughness(indexCombined) = 0;
    dataT.aPred(indexCombined) = 0;
    if size(stressThreshData,1) < length(indexCombined)
        stressThreshData(length(indexCombined),1) = 0;
    end
    stressThreshData(indexCombined,:) = stressThreshData(indexCombined,:) * 0;


end