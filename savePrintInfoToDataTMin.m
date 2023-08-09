%Kelsey Snapp
%Kab Lab
%5/6/21
% Saves all of the printer data to dataT

function dataT = savePrintInfoToDataTMin(dataT,printerT,ID,selectedPrinter,...
    selectedNozzle,campaignMode,targetHeight,effectiveArea,targetMass)

    dataT.ID_Number(ID) = ID;
    dataT.PrinterNumber(ID) = selectedPrinter;            
    dataT.STL_Mode(ID) = printerT.STL_Mode{1}(selectedPrinter);
    dataT.PrinterNozzle(ID) = selectedNozzle;
    dataT.NozzleSize(ID) = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
    dataT.FilamentID(ID) = printerT.Filament{1}(selectedNozzle+1,...
        selectedPrinter);
    dataT.FilamentModulus(ID) = printerT.Modulus{1}(selectedNozzle+1,...
        selectedPrinter);     
    dataT.Stress25(ID) = printerT.Stress25{1}(selectedNozzle+1,selectedPrinter);
    dataT.Density(ID) = printerT.Density{1}(selectedNozzle+1,selectedPrinter);
    dataT.Campaign(ID) = campaignMode;
    dataT.TargetHeight(ID) = targetHeight;
    dataT.EffectiveArea(ID) = effectiveArea;
    dataT.TargetMass(ID) = targetMass;
    dataT.ExtrusionMultiplier(ID) = printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter);
    dataT.Campaign(ID) = campaignMode;
     
end