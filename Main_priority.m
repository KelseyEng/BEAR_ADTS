% Matlab Control Code for Single Line Prints
clear all
close all
clc

%load('test.mat')
%load('testBackUp.mat')
%save('test.mat')

%instronCountOffset = instronCount - 1;
%instronCount-instronCountOffset

statusPython = pyenv;
if strcmp(statusPython.Status,'NotLoaded')
    pyenv(Version="C:\Coding\OctoRestBEAR\myenv\Scripts\python.exe")
end
format short g

% printerStatus = zeros(1,5,'int8');-2 means permanently disabled;  -1 means temporarily disabled; 0 means ready to ...
%   print (empty); 1 means assigned print, 2 means printing; 3 means done printing; (part occupying)
% printerPriority = int8(1:5); 
% instronStatus = int8(0);  0 means disabled; 1 means ready to test (empty), 2 means testing; 3 means done testing...
%   (part occupying)
% scaleStatus = int8(0); 0 means disabled; 1 means ready to test (empty), 2 means testing; 3 means done testing...
%   (part occupying)
% gcodeStatus = int8(0); 0 means disabled; 1 means ready to calculate next (empty), 2 means calculating, 3 means ...
%    done calculating;
% printerID; The ID Number of the part currently assigned to the printer.
% scaleID; The ID number of the part currently sitting on the scale.
% instronID; The ID Number of the part currently sitting on the Instron.

%% Testing Mode: Set to 1 for actual runs. 0 turns off features for virtual runs (to test out software, etc)
testT_names = {'STL','Printer','UR','Instron','Scale','Slack','Cam','Printability'};
    testT = array2table(zeros(1,length(testT_names)),'VariableNames',testT_names);
testT.STL = 2;
testT.Printer = 1;
testT.UR = 1;
testT.Instron = 1;
testT.Scale = 1;
testT.Slack = 1;
testT.Camera = 1;
testT.Printability = 1;
testT.Brush = 1;
testT.Remote = 1;


%% Initialization
createFolder('gcode')
createFolder('pictures')
createFolder('STL')
createFolder('videos')
createFolder('INI')
createFolder('Instron')
createFolder('GPRModel')
createFolder('TISC')
createFolder('Modulus')


if testT.Slack 
    conversation = getSlackCommands();
    if isempty(conversation)
        disp('Unable to get conversation history')
        slackTimeStampTemp = 0;
    else
        % Sets time stamp for beginning of campaign so that it will ignore 
        %previous commands
        slackTimeStampTemp = str2double(conversation{1}.ts); 
    end
end




if isfile('test.mat')
    startMessage(testT)
    load('test.mat')
    if exist('robotCam','var')
        clear robotCam
    end

    priorityT.Level{1} = 1;
    if ~isempty(priorityT.Temp{1})
        priorityT.List{1} = priorityT.Temp{1}; 
        priorityT.Temp{1} = [];
    end

    
    if sum(printerT.Status{1} ~= -2) == 0
        msg = 'All printers currently disabled. Enable a printer in slack and then unpause through Matlab';
        postSlackMsg(msg,testT)
        pause
    end
        
