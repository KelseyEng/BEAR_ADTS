%Kelsey Snapp
%Kab Lab
%11/22/21
% Calculates the ext mult based on prior prints

function extMult = calcTargetExtMult(dataT,selectedPrinter,selectedNozzle,printerT,IgainFil)

    [~,indexCombined] = massBySTL_Mode(dataT,selectedPrinter,selectedNozzle,[311,312],printerT); 
    initialExtMult = printerT.InitialExtMult{1}(selectedNozzle+1,selectedPrinter);
    if ~any(indexCombined)
        extMult = initialExtMult;
    else   
        T = dataT(indexCombined,:);
        MassAdjust = sum((T.TargetMass - T.Mass)./T.TargetMass);
        extMult = initialExtMult *(1+ IgainFil*MassAdjust);
    end

end