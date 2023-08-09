%Kelsey Snapp
%Kab Lab
%6/30/23
% Rotates part on instron and sends command to other matlab computer to start crushing/video.
%Does not wait for finish.




function instronStatus = rotateInstron(dataT,ID)

    camName = camNameFunction();
    
    %% Rotate Part on Instron
    command = ['python controlUR5.py ','/programs/RG2/rotateInstron.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    picName = strcat('pictures//',sprintf('instron%d_Side.png', ID));
    img = takePicture(camName, picName, 1,2);
    [status,~] = applyNN(img,'instronNet.mat')
    
    if strcmp(string(status),'GripperMalfunction')
        openGripper()
        img = takePicture(camName, picName, 1,2);
        [status,~] = applyNN(img,'instronNet.mat')
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
            sendMatlabInstronTrigger(ID,'_Side')
        end
        instronStatus = 2;
    else    
        instronStatus = 0;
        msg = sprintf('No part detected on Instron. ID%d has been cancelled and may be reprinted at a later time.',ID);
        postSlackMsg(msg,testT)
    end     
    
end