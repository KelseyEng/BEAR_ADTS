%Kelsey Snapp
%Kab Lab
%9/17/21
%Merges Values From compute node that generates STL and current BEAR State.


function  [dataT,printerT,dataC] = mergeState(dataT,printerT,fnameResponse,selectedPrinter,ID,IgainFil,dataC)
    %Load Data
    try
        %Use printerT_Old to get state of printerT when parts were selected
        load(fnameResponse,'xNew','DPS','printerT_Old'); 
        if isempty(xNew)
            disp('xNew empty')
            printerT.Status{1}(selectedPrinter) = 0.9;
            return
        end
    catch
        pause(10)
        try
            load(fnameResponse,'xNew','DPS','printerT_Old');
        catch
            disp('Unable to Load Response File. Will try again later.')
            printerT.Status{1}(selectedPrinter) = 0.9;
            return
        end
    end
    
    switch dataT.STL_Mode(ID)
        case 11
    
            switch DPS.xMode
                case {1,4,5}
                    C1T = xNew(1);
                    C2T = xNew(2);
                    C1B = xNew(3);
                    C2B = xNew(4);
                    twist = xNew(5);
                    wallThickness = xNew(6);
                    wavelength = xNew(8);
                    amplitude = xNew(9);
                    wallAngle = xNew(10);
                    capExtMult = 1;
                    targetHeight = xNew(14);
                    targetMass = xNew(11)*xNew(14);

                case 2
                    C1T = 0;
                    C2T = 0;
                    C1B = 0;
                    C2B = 0;
                    twist = 0;
                    wallThickness = xNew(1);
                    wavelength = 0;
                    amplitude = 0;
                    wallAngle = xNew(2);   
                    capExtMult = 1;

                case 3
                    C1T = xNew(1);
                    C2T = xNew(2);
                    C1B = xNew(3);
                    C2B = xNew(4);
                    twist = xNew(5);
                    wallThickness = xNew(6);
                    wavelength = xNew(8);
                    amplitude = xNew(9);
                    wallAngle = xNew(10);
                    capExtMult = xNew(16);

            end

            %selectNozzle
            if wallThickness < 0.7
                nozzleSize = 0.5;
            else
                nozzleSize = 0.75;
            end

            %Select Nozzle
            selectedNozzle = find((printerT_Old.Nozzle{1}(:,selectedPrinter)==nozzleSize)==1)-1;
            if length(selectedNozzle) > 1
                selectedNozzle = randi(2)-1;
            end
            density = printerT_Old.Density{1}(selectedNozzle+1,selectedPrinter)/1000; %g/mm^3

            if any(DPS.xMode == [2,3])
                targetMass = printerT_Old.TargetMass{1}(selectedNozzle+1,selectedPrinter);
                targetHeight = printerT_Old.TargetHeight{1}(selectedNozzle+1,selectedPrinter);
            end

            % Get Cap Height
            capHeight = printerT_Old.CapHeight{1}(selectedNozzle+1,selectedPrinter);

            % Calculate STL_Length
            STL_Length = calcSTL_Length(targetMass,targetHeight,capHeight,wallThickness,density);

            %Calculate Target Filament Length
            printerT_Old.TargetFilamentLength{1}(selectedNozzle+1,selectedPrinter) = calcTargetFilamentLength(dataT,...
                selectedPrinter,selectedNozzle,printerT_Old,targetMass,IgainFil);

            %Save Data to matrix
            dataT = savePrintInfoToDataT(dataT,printerT_Old,ID,selectedPrinter,C1T,C2T,C1B,C2B,twist,...
                selectedNozzle,wavelength,amplitude,wallAngle,STL_Length,wallThickness,targetMass,targetHeight,capHeight,...
                capExtMult,DPS.campaignMode,0,1);
            
            printerT.Status{1}(selectedPrinter) = 1;
        
        case 311
            campaignMode = 3;
            targetMass = 0;
            selectedNozzle = 0;

            % Default Part Test
            vStar = xNew(1);
            hStar = xNew(2);
            dL = xNew(3); %mm
            dZ = xNew(4); %mm
            H = 30; %mm
            L = 30; %mm
            eDot = 35; %mm/min
            alpha = 1;
            printerT.ExtrusionMult{1}(selectedNozzle+1,selectedPrinter) = 1;
            eMult = 1;

            dataC = saveSquiglyData(dataC,ID,vStar,hStar,dL,dZ,L,H,eDot,eMult,alpha);

            dataT = savePrintInfoToDataTMin(dataT,printerT,ID,...
                selectedPrinter,selectedNozzle,campaignMode,...
                H,L^2,targetMass);
            
            printerT.Status{1}(selectedPrinter) = 1.1;
          
    end
    
    % Final Clean up
    delete(fnameResponse)
    
    
    
end