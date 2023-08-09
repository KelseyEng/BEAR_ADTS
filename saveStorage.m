%Kelsey Snapp
%Kab Lab
%6/10/21
%Saves the storage mat to xlsx and then posts to slack.


function saveStorage(storageStatusMat,filamentIDT,dataT)


    totalLength = sum(sum(storageStatusMat));
    outputString = strings(totalLength+1,4);
    outputString(1,:) = {'Cylinder','ID','Color','Type'};
    count = 2;
    for selectedPrinter = 1:size(storageStatusMat,1)
        for column = 1:size(storageStatusMat,2)
            if storageStatusMat(selectedPrinter,column)    
                ID = storageStatusMat(selectedPrinter,column);
                if ID
                    outputString(count,1) = selectedPrinter;
                    outputString(count,2) = ID;
                    filamentID = dataT.FilamentID(ID);
                    outputString(count,3) = filamentIDT.Color{filamentID};
                    outputString(count,4) = filamentIDT.TypeOfFilament{filamentID};
                    count = count + 1;
                end
            end
        end
    end
    fname = 'savedStorage.xlsx';
    xlswrite(fname,outputString)
    postSlackImg(fname)
    delete(fname)
    
end