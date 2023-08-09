% Kelsey Snapp
% Kab Lab
% March 18, 2021
% Slices the STL and send to printer.


function [printerT, dataT] = startPrint(dataT,dataC,selectedPrinter,ID,testT, printerT,filamentIDT)
    try
        if testT.STL
            selectedNozzle = dataT.PrinterNozzle(ID);
            switch dataT.STL_Mode(ID)
                case 1
                    % Cylinder Tests

                    % Set Nozzle Temp
                    filamentID = dataT.FilamentID(ID);
                    nozzleTemp = filamentIDT.NozzleTemp(filamentID);
                    removalTemp = filamentIDT.RemovalTemp(filamentID);
                    if dataT.Density(ID) == 0.6
                        src_gcode = sprintf('cylinder_T%dLowDensity.gcode',selectedNozzle);
                    else
                        src_gcode = sprintf('cylinder_T%d.gcode',selectedNozzle);
                    end
                    changeGcode(src_gcode,nozzleTemp,removalTemp)
                    
                    % Save off gcode under ID name
                    fname_gcode = sprintf('ID%d.gcode',ID);
                    copyfile(src_gcode,fname_gcode)              
                
                case 7
                    src_gcode = 'gcode//Mode7//Mode7_1.gcode';
                    fname_gcode = sprintf('ID%d.gcode',ID);
                    copyfile(src_gcode,fname_gcode)
                
                case 13
                    src_gcode = sprintf('gcode//ID%d.gcode',ID);
                    fname_gcode = sprintf('ID%d.gcode',ID);
                    copyfile(src_gcode,fname_gcode)
                
                case 301
                    src_gcode = 'cylinder_P6.gcode';
                    fname_gcode = sprintf('ID%d.gcode',ID);
                    copyfile(src_gcode,fname_gcode)
                
                case {302,303,311,312}
                    % Generate Squigly gcode
                    [targetMass,~,layers] = generateSquiglyGcode(dataC,ID,testT);
                    fname_gcode = sprintf('ID%d.gcode',ID);
                    
                    %Save data to tables
                    dataC_Row = find(dataC{3}.ID == ID,1);
                    dataT.TargetMass(ID) = targetMass;
                    dataC{3}.Layers(dataC_Row) = layers;
                    
                

                otherwise
                    %Move stl file to current working folder
                    fname_stl = sprintf('ID%d.stl',ID);
                    src_stl = strcat('STL//',fname_stl);
                    dst_stl = fname_stl;
                    try
                        movefile(src_stl, dst_stl);
                    catch
                        postSlackMsg('Unable to find required STL. Will regenerate STL.',testT)
                        printerT.Status{1}(selectedPrinter) = 0;
                        return
                    end

                    %Select ini file
                    fname_ini = sprintf('DefaultP%dN%d.ini',selectedPrinter,selectedNozzle);

                    % Check if ini exists
                    if ~isfile(fname_ini)
                        if selectedNozzle == 0
                            copyfile('DefaultT0.ini',fname_ini)
                        else
                            copyfile('DefaultT1.ini',fname_ini)
                        end        
                    end
                    
                    % Change ini
                    filamentID = dataT.FilamentID(ID);
                    newNozTemp = filamentIDT.NozzleTemp(filamentID);
                    fanOn = filamentIDT.FanOn(filamentID);
                    newRemovalTemp = filamentIDT.RemovalTemp(filamentID);
                    newBedTemp = filamentIDT.BedTemp(filamentID);
                    changeINI(fname_ini,newNozTemp,fanOn,newRemovalTemp,newBedTemp)    

                    % Set up variables for loop to optimize filament length
                    targetFilamentLength = dataT.TargetFilamentLength(ID);
                    finalFilamentLength = 0;
                    extMult = dataT.ExtrusionMultiplier(ID);
                    capExtMult = dataT.CapExtMult(ID);

                    if printerT.STL_Mode{1}(selectedPrinter) > 7
                        count = 0;
                        if capExtMult ~= 1
                            heightTarget = dataT.TargetHeight(ID);
                            capExtMult = dataT.CapExtMult(ID);
                        end
                        % Loop for filament Length
                        while abs(targetFilamentLength-finalFilamentLength)/targetFilamentLength > .01

                            dataT.ExtrusionMultiplier(ID) = extMult;
                            setExtrusionMultiplier(fname_ini,extMult)
                            [finalFilamentLength,fname_gcode] = stl2gcode(fname_stl,fname_ini);
                            if capExtMult ~= 1
                               finalFilamentLength = changeExtMultGcode(fname_gcode,capExtMult,heightTarget);
                            end
                            extMult = extMult * targetFilamentLength/finalFilamentLength;
                            if extMult < .1
                                extMult = .1;
                            end
                            count = count + 1;
                            if count > 100
                                break
                            end

                        end
                        extMult = dataT.ExtrusionMultiplier(ID);

                        %Limits on final Extrusion Multiplier
                        if extMult > 2
                            dataT.ExtrusionMultiplier(ID) = 2;
                            extMult = dataT.ExtrusionMultiplier(ID);
                            setExtrusionMultiplier(fname_ini,extMult)
                            [finalFilamentLength,fname_gcode] = stl2gcode(fname_stl,fname_ini);
                            if capExtMult ~=1
                               finalFilamentLength = changeExtMultGcode(fname_gcode,capExtMult,heightTarget);
                            end
                            postSlackMsg('Extrusion Multiplier set to 2',testT)
                        elseif extMult < .1
                            dataT.ExtrusionMultiplier(ID) = .1;
                            extMult = dataT.ExtrusionMultiplier(ID);
                            setExtrusionMultiplier(fname_ini,extMult)
                            [finalFilamentLength,fname_gcode] = stl2gcode(fname_stl,fname_ini);   
                            if capExtMult ~=1
                               finalFilamentLength = changeExtMultGcode(fname_gcode,capExtMult,heightTarget);
                            end
                            postSlackMsg('Extrusion Multiplier set to 0.1',testT)
                        end

                        printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = extMult; 

                    else
                        setExtrusionMultiplier(fname_ini,extMult)
                        [finalFilamentLength,fname_gcode] = stl2gcode(fname_stl,fname_ini);
                    end

                    dataT.FinalFilamentLength(ID) = finalFilamentLength;

                    % Check if extrusion multiplier is within normal range
                    if extMult > 1.5 || extMult < 0.5
                        msg = sprintf('Warning: Extrusion Multiplier for Printer %d is out of range. Multiplier is %.2f.',...
                            selectedPrinter,extMult);
                        postSlackMsg(msg,testT)
                    end


                    %Save off INI file
                    dst_ini = sprintf('INI\\ID%d.ini',ID);
                    copyfile(fname_ini,dst_ini)

                    %Move stl back to STL folder
                    movefile(dst_stl, src_stl);
            end

            %Send G-code to printer
            if testT.Printer
                
                command = ['python controlUR5.py ','/programs/RG2/moveP4.urp'];
                protectiveStop = moveUR5AndWait(command);

                clearStatus = checkClear();
                if clearStatus == 0
                    protectiveStopHelp()
                end
                
                [status,~] = printerStart(selectedPrinter,fname_gcode);% send twice with pause
                pause(2)
                if selectedPrinter < 6
                    [status,~] = printerStart(selectedPrinter,fname_gcode);% send twice with pause
                end
            else
                status = 0;
            end

            %Send G-code to gcode folder
            src_gcode = fname_gcode;
            dst_gcode = sprintf('gcode//ID%d.gcode',ID);
            movefile(src_gcode,dst_gcode);
        else
            status = 0;
        end
        %% Error Checking
        if status == 0
            printerT.Status{1}(selectedPrinter) = 2;
        else
            printerT.Status{1}(selectedPrinter) = 1.1;
            msg = sprintf('Unable to start print on Printer %d. Please check connection. Will retry starting printer.'...
                ,selectedPrinter);
            postSlackMsg(msg,testT)
        end
    catch e
        msg = sprintf('Unable to start print on Printer %d. Please check connection. Printer is currently disabled.'...
                ,selectedPrinter);
        postSlackMsg(msg,testT)
        printerT.Status{1}(selectedPrinter) = -2.6;
        
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
    end

end