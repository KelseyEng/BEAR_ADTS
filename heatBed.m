%Kelsey Snapp
%Kab Lab
%7/21/23
%Moves part from printer to Scale and records weight


function status = heatBed(selectedPrinter,targetTemp)

    if targetTemp == 100
        [status,msg] = printerStart(selectedPrinter,'heatBed.gcode');
    elseif targetTemp == 0
        [status,msg] = printerStart(selectedPrinter,'coolBed.gcode');
    end

end