else
    disp('Starting New Campaign. Please confirm by pressing any key.')
    pause
    disp('Starting Campaign')
    
    % Initialize variables
    filamentIDT = readtable('FilamentLog.xlsx');
    instronStatus = 1;
    scaleStatus = 1;
    scaleID = 0; 
    instronID = 0;
    storageStatusMat = zeros(27,5); 
    IgainFil = .1; 
    instronCount = 1;
    instronCountOffset = 0;
    calculateList = [];
    instronPath = 'G:\Shared drives\MetamaterialAutocrusher\InstronData\InstronDatabase_BEAR\SampleData_1_Exports\';
    comPath = 'U:\eng_research_kablab\users\ksnapp\ComFolder';
    TISCPath = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/';
    stressThreshLimits = logspace(-4,1,1000);
    temp1 = flip(-4:-5/999:-5);
    temp1(end) = [];
    temp2 = 1:5/999:2;
    temp2(1) = [];
    stressThreshLimits = [10^-5, 10.^temp1, stressThreshLimits, 10.^temp2, 100];
    stressThreshData = stressThreshLimits * 0;
    sigmoidCutoff = .5;

    
    
    %Initialize priority table
    priorityT_names = {'Level','Printer','Instron','List','Temp','Pause'};
    priorityT = table({1},{[7,1:6,8:11]},{[6,5,1,7,4,3,2,8:11]},{[6,5,1,7,4,3,2,8:11]},{[]},{[]},...
        'VariableNames',priorityT_names);
    
    %Initialize printer table
    availablePrinters = 1:6;
    status = initializePrinterStatus(availablePrinters);
    filament = readtable('printerFilamentStatus.xlsx');
    filament = table2array(filament(2:3,2:7));
    nozzle = readtable('printerNozzleStatus.xlsx');
    nozzle = table2array(nozzle(2:3,2:7));
    modulus = generateModulusList(filament,filamentIDT); 
    
    printerT_names = {'AvailablePrinters','PrintPriority','MonitorPriority','Status','ID','STL_Mode','PicCount'...
        'Filament','Nozzle','Modulus','CalibrationStatus','ExtrusionMult','STL_Length',...
        'InitialFilamentMassRatio','TargetFilamentLength','MassCutoff','DecisionPolicy','CleanCount','Stress25',...
        'FailCount','SearchRange','TargetMass','Density','TargetHeight','CapHeight','CapExtMult','NozzleActive','InitialExtMult'};
    printerT = table({availablePrinters},{availablePrinters},{availablePrinters},{status},{zeros(1,6)},{ones(1,6)},...
        {ones(1,6)},{filament},{nozzle},{modulus},{zeros(2,6)},{zeros(2,6)},{zeros(2,6)},{zeros(2,6)},{zeros(2,6)},...
        {ones(2,6)},{ones(1,6)*2},{zeros(1,6)},{zeros(2,6)},{zeros(1,6)},{zeros(2,6)},{zeros(2,6)},{zeros(2,6)},...
        {ones(2,6)},{zeros(2,6)},{ones(2,6)},{ones(2,6) == 1},{ones(2,6)},'VariableNames',printerT_names);
    
    clear availablePrinters status filament nozzle modulus targetLength
    
    %Initialize Data Table
    dataT_names = {'ID_Number','PrinterNumber','PrinterNozzle','TimePrintStarted','TargetMass','Mass',...
        'TimeInstronCrushed','StorageLocation','STL_Mode','ExtrusionMultiplier','STL_Length','InstronTestNumber',...
        'Toughness','SimulatedData','C1T','C2T','C1B','C2B','Twist','Wavelength','Amplitude','STL_LengthRatio',...
        'NozzleSize','FilamentModulus','FilamentID','DecisionPolicy','TargetFilamentLength','FinalFilamentLength',...
        'MassCorrected','Printable','RMSEPre','RMSEPost','aPred','Height','MaxRadius',...
        'WallThickness','Stress25','Stress20','MaxStress20','CriticalStress','CriticalEfficiency','Density',...
        'DensificationStrain','TargetHeight','CapHeight','CapExtMult','WallAngle',...
        'Failed','Campaign','ReboundHeight','EffectiveArea','KSadjusted','MaxD'}; 
    dataTadd = array2table(zeros(5,length(dataT_names)),'VariableNames',dataT_names); 
    dataT = dataTadd;
    
    % Initialize Parse Table
    parseT_names = {'Pause','PauseForDay','SlackMessageLevel','ResetInstronOffset','RemoveScale','TestStored','AvoidInstron','InstronCountReset'};
    parseT = array2table(zeros(1,length(parseT_names)),'VariableNames',parseT_names);
    
    % Initialize Time Table
    timeT_names = {'SaveDataT'};
    timeT = array2table(zeros(1,1),'VariableNames',timeT_names);
    timeT.SaveDataT = exceltime(datetime('now'));
    testSaveNum = 1;

    
    
end


% Initial Python UR5 Connection
global UR5Connection
global arm
UR5Connection = 1;
if UR5Connection == 0
    arm = pythonArmConnection;
end


% Move the UR5 from Home position to ready Position
if testT.UR
    initializeRobot()
end
disp('Moving UR5 to down position')

