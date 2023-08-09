%Kelsey Snapp & Rashid Kolaghassi
%Kab Lab
%3/9/22
% Generates GP and runs Predict for a single task

function [mdl,yMu,ySdv] = TrainAndPredict(task,comPath,xObsList,yObsList,xPred,DP,DPS,modelType,retrain,iterLHS) 
    
    if isempty(yObsList{iterLHS,task})
        try
            GPName = [comPath,sprintf('GPModels/GP_DP%dTask%d.mat',DP,task)];
            load(GPName,'gprMdl')
        catch
            disp('Unable to Load GPR Model')
        end
    else 
        yObs = yObsList{iterLHS,task};
        xObs = xObsList{iterLHS,task};
        if modelType(task) == 1
            %Create NN
            t_matrix = createTargetMatrix(yObs);
            mdl = patternnet(size(xObs,2));
            mdl.divideParam.trainRatio = 0.9;
            mdl.divideParam.valRatio = 0.1;
            mdl.divideParam.testRatio = 0;
            mdl.trainParam.showWindow = false;
            mdl = train(mdl,xObs',t_matrix);
        else
            %Create GP
            mdl = trainGP(xObs,yObs,DPS.yModeList(task),DPS.xMode,comPath,retrain);
        end
    end
    
    %Run predictions through Model
    [yMu,ySdv] = modelPredict(mdl,xPred,modelType(task));
    

        
end