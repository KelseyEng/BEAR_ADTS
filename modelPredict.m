%Kelsey Snapp
%Kab Lab
%7/29/22
% Runs xPred through model

function [yMu,ySdv] = modelPredict(model,xPred,modelType)

    if modelType == 1
        yMu = model(xPred');
        yMu = yMu(1,:)';
        ySdv = 0;
    else
        [yMu,ySdv] = predict(model,xPred);
    end

end