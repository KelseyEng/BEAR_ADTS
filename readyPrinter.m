%Kelsey Snapp
%Kab Lab
%9/16/21
%Moves printer to ready position

function readyPrinter(selectedPrinter)

    fname_gcode = 'preparePrinter.gcode';
    try
        [~,~] = printerStart(selectedPrinter,fname_gcode);
    catch
        msg = ('Unable to prepare Printer. Please check if possible in Octoprint.');
        postSlackMsg(msg)
    end
    pause(10)
end