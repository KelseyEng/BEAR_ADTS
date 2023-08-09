%Kelsey Snapp
%Kab Lab
%3/19/21
% selectExperiment




function [dataT,dataC,printerT,filamentIDT] = selectExperiment(dataT,dataC,printerT,IgainFil,filamentIDT,selectedPrinter,...
    ID,stressThreshData,stressThreshLimits,testT,sigmoidCutoff)

    while true
        %Set default value for some variables and find next ID number
        C1T = 0;
        C2T = 0.5;
        C1B = C1T;
        C2B = C2T;
        twist = 0; % radians
        wavelength = 0;
        amplitude = 0; %radians
        STL_Length = 0; %mm
        wallThickness = 0; %mm
        targetMass = 3.3; %g
        defaultHeight = 19; %mm
        capHeight = 0; %mm
        capExtMult = 0; %unitless
        wallAngle = 0; %degrees
        campaignMode = 1; %GCS



        disp('Calculating next experiment. This may take a while.')

        %Turn off printer if no active nozzles.
        if ~any(printerT.NozzleActive{1}(:,selectedPrinter))
            printerT.Status{1}(selectedPrinter) = -2.5;
            msg = sprintf('Printer %d has no active nozzles. It will be disabled.',selectedPrinter);
            postSlackMsg(msg)
        end


        %% Run STL Mode
        switch printerT.STL_Mode{1}(selectedPrinter)

            case 1 %Print Cylinders to measure modulus         
                for selectedNozzle = 0:1
                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                        filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                        if isnan(filamentIDT.CylinderModulus(filamentID)) || filamentIDT.CylinderModulus(filamentID) == 0
                            printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                            density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                            targetHeight = 16; %mm
                            effectiveArea = pi*4^2; %mm^2
                            targetMass = density *effectiveArea *targetHeight; %g
                            dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                                    selectedPrinter,selectedNozzle,campaignMode,...
                                    targetHeight,effectiveArea,targetMass);
                            filamentIDT.CylinderID(filamentID) = ID;
                            writetable(filamentIDT,'FilamentLog.xlsx');
                            printerT.Status{1}(selectedPrinter) = 1.1;
                            return
                        end
                    end
                end

                printerT.STL_Mode{1}(selectedPrinter) = 2; % No cylinders to print. Move to next step.

            case 2 % Get STL Length

                % Check if any of the nozzles need to have a calibration print
                [selectedNozzle,filamentIDT] = checkPrecalibration(selectedPrinter,printerT,filamentIDT,dataT,2); 

                if selectedNozzle > -1
                    % Print preCalibration on selected nozzle
                    printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                    if printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter) == .75
                        printerT.STL_Length{1}(selectedNozzle+1,selectedPrinter) = 182;
                    else
                        printerT.STL_Length{1}(selectedNozzle+1,selectedPrinter) = 275;
                    end
                    density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                    STL_Length = printerT.STL_Length{1}(selectedNozzle+1,selectedPrinter);
                    targetMass = 3.3;
                    wallThickness = targetMass/(defaultHeight * STL_Length * density);
                    dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,...
                        selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,...
                        defaultHeight,capHeight,capExtMult,campaignMode,1,1);
                    printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) = 3;
                    printerT.Status{1}(selectedPrinter) = 1;
                    return
                else
                    printerT.STL_Mode{1}(selectedPrinter) = 3; % No calibration prints to print. Move to next step.
                end

            case 3 %Optimize STL Length for Nozzle
                targetMass = 3.3;
                activeNozzles = printerT.NozzleActive{1}(:,selectedPrinter);
                if ~any(printerT.CalibrationStatus{1}(activeNozzles,selectedPrinter) == 3) %STL Length found for all nozzles
                    printerT.STL_Mode{1}(selectedPrinter) = 11;
                    break
                else
                    for selectedNozzle = 0:1
                        if printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) == 3 && ...
                                printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                            [lastMass,lastID] = massOfLastPrint(dataT,selectedNozzle,selectedPrinter);
                            if abs(lastMass-targetMass)/targetMass > .05 %Last print exceeds bounds
                                printerT.STL_Length{1}(selectedNozzle+1,selectedPrinter) = round(printerT.STL_Length{1}...
                                    (selectedNozzle+1,selectedPrinter) * (1+((targetMass-lastMass)/targetMass)));
                                printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                                STL_Length = printerT.STL_Length{1}(selectedNozzle+1,selectedPrinter);
                                density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                                wallThickness = targetMass/(defaultHeight * STL_Length * density);
                                dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,...
                                    twist,selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,...
                                    targetMass,defaultHeight,capHeight,capExtMult,campaignMode,1,1);
                                printerT.Status{1}(selectedPrinter) = 1;
                                return
                            else %Mass within tolerance. STL_Length selected
                                printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) = 0;
                                printerT.InitialFilamentMassRatio{1}(selectedNozzle+1,selectedPrinter) = ...
                                    dataT.FinalFilamentLength(lastID)/targetMass;
                                filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                                filamentIDT.InitialFilamentMassRatio(filamentID) = ...
                                    printerT.InitialFilamentMassRatio{1}(selectedNozzle+1,selectedPrinter);
                                writetable(filamentIDT,'FilamentLog.xlsx');
                            end
                        end
                    end
                end      

            case 4  % deprecated

            case 5 %deprecated
                
            case 6 % Print and store list of parts
                TPASFname = 'ToPrintAndStoreList.xlsx';
                if ~exist(TPASFname,'file')
                    postSlackMsg('ToPrintAndStoreList.xlsx file found')
                    printerT.STL_Mode{1}(selectedPrinter) = 11;
                else
                    TPASTable = readtable(TPASFname);
                    TPASTable = checkPrevData(TPASTable,dataT,TPASFname,filamentIDT);
                    foundSample = 0;
                    for row = 1:size(TPASTable,1)
                        if TPASTable.Status(row) > 0 %Part already printing or printed
                            continue
                        end          
                        targetPrinter = TPASTable.PrinterNumber(row);
                        if targetPrinter > 0 && targetPrinter ~= selectedPrinter
                            continue
                        end

                        targetMass = TPASTable.TargetMass(row);
                        nozzleSize = TPASTable.NozzleSize(row);
                        filamentType = TPASTable.FilamentType(row);
                        
                        for selectedNozzle = 0:1
                            if ~printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                continue
                            end
                            %Check if printer can print part
                            selectedNozzleSize = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentType = filamentIDT.TypeOfFilament{selectedFilamentID};
                            if selectedNozzleSize == nozzleSize && strcmp(selectedFilamentType,filamentType) 
                                % Get data from To Print List
                                C1T = TPASTable.C1T(row);
                                C2T = TPASTable.C2T(row);
                                C1B = TPASTable.C1B(row);
                                C2B = TPASTable.C2B(row);
                                twist = TPASTable.Twist(row);
                                wavelength = TPASTable.Wavelength(row);
                                amplitude = TPASTable.Amplitude(row);
                                wallAngle = TPASTable.WallAngle(row);
                                wallThickness = TPASTable.WallThickness(row);
                                targetHeight = TPASTable.TargetHeight(row);
                                capHeight = TPASTable.CapHeight(row);
                                capExtMult = TPASTable.CapExtMult(row);
                                
                                density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                                STL_Length = calcSTL_Length(targetMass,targetHeight,capHeight,wallThickness,density);
                                   

                                %Calculate Target Filament Length
                                printerT.TargetFilamentLength{1}(selectedNozzle+1,selectedPrinter) = ...
                                    calcTargetFilamentLength(dataT,selectedPrinter,selectedNozzle,printerT,targetMass,...
                                    IgainFil);
                                
                                % Save Data to dataT Matrix
                                dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,...
                                    twist,selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,...
                                    targetMass,targetHeight,capHeight,capExtMult,campaignMode,1,1);
                                printerT.Status{1}(selectedPrinter) = 1;

                                % Save Data to ToPrint Table
                                foundSample = 1;
                                TPASTable.Status(row) = 1;
                                TPASTable.CurrentBearID(row) = ID;
                                TPASTable.PrinterNumber(row) = selectedPrinter;
                                TPASTable.PrinterNozzle(row) = selectedNozzle;
                                TPASTable.TargetFilamentLength(row) = printerT.TargetFilamentLength{1}(selectedNozzle+1,...
                                    selectedPrinter);
                                TPASTable.FilamentModulus(row) = printerT.Modulus{1}(selectedNozzle+1,selectedPrinter);
                                TPASTable.FilamentID(row) = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);

                                writetable(TPASTable,TPASFname)
                                return
                            end
                        end
                    end

                    if ~foundSample
                        printerT.STL_Mode{1}(selectedPrinter) = 11;
                        msg = ...
            sprintf('No ToPrintAndStore parts available for printer %d. Printer %d will return to print samples for campaign.'...
                            ,selectedPrinter,selectedPrinter);
                        postSlackMsg(msg,testT)
                        return
                    end   
                end
                
            case 7 %Repeated Printing of gcode                   
                for selectedNozzle = 0:1
                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                        filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                        campaignMode = 2;
                        dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,...
                            selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,...
                            defaultHeight,capHeight,capExtMult,campaignMode,1,1);
                        dataT.ExtrusionMultiplier(ID) = 1;
                        printerT.Status{1}(selectedPrinter) = 1.1;
                        return
                    end
                end

                printerT.STL_Mode{1}(selectedPrinter) = 11; % No nozzles active.
                disp('Attempted print of STLMode 7 failed because no nozzles active')

            case 8 %Print CLS samples for Impact Testing
                clsFname = 'CLS_List.xlsx';
                if ~exist(clsFname,'file')
                    postSlackMsg('No CLS List file found')
                    printerT.STL_Mode{1}(selectedPrinter) = 11;
                else
                    CLS_Table = readtable(clsFname);
                    foundSample = 0;
                    for row = 1:length(CLS_Table.PreviousBearID)
                        if CLS_Table.Status(row) > 0 %Part already printing or printed
                            continue
                        end                   
                        targetPrinter = CLS_Table.PrinterNumber(row);
                        if targetPrinter > 0 && targetPrinter ~= selectedPrinter
                            continue
                        end
                        previousID = CLS_Table.PreviousBearID(row);
                        targetMass = CLS_Table.TargetMass(row);
                        nozzleSize = dataT.NozzleSize(previousID);
                        filamentID = dataT.FilamentID(previousID);
                        filamentType = filamentIDT.TypeOfFilament{filamentID};
                        

                        for selectedNozzle = 0:1
                            if ~printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                continue
                            end
                            selectedNozzleSize = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentType = filamentIDT.TypeOfFilament{selectedFilamentID};
                            if selectedNozzleSize == nozzleSize && strcmp(selectedFilamentType,filamentType) %Check ...
                                %if printer can print part
                                C1T = dataT.C1T(previousID);
                                C2T = dataT.C2T(previousID);
                                C1B = dataT.C1B(previousID);
                                C2B = dataT.C2B(previousID);
                                twist = dataT.Twist(previousID);
                                wavelength = dataT.Wavelength(previousID);
                                amplitude = dataT.Amplitude(previousID);
                                wallAngle = dataT.WallAngle(previousID);
                                STL_Length = dataT.STL_Length(previousID);
                                wallThickness = dataT.WallThickness(previousID);
                                targetHeight = dataT.TargetHeight(previousID);
                                capHeight = dataT.CapHeight(previousID);
                                capExtMult = dataT.CapExtMult(previousID);
                                if isnan(targetMass)
                                    targetMass = dataT.TargetMass(previousID);
                                end

                                %Calculate Target Filament Length
                                printerT.TargetFilamentLength{1}(selectedNozzle+1,selectedPrinter) = ...
                                    calcTargetFilamentLength(dataT,selectedPrinter,selectedNozzle,printerT,targetMass,...
                                    IgainFil);
                                
                                % Save Data to Matrix
                                dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,...
                                    twist,selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,...
                                    targetMass,targetHeight,capHeight,capExtMult,campaignMode,1,1);
                                printerT.Status{1}(selectedPrinter) = 1;



                                % Save Data to CLS Table
                                foundSample = 1;
                                CLS_Table.Status(row) = 1;
                                CLS_Table.CurrentBearID(row) = ID;
                                CLS_Table.PrinterNumber(row) = selectedPrinter;
                                CLS_Table.PrinterNozzle(row) = selectedNozzle;
                                CLS_Table.TargetFilamentLength(row) = printerT.TargetFilamentLength{1}(selectedNozzle+1,...
                                    selectedPrinter);
                                CLS_Table.PreviousToughness(row) = dataT.Toughness(previousID);
                                CLS_Table.C1T(row) = C1T;
                                CLS_Table.C2T(row) = C2T;
                                CLS_Table.C1B(row) = C1B;
                                CLS_Table.C2B(row) = C2B;
                                CLS_Table.Twist(row) = twist;
                                CLS_Table.NozzleSize(row) = nozzleSize;
                                CLS_Table.Amplitude(row) = amplitude;
                                CLS_Table.Wavelength(row) = wavelength;
                                CLS_Table.WallAngle(row) = wallAngle;
                                CLS_Table.CapHeight(row) = capHeight;
                                CLS_Table.CapExtMult(row) = capExtMult;
                                CLS_Table.FilamentModulus(row) = printerT.Modulus{1}(selectedNozzle+1,selectedPrinter);
                                CLS_Table.FilamentID(row) = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                                CLS_Table.PreviousDecisionPolicy(row) = dataT.DecisionPolicy(previousID);
                                
                                % Check that CLS_ID is assigned
                                CLS_ID = CLS_Table.CLS_ID(row);
                                if CLS_ID == 0 || isnan(CLS_ID)
                                    CLS_Table.CLS_ID(row) = max(CLS_Table.CLS_ID) + 1;
                                end
                                writetable(CLS_Table,clsFname)
                                return
                            end
                        end
                    end

                    if ~foundSample
                        printerT.STL_Mode{1}(selectedPrinter) = 11;
                        msg = ...
            sprintf('No CLS prints available for printer %d. Printer %d will return to print samples for campaign.'...
                            ,selectedPrinter,selectedPrinter);
                        postSlackMsg(msg,testT)
                        return
                    end   
                end

            case 10 %BO with mass by extrusion mult (Deprecated!)

            case 11 %BO with mass by filament Length
                
                % Save Generate Mat
                comPath = 'U:/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
                fnameGenerate = strcat(comPath,sprintf('GenerateID%d.mat',ID));
                try
                    dataCamp = dataC{campaignMode};
                    save(fnameGenerate,'printerT','selectedPrinter','testT','dataT','stressThreshData',...
                        'stressThreshLimits','sigmoidCutoff','filamentIDT','dataCamp') 
                    dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,...
                        -1,wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,...
                        defaultHeight,capHeight,capExtMult,campaignMode,1,0);
                    
                catch e
                    fprintf(1,'The identifier was:\n%s',e.identifier);
                    fprintf(1,'There was an error! The message was:\n%s',e.message);
                    msg = 'Unable to save to U Drive. Drive may be full.';
                    postSlackMsg(msg,testT)
                    printerT = incrementFail(printerT,selectedPrinter,testT);
                    break
                end
                
                if testT.STL == 1
                    
                    %Generate on local computer
                    status = 0;
                    while status < 2                       
                        
                        status = decideExperimentDispatcher(ID,comPath,fnameGenerate);
                    end

                end
                
                printerT.Status{1}(selectedPrinter) = 0.9;

                return
                
                
                
            case 12 %Print Parts from List
                toPrintFname = 'ToPrintList.xlsx';
                if ~exist(toPrintFname,'file')
                    postSlackMsg('ToPrintList.xlsx file found')
                    printerT.STL_Mode{1}(selectedPrinter) = 11;
                else
                    toPrintTable = readtable(toPrintFname);
                    toPrintTable = checkPrevData(toPrintTable,dataT,toPrintFname,filamentIDT);
                    foundSample = 0;
                    for row = 1:size(toPrintTable,1)
                        if toPrintTable.Status(row) > 0 %Part already printing or printed
                            continue
                        end         
                        targetPrinter = toPrintTable.PrinterNumber(row);
                        if targetPrinter > 0 && targetPrinter ~= selectedPrinter
                            continue
                        end

                        targetMass = toPrintTable.TargetMass(row);
                        nozzleSize = toPrintTable.NozzleSize(row);
                        filamentType = toPrintTable.FilamentType(row);
                        
                        for selectedNozzle = 0:1
                            if ~printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                continue
                            end
                            %Check if printer can print part
                            selectedNozzleSize = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentType = filamentIDT.TypeOfFilament{selectedFilamentID};
                            if selectedNozzleSize == nozzleSize && strcmp(selectedFilamentType,filamentType) 
                                % Get data from To Print List
                                C1T = toPrintTable.C1T(row);
                                C2T = toPrintTable.C2T(row);
                                C1B = toPrintTable.C1B(row);
                                C2B = toPrintTable.C2B(row);
                                twist = toPrintTable.Twist(row);
                                wavelength = toPrintTable.Wavelength(row);
                                amplitude = toPrintTable.Amplitude(row);
                                wallAngle = toPrintTable.WallAngle(row);
                                wallThickness = toPrintTable.WallThickness(row);
                                targetHeight = toPrintTable.TargetHeight(row);
                                capHeight = toPrintTable.CapHeight(row);
                                capExtMult = toPrintTable.CapExtMult(row);
                                
                                density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                                STL_Length = calcSTL_Length(targetMass,targetHeight,capHeight,wallThickness,density);
                                   

                                %Calculate Target Filament Length
                                printerT.TargetFilamentLength{1}(selectedNozzle+1,selectedPrinter) = ...
                                    calcTargetFilamentLength(dataT,selectedPrinter,selectedNozzle,printerT,targetMass,...
                                    IgainFil);
                                
                                % Save Data to dataT Matrix
                                dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,...
                                    twist,selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,...
                                    targetMass,targetHeight,capHeight,capExtMult,campaignMode,1,1);
                                printerT.Status{1}(selectedPrinter) = 1;

                                % Save Data to ToPrint Table
                                foundSample = 1;
                                toPrintTable.Status(row) = 1;
                                toPrintTable.CurrentBearID(row) = ID;
                                toPrintTable.PrinterNumber(row) = selectedPrinter;
                                toPrintTable.PrinterNozzle(row) = selectedNozzle;
                                toPrintTable.TargetFilamentLength(row) = printerT.TargetFilamentLength{1}(selectedNozzle+1,...
                                    selectedPrinter);
                                toPrintTable.FilamentModulus(row) = printerT.Modulus{1}(selectedNozzle+1,selectedPrinter);
                                toPrintTable.FilamentID(row) = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);

                                writetable(toPrintTable,toPrintFname)
                                return
                            end
                        end
                    end

                    if ~foundSample
                        printerT.STL_Mode{1}(selectedPrinter) = 11;
                        msg = ...
            sprintf('No ToPrint parts available for printer %d. Printer %d will return to print samples for campaign.'...
                            ,selectedPrinter,selectedPrinter);
                        postSlackMsg(msg,testT)
                        return
                    end   
                end

                
            case 13 %Print Parts from Gcode List
                toPrintFname = 'G:/My Drive/PrivateData/Adedire/ToPrintGcodeList.xlsx';
                if ~exist(toPrintFname,'file')
                    postSlackMsg('ToPrintGcodeList.xlsx file found')
                    printerT.STL_Mode{1}(selectedPrinter) = 11;
                else
                    toPrintTable = readtable(toPrintFname);
                    foundSample = 0;
                    for row = 1:size(toPrintTable,1)
                        if toPrintTable.Status(row) > 0 %Part already printing or printed
                            continue
                        end             
                        targetPrinter = toPrintTable.PrinterNumber(row);
                        if targetPrinter > 0 && targetPrinter ~= selectedPrinter
                            continue
                        end

                        nozzleSize = toPrintTable.NozzleSize(row);
                        filamentType = toPrintTable.FilamentType(row);
                        
                        for selectedNozzle = 0:1
                            if ~printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                continue
                            end
                            %Check if printer can print part
                            selectedNozzleSize = printerT.Nozzle{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                            selectedFilamentType = filamentIDT.TypeOfFilament{selectedFilamentID};
                            if selectedNozzleSize == nozzleSize && strcmp(selectedFilamentType,filamentType) 
                                
                                % Save Data to dataT Matrix
                                campaignMode = 4;
                                targetHeight = toPrintTable.TargetHeight_mm(row);
                                effectiveArea = toPrintTable.Area_mm2(row);
                                targetMass = toPrintTable.TargetMass_g(row);
                                
                                dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                                    selectedPrinter,selectedNozzle,campaignMode,...
                                    targetHeight,effectiveArea,targetMass);
                                printerT.Status{1}(selectedPrinter) = 1.1;
                                
                                % Save gcode
                                src = sprintf('G:/My Drive/PrivateData/Adedire/Campaign_gcode/singlecolumnhoneycomb_%d.gcode',...
                                    toPrintTable.gcodeID(row));
                                dst = sprintf('C:/Coding/BEAR/gcode/ID%d.gcode',ID);
                                try
                                    copyfile(src,dst)
                                catch
                                    msg = sprintf('%s not found. Will try next file.',...
                                        src);
                                    postSlackMsg(msg,testT)
                                    toPrintTable.Status(row) = 1;
                                    continue
                                end

                                % Save Data to ToPrint Table
                                foundSample = 1;
                                toPrintTable.Status(row) = 1;
                                toPrintTable.CurrentBearID(row) = ID;
                                toPrintTable.PrinterNumber(row) = selectedPrinter;
                                toPrintTable.PrinterNozzle(row) = selectedNozzle;
                                toPrintTable.FilamentID(row) = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                                writetable(toPrintTable,toPrintFname)
                                
                                return
                            end
                        end
                    end

                    if ~foundSample
                        printerT.STL_Mode{1}(selectedPrinter) = 11;
                        printerT.Status{1}(selectedPrinter) = -2.4;
                        msg = ...
            sprintf('No ToPrintGcode parts available for printer %d. Printer %d is turned off.'...
                            ,selectedPrinter,selectedPrinter);
                        postSlackMsg(msg,testT)
                        return
                    end   
                end
                
                
                
            case 301 %Print Cylinders to measure modulus         
                for selectedNozzle = 0:1
                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                        filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                        if isnan(filamentIDT.CylinderModulus(filamentID)) || filamentIDT.CylinderModulus(filamentID) == 0
                            printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                            density = printerT.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3
                            targetHeight = 16; %mm
                            effectiveArea = pi*4^2; %mm^2
                            targetMass = density *effectiveArea *targetHeight; %g
                            campaignMode = 3;
                            dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                                    selectedPrinter,selectedNozzle,campaignMode,...
                                    targetHeight,effectiveArea,targetMass);
                            filamentIDT.CylinderID(filamentID) = ID;
                            writetable(filamentIDT,'FilamentLog.xlsx');
                            printerT.Status{1}(selectedPrinter) = 1.1;
                            return
                        end
                    end
                end
                
                printerT.STL_Mode{1}(selectedPrinter) = 302; % No cylinders to print. Move to next step.
                
            case 302 % Print Initial 

                % Check if any of the nozzles need to have a calibration print
                [selectedNozzle,filamentIDT] = checkPrecalibration(selectedPrinter,printerT,filamentIDT,dataT,302); 

                if selectedNozzle > -1
                    % Print preCalibration on selected nozzle
                    printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                    campaignMode = 3;
                    targetMass = 3.49;
                    
                    % Default Part Test
                    vStar = 0.15;
                    hStar = 9;
                    dL = 1.7;
                    dZ = 1.16;
                    H = 15;
                    L = 15;
                    eDot = 25;
                    eMult = 1;
                    alpha = 1;
                    printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = eMult;

                    dataC = saveSquiglyData(dataC,ID,vStar,hStar,dL,dZ,L,H,eDot,eMult,alpha);
                    
                    
                    dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                        selectedPrinter,selectedNozzle,campaignMode,...
                        H,L^2,targetMass);
                    
                    printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) = 3;
                    printerT.Status{1}(selectedPrinter) = 1.1;
                    return
                else
                    printerT.STL_Mode{1}(selectedPrinter) = 303; % No calibration prints to print. Move to next step.
                end

            case 303 %Optimize ext Mult for Nozzle
                targetMass = 3.49;
                activeNozzles = printerT.NozzleActive{1}(:,selectedPrinter);
                if ~any(printerT.CalibrationStatus{1}(activeNozzles,selectedPrinter) == 3) %STL Length found for all nozzles
                    printerT.STL_Mode{1}(selectedPrinter) = 311;
                    break
                else
                    for selectedNozzle = 0:1
                        if printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) == 3 && ...
                                printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                            [lastMass,lastID] = massOfLastPrint(dataT,selectedNozzle,selectedPrinter);
                            if abs(lastMass-targetMass)/targetMass > .05 %Last print exceeds bounds
                                campaignMode = 3;
                                
                                printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = round(printerT.ExtrusionMult{1}...
                                    (selectedNozzle+1,selectedPrinter) * (1+((targetMass-lastMass)/targetMass)),3);
                    
                                % Default Part Test
                                vStar = 0.15;
                                hStar = 9;
                                dL = 1.7;
                                dZ = 1.16;
                                H = 15;
                                L = 15;
                                eDot = 25;
                                eMult = printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter);
                                alpha = 1;
                                printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = eMult;

                                dataC = saveSquiglyData(dataC,ID,vStar,hStar,dL,dZ,L,H,eDot,eMult,alpha);
                                
                                dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                                    selectedPrinter,selectedNozzle,campaignMode,...
                                    H,L^2,targetMass);
                    
                                printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) = 3;
                                printerT.Status{1}(selectedPrinter) = 1.1;
                                return
                                
                            else %Mass within tolerance. STL_Length selected
                                printerT.CalibrationStatus{1}(selectedNozzle+1,selectedPrinter) = 0;
                                rowC = find(dataC{3}.ID == lastID);
                                printerT.InitialExtMult{1}(selectedNozzle+1,selectedPrinter) = ...
                                    dataC{3}.Emult(rowC);
                                filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                                filamentIDT.InitialExtMult(filamentID) = ...
                                    printerT.InitialExtMult{1}(selectedNozzle+1,selectedPrinter);
                                writetable(filamentIDT,'FilamentLog.xlsx');
                            end
                        end
                    end
                end   
                
            case 311 %Active Learning Squigly Campaign
                % Save Generate Mat
                campaignMode = 3; 
                comPath = 'U:/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
                fnameGenerate = strcat(comPath,sprintf('GenerateID%d.mat',ID));
                try
                    dataCamp = dataC{campaignMode};
                    save(fnameGenerate,'printerT','selectedPrinter','testT','dataT','stressThreshData',...
                        'stressThreshLimits','sigmoidCutoff','filamentIDT','dataCamp') 
                    dataT = savePrintInfoToDataT(dataT,printerT,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,...
                        -1,wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,...
                        defaultHeight,capHeight,capExtMult,campaignMode,1,0);
                    
                catch e
                    fprintf(1,'The identifier was:\n%s',e.identifier);
                    fprintf(1,'There was an error! The message was:\n%s',e.message);
                    msg = 'Unable to save to U Drive. Drive may be full.';
                    postSlackMsg(msg,testT)
                    printerT = incrementFail(printerT,selectedPrinter,testT);
                    break
                end
                
                if testT.STL == 1
                    
                    %Generate on local computer
                    status = 0;
                    while status < 2                       
                        
                        status = decideExperimentDispatcher(ID,comPath,fnameGenerate);
                    end

                end
                
                printerT.Status{1}(selectedPrinter) = 0.9;

                return

            case 312 %Print from List Squigly Campaign
                toPrintFname = 'ToPrintListC3Squiggly.xlsx';
                if ~exist(toPrintFname,'file')
                    postSlackMsg('ToPrintListC3Squiggly.xlsx file found')
                    printerT.STL_Mode{1}(selectedPrinter) = 311;
                else
                    toPrintTable = readtable(toPrintFname);
                    foundSample = 0;
                    for row = 1:size(toPrintTable,1)
                        if toPrintTable.Status(row) > 0 %Part already printing or printed
                            continue
                        end                  
                       
                        for selectedNozzle = 0:1
                            if ~printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                                continue
                            end
                            campaignMode = 3;
                            targetMass = 0;

                            % Default Part Test
                            vStar = toPrintTable.Vstar(row);
                            hStar = toPrintTable.Hstar(row);
                            dL = toPrintTable.Dl(row);
                            dZ = toPrintTable.Dz(row);
                            H = toPrintTable.H(row);
                            L = toPrintTable.L(row);
                            eDot = toPrintTable.Edot(row);
                            alpha = toPrintTable.Alpha(row);
                            eMult = calcTargetExtMult(dataT,selectedPrinter,selectedNozzle,printerT,IgainFil);
                            printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
                            
                            dataC = saveSquiglyData(dataC,ID,vStar,hStar,dL,dZ,L,H,eDot,eMult,alpha);
                            
                            dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                                selectedPrinter,selectedNozzle,campaignMode,...
                                H,L^2,targetMass);
                            
                            
                            foundSample = 1;
                            toPrintTable.ID(row) = ID;
                            toPrintTable.Status(row) = 1;
                            writetable(toPrintTable,toPrintFname)
                            
                            printerT.Status{1}(selectedPrinter) = 1.1;
                            return
                        end
                    end

                    if ~foundSample
                        printerT.STL_Mode{1}(selectedPrinter) = 311;
                        printerT.Status{1}(selectedPrinter) = -2.4;
                        msg = ...
            sprintf('No ToPrint parts available for printer %d. Printer %d will be disabled.'...
                            ,selectedPrinter,selectedPrinter);
                        postSlackMsg(msg,testT)
                        return
                    end   
                end
                


        end
    end
end
