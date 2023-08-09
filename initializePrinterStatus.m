%Kelsey Snapp
%Kab Lab
%4/1/21
% Initialized the printer status based on available printers

function printerStatus = initializePrinterStatus(availablePrinters)

    printerStatus = zeros(1,5)-2;
    printerStatus(availablePrinters)=0.1;

end