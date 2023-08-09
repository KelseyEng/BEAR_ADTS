%Kelsey Snapp
%Kab Lab
%3/9/2023
% Reset Bluehill software

function [parseT,instronCountOffset,calculateList] = resetBluehill(parseT,testT,instronCount,instronCountOffset,calculateList)

    msg = 'Bear is ready for Bluehill Software reset: Please see main controller computer for additional instructions.';
    postSlackMsg(msg,testT)
    musicHelp()
    
    % Check if all samples have been processed
    if ~isempty(calculateList)
        disp('Calculate List is not empty. The following IDs are missing Instron data')
        calculateList
        msg = 'Do you want to continue and ignore this point? 1 for yes, 0 for no: ';
        ignorePoint = input(msg);

        while 1
            validInput = checkInputBounds(1,0:1,ignorePoint);
            if validInput
                break
            end
            msg2 = 'Invalid input.\n';
            ignorePoint = input(strcat(msg2,msg));
        end
        
        if ignorePoint == 0
            disp('You have chosen to not continue with the Bluehill reset.')
            parseT.InstronCountReset = 0;
            return
        end
        
    end
        
    calculateList = [];
    disp('Calculate List is cleared')
    
    %Reset instron count offset in matlab
    instronCountOffset = instronCount - 1;
    disp('Instron Count Offset has been updated')
    disp('Please start new Bluehill test. Press any key to continue.')
    pause
    
    %Rename instron folder so that new data doesn't overwrite it.
    folderPath = 'G:/Shared drives/MetamaterialAutocrusher/InstronData/InstronDatabase_BEAR';
    src = [folderPath,'/SampleData_1_Exports'];
    files = dir(folderPath);
    
    runNum = 0;
    for i = 1:size(files,1)
        if contains(files(i).name,'Batch')
            num = str2double(files(i).name(6:end));
            if num > runNum
                runNum = num;
            end
        end
    end
    dst = [folderPath,'/Batch',num2str(runNum+1)];
    
    mkdir(dst)
    movefile(src,dst)
    
    %Reset instron count trigger
    parseT.InstronCountReset = 0;
end