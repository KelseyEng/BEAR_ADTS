%Kelsey Snapp
%Kab Lab
%3/18/21
% Uses octocommand to see if printer is active or not.


function [printerT,output] = checkPrinterStatus(selectedPrinter,printerT,testT,logResult,filamentIDT,dataT)
    output = printerT.Status{1}(selectedPrinter);
    if testT.Printer
        % Get bedTemp
        ID = printerT.ID{1}(selectedPrinter);
        if ID == 0
            bedTarget = 80;
        else
            filamentID = dataT.FilamentID(ID);
            if filamentID == 0
                bedTarget = 80;
            else
                bedTarget = filamentIDT.RemovalTemp(filamentID);
            end
        end
        for i = 1:3 %Check 3 times if not connecting. After that, give up.
            if selectedPrinter == 6
                printerDone = py.BEAR.get_printer_info();
                printerDone = char(printerDone);
                if strcmp(printerDone,'Currently printing!')
                    printerDone = 0;
                    return
                elseif strcmp(printerDone,'Not currently printing...')
                    printerDone = 1;
                else 
                    printerDone = 0;
                    disp('Unable to get status of printer 6.')
                end
                pause(5)
                bedTemp = py.BEAR.get_bed_temp();
                bedTemp = char(bedTemp);
                bedTemp = str2double(bedTemp(28:end));
                status = 0;
            else
                command = ['python2 octocmd',num2str(selectedPrinter) ,' status']; 
                [status,dosmsg] = dos(command); 
            end

            if status == 0
                if ~(selectedPrinter == 6)
                    printerDone = parsePrinterStatus(dosmsg)-2;
                    bedTemp = parseBedTemp(dosmsg);
                end
                if abs(bedTemp - bedTarget) < 5
                    tempReached = 1;
                else
                    tempReached = 0; 
                end
                if printerDone && tempReached
                    output = 3;
                elseif printerDone
                    output = 4;
                end
                break %Break if you successfully get printer Status.
            end
        end        
    else
        output = randi(2)+1;
    end
    
    if logResult && output < 4
        printerT.Status{1}(selectedPrinter) = output;
    end
end