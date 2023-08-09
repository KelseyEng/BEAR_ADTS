%Kelsey Snapp
%Kab Lab
%3/18/21
%Looks for available storage location and updates storageStatus

function [storageNumber,storageStatus,dataT] = checkAvailableStorage(dataT,ID,storageStatus,printerID)

    if printerID == 0
        printerID = dataT.PrinterNumber(ID);
    end
    
    if dataT.STL_Mode(ID) == 7
        storageNumber = 27;
    elseif dataT.STL_Mode(ID) == 6
        storageNumber = 14;
    else       
        storageNumber = find(storageStatus(:,printerID)==0,1);
        if isempty(storageNumber)
            storageNumber = 1000;
        else
            storageStatus(storageNumber,printerID) = ID;
        end
    end
    dataT.StorageLocation(ID) = storageNumber;
end