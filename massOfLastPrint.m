%Kelsey Snapp
%Kab Lab
%3/24/21
% Gets the mass of the last print assigned to printer. Will get zero mass
% if not yet weighed

function [mass,index] = massOfLastPrint(dataT,selectedNozzle,selectedPrinter)

    indexNozzle = sum(dataT.PrinterNozzle==selectedNozzle,2); %Summing allows you to check for multiple Nozzles
    indexPrinter = sum(dataT.PrinterNumber == selectedPrinter,2); %Summing allows you to check for multiple Printers
    mass = dataT.Mass(indexNozzle & indexPrinter);
    if isempty(mass)
        mass = 0;
    else
        mass(mass <= 0) = [];
        mass = mass(end);
    end
    
    index = dataT.ID_Number(indexNozzle & indexPrinter);
    if isempty(index)
        index = 0;
    else
        index = index(end);
    end

end