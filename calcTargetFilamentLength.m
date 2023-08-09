%Kelsey Snapp
%Kab Lab
%11/22/21
% Calculates the target filament length based on target mass and calculated
% filament to mass ratio

function targetFilamentLength = calcTargetFilamentLength(dataT,selectedPrinter,selectedNozzle,printerT,targetMass,IgainFil)

    [~,indexCombined] = massBySTL_Mode(dataT,selectedPrinter,selectedNozzle,[6,8,11,12],printerT); 
    initialFilamentMassRatio = printerT.InitialFilamentMassRatio{1}(selectedNozzle+1,selectedPrinter);
    if ~any(indexCombined)
        filamentMassRatio = initialFilamentMassRatio;
    else
        filamentMassRatio = calcFilamentMassRatio(dataT(indexCombined,:),initialFilamentMassRatio,IgainFil);
    end
    targetFilamentLength = targetMass * filamentMassRatio;

end