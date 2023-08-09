%Main_MaintenanceMode


clear all
close all
clc

createFolder('gcode')
createFolder('pictures')
createFolder('STL')
createFolder('videos')
createFolder('INI')
createFolder('Instron')
createFolder('GPRModel')
createFolder('TISC')
createFolder('Modulus')

load('test.mat')

camName = camNameFunction();
global robotCam
openGripper()
robotCam = webcam(camName);

conversation = getSlackCommands();
slackTimeStamp = str2num(conversation{1}.ts); % Sets time stamp for beginning of campaign so that it will ignore 
                                                    %previous commands

parseT.Pause = 0;

postSlackMsg('Maintenance Mode Activated: Use Bear: Pause command to exit.',testT)

while parseT.Pause == 0
    
    pause(5)

    [slackTimeStamp,printerT,priorityT,parseT,storageStatusMat,scaleID,scaleStatus,dataT, filamentIDT] = ...
        parseSlack(slackTimeStamp,printerT,priorityT,parseT,dataT,storageStatusMat,filamentIDT,scaleID,instronID,...
        scaleStatus,stressThreshData,stressThreshLimits,testT,sigmoidCutoff);
     
end

parseT.Pause = 0;

postSlackMsg('Maintenance Mode Deactivated',testT)

clear robotCam

save('test.mat')
