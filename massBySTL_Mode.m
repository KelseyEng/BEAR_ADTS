%Kelsey Snapp
%Kab Lab
%3/19/21
% Finds all the mass of that printer/nozzle/filamentID by STL_Mode

function [massList,indexCombined] = massBySTL_Mode(dataT,selectedPrinter,selectedNozzle,STL_Mode,printerT)
    
    filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);

    idxSTL = any(dataT.STL_Mode == STL_Mode,2);
    idxPrinter = dataT.PrinterNumber == selectedPrinter;
    idxNozzle = dataT.PrinterNozzle == selectedNozzle;
    idxFilamentID = dataT.FilamentID == filamentID;
    idxMass = (dataT.Mass - dataT.TargetMass)./dataT.TargetMass > -.33;
    idxMass2 = (dataT.Mass - dataT.TargetMass)./dataT.TargetMass < 2;
    idxCutoff = dataT.ID_Number > printerT.MassCutoff{1}(selectedNozzle+1,selectedPrinter);
    
    indexCombined = idxSTL & idxPrinter & idxNozzle & idxFilamentID & idxMass & idxMass2 & idxCutoff;
    
    massList = dataT.Mass(indexCombined);    

end