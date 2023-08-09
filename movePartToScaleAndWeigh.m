%Kelsey Snapp
%Kab Lab
%3/18/21
%Moves part from printer to Scale and records weight



function [dataT,scaleStatus,filamentIDT] = movePartToScaleAndWeigh(selectedPrinter,dataT,printerT,testT,filamentIDT,ID)
    
    if testT.Scale
        
        %% Confirm Scale Clear
        mass = readWeightQuick;
        for count = 1:2 
            if mass < .1
                break
            end
            brushScale()

            mass = readWeightQuick;
        end
        if mass > .1
            musicHelp()
            msg = sprintf('Scale reading weight value of %.02fg. Unable to proceed until scale is cleared. Press enter in Matlab when clear.',mass);
            postSlackMsg(msg,testT)
            musicHelp()
            pause
        end
        
        if dataT.STL_Mode(ID) == 1 || dataT.STL_Mode(ID) == 301
            filamentID = dataT.FilamentID(ID);
            msg = sprintf('Weighing cylinder on Printer %d.',...
                selectedPrinter);
            postSlackMsg(msg,testT)
            musicHelp()
            printGood = input('Did the cylinder print successfully? 1 for yes, 0 for no');
            if ~printGood
                scaleStatus = -8;
                msg = 'Cylinder will be reprinted.';
                postSlackMsg(msg,testT);
                return
            end          
            
            msg = sprintf('Weighing cylinder on Printer %d. Please enter cylinder height in mm on Matlab interface.',...
                selectedPrinter);
            postSlackMsg(msg,testT)
            filamentIDT.CylinderHeight(filamentID) = input('Please enter height in mm: ');
            filamentIDT.CylinderDiameter(filamentID) = input('Please enter diameter in mm: ');
            dataT.EffectiveArea(ID) = calcEffArea(filamentIDT.CylinderDiameter(filamentID)/2);
            disp('Please place cylinder on scale and press any key on Matlab.')
            pause
            mass = readWeight; 
            filamentIDT.CylinderMass(filamentID) = mass;
            writetable(filamentIDT,'FilamentLog.xlsx');
            
        elseif dataT.STL_Mode(ID) == 8
            CLS_Table = readtable('CLS_List.xlsx');
            rowNumber = find(CLS_Table.CurrentBearID == ID);
            CLS_ID = CLS_Table.CLS_ID(rowNumber);
            msg = sprintf('ITCLS Sample %d is ready to remove from Printer %d.', CLS_ID, selectedPrinter);
            postSlackMsg(msg,testT)
            musicHelp()
            response = input('Did ITCLS Sample Print Succesfully? (1-Yes, 0-No, please reprint):');
            if response == 1
                CLS_Table.Status(rowNumber) = 2;
                disp('Please place ITCLS Sample on Scale and press any key.')
                pause
                mass = readWeight; 
                fprintf('The mass of ITCLS %d is %.02f g.\n',CLS_ID,mass)
                CLS_Table.Mass(rowNumber) = mass; 
                dataT.Mass(ID) = mass;
                CLS_Table.TimePrinted(rowNumber) = dataT.TimePrintStarted(ID);
                CLS_Table.ExtrusionMultiplier(rowNumber) = dataT.ExtrusionMultiplier(ID);
                disp('Please remove ITCLS Sample from scale and store. Press any key when done.')
                pause
                disp('The Bear will continue with its work.')
            else
                CLS_Table.Status(rowNumber) = 0;
                CLS_Table.CurrentBearID(rowNumber) = 0;
            end
            writetable(CLS_Table,'CLS_List.xlsx')
            scaleStatus = -8;
            return
        else
            
        
            %% Go Through Attempts to remove
            attempt = 1;
            mass = 0;
            while attempt < 4 && mass <= .1
                switch attempt
                    case 2
                        musicHelp()
                        msg = sprintf('No mass registered. Will try grabbing part again from printer %d.',...
                            selectedPrinter);
                        postSlackMsg(msg,testT)
                    case 3
                        musicHelp()
                        msg = sprintf('No mass registered on scale. Will try grabbing part final time from printer %d.',...
                            selectedPrinter);
                        postSlackMsg(msg,testT)
                        beep
                end
                [scaleStatus,picStatus,picName,imgScale] = partToScale(selectedPrinter, ID, attempt,testT,dataT);
                
                if scaleStatus == -9
                    return
                end

                %do quick check of weight to confirm something is there 
                mass = readWeightQuick;
                if mass > .1
                    mass = readWeight; 
                    postSlackImg(picName)
                    [status,~] = applyNN(imgScale,'sidewaysNet.mat');
                    postSlackMsg(status,testT)
                    if (strcmp(string(status),'Sideways') && dataT.Campaign(ID) == 1) || dataT.Campaign(ID) == 2
                        musicHelp()
                        msg = 'Part is classified as sideways. It will be removed unless "Bear: save scale" command is sent within 60 seconds.';
                        postSlackMsg(msg,testT)
                        pause(60)
                        scaleStatus = -1;
                        dataT.Mass(ID) = mass;
                        fprintf('The mass of ID %d is %.02f g.\n',ID,mass)
                        return
                    end
                end
                attempt = attempt + 1;
                
            end
        end
    else
        mass = normrnd(dataT.TargetMass(ID),.1); % simulated data when running virtual debugging
    end

    %% End Check
    %If still no weight, move to next sample
    if mass <= .1
        scaleStatus = 1;
        dataT.Mass(ID) = -1;
        dataT.Printable(ID) = -0.9;
        dataT.Failed(ID) = 1;
    else
        if abs((mass - dataT.TargetMass(ID))/dataT.TargetMass(ID)) > .1 && ~dataT.STL_Mode(ID) == 1
            musicHelp()
            msg = 'Mass of part on scale is more than 10% deviation from target mass. Please check scale and reposition';
            postSlackMsg(msg,testT)
            pause(60)
            mass = readWeight; 
        end
            
        dataT.Mass(ID) = mass;
        fprintf('The mass of ID %d is %.02f g.\n',ID,mass)
        scaleStatus = 3;
    end
  
end