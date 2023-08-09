%Kelsey Snapp
%Kab Lab
%3/31/21

function displayMessage3(selectedPrinter,printerT,parseT,testT)
    ID = printerT.ID{1}(selectedPrinter);
    msg = sprintf('Weighing part %d from printer %d\n', ID, selectedPrinter);
    
%     if parseT.SlackMessageLevel >0
%         postSlackMsg(msg,testT)
%     else
        disp(msg)
%     end
end