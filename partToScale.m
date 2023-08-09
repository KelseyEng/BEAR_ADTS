
%Kelsey Snapp
%Kab Lab
%6/22/21
%Moves Part to Scale from Printer

function [scaleStatus,picStatus,picName,imgScale] = partToScale(selectedPrinter,...
    ID, attempt,testT,dataT)
    camName = camNameFunction();
    
    scaleStatus = 3;
    
    if selectedPrinter == 0
%         command = sprintf('python controlUR5.py /programs/RG2/moveP%d.urp',5);
%         protectiveStop = moveUR5AndWait(command);
%         
%         command = 'python controlUR5.py /programs/helmetpads/sl_moveOrange5.urp';
%         protectiveStop = moveUR5AndWait(command);
%         
%         closeGripper()
%         pause(1)
%         
%         command = sprintf('python controlUR5.py /programs/helmetpads/sl_moveToP%d.urp',5);
%         protectiveStop = moveUR5AndWait(command);
%         
%         picStatus = 0;
        disp('pick saved part not set up')
        
    else

        command = sprintf('python controlUR5.py /programs/RG2/moveP%d.urp',selectedPrinter);
        protectiveStop = moveUR5AndWait(command);

        %Take picture of part on bed

        if attempt == 1
            picName = 'BedPart';
        elseif attempt == 2
            picName = 'BedPartRetry';
        else
            picName = 'BedPartRetryFinal';
        end
        img = imageBed(ID,selectedPrinter,picName,0,testT);
        [picStatus,~] = applyNN(img,'bedNet.mat');

        % Pick up part
        if attempt == 3
            % Heat bed for removal if this is last try on printer 6
            if selectedPrinter == 6
                status = heatBed(selectedPrinter,100);
                
                %Wait until bed heated
                count = 1;
                while status == 0
                    bedTemp = py.BEAR.get_bed_temp();
                    bedTemp = char(bedTemp);
                    bedTemp = str2double(bedTemp(28:end));
                    if bedTemp > 95 || count > 20
                        break
                    end            
                    count = count + 1;
                    pause(30)
                end
                
            end
            command = sprintf('python controlUR5.py /programs/RG2/ripP%d.urp',selectedPrinter);
            if selectedPrinter == 6
                status = heatBed(selectedPrinter,0);
            end
        else
            command = sprintf('python controlUR5.py /programs/RG2/pickP%d.urp',selectedPrinter);
        end
        protectiveStop = moveUR5AndWait(command);

        if protectiveStop
            scaleStatus = -9;
            
            if selectedPrinter == 6
                command = sprintf('python controlUR5.py /programs/RG2/bedCenterP%d.urp',selectedPrinter);
                protectiveStop = moveUR5AndWait(command);
            end

            openGripper()

            command = sprintf('python controlUR5.py /programs/RG2/moveP%d.urp',selectedPrinter);
            protectiveStop = moveUR5AndWait(command);

            musicHelp()
            message = sprintf('Printer %d disabled due to protective stop. Please free part and enable resume printer.',selectedPrinter);
            postSlackMsg(message,testT)

            imgScale = 0;

            return
        end

%         if attempt == 4
%             command = sprintf('python controlUR5.py /programs/helmetpads/sl_p%d_rip.urp',selectedPrinter);
%             protectiveStop = moveUR5AndWait(command);
%         end

        
    end
    
    % Take Ruler Picture
    if dataT.Campaign(ID) == 3
        global robotCam
        robotCam.Focus = 40;
        command = 'python controlUR5.py /programs/RG2/picMeasure.urp';
        protectiveStop = moveUR5AndWait(command);
        picName = strcat('pictures//',sprintf('Measure%dA%d.png',ID,attempt));
        imgScale = takePicture(camName, picName, 0, 0);
        command = 'python controlUR5.py /programs/RG2/picMeasureReturn.urp';
        protectiveStop = moveUR5AndWait(command);
        robotCam.Focus = 20;
    end

    command = 'python controlUR5.py /programs/RG2/dropScale.urp';
    protectiveStop = moveUR5AndWait(command);


    % Get Picture on Scale
    picName = strcat('pictures//',sprintf('scale%dA%d.png',ID,attempt));
    imgScale = takePicture(camName, picName, 0, 0);

    command = 'python controlUR5.py /programs/RG2/moveScale.urp';
    protectiveStop = moveUR5AndWait(command);

    if protectiveStop
        protectiveStopHelp()
    end
    
end