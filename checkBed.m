%Kelsey Snapp
%Kab Lab
%6/17/21
%Takes picture of bed and runs through NN

function status = checkBed(ID,selectedPrinter,testT)

    openGripper()
    img = imageBed(ID,selectedPrinter,'bedEmptyPre', 1,testT); % Do not change 'bedEmptyPre' without changing inside
    [status,~] = applyNN(img,'bedNet.mat');
    
    if strcmp(string(status),'GripperMalfunction')
        openGripper()
        img = imageBed(ID,selectedPrinter,'bedEmptyPre',1); % Do not change 'bedEmptyPre' without changing inside
        [status,~] = applyNN(img,'bedNet.mat')
    end
    
    if contains(string(status),'NotReady')
        
        readyPrinter(selectedPrinter)
        openGripper()
        img = imageBed(ID,selectedPrinter,'bedEmptyPre',1); % Do not change 'bedEmptyPre' without changing inside
        [status,~] = applyNN(img,'bedNet.mat')
    end
    
end