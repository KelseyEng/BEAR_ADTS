%Kelsey Snapp
%Kab Lab
%7/15/21
% Filters xObs and yObs


function [xObsPrinter,yObsPrinter,idxCombined] = filterObs(xObs,yObs,printerT,selectedPrinter,xMode)
    switch xMode
        case 1
            logModX = xObs(:,7);
            wallThicknessX = xObs(:,6);
            targetMassX = xObs(:,11).*xObs(:,14);
            densityX = xObs(:,13);
        case 2
            logModX = xObs(:,3);
            wallThicknessX = xObs(:,1);
            targetMassX = 2.1;
            densityX = xObs(:,5);
        case 3
            idxCombined = xObs(:,15) > 0;
            xObsPrinter = xObs(idxCombined);
            yObsPrinter = yObs(idxCombined);
            return
        case 301
            idxCombined = ones(size(yObs),'logical');
            xObsPrinter = xObs;
            yObsPrinter = yObs;
            return
    end

    count = 1;
    for selectedNozzle = 0:1
        if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
            logMod = log(printerT.Modulus{1}(selectedNozzle+1,selectedPrinter));
            nozzleSize = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
            targetDensity = printerT.Density{1}(selectedNozzle+1,selectedPrinter);
            if nozzleSize == 0.5
                wallThickness = [0.45;0.7];
            else
                wallThickness = [0.7;1];
            end
            if targetDensity == 0.6
                wallThickness(2) = wallThickness(2) * 2;
            end
            targetMass = printerT.TargetMass{1}(selectedNozzle+1,selectedPrinter);
            idxMod = abs(logModX - logMod) < logMod*.1; %Don't use equality because of rounding error
            idxWallThickness = (wallThicknessX > wallThickness(1) & wallThicknessX < wallThickness(2));
            idxMass = abs(targetMassX - targetMass)/targetMass < 0.05;
            idxDensity = densityX == targetDensity;
            idxCombined(:,count) = idxWallThickness & idxMod & idxMass & idxDensity;
            count = count + 1;
        end
    end
    
    idxCombined = any(idxCombined,2);
    xObsPrinter = xObs(idxCombined,:);
    yObsPrinter = yObs(idxCombined,:);


end