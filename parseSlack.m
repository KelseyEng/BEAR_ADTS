%Kelsey Snapp
%Kab Lab
%5/11/21
%Reads Slack commands and acts on them.


function [slackTimeStamp,printerT,priorityT,parseT,storageStatusMat,scaleID,scaleStatus,dataT,filamentIDT,anythingChange] = ...
    parseSlack(slackTimeStamp,printerT,priorityT,parseT,dataT,storageStatusMat,filamentIDT,scaleID,instronID,...
    scaleStatus,stressThreshData,stressThreshLimits,testT,anythingChange)

    conversation = getSlackCommands();
    if isempty(conversation)
        disp('Unable to get conversation history')
        return
    end
    msgCount = 1;
    while str2num(conversation{msgCount}.ts) > slackTimeStamp % Find the last message recieved
        msgCount = msgCount + 1;
    end
    slackTimeStamp = str2num(conversation{1}.ts);  
    
    try
    
        msgCount = msgCount-1; %Exclude last message recieved
        for i = msgCount:-1:1 %Loop through them from oldest to newest
            text = conversation{i}.text; 
            if length(text)>5
            text = lower(text);
            text = strrep(text,' ','');
                if strcmp('bear:',text(1:5))
                    disp(text)
                    indexColon = strfind(text,':');
                    indexColon(end+1) = length(text)+1;
                    subText = cell(1,length(indexColon)-1);
                    for j = 1:(length(indexColon)-1)
                        subText{j} = text((indexColon(j)+1):(indexColon(j+1)-1));
                    end
                    subText(cellfun('isempty',subText))=[];
                    anythingChange = 1;
                    switch subText{1}
                        case 'quickpause'
                            priorityT.Pause{1} = priorityT.List{1};
                            priorityT.List{1} = 100;
                            priorityT.Level{1} = 0;
                            command = ['python controlUR5.py ','/programs/RG2/moveInstron.urp'];
                            protectiveStop = moveUR5AndWait(command);
                            msg = 'Note: This is a quick pause. Matlab is still running. Use Command "bear:resume" to continue.';
                            postSlackMsg(msg,testT)

                        case 'resume'
                            if priorityT.List{1} == 101
                                command = 'python controlUR5.py /programs/helmetpads/switchEndEffectorReturn.urp';
                                protectiveStop = moveUR5AndWait(command);
                                
                                initializeRobot()
                            end
                            priorityT.List{1} = priorityT.Pause{1};
                            priorityT.Pause{1} = [];
                            postSlackMsg('Campaign Resumed',testT)

                        case 'pause'
                            parseT.Pause = 1;
                            postSlackMsg('Matlab will stop.',testT)

                        case 'pauseforday'
                            priorityT.Temp{1} = priorityT.List{1};
                            priorityT.List{1}(priorityT.List{1} == 1 | priorityT.List{1} == 2) = [];
                            parseT.PauseForDay = 1;
                            msg = 'BEAR will finish testing all prints that have started, but will not start any more prints for the day.';
                            postSlackMsg(msg,testT)

                        case 'disableprinter'
                            if length(subText)<2
                                msg = 'Insufficient command for disabling printer. Please enter printer value after colon.';
                            else
                                selectedPrinter = str2double(subText{2});
                                printerT.Status{1}(selectedPrinter) = -2.4;
                                msg = sprintf('Printer %d disabled\n',selectedPrinter);
                            end
                            postSlackMsg(msg,testT)

                        case 'enableprinter'
                            if length(subText)<3
                                msg = 'Insufficient command for enabling printer. Please select resume or reset method.';
                            else
                                selectedPrinter = str2double(subText{2});
                                enableMethod = subText{3};
                                switch enableMethod
                                    case 'resume'
                                        printerT.Status{1}(selectedPrinter) = 2;
                                        msg = sprintf('Printer %d enabled. Resuming print.\n',selectedPrinter);
                                    case 'reset'
                                        printerT.Status{1}(selectedPrinter) = 4.1;
                                        printerT.ID{1}(selectedPrinter) = 0;
                                        printerT.FailCount{1}(selectedPrinter) = 0;
                                        msg = sprintf('Printer %d enabled. Resetting printer.\n',selectedPrinter);
                                    otherwise
                                        msg = 'Enable Method not recognized. Please select between resume or reset.';
                                end
                            end                      
                            postSlackMsg(msg,testT)

                        case 'setinstronpriority'
                            priorityT.List{1} = priorityT.Instron{1};
                            postSlackMsg('Priority Instron Set',testT)

                        case 'setprinterpriority'
                            priorityT.List{1} = priorityT.Printer{1};
                            postSlackMsg('Priority Printer Set',testT)

                        case 'disablenozzle'
                            selectedPrinter = str2double(subText{2});
                            selectedNozzle = str2double(subText{3});
                            printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter) = 0;   
                            msg = sprintf('Nozzle %d on printer %d is disabled.',selectedNozzle,selectedPrinter);
                            postSlackMsg(msg,testT)

                        case 'enablenozzle'
                            selectedPrinter = str2double(subText{2});
                            selectedNozzle = str2double(subText{3});
                            
                            printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter) = 1;                         
                            printerT.STL_Mode{1}(selectedPrinter) = 1; %Set STL_Mode to go through checklist

                            msg = sprintf('Nozzle %d on printer %d is enabled.',selectedNozzle,selectedPrinter);
                            postSlackMsg(msg,testT)

                        case 'help'
                            postSlackImg('CurrentBearCommands.docx')

                        case 'status'
                            numberOfPrints = sum(dataT.Toughness>0.01);
                            topPerformer = max(dataT.Toughness(dataT.STL_Mode==10));
                            msg = sprintf('%d prints have been tested. The top performer is %.02f J.',numberOfPrints,topPerformer);
                            postSlackMsg(msg,testT)
                            
                        case 'clearstorage'
                            selectedPrinter = str2double(subText{2});
                            if selectedPrinter == 0
                                storageStatusMat = storageStatusMat*0;
                            else
                                storageStatusMat(:,selectedPrinter) = 0;
                            end
                            postSlackMsg('Storage matrix cleared.',testT)
                            
                        case 'savestorage'
                            saveStorage(storageStatusMat,filamentIDT,dataT)                            
                            
                        case 'filamentstatus'
                            filamentUsed = zeros(size(printerT.Filament{1}));
                            outputString = strings(numel(printerT.Filament{1})+1,5);
                            outputString(1,:) = {'Printer','Nozzle','Type','Color','Mass Used'};
                            count = 2;
                            for selectedPrinter = 1:5
                                for selectedNozzle = 0:1
                                    filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                        dataTemp = dataT(dataT.FilamentID == filamentID,:);
                                        outputString(count,1) = selectedPrinter;
                                        outputString(count,2) = selectedNozzle;
                                        outputString(count,3) = filamentIDT.TypeOfFilament{filamentID};
                                        outputString(count,4) = filamentIDT.Color{filamentID};
                                        outputString(count,5) = sum(dataTemp.Mass)*1.1;
                                    end
                                    count = count + 1;
                                end
                            end
                            fname = 'FilamentUsed.xlsx';
                            if exist(fname, 'file')
                                delete(fname)
                            end
                            xlswrite(fname,outputString)
                            postSlackImg(fname)
                            
                        case 'showparityplot'
                            postSlackImg('parity.jpg')
                            
                        case 'showlengthscaleplot'
                            postSlackImg('lengthScale.jpg')
                            
                        case 'imagebed'
                            if length(subText)<2
                                msg = 'Insufficient command for imaging bed. Please enter printer value after colon.';
                            else
                                selectedPrinter = str2double(subText{2});
                                picID = printerT.PicCount{1}(selectedPrinter);
                                printerT.PicCount{1}(selectedPrinter) = picID + 1;
                                openGripper()
                                img = imageBed(picID,selectedPrinter,'manual',0);
                                imwrite(img,'slack.jpg');
                                msg = sprintf('Picture of printer %d taken.',selectedPrinter);
                                postSlackImg('slack.jpg')
                            end
                            postSlackMsg(msg,testT)   
                            
                        case 'grippermaintenance'
                            priorityT.Pause{1} = priorityT.List{1};
                            priorityT.List{1} = 101;
                            priorityT.Level{1} = 0;
                            homeRobot()
                            command = 'python controlUR5.py /programs/helmetpads/switchEndEffector.urp';
                            protectiveStop = moveUR5AndWait(command);
                            msg = 'Note: This is a quick pause. Matlab is still running. Use Command "bear:resume" to continue.';
                            postSlackMsg(msg,testT)
                            
                        case 'plotmass'
                            plotMassAndExtrusion(dataT,printerT)
                            
                        case 'inputmass'
                            if length(subText)<3
                                msg = 'Insufficient command for imaging bed. Please enter ID number and mass.';
                            else
                                ID = str2double(subText{2});
                                mass = str2double(subText{3});
                                dataT.Mass(ID) = mass;
                                dataT.MassCorrected(ID) = 1;
                                msg = sprintf('Mass for Sample %d has been changed to %.3f.',ID,mass);
                            end
                            postSlackMsg(msg,testT)  
                            
                        case 'partnotprintable'
                            if length(subText)<2
                                msg = 'Insufficient commands. Please read documentation by typing "Bear: help"';
                            else
                                selectionMethod = subText{2};
                                switch selectionMethod
                                    case 'id'
                                        ID = str2double(subText{3});
                                    case 'printer'
                                        selectedPrinter = str2double(subText{3});
                                        printerT.Status{1}(selectedPrinter) = 4.1;
                                        ID = printerT.ID{1}(selectedPrinter);
                                        msg = sprintf('Printer %d reset. If printer not ready, please disable.',selectedPrinter);
                                        postSlackMsg(msg,testT)
                                    case 'scale'
                                        ID = scaleID;
                                        selectedPrinter = dataT.PrinterNumber(ID);
                                        printerT.Status{1}(selectedPrinter) = 4.1;
                                        scaleID = 0;
                                        scaleStatus = 1;
                                        msg = 'Please clear part from scale';
                                        postSlackMsg(msg,testT)
                                    case 'instron'
                                        ID = instronID;
                                        selectedPrinter = dataT.PrinterNumber(ID);
                                        printerT.Status{1}(selectedPrinter) = 4.1;
                                    otherwise
                                        msg = 'Selection Method not recognized. Please read documentation by typing "Bear: help"';
                                        ID = [];
                                end
                                if ~isempty(ID)
                                    dataT.Printable(ID) = -1;
                                    dataT.Failed(ID) = 1;
                                    msg = sprintf('ID %d is declared not printable.',ID);
                                end
                            end                      
                            postSlackMsg(msg,testT)
                            
                        case 'notifyremoval'
                            if length(subText)<2
                                msg = 'Insufficient commands. Please read documentation by typing "Bear: help"';
                            else
                                selectionMethod = subText{2};
                                switch selectionMethod
                                    case 'yes'
                                        msg = 'The BEAR will notify you through Slack when it removes a part.';
                                        parseT.SlackMessageLevel = 1;
                                    case 'no'
                                        msg = 'The BEAR will NOT notify you through Slack when it removes a part.';
                                        parseT.SlackMessageLevel = 0;
                                    otherwise
                                        msg = 'Command not recognized. Please read documentation by typing "Bear: help"';
                                end
                            end   
                            postSlackMsg(msg,testT)
                            
                        case 'setsigmoidcutoff'
                            sigmoidCutoff = str2double(subText{2});
                            msg = sprintf('Sigmoid cutoff set to %.03f.',sigmoidCutoff);
                            postSlackMsg(msg,testT)
                            plotSigmoidCutoff(sigmoidCutoff)
                            postSlackImg('slack.jpg')
                            
                        case 'setxpredlimits'
                            newLimit = str2double(subText{4});
                            edit_xPred(1,2,newLimit)
                            edit_xPred(1,4,newLimit)
                            postSlackMsg('New xPred Limit Set',testT)
                            
                        case 'printerstatus'
                            for selectedPrinter = 1:length(printerT.Status{1})
                                status = printerT.Status{1}(selectedPrinter);
                                switch status
                                    case -2
                                        pStatus = 'Disabled';
                                    case -2.1
                                        pStatus = 'Disabled: Bed not clean';
                                    case -2.2
                                        pStatus = 'Disabled: Consecutive print failures';
                                    case -2.3
                                        pStatus = 'Disabled: Protective stop';
                                    case -2.4
                                        pStatus = 'Disabled: Manually Disabled';
                                    case -2.5
                                        pStatus = 'Disabled: No active nozzles';
                                    case -2.6
                                        pStatus = 'Disabled: Printer connection failure';
                                    case 0
                                        pStatus = 'Bed Clean. Waiting for Instron Data';
                                    case 0.1
                                        pStatus = 'Ready to select next part';
                                    case 0.9
                                        pStatus = 'Part is being selected on compute nodes';
                                    case 1
                                        pStatus = 'Waiting to Generate STL';
                                    case 1.1
                                        pStatus = 'Ready to Start Print';
                                    case 2
                                        pStatus = 'Printing';
                                    case 3
                                        pStatus = 'Print Finished';
                                    case 4
                                        pStatus = 'Waiting to Clean Bed. Waiting for Instron Data';
                                    case 4.1
                                        pStatus = 'Waiting to Clean Bed. Instron Data Obtained';
                                    otherwise
                                        pStatus = 'Status unknown';
                                    
                                end
                                disabledNozzles = [];
                                for selectedNozzle = 0:1
                                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter) == 0
                                        disabledNozzles(end+1) = selectedNozzle;
                                    end
                                end
                                switch length(disabledNozzles)
                                    case 0
                                        msg = sprintf('Printer %d: %s.',selectedPrinter,pStatus);
                                    case 1
                                        msg = sprintf('Printer %d: %s. Nozzle %d disabled.',selectedPrinter,pStatus,disabledNozzles);
                                    case 2
                                        msg = sprintf('Printer %d: %s. Both Nozzles disabled.',selectedPrinter,pStatus);
                                end
                                postSlackMsg(msg,testT)
                                msg = sprintf('STL Mode: %d',printerT.STL_Mode{1}(selectedPrinter));
                                postSlackMsg(msg,testT)
                                msg = sprintf('Decision Policy: %d',printerT.DecisionPolicy{1}(selectedPrinter));
                                postSlackMsg(msg,testT)
                                lastPartDate = getLastPrint(selectedPrinter,dataT);
                                msg = sprintf('Last Print Started: %s',lastPartDate);
                                postSlackMsg(msg,testT)
                                fprintf('\n')
                                pause(1)   
                            end
                            
                        case 'updateprintable'
                    fname = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/printableUpdate.mat';
                            loadStruct = load(fname);
                            dataTupdate = loadStruct.dataT;
                            
                            %Mass Update
                            idxMass = dataTupdate.Mass == -99;
                            dataT.Mass(idxMass) = -99;
                            dataT.MassCorrected(idxMass) = 1;
                            dataT.Failed(idxMass) = 1;
                            
                            %Toughness Update
                            idxToughness = dataTupdate.Toughness == -99;
                            dataT.Toughness(idxToughness) = -99;
                            dataT.Failed(idxToughness) = 1;
                            
                            %Printable Update
                            updateP = dataTupdate.Printable;
                            lastIndex = max([find(updateP == 1,1,'last'), find(updateP == -1,1,'last')]);
                            dataT.Printable(1:lastIndex) = updateP(1:lastIndex);
                            
                            postSlackMsg('Printable Space Updated',testT)
                                                      
                        case 'weeklyprogress'
                            plotWeeklyProgress(dataT)
                            
                        case 'setmasscutoff'
                            selectedPrinter = str2double(subText{2});
                            selectedNozzle = str2double(subText{3});
                            newCutoff = str2double(subText{4});
                            
                            printerT.MassCutoff{1}(selectedNozzle+1,selectedPrinter) = newCutoff;
                            postSlackMsg('New Mass Cutoff Set',testT)
                            disp(printerT.MassCutoff{1})
                            
                        case 'redocylinder'
                            filamentID = str2double(subText{2});
                            filamentIDT.CylinderModulus(filamentID) = NaN;
                            filamentIDT.CylinderHeight(filamentID) = NaN;
                            filamentIDT.CylinderDiameter(filamentID) = NaN;
                            filamentIDT.CylinderMass(filamentID) = NaN;
                            filamentIDT.CylinderID(filamentID) = NaN;
                            
                            selectedPrinter = filamentIDT.Printer(filamentID);
                            printerT.STL_Mode{1}(selectedPrinter) = 1;
                            msg = sprintf('Retesting cylinder for filament ID %d.',filamentID);
                            postSlackMsg(msg,testT)
                            
                        case 'printcls'
                            printerT.STL_Mode{1}(printerT.STL_Mode{1} == 11) = 8;
                            postSlackMsg('Will print CLS Samples Listed in CLS_List.xlsx',testT)
                            
                        case 'setdp'
                            selectedPrinter = str2double(subText{2});
                            newDP = str2double(subText{3});
                            printerT.DecisionPolicy{1}(selectedPrinter) = newDP;
                            msg = sprintf('Printer %d Decision Policy changed to %d.',selectedPrinter,newDP);
                            postSlackMsg(msg,testT)
                               
                        case 'savedata'
                            writetable(dataT,'data.xlsx')
                            postSlackImg('data.xlsx')
                            
                        case 'resetinstronoffset'
                            parseT.ResetInstronOffset = 1;
                            postSlackMsg('Resetting Instron Offset',testT)
                            
                        case 'monitorprint'
                            selectedPrinter = str2double(subText{2});
                            openGripper()
                            fprintf('Monitoring Print %d\n',selectedPrinter)
                            [printerT,img] = monitorPrint(selectedPrinter,printerT);
                            imwrite(img,'slack.jpg');
                            msg = sprintf('Picture of printer %d taken.',selectedPrinter);
                            postSlackImg('slack.jpg')
                            
                        case 'recalcapred'
                                postSlackMsg('Recalculating aPred data.',testT)
                                for ID = dataT.ID_Number(dataT.ID_Number > 0)'
                                    fname = sprintf('Instron\\ID%d.csv',ID);
                                    if exist(fname,'file')
                                        FDT = csvread(fnameDst,3,0);
                                        FDT(1,:) = [];
                                        dataT.aPred(ID) = calcAPred(FDT,dataT,ID);
                                    else
                                        dataT.aPred(ID) = -1;
                                    end
                                end
                                postSlackMsg('aPred data recalculated',testT)
                                
                        case 'plotcriticalpoints'
                            fname = plotCriticalPoints(dataT,stressThreshData,stressThreshLimits,filamentIDT);
                            postSlackImg(fname)
                            
                        case 'displayvariable'
                            tempText = conversation{i}.text;
                            tempText = strrep(tempText,' ','');
                            indexColon = strfind(tempText,':');
                            uCom = tempText(indexColon(2)+1:end);
                            disp(uCom)
                            disp(eval(uCom))
                            
                        case 'plotfd'
                            ID = str2double(subText{2});
                            fname = plotFD(dataT,ID);
                            postSlackImg(fname)
                            
                        case 'movetestmat'
                            src = 'test.mat';
                            dst = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/test.mat';
                            try
                                movefile(src,dst)
                                postSlackMsg('test.mat copied sucessfully.',testT)
                            catch
                                postSlackMsg('test.mat NOT copied.',testT)
                            end
                            
                        case 'plotavss'
                            fname = plotAvsStress(dataT,filamentIDT);
                            postSlackImg(fname)
                            
                        case 'setstlmode'
                            selectedPrinter = str2double(subText{2});
                            newSTL_Mode = str2double(subText{3});
                            printerT.STL_Mode{1}(selectedPrinter) = newSTL_Mode;
                            msg = sprintf('Printer %d STL Mode changed to %d.',selectedPrinter,newSTL_Mode);
                            postSlackMsg(msg,testT)
                            
                        case 'checktoprintlist'
                            checkToPrintList(dataT,testT)
                            
                        case 'printfromlist'
                            printerT.STL_Mode{1}(printerT.STL_Mode{1} == 11) = 12;
                            postSlackMsg('Will print Samples Listed in ToPrintList.xlsx',testT)
                            
                        case 'failed'
                            ID = str2double(subText{2});
                            dataT.Toughness(ID) = -99;
                            dataT.Failed(ID) = 1;
                            msg = sprintf('Part %d marked as failed.',ID);
                            postSlackMsg(msg,testT)
                            
                        case 'storescale'
                            parseT.RemoveScale = 1;
                            postSlackMsg('Part on scale will be stored for later.',testT)
                            
                        case 'savescale'
                            if dataT.STL_Mode(scaleID) == 6
                                postSlackMsg('Part on scale is storage only. It will be stored as normal.',testT)
                            else
                                parseT.RemoveScale = 0;
                                postSlackMsg('Part on scale will be tested.',testT)
                            end
                            
                        case 'teststorage'
                            storageIdx = str2double(subText{2});
                            ID = storageStatusMat(storageIdx,6);
                            parseT.TestStored = ID;
                            msg = sprintf('Part %d will be tested.',ID);
                            postSlackMsg(msg,testT)
                            
                        case 'imageprinter'
                            selectedPrinter = str2double(subText{2});
                            openGripper()
                            picName = 'slack.png';
                            [~] = monitorPrint(selectedPrinter,picName);
                            postSlackImg(picName)
                            
                        case 'loadfilament'
                            [filamentIDT,printerT] = loadNewFilament(filamentIDT,printerT);
                            
                        case 'avoidinstron'
                            if length(subText)<2
                                msg = 'Insufficient commands. Please read documentation by typing "Bear: help"';
                            else
                                selectionMethod = subText{2};
                                switch selectionMethod
                                    case 'on'
                                        msg = 'The BEAR will NOT move the robot into the Instron testing area.';
                                        parseT.AvoidInstron = 1;
                                    case 'off'
                                        msg = 'The BEAR will resume interacting with the Instron.';
                                        parseT.AvoidInstron = 0;
                                    otherwise
                                        msg = 'Command not recognized. Please read documentation by typing "Bear: help"';
                                end
                            end  
                            postSlackMsg(msg,testT)
                            
                        case 'resetbluehill'
                            
                            msg = 'The Bear will not start new Instron tests. Once all ongoing tests have been processed, it will prompt you to continue with reset.';
                            postSlackMsg(msg,testT)
                            parseT.InstronCountReset = 1;
                                
                        otherwise
                            postSlackMsg(strcat('Command not recognized:',conversation{i}.text),testT)
                    end
                end
            end
        end
    catch e
        msg = 'Parsing Failed. All previous commands will be ignored. Please try again. If this problem persists, please check documentation';
        postSlackMsg(msg,testT)
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
    end
       
        
        
end