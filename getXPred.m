%Kelsey Snapp
%Kab Lab
%3/9/22
% Generates xPred Samples

function [xPred,modKey] = getXPred(printerT,selectedPrinter,DPS,targetPoint,iterLHS)


    xPred = [];
    modKey = [];
    for selectedNozzle = 0:1
        if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
            switch DPS.campaignMode
                case 3
                    temp = getSpaceSquiggly(DPS,iterLHS);
                    xPred = [xPred;temp];
                otherwise
                    targetMass = printerT.TargetMass{1}(selectedNozzle+1,selectedPrinter);
                    nozzle = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
                    modulus = printerT.Modulus{1}(selectedNozzle+1,selectedPrinter);
                    stress25 = printerT.Stress25{1}(selectedNozzle+1,selectedPrinter);
                    density = printerT.Density{1}(selectedNozzle+1,selectedPrinter);
                    targetHeight = printerT.TargetHeight{1}(selectedNozzle+1,selectedPrinter);
                    capHeight = printerT.CapHeight{1}(selectedNozzle+1,selectedPrinter);
                    temp = getSpaceTISC(nozzle,log(modulus),log(stress25),targetMass,DPS,targetPoint,density,...
                        targetHeight,capHeight,iterLHS);
                    xPred = [xPred;temp];
                    modKey = [modKey,ones(size(temp,1),1)*modulus];
            end
                    
        end
    end
    
    
end