if testT.Camera
        camName = camNameFunction();
        global robotCam
        openGripper()
        robotCam = webcam(camName);
        robotCam.Focus = 20;
    %     preview(robotCam)
end

if testT.Slack
    slackTimeStamp = slackTimeStampTemp;
    clear slackTimeStampTemp

    [slackTimeStamp,printerT,priorityT,parseT,storageStatusMat,scaleID,scaleStatus,dataT,filamentIDT] = ...
        parseSlack(slackTimeStamp,printerT,priorityT,parseT,dataT,storageStatusMat,filamentIDT,scaleID,instronID,...
        scaleStatus,stressThreshData,stressThreshLimits,testT,sigmoidCutoff);
end


%% Main Loop

while priorityT.Level{1}>0
    anythingChange = 0;
    switch priorityT.List{1}(priorityT.Level{1})
        
        
        case 1 %Select Experiment
            printerPriorityListTemp = printerT.PrintPriority{1};
            for selectedPrinter = printerPriorityListTemp
                if abs(printerT.Status{1}(selectedPrinter) - 0.1) < 0.001
                    ID = find(dataT.ID_Number==0,1);
                    dataT.ID_Number(ID) = ID;
                    printerT.ID{1}(selectedPrinter) = ID;
                    [dataT, stressThreshData] = clearSimulatedData(dataT,selectedPrinter,...
                        stressThreshData); %Clear previous simulated data for printer

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [dataT,dataC,printerT,filamentIDT] = selectExperiment(dataT,dataC,printerT,...
                        IgainFil,filamentIDT,selectedPrinter,ID,stressThreshData,...
                        stressThreshLimits,testT,sigmoidCutoff); 
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                

                    anythingChange = 1;
                    break
                end          
            end
            
        case 2 %Generate STL
            printerPriorityListTemp = printerT.PrintPriority{1};
            for selectedPrinter = printerPriorityListTemp
                ID = printerT.ID{1}(selectedPrinter);
                if printerT.Status{1}(selectedPrinter) == 0.9
                    % Check for STL
                    fnameResponse = strcat(comPath,sprintf('\\STLGenerator\\responseID%d.mat',ID));
                    if exist(fnameResponse,'file')
                                              
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [dataT,printerT,dataC] = mergeState(dataT,printerT,fnameResponse,selectedPrinter,ID,IgainFil,dataC);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                    else
                        continue
                    end      
                end
                
                if printerT.Status{1}(selectedPrinter) == 1
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    dataT.MaxRadius(ID) = generate2DSingleLineSTL(dataT,ID,testT);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    dataT.EffectiveArea(ID) = calcEffArea(dataT.MaxRadius(ID));
                    printerT.Status{1}(selectedPrinter) = 1.1;
                    anythingChange = 1;
                    break
                end
            end
   
        case 3 %Start Print
            printerPriorityListTemp = printerT.PrintPriority{1};
            for selectedPrinter = printerPriorityListTemp
                ID = printerT.ID{1}(selectedPrinter);
                if printerT.Status{1}(selectedPrinter) == 1.1
                    [~,printing] = checkPrinterStatus(selectedPrinter,printerT,testT,0,filamentIDT,dataT);
                    if printing > 2 && ID
                        displayMessage2(selectedPrinter,ID,testT)
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        [printerT, dataT] = startPrint(dataT,dataC,selectedPrinter,ID,testT, printerT,filamentIDT); 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        if printerT.Status{1}(selectedPrinter) == 2
                            dataT.TimePrintStarted(ID) = exceltime(datetime); %print start time in excel time
                            if ~any(printerT.STL_Mode{1}(selectedPrinter) == [8])
                                printerT.PrintPriority{1} = shiftToEnd(printerT.PrintPriority{1},selectedPrinter);
                            end
                            anythingChange = 1;
                            break
                        elseif printerT.Status{1}(selectedPrinter) == 1 % Printer Connection Failure
                            printerT.PrintPriority{1} = shiftToEnd(printerT.PrintPriority{1},selectedPrinter);
                            anythingChange = 1;
                            break
                        end
                    end
                end
            end

            
        case 4 %Weigh Part
            if parseT.RemoveScale == 1
                if scaleStatus ==3
                    % Move part to storage
%                     [storageNumber,storageStatusMat,dataT] = checkAvailableStorage(dataT,scaleID,storageStatusMat,6);
%                     storePart(storageNumber,testT,2)
%                     postSlackMsg('Part on Scale Stored.',testT)
%                     selectedPrinter = dataT.PrinterNumber(scaleID);
%                     if printerT.Status{1}(selectedPrinter) == 4 || printerT.Status{1}(selectedPrinter) == 0
%                         printerT.Status{1}(selectedPrinter) = 4.1;
%                     end
                    disp('Store Scale temporarily disabled')
                else
                    postSlackMsg('No part on scale to store.',testT)
                end
                scaleStatus = 1;
                parseT.RemoveScale = 0;
            end
            if scaleStatus == 1
                if parseT.TestStored > 0
                    selectedPrinter = 0;
                    scaleID = parseT.TestStored;
                    %%%%%%%%%%%%%%%%%%
                    [dataT,scaleStatus,filamentIDT] = movePartToScaleAndWeigh(selectedPrinter,dataT,printerT,...
                                testT,filamentIDT,scaleID);
                    %%%%%%%%%%%%%%%%%%
                    parseT.TestStored = 0;
                    if scaleStatus == -1 %Part Sideways
                        parseT.RemoveScale = 1;
                        scaleStatus = 3;
                    elseif scaleStatus < 1
                        scaleStatus = 1;
                    end
                else
                    printerPriorityListTemp = printerT.PrintPriority{1};
                    for selectedPrinter = printerPriorityListTemp
                        if printerT.Status{1}(selectedPrinter) == 2
                            [printerT,~] = checkPrinterStatus(selectedPrinter,printerT,testT,1,filamentIDT,dataT);
                        end
                        if printerT.Status{1}(selectedPrinter) == 3
                            displayMessage3(selectedPrinter,printerT,parseT,testT)
                            scaleID = printerT.ID{1}(selectedPrinter);

                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            [dataT,scaleStatus,filamentIDT] = movePartToScaleAndWeigh(selectedPrinter,dataT,printerT,...
                                testT,filamentIDT,scaleID);
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            if scaleStatus == -1 %Part Sideways
                                parseT.RemoveScale = 1;
                                scaleStatus = 3;
                            end
                            if scaleStatus == 3
                                if any(printerT.STL_Mode{1}(selectedPrinter) == [2,3,12,13,302,303,312])
                                    printerT.Status{1}(selectedPrinter) = 4.1;
                                elseif printerT.STL_Mode{1}(selectedPrinter) == 6
                                    printerT.Status{1}(selectedPrinter) = 4.1;
                                    parseT.RemoveScale = 1;
                                else
                                    printerT.Status{1}(selectedPrinter) = 4;
                                end
                                printerT.ID{1}(selectedPrinter) = 0;
                                printerT.FailCount{1}(selectedPrinter) = 0;
                            elseif scaleStatus == 1
                                message = sprintf('ID %d not detected. Resetting Printer %d.',...
                                    printerT.ID{1}(selectedPrinter),selectedPrinter);
                                postSlackMsg(message,testT)
                                printerT.Status{1}(selectedPrinter) = 4.1;
                                printerT = incrementFail(printerT,selectedPrinter,testT);
                            elseif scaleStatus == -8 %Part removed and printer ready for next print
                                printerT.Status{1}(selectedPrinter) = 4.1;
                                scaleStatus = 1;
                            elseif scaleStatus == -9 %Protective stop during part removal
                                printerT.Status{1}(selectedPrinter) = -2.3; 
                                scaleStatus = 1;
                            end
                            anythingChange = 1;
                            break
                        end
                    end
                end
            end
            
            
        case 5 %Crush Part
            if instronStatus < 2 ...
                    && scaleStatus == 3 ...
                    && testT.Instron < 2 ...
                    && parseT.RemoveScale == 0 ...
                    && parseT.AvoidInstron == 0 ...
                    && parseT.InstronCountReset == 0
                
                if instronStatus == 0 && testT.UR
                    brushInstron()
                end
                if instronCount-instronCountOffset > 1000
                    parseT.Pause = 1;
                    postSlackMsg('Instron Count Exceeded. Bear will shut down. Please open new test file in Bluehill.',testT)
                else
                    displayMessage4(scaleID,instronCount-instronCountOffset)
                    if testT.Instron
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        instronStatus = movePartToInstronAndCrush(scaleID,dataT,testT); 
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                    else
                        instronStatus = 2; %Crushing
                    end
                    if instronStatus == 2
                        instronID = scaleID;
                        dataT.TimeInstronCrushed(instronID) = exceltime(datetime); %print start time in excel time
                        dataT.InstronTestNumber(instronID) = instronCount;
                        instronCount = instronCount + 1;
                    else
                        selectedPrinter = dataT.PrinterNumber(scaleID);
                        printerT.Status{1}(selectedPrinter) = 4.1; %Set printer to ready so it can print next print.
                        brushInstron()
                        dataT.Failed(ID) = 1;
                    end
                    scaleID = 0;
                    scaleStatus = 1;
                    anythingChange = 1;
                end
            end

            
        case 6 %Remove part from Instron
            
            if instronStatus == 2
                instronStatus = checkMatlabInstronStatus(testT);
            end

            if instronStatus == 3 ...
                    && testT.Instron < 2 ...
                    && parseT.AvoidInstron == 0
                
                displayMessage5(instronID)
                if testT.Instron
                    
                    % Rotate part for side testing for Campaign 3 (Squiggly
                    % Print)
                    if dataT.Campaign(instronID) == 3
                        dataC_Row = find(dataC{3}.ID == instronID,1);
                        if dataC{3}.InstronTestNumber(dataC_Row) == 0
                            if ~isempty(dataC_Row)
                                instronStatus = rotateInstron(dataT,instronID);
                                if instronStatus == 2
                                    dataC{3}.InstronTestNumber(dataC_Row) = instronCount;
                                    instronCount = instronCount + 1;
                                    anythingChange = 1;
                                    continue
                                end
                            end
                        end
                    end
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    [storageNumber,storageStatusMat,dataT] = checkAvailableStorage(dataT,instronID,storageStatusMat,0);
                    storePart(storageNumber,testT,1) 
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
                end
                calculateList = [calculateList,instronID];
                instronID = 0;
                instronStatus = 0;
                anythingChange = 1;
            end         
            
        case 7 % Get Instron File & calculate Metric
            
            calculateListTemp = calculateList;
            for ID = calculateListTemp
                selectedPrinter = dataT.PrinterNumber(ID);
                if testT.UR
                    instronTestNumber = dataT.InstronTestNumber(ID)-instronCountOffset;
                    fnameClipped = sprintf('SampleData_1_%d.csv',instronTestNumber);
                    fnameSrc = strcat(instronPath,fnameClipped);
                    if isfile(fnameSrc)
                        fnameDst = sprintf('Instron\\ID%d.csv',ID);
                        fnameDst2 = sprintf('G:/My Drive/BEARData//Instron/ID%d.csv',ID);
                        try
                            copyfile(fnameSrc,fnameDst)
                            try
                                copyfile(fnameSrc,fnameDst2)
                            end
                            pause(.5)
                            FDT = csvread(fnameDst,3,0);
                            FDT(1,:) = [];
                            if size(FDT,1) < 10
                                if printerT.Status{1}(selectedPrinter) == 4 || printerT.Status{1}(selectedPrinter) == 0
                                    printerT.Status{1}(selectedPrinter) = printerT.Status{1}(selectedPrinter)+.1;
                                end
                            
                                index = find(calculateList==ID);
                                calculateList(index) = [];
                                anythingChange = 1;
                                continue
                            end
                            [dataT,printerT,filamentIDT,stressThreshData,dataC] = processData(FDT,dataT,...
                                testT,ID,filamentIDT,printerT,stressThreshData,stressThreshLimits,dataC);
                            
                            
                            
                            % Move data for campaign 3
                            if dataT.Campaign(ID) == 3
                                dataC = processSideTest(dataT,dataC,ID,instronCountOffset,instronPath,testT);
                                moveC3Data(dataT,dataC,ID,fnameSrc,filamentIDT)
                            end
                            
                            if printerT.Status{1}(selectedPrinter) == 4 || printerT.Status{1}(selectedPrinter) == 0
                                printerT.Status{1}(selectedPrinter) = printerT.Status{1}(selectedPrinter)+.1;
                            end
                              
                            index = find(calculateList==ID);
                            calculateList(index) = [];
                            % Save test.mat to google drive
                            fname = 'G:/My Drive/BEARData/test.mat';
                            save(fname)
                            anythingChange = 1;
                        catch e
                            disp('Instron File Failed to Copy Instron File')
                            fprintf(1,'The identifier was:\n%s',e.identifier);
                            fprintf(1,'There was an error! The message was:\n%s',e.message);
                            if printerT.Status{1}(selectedPrinter) == 4 || printerT.Status{1}(selectedPrinter) == 0
                                printerT.Status{1}(selectedPrinter) = printerT.Status{1}(selectedPrinter)+.1;
                            end
                        end
                    end
                else
                    % Enter Simulate Data for testing purposes
                    T = dataT(ID,:);
                    xObs = [T.C1T,T.C2T,T.C1B,T.C2B,T.Twist,T.WallThickness,log(T.FilamentModulus),T.Wavelength,T.Amplitude,...
                        T.STL_LengthRatio,T.TargetMass];
                    % Create Random Weights if needed
                    if ~exist('simWeights','Var')
                        simWeights = rand(3,length(xObs));
                    end
                    dataT.Toughness(ID) = sum(xObs.*simWeights(1,:));
                    dataT.aPred(ID) = sum(xObs.*simWeights(2,:)); % g
                    dataT.Height(ID) = sum(xObs.*simWeights(3,:)); %mm
                    stressThreshData(ID,:) = rand(1,1000)*xObs(7);
                    dataT = calcCriticalPoint(dataT,stressThreshData,stressThreshLimits,ID,testT);
                    dataT.SimulatedData(ID) = 0;
                    index = find(calculateList==ID);
                    calculateList(index) = [];
                    anythingChange = 1;
                    printerT.Status{1}(selectedPrinter) = 0;

                        

                    if dataT.STL_Mode(ID) == 1
                        filamentID = dataT.FilamentID(ID);
                        filamentIDT.CylinderModulus(filamentID) = rand(1)*245 + 5;
                        selectedPrinter = dataT.PrinterNumber(ID);
                        selectedNozzle = dataT.PrinterNozzle(ID);
                        printerT.Modulus{1}(selectedNozzle+1,selectedPrinter) = ...
                            filamentIDT.CylinderModulus(filamentID);
                        writetable(filamentIDT,'FilamentLog.xlsx');
                    end
                end
            end
            
            % Reset Bluehill software
            if parseT.InstronCountReset == 1 ...
                    && instronStatus < 2
                
                [parseT,instronCountOffset,calculateList] = resetBluehill(parseT,testT,instronCount,instronCountOffset,calculateList);
                
            end
            
        case 8  %Clean Instron
            if instronStatus == 0 ...
                    && testT.UR ...
                    && testT.Instron < 2 ...
                    && parseT.AvoidInstron == 0
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                brushInstron()
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                instronStatus = 1;
            end
            
        case 9 %Clean Print Bed
            printerPriorityListTemp = printerT.PrintPriority{1};
            for selectedPrinter = printerPriorityListTemp
                if printerT.Status{1}(selectedPrinter) == 4 || printerT.Status{1}(selectedPrinter) == 4.1
                    if testT.UR
                        picCount = printerT.PicCount{1}(selectedPrinter);
                        printerT.PicCount{1}(selectedPrinter) = picCount + 1;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        status = checkBed(picCount,selectedPrinter,testT)
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        if contains(string(status),'Dirty')
                            printerT = scrapePrinter(selectedPrinter,printerT);
                            status = checkBed(picCount + 1,selectedPrinter,testT)
                            printerT.PicCount{1}(selectedPrinter) = picCount + 2;
                        end
                        if contains(string(status),'Clean')
                            printerT.Status{1}(selectedPrinter) = printerT.Status{1}(selectedPrinter) - 4;
                            printerT.CleanCount{1}(selectedPrinter) = 0;
                        else
                            printerT.CleanCount{1}(selectedPrinter) = printerT.CleanCount{1}(selectedPrinter) + 1;
                            printerT.PrintPriority{1} = shiftToEnd(printerT.PrintPriority{1},selectedPrinter);
                            if printerT.CleanCount{1}(selectedPrinter) > 9
                                printerT.Status{1}(selectedPrinter) = -2.1;
                                msg = sprintf('Bed not clean. Printer %d disabled.',selectedPrinter);
                                postSlackMsg(msg,testT)
                            end
                        end
                    end
                    anythingChange = 1;
                    break
                end
            end
                                     
        otherwise
            anythingChange = 1.1;
            disp('No current tasks. Waiting for tasks to become available.')
            pause(30)
    end

    
    %% End of loop actions
    
    if anythingChange > 0
        priorityT.Level{1} = 0;
        
         %Check Slack
        if testT.Slack
            [slackTimeStamp,printerT,priorityT,parseT,storageStatusMat,scaleID,scaleStatus,dataT, filamentIDT,anythingChange] = ...
                parseSlack(slackTimeStamp,printerT,priorityT,parseT,dataT,storageStatusMat,filamentIDT,scaleID,...
                instronID,scaleStatus,stressThreshData,stressThreshLimits,testT,anythingChange);
        end

        %Other actions

        if parseT.Pause
            priorityT.Level{1} = -1;
            parseT.Pause = 0;
        end

        if parseT.PauseForDay
            printerState = printerT.Status{1} >= 4 | printerT.Status{1} < 2;
            if sum(instronID + scaleID + printerState) == 0 && isempty(calculateList) 
                priorityT.Level{1} = -1;
                parseT.PauseForDay = 0;
                if testT.Printer
                    turnOffPrinters(printerT)
                end
            end
        end

        if parseT.ResetInstronOffset
            instronCountOffset = instronCount-1;
            parseT.ResetInstronOffset = 0;
        end


        if sum(fix(printerT.Status{1}) ~= -2) == 0
            msg = 'All printers are currently disabled. BEAR will shut down until a human can help.';
            postSlackMsg(msg,testT)
            priorityT.Level{1} = -1;
            if testT.Printer
                turnOffPrinters(printerT)
            end
        end


        if dataT.ID_Number(end)>0
            if size(dataT,2) ~= size(dataTadd,2)
                dataTadd = array2table(zeros(5,length(dataT_names)),'VariableNames',dataT_names); 
            end            
            dataT = [dataT;dataTadd]; %Extend Data Table when necessary
        end

        % Check timeT variables
        % Save test.mat every hour to G drive
        if exceltime(datetime('now')) - timeT.SaveDataT > 1/24
            try
                sName = sprintf('G:/My Drive/BEARData/testmats/test%d.mat',testSaveNum);
                save(sName)
                testSaveNum = testSaveNum + 1;
                timeT.SaveDataT = exceltime(datetime('now'));
                disp('Test.mat saved to G Drive.')
            catch
                msg = 'Warning: Cannot save mat of workspace to G:Drive. Check connection.';
                postSlackMsg(msg,testT)
            end
        end
        
        if anythingChange == 1
            if toggle == 1
                sName = 'test.mat';
                toggle = 0;
            else
                sName = 'testBackUp.mat';
                toggle = 1;
            end
            try
                save(sName)
            catch
                try
                    save('test1.mat')
                    msg = 'Warning: Cannot save mat of workspace. Check file.';
                    postSlackMsg(msg,testT)
                catch
                    msg = 'Warning: Cannot save back-up mat of workspace. Check file immediately!';
                    postSlackMsg(msg,testT)
                    pause
                end
            end
        end
    end
    
    priorityT.Level{1} = priorityT.Level{1} + 1;
    
end   

%% End Procedure

if testT.UR
    homeRobot()
end

clear robotCam


try
    save('test.mat')
catch
    try
        save('test1.mat')
        msg = 'Warning: Cannot save mat of workspace. Check file.';
        postSlackMsg(msg,testT)
    catch
        msg = 'Warning: Cannot save back-up mat of workspace. Check file immediately!';
        postSlackMsg(msg,testT)
        pause
    end
end


writetable(dataT,'data.xlsx')
saveStorage(storageStatusMat,filamentIDT,dataT) 

disp('Campaign Done')



% clear all
close all
