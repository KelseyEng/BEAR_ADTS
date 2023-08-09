%Kelsey Snapp
%Kab Lab
%3/9/22
% Applies Decision Policy

function applyDP(fnameResponse,numTasks,fnameTasker,ID,comPath)
    numIterLHS = 1;
        
    if numTasks == 0
        %% Pick Random Point
        load(fnameTasker,'xPredList','DPS')
        xNew = xPredList{1}(randi(size(xPredList{1},1)),:);
        disp('Picking Random Experiment')
    else
        iterLHS = 1;
        while iterLHS <= numIterLHS
            if iterLHS  == 1
                %% Load Data from Tasker and individual tasks
                load(fnameTasker,'modKeyList','DP','xObsList','yObsList',...
                    'printerT','selectedPrinter','compLine','stressThreshLimits',...
                    'DPS','xPredList','modulusAdj','sigmoidCutoff','modelType','dataT','C','dataCamp')
                
                numIterLHS = DPS.numIterLHS;

                for task = 1:numTasks
                    fnameTask = [comPath,sprintf('Task%dID%d.mat',task,ID)];
                    s = load(fnameTask);
                    yMuList{iterLHS,task} = s.yMu;
                    ySdvList{iterLHS,task} = s.ySdv;
                    MdlList(iterLHS,task) = {s.mdl};
                end
            else
                %% Recalculate using GPR Models
                % Get new xPred                   

                focusRad = DPS.FocusRad(iterLHS);

                % Narrow GP's training set
                for task = 1:numTasks
                    if DPS.RetrainGP(iterLHS,task) == 0 || focusRad == 0
                        xObsList{iterLHS,task} = xObsList{iterLHS-1,task};
                        yObsList{iterLHS,task} = yObsList{iterLHS-1,task};
                    else
                        %Sort by distance from target point
                        xObs = xObsList{iterLHS-1,task};
                        xObsTemp = xObsList{1,end};
                        idx = 0;
                        focusRad2 = focusRad;
                        normVal = range(xObsTemp);
                        normVal(normVal == 0) = 1;
                        if DP == 17
                            normVal([7,12,13]) = inf;
                        end
                        dist = vecnorm((xObs-xNew)./normVal,2,2);
                        while sum(idx) < 10 
                            idx = dist < focusRad2;
                            focusRad2 = focusRad2 * 1.1;
                        end
                        xObsList{iterLHS,task} = xObs(idx,:);
                        yObsList{iterLHS,task} = yObsList{iterLHS-1,task}(idx);
                    end
                end          
                
                % Get new potential points                
                [xPredList{iterLHS},modKeyList{iterLHS}] = getXPred(printerT,selectedPrinter,DPS,xNew,iterLHS);
                
                % Retrain GPs if needed and predict
                
                for task = 1:length(MdlList)
                    if DPS.RetrainGP(iterLHS,task) == 0
                        mdl = MdlList{iterLHS-1,task};
                        [yMuList{iterLHS,task},ySdvList{iterLHS,task}] = modelPredict(mdl,xPredList{iterLHS},modelType(task));
                    else
                        [mdl,yMuList{iterLHS,task},ySdvList{iterLHS,task}] = TrainAndPredict(task,comPath,xObsList,yObsList,xPredList{iterLHS},DP,DPS,modelType,1,iterLHS);
                    end
                    MdlList(iterLHS,task) = {mdl};
                end            
                
            end

            %% Adjust yMuList if needed
            for task = 1:numTasks
                yMode = DPS.yModeList(task);
                switch yMode
                    case 1 %Printability
                        %Need to Add Error Propogation
                        yMuListOrig{iterLHS,task} = 1./(1+exp(-20*(yMuList{iterLHS,task}-sigmoidCutoff)));
                        ySdvListOrig{iterLHS,task} = ySdvList{iterLHS,task};
                    case 4 %Critical Stress
                        %Need to Add Error Propogation
                        yMuListOrig{iterLHS,task} = (10.^yMuList{iterLHS,task}).*(modKeyList{iterLHS}.^modulusAdj);     
                        ySdvListOrig{iterLHS,task} = ySdvList{iterLHS,task};
                    case 6 % Max Stress 10
                        yMuListOrig{iterLHS,task} = 10.^yMuList{iterLHS,task};     
                        ySdvListOrig{iterLHS,task} = ySdvList{iterLHS,task};
                    otherwise
                        yMuListOrig{iterLHS,task} = yMuList{iterLHS,task};
                        ySdvListOrig{iterLHS,task} = ySdvList{iterLHS,task};
                end
            end            

            %% Build functions that the DP evaluates
            % Define printabilityTransformation
            if DPS.yModeList(end) == 1 || DPS.yModeList(end) == 300
                printabilityTransformation{iterLHS} = yMuListOrig{iterLHS,end};
            else
                printabilityTransformation = 1;
            end

            % Define other parameters
            switch DP
                case 2
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,1};

                case {3,4}
                    [~,zObsPrinter,~] = filterObs(xObsList{1,1},yObsList{1,1},printerT,selectedPrinter,DPS.xMode);
                    zMuList{iterLHS} = yMuListOrig{iterLHS,1};
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,1};

                case {8,10,12,13,17,18,19,20,22,23}               
                    % Find stress index for each point prediction
                    predCS = yMuListOrig{iterLHS,1};
                    idxCriticalStress = zeros(size(predCS,1),1);
                    for i = 1:length(predCS)
                        temp = find(predCS(i) < stressThreshLimits,1);
                        if isempty(temp)
                            idxCriticalStress(i) = length(stressThreshLimits);
                        else
                            idxCriticalStress(i) = temp;
                        end
                    end

                    % Apply compLine penalty and error propogate
                    zMuList{iterLHS} = yMuListOrig{iterLHS,2} - compLine(idxCriticalStress)';   
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,2};

                    zObsPrinter = 0;

                case 11
                    %Error propogation
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,2};
                    
                case 14
                    if ~exist('randDegree','Var')
                        rng('shuffle')
                        randDegree = rand(1)*45;
                        rotMat = [cosd(randDegree) -sind(randDegree); sind(randDegree) cosd(randDegree)];
                    end
                    points = [yMuListOrig{iterLHS,1},yMuListOrig{iterLHS,2}];
                    for i = 1:size(points,1)
                        points(i,:) = points(i,:) * rotMat;
                    end
                    zMuList{iterLHS} = points(:,1);
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,1} + ySdvListOrig{iterLHS,2};
                    
                    % get zObsPrinter
                    pointsPrinter = [yObsList{1,1},yObsList{1,2}];
                    for i = 1:size(pointsPrinter,1)
                        pointsPrinter(i,:) = pointsPrinter(i,:) * rotMat;
                    end
                    zObsPrinter = pointsPrinter(:,1);
                    
                case 15
                    yMuStress = yMuListOrig{iterLHS,1};
                    yMuA = yMuListOrig{iterLHS,2};
                    [pList,idxP] = paretoFront(yMuStress,yMuA,-1,-1);
                    idxA = pList(:,2) < 175;
                    idxS = pList(:,1) < -1;
                    idxComb = idxA & idxS;
                    idxPotential{iterLHS} = idxP(idxComb);
                    
                case 16
                    zMuList{iterLHS} = yMuListOrig{iterLHS,1} .* yMuListOrig{iterLHS,2};   
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,1} + ySdvListOrig{iterLHS,2};
                    zObsPrinter = 0;
                    
                case 21
                    if ~exist('randDegree','Var')
                        rng('shuffle')
                        randDegree = rand(1)*-45;
                        rotMat = [cosd(randDegree) -sind(randDegree); sind(randDegree) cosd(randDegree)];
                    end
                    points = [log10(yMuListOrig{iterLHS,3}),log10(yMuListOrig{iterLHS,1}.*yMuListOrig{iterLHS,2})];
                    for i = 1:size(points,1)
                        points(i,:) = points(i,:) * rotMat;
                    end
                    zMuList{iterLHS} = points(:,1);
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,3} + ySdvListOrig{iterLHS,1} + ySdvListOrig{iterLHS,2};
                    
                    % get zObsPrinter
                    pointsPrinter = [yObsList{1,3},log10((yObsList{1,1}.*yObsList{1,2}))];
                    for i = 1:size(pointsPrinter,1)
                        pointsPrinter(i,:) = pointsPrinter(i,:) * rotMat;
                    end
                    zObsPrinter = pointsPrinter(:,1);
                    
                otherwise
                    zMuList{iterLHS} = yMuListOrig{iterLHS,1};
                    zSdvList{iterLHS} = ySdvListOrig{iterLHS,1};
                    [~,zObsPrinter,~] = filterObs(xObsList{1,1},yObsList{1,1},printerT,selectedPrinter,DPS.xMode);

            end

            %% Apply DP
            % Restrict DP to new points or all previous points as well
            if DPS.RestrictGP == 1
                iterIdx = length(zMuList);
            else
                iterIdx = 1:length(zMuList);
            end
            zMu = vertcat(zMuList{iterIdx});
            zSdv = vertcat(zSdvList{iterIdx});
            xPred = vertcat(xPredList{iterIdx});
            PTF = vertcat(printabilityTransformation{iterIdx});
            
            % Apply Selected DP
            switch DPS.DPMode
                case 1 % Maximum Variance (MV)
                    maxVal = max(zSdv.*PTF);
                    idxNew = find(zSdv.*PTF == maxVal);
                    if length(idxNew) > 1
                        idxNew = idxNew(randi(length(idxNew)));
                    end
                    xNew = xPred(idxNew,:);  

                case 2 % Expected Improvement Max (EI+)
                    [xNew,~,idxNew] = aqstFxn_EI(xPred,zMu,zSdv,zObsPrinter,PTF);
                    
                case 3 % Expected Improvement Min (EI-)
                    [xNew,~,idxNew] = aqstFxn_EI_min(xPredList,zMuList,zSdvList,zObsPrinter,PTF);
                    
                case 4 %Random
                    dice = randi(size(idxPotential,1));
                    idxNew = idxPotential(dice);
                    xNew = xPred(idxNew,:);  
                    
                case 5 % Upper Confidence Bound (UCB)
                    if iterLHS == 1
                        w = 20;
                    else
                        w = 5;
                    end
                    [~,idxNew] = max((zMu + w*zSdv).*PTF);
                    xNew = xPred(idxNew,:);  
            end
            xNewList{iterLHS} = xNew;
            idxNewList{iterLHS} = idxNew;
            iterLHS = iterLHS + 1;
        end
    end

    %% Save response for Controller Computer
    printerT_Old = printerT;
    save(fnameResponse,'xNew','DPS','printerT_Old')
    
    %% Save GP
    if mod(ID,1) == 0
        filenamegprmodel = sprintf('GPRModel/ID%d.mat',ID);
        try
            save(filenamegprmodel,'-v7.3')
        catch
            fprintf('Unable to save GPRModel for ID%d\n',ID)
        end
    end

end