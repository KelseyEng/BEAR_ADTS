%Kelsey Snapp
%Kab Lab
%6/22/21
%Turns off all printers

function turnOffPrinters(printerT)

    fname_gcode = 'TurnOffPrinter.gcode';
    for selectedPrinter = printerT.AvailablePrinters{1}
        try
            [~,~] = printerStart(selectedPrinter,fname_gcode);% send twice with pause
            pause(2)
            [~,~] = printerStart(selectedPrinter,fname_gcode);% send twice with pause
        catch
            msg = ('Unable to Turn Off Printers. Please confirm that they were turned off.');
            postSlackMsg(msg)
        end
    end
                
end