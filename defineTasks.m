%Kelsey Snapp
%Kab Lab
%3/9/22
% Defines GP models to Run

function defineTasks(fnameTasker,fnameGenerate)

    %% Define variables for function based on Decision Policy
    
    load(fnameGenerate,'printerT','selectedPrinter','testT','dataT','stressThreshData','stressThreshLimits',...
        'sigmoidCutoff','filamentIDT','dataCamp')
    
    DP = printerT.DecisionPolicy{1}(selectedPrinter);
    
    DPS = defineDPS(DP,testT);
    
    %% Define Samples that will make up GP
     
    [T,idxCombined,C] = generateT(DPS,stressThreshData,dataT,filamentIDT,selectedPrinter,printerT,dataCamp);

    %% Define x-inputs for GP (XObs)
    
    xObsList = generateXObsList(T,DPS.xMode,C);
        
    %% Define y-inputs for GP (yObs) 
    
    [yObsList,modelType,modulusAdj] = generateYObsList(DPS.yModeList,T,C);
    if isempty(T)
        numTasks = 0;
    else
        numTasks = length(yObsList);
    end
    
    
    %% Filter GP input
     %Sort by distance from target point
     iterLHS = 1;
     focusRad = DPS.FocusRad(iterLHS);
     focusIdx = DPS.FocusIdx;
     [~,idxFoc] = max(yObsList{iterLHS,focusIdx});
     xFoc = xObsList{iterLHS,focusIdx}(idxFoc,:);
     for task = 1:numTasks
        if ~(DPS.RetrainGP(iterLHS,task) == 0) && focusRad > 0
            %Sort by distance from target point
            xObs = xObsList{iterLHS,task};
            xObsTemp = xObsList{1,end};
            idx = 0;
            focusRad2 = focusRad;
            normVal = range(xObsTemp);
            normVal(normVal == 0) = 1;
            %If DP only uses one filament ignore material related distances
            if DP == 17 || DP == 25 || DP == 26 || DP == 27 || DP == 28
                normVal([7,12,13]) = inf;
            end
            dist = vecnorm((xObs-xFoc)./normVal,2,2);
            count = 1;
            while sum(idx) < 100 && count < 100
                idx = dist < focusRad2;
                focusRad2 = focusRad2 * 1.1;
                count = count + 1;
            end
            xObsList{iterLHS,task} = xObs(idx,:);
            yObsList{iterLHS,task} = yObsList{iterLHS,task}(idx);
        end
    end   

    %% Load List of available experiments
    if DPS.FocusRad(1) > 0
        [~,idx] = max(yObsList{DPS.FocusIdx});
        targetPoint = xObsList{DPS.FocusIdx}(idx,:);
    else
        targetPoint = 0;
    end
    [xPredList{1},modKeyList{1}] = getXPred(printerT,selectedPrinter,DPS,targetPoint,1);
    

    %% Create Comp Line
        if DPS.CompLine == 1            
            % Define compLine
            if sum(idxCombined) == 0
                compLine = zeros(1,size(stressThreshData,2));
            else
                [yMax,~] = max(stressThreshData(idxCombined,:));
                compLine = yMax./stressThreshLimits;
            end
        end
        
        % Further Adjust Compline
        if any(DPS.xMode == [4,5]) %Extrudable
            xObs = xObsList{1};
            % Find Parts already tested that are extrudable
            idxC1 = xObs(:,1) == xObs(:,3);
            idxC2 = xObs(:,2) == xObs(:,4);
            if DPS.xMode == 4
                idxTwist = xObs(:,5) == 0;
            else
                idxTwist = ones(size(xObs(:,5)),'logical');
            end                
            idxWavelength = xObs(:,8) == 0 | xObs(:,9) == 0;
            idxWallAngle = xObs(:,10) == 0;
            
            idxExtrudable = idxC1 & idxC2 & idxTwist & idxWavelength & idxWallAngle;
            
            % Further filter compline to those parts that are extrudable.
            stressThreshData2 = stressThreshData(idxCombined,:);
            if sum(idxExtrudable) == 0
                compLine = zeros(1,size(stressThreshData,2));
            else
                [yMax,~] = max(stressThreshData2(idxExtrudable,:));
                compLine = yMax./stressThreshLimits;
            end
        
        elseif DP == 10
            %Filter CompLine to printable Parts
            [~,~,idxPrinter] = filterObs(xObsList{1},ones(size(xObsList{1},1),1),printerT,selectedPrinter,DPS.xMode);
            stressThreshData2 = stressThreshData(idxCombined,:);
            if sum(idxPrinter) == 0
                compLine = zeros(1,size(stressThreshData,2));
            else
                [yMax,~] = max(stressThreshData2(idxPrinter,:));
                compLine = yMax./stressThreshLimits;
            end
        end
        
        % set compline as max compLine
        if DPS.MaxCompLine == 1
            idxMinBound = printerT.SearchRange{1}(1,selectedPrinter);
            idxMaxBound = printerT.SearchRange{1}(2,selectedPrinter);
            compLine = compLine*0 + max(compLine(idxMinBound:idxMaxBound));
        end
        
        % Adjust CompLine for search boundaries
        if DPS.BoundaryCompLine == 1
            idxMinBound = printerT.SearchRange{1}(1,selectedPrinter);
            idxMaxBound = printerT.SearchRange{1}(2,selectedPrinter);
            minBound = compLine(idxMinBound);
            maxBound = compLine(idxMaxBound);
            compLinePenalty = .001;
            for i = 1:length(compLine)
                if i < idxMinBound
                    delta = idxMinBound - i;
                    compLine(i) = minBound + delta * compLinePenalty;
                elseif i > idxMaxBound
                    delta = i - idxMaxBound;
                    compLine(i) = maxBound + delta * compLinePenalty;
                end
            end
        end 

    
    %% Save off Commands to Run
    if ~exist('compLine','Var')
        compLine = 0;
    end
    if ~exist('modulusAdj','Var')
        modulusAdj = 0;
    end
    
    try
        save(fnameTasker,'dataT','numTasks','xObsList','yObsList','xPredList','DP',...
            'DPS','modKeyList','printerT','selectedPrinter','compLine','stressThreshLimits',...
            'modulusAdj','sigmoidCutoff','modelType','C','dataCamp','-v7.3')
    catch
        save(fnameTasker)
        disp('Variable Undefined during save')
    end
    


end