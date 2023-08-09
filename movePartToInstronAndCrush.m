%Kelsey Snapp
%Kab Lab
%3/18/21
% Moves part from scale to instron and sends command to other matlab computer to start crushing/video.
%Does not wait for finish.



function instronStatus = movePartToInstronAndCrush(ID,dataT,testT)

    camName = camNameFunction();
    
    %% Move Part to Instron
    partToInstron() 
    
    if dataT.STL_Mode(ID) == 1 || dataT.STL_Mode(ID) == 301
        msg = ('Please confirm that cylinder was moved to instron. Wear eye protection when crushing. Press any key in Matlab to continue');
        musicHelp()
        postSlackMsg(msg,testT)
        pause
    end
    
    picName = strcat('pictures//',sprintf('instron%d.png', ID));
    img = takePicture(camName, picName, 1,2);
    [status,~] = applyNN(img,'instronNet.mat')
    
    if strcmp(string(status),'GripperMalfunction')
        openGripper()
        img = takePicture(camName, picName, 1,2);
        [status,~] = applyNN(img,'instronNet.mat')
    end
    if strcmp(string(status),'Empty')
        weight = readWeightQuick;
        if weight > 0.5
            
            msg = 'No part detected on Instron. Regrabbing from Scale.';
            postSlackMsg(msg)
            
            %Try regrabbing part from scale            
            command = ['python controlUR5.py ','/programs/RG2/moveInstron.urp'];
            protectiveStop = moveUR5AndWait(command);
            
            partToInstron() 
            picName = strcat('pictures//',sprintf('instron%d.png', ID));
            img = takePicture(camName, picName, 1,2);
            [status,~] = applyNN(img,'instronNet.mat')
        end
    end
    
    if ~(strcmp(string(status),'Part') || dataT.STL_Mode(ID) == 1)
        msg = 'No part detected on Instron. If part is not detected in 60 s, it will be cancelled.';
        postSlackMsg(msg,testT)
        musicHelp()
        pause(60)
        img = takePicture(camName, picName, 1, 2);
        [status,~] = applyNN(img,'instronNet.mat')
    end

    command = ['python controlUR5.py ','/programs/RG2/moveInstron.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    command = ['python controlUR5.py ','/programs/RG2/moveP4.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    clearStatus = checkClear();
    if clearStatus == 0
        protectiveStopHelp(testT)
    end
    
    %% Send command to alternate Matlab if Part is on Instron
    if strcmp(string(status),'Part') || dataT.STL_Mode(ID) == 1 || dataT.STL_Mode(ID) == 7 || dataT.STL_Mode(ID) > 300
        if protectiveStop
            protectiveStopHelp()
        else
            musicHelp()
            imwrite(img,'slack.jpg');
            postSlackImg('slack.jpg')
            pause(60)
            sendMatlabInstronTrigger(ID,'')
        end
        instronStatus = 2;
    else    
        instronStatus = 0;
        msg = sprintf('No part detected on Instron. ID%d has been cancelled and may be reprinted at a later time.',ID);
        postSlackMsg(msg,testT)
    end     
    
    
    
end