%Kelsey Snapp
%Kab Lab
%5/6/21
% Saves all of the printer data to dataT

function dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,selectedNozzle,...
    wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,targetHeight,capHeight,capExtMult,campaignMode,PRE,POST)

    if PRE
        dataT.ID_Number(ID) = ID;
        dataT.PrinterNumber(ID) = selectedPrinter;            
        dataT.DecisionPolicy(ID) = printerT.DecisionPolicy{1}(selectedPrinter);
        dataT.STL_Mode(ID) = printerT.STL_Mode{1}(selectedPrinter);
    end
    
    if POST
        dataT.STL_Length(ID) = STL_Length;
        dataT.TargetFilamentLength(ID) = printerT.TargetFilamentLength{1}(selectedNozzle+1,selectedPrinter);
        dataT.C1T(ID) = C1T;
        dataT.C2T(ID) = C2T;
        dataT.C1B(ID) = C1B;
        dataT.C2B(ID) = C2B;
        dataT.Twist(ID) = twist;
        dataT.Wavelength(ID) = wavelength;
        dataT.Amplitude(ID) = amplitude;
        dataT.PrinterNozzle(ID) = selectedNozzle;
        dataT.NozzleSize(ID) = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
        dataT.FilamentID(ID) = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
        dataT.FilamentModulus(ID) = printerT.Modulus{1}(selectedNozzle+1,selectedPrinter);     
        dataT.WallThickness(ID) = wallThickness;
        dataT.TargetMass(ID) = targetMass;
        dataT.Stress25(ID) = printerT.Stress25{1}(selectedNozzle+1,selectedPrinter);
        dataT.Density(ID) = printerT.Density{1}(selectedNozzle+1,selectedPrinter);
        dataT.TargetHeight(ID) = targetHeight;
        dataT.CapHeight(ID) = capHeight;
        dataT.CapExtMult(ID) = capExtMult;
        dataT.ExtrusionMultiplier(ID) = printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter);
        dataT.WallAngle(ID) = wallAngle;
        dataT.Campaign(ID) = campaignMode;
        
        %%Calculate STL_LengthRatio
        STL_LengthRatio = calcSTL_LengthRatio(STL_Length,wallAngle,targetHeight);
        dataT.STL_LengthRatio(ID) = STL_LengthRatio;
    end                
end