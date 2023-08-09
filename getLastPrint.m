%Kelsey Snapp
%Kab Lab
%2/28/2023
% Gets the time that the last part printed on that printer was sent to
% Printer and turns it into a string


function lastPartDate = getLastPrint(selectedPrinter,dataT)
    
    idx = dataT.PrinterNumber == selectedPrinter;
    
    lastPartDate = max(dataT.TimePrintStarted(idx));
    
    lastPartDate = datetime(lastPartDate,'convertfrom','excel');
    lastPartDate = string(lastPartDate);

end