%Kelsey Snapp
%Kab Lab
%5/4/21
% Checks to see if precalibration has been done for the filament loaded
% into selected printer. If not, does precalibration print. If so, stores
% precalibration results

function [availableNozzle,filamentIDT] = checkPrecalibration(selectedPrinter,printerT,filamentIDT,dataT,clbNum)

    availableNozzle = -1;

    for selectedNozzle = 0:1
        if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
            filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
            
            filamentIdx = dataT.FilamentID == filamentID;
            calibrationIdx = dataT.STL_Mode == clbNum;
            massIdx = dataT.Mass > 0;

            calibrationMass = dataT.Mass(filamentIdx & calibrationIdx & massIdx); 
            if ~isempty(calibrationMass)
                calibrationMass = calibrationMass(end);
            end

            if calibrationMass > 0
                filamentIDT.PreCalibrationWeight(filamentID) = calibrationMass;
                writetable(filamentIDT,'FilamentLog.xlsx');
            else
                availableNozzle = selectedNozzle;
                return
            end
        end
    end
end