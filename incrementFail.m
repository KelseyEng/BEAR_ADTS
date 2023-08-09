%Kelsey Snapp
%Kab Lab
%2/22/2022
%Adds to fail count and checks if printer should be disabled

function printerT = incrementFail(printerT,selectedPrinter,testT)

    printerT.FailCount{1}(selectedPrinter) = printerT.FailCount{1}(selectedPrinter) + 1;
    if printerT.FailCount{1}(selectedPrinter) > 2
        printerT.Status{1}(selectedPrinter) = -2.2;
        message = sprintf('Printer %d has failed 3 successive prints. It is disabled.',selectedPrinter);
        postSlackMsg(message,testT)
    end

end