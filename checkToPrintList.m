
% KAB Lab
% Kelsey Snapp
% 4/8/22
% Checks if parts in to print list were succesfully printed. If not, it
% tries again. Otherwise, declares them complete. This should be run after
% the researcher reviews parts for orientation, etc.


function checkToPrintList(dataT,testT)
    %Load To Print Table
    toPrintFname = 'ToPrintList.xlsx';
    toPrintTable = readtable(toPrintFname);
    
    count = 0;
    % Check pending prints to see if successful
    for rowNum = 1:size(toPrintTable,1)
        if toPrintTable.Status(rowNum) == 1
            ID = toPrintTable.CurrentBearID(rowNum);
            if isnan(ID) || ID < 1
                continue
            end
            if dataT.Printable(ID) == -1 || dataT.Toughness(ID) > 0
                toPrintTable.Status(rowNum) = 2;
            else
                toPrintTable.Status(rowNum) = 0;
                count = count + 1;
            end
        end
    end 
    
    %Save updated table back to file
    writetable(toPrintTable,toPrintFname)
    msg = sprintf('%d parts failed and can be reprinted.',count);
    postSlackMsg(msg,testT)
end