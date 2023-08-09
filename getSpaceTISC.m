%Kelsey Snapp
%Kab Lab
%5/9/21
% Gets Search Space for TISC

function xPred = getSpaceTISC(nozzle,logmod,logstress25,targetMass,DPS,targetPoint,density,targetHeight,...
    capHeight,iterLHS)
    
    
    %% Decide set up focusMode
    if DPS.FocusRad(iterLHS) == 0
        focusMode = 0;
    else
        focusMode = 1;
    end
    
    %% Set up boundaries for LHS
    % Set Wall Thickness Boundaries
    if nozzle == 0.5
        wallThickness = [0.45;0.699999999];
    elseif nozzle == 0.75
        wallThickness = [0.7;1];
    end
    if density == 0.6
        wallThickness(2) = wallThickness(2) * 3;
    end
    
    switch DPS.xMode
        case 1 % General GCS
            
            % Set Boundaries
            c1 = [0;1.2];
            c2 = [-1;1];
            twist = [0;.1];
            wallAngle = [0;75];
            wavelength = [0;.05];
            amplitude = [0;1];
            targetHeight = [10;45];
            targetMassPH = [.05;.3];
            boundaries = [c1,c2,c1,c2,twist,wallThickness,wavelength,amplitude,wallAngle,targetMassPH,targetHeight];
            
            % If Shrink boundaries for focus radius
            if focusMode == 1
                boundaries2 = shrinkBoundaries(targetPoint([1:6,8:11,14]),...
                    DPS.FocusRad(iterLHS),...
                    boundaries, ...
                    DPS.LHSMethod(iterLHS));
            end
            
            % Run LHS
            numPts = 1e6;
            xPred = getSamplePoints(numPts,boundaries2,DPS,iterLHS);
            
            % Exclude parts that are outside hypersphere
            if focusMode == 1 && DPS.LHSMethod(iterLHS) == 2
                xPred = checkHypersphereBoundaries(targetPoint([1:6,8:11,14]),DPS.FocusRad(iterLHS),boundaries,xPred);          
            end

            % Add constant parameters
            xPred = [xPred(:,1:6),...
                ones(size(xPred,1),1).*logmod,...
                xPred(:,7:10),...
                ones(size(xPred,1),2).*[logstress25,density],...
                xPred(:,11)];
            
        
        case 2 %Cylinder/Cone Mode
            
            % Set Boundaries
            wallAngle = [0;75];        
            boundaries = [wallThickness,wallAngle];
            
            % If Shrink boundaries for focus radius
            if focusMode == 1
                boundaries = shrinkBoundaries(targetPoint([1:2]),...
                    DPS.FocusRad(iterLHS),...
                    boundaries, ...
                    DPS.LHSMethod(iterLHS));
            end

            % Run LHS
            numPts = 1e5;
            xPred = getSamplePoints(numPts,boundaries,DPS,iterLHS);
            
            % Exclude parts that are outside hypersphere
            if focusMode == 1 && DPS.LHSMethod(iterLHS) == 2
                xPred = checkHypersphereBoundaries(targetPoint([1:2]),DPS.FocusRad(iterLHS),boundaries,xPred);          
            end
            
            % Add constant parameters
            xPred = [xPred,ones(size(xPred,1),2).*[logmod,logstress25]];
            
        case 3 %Cap Mode
            
            % Set Boundaries
            c1 = [0;1];
            c2 = [-1;1];
            twist = [0;.1];
            wallAngle = [0;75];
            wavelength = [0;.05];
            amplitude = [0;1];
            capExtMult = [.5;1];
            boundaries = [c1,c2,c1,c2,twist,wallThickness,wavelength,amplitude,wallAngle,capExtMult];
            
            % If Shrink boundaries for focus radius
            if focusMode == 1
                boundaries = shrinkBoundaries(targetPoint([1:6,8:10,16]),...
                    DPS.FocusRad(iterLHS),...
                    boundaries, ...
                    DPS.LHSMethod(iterLHS));
            end
            
            % Run LHS
            numPts = 1e6;
            xPred = getSamplePoints(numPts,boundaries,DPS,iterLHS);
            
            % Exclude parts that are outside hypersphere
            if focusMode == 1 && DPS.LHSMethod(iterLHS) == 2
                xPred = checkHypersphereBoundaries(targetPoint([1:6,8:10,16]),DPS.FocusRad(iterLHS),boundaries,xPred);          
            end
            
            % Add constant parameters
            xPred = [xPred(:,1:6),...
                    ones(size(xPred,1),1).*logmod,...
                    xPred(:,7:9),...
                    ones(size(xPred,1),5).*...
                        [targetMass/(targetHeight+capHeight),...
                        logstress25,...
                        density,...
                        targetHeight+capHeight,...
                        capHeight/(targetHeight+capHeight)],...
                    xPred(:,10)];
            xPred(:,end) = 1;

            
        case 4 % Extrudable Parts
            
            % Set Boundaries
            c1 = [0;1.2];
            c2 = [-1;1];
            twist = 0;
            wallAngle = 0;
            wavelength = 0;
            amplitude = 0;
            targetHeight = [10;45];
            targetMassPH = [.05;.3];
            boundaries = [c1,c2,wallThickness,targetMassPH,targetHeight];
            
            % If Shrink boundaries for focus radius
            if focusMode == 1
                boundaries = shrinkBoundaries(targetPoint([1:2,6,11,14]),...
                    DPS.FocusRad(iterLHS),...
                    boundaries, ...
                    DPS.LHSMethod(iterLHS));
            end

            % Run LHS
            numPts = 1e6;
            xPred = getSamplePoints(numPts,boundaries,DPS,iterLHS);
            
            % Exclude parts that are outside hypersphere
            if focusMode == 1 && DPS.LHSMethod(iterLHS) == 2
                xPred = checkHypersphereBoundaries(targetPoint([1:2,6,11,14]),DPS.FocusRad(iterLHS),boundaries,xPred);          
            end

            % Add constant parameters
            xPred = [xPred(:,1:2),...
                    xPred(:,1:2),...
                    ones(size(xPred,1),1).*twist,...
                    xPred(:,3),...
                    ones(size(xPred,1),1).*logmod,...
                    ones(size(xPred,1),3).*[wavelength,amplitude,wallAngle],...
                    xPred(:,4),...
                    ones(size(xPred,1),2).*[logstress25,density],...
                    xPred(:,5)];
             
               
        case 5 % Extrudable Parts with twist
            
            % Set Boundaries
            c1 = [0;1.2];
            c2 = [-1;1];
            twist = [0;.2];
            wallAngle = 0;
            wavelength = 0;
            amplitude = 0;
            targetHeight = [10;45];
            targetMassPH = [.05;.3];
            boundaries = [c1,c2,twist,wallThickness,targetMassPH,targetHeight];
            
            % If Shrink boundaries for focus radius
            if focusMode == 1
                boundaries = shrinkBoundaries(targetPoint([1:2,5,6,11,14]),...
                    DPS.FocusRad(iterLHS),...
                    boundaries, ...
                    DPS.LHSMethod(iterLHS));
            end

            % Run LHS
            numPts = 1e6;
            xPred = getSamplePoints(numPts,boundaries,DPS,iterLHS);
            
            % Exclude parts that are outside hypersphere
            if focusMode == 1 && DPS.LHSMethod(iterLHS) == 2
                xPred = checkHypersphereBoundaries(targetPoint([1:2,5,6,11,14]),DPS.FocusRad(iterLHS),boundaries,xPred);          
            end
            
            % Add constant parameters
            xPred = [xPred(:,1:2),...
                xPred(:,1:2),...
                xPred(:,3:4),...
                ones(size(xPred,1),1).*logmod,...
                ones(size(xPred,1),3).*[wavelength,amplitude,wallAngle],...
                xPred(:,5),...
                ones(size(xPred,1),2).*[logstress25,density],...
                xPred(:,6)];
  
        otherwise
            disp('xMode Invalid')
    end
    


    %% Check for exclusions
    
    if DPS.xMode ~= 2
        % Check if top or bottom is valid shape
        %Get polygon edges from database
        if isfolder('U:\eng_research_kablab\users\ksnapp\NatickCollabHelmetPad\TSCTestData')
                fname = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150e01.mat';
        else
            fname = '/ad/eng/research/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150e01.mat';
        end
        load(fname,'tOutline')

        %Check whether top and bottom is inside polygon?
        inT = inpolygon(xPred(:,1),xPred(:,2),tOutline(:,1),tOutline(:,2));
        inT2 = inpolygon(xPred(:,3),xPred(:,4),tOutline(:,1),tOutline(:,2));
        xPred = xPred(inT&inT2,:);

        % Exclude parts that have small bottom perimeter
        onesList = ones(size(xPred,1),1);
        idxExclude = checkBottomP(xPred(:,10),xPred(:,11).*xPred(:,14),xPred(:,13),xPred(:,14),...
            capHeight*onesList,xPred(:,6));
        xPred(idxExclude,:) = [];
        
    end

    


end



