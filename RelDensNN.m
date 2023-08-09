%Kelsey Snapp
%Kab Lab
%11/30/22
% Uses a NN to predict relative density and filters out parts that are
% outside boundaries

function [xPred,modKey] = RelDensNN(xPred,modKey)

    X = xPred(:,[1:4,6,10,11,14]);
    X(:,7) = X(:,7) .* X(:,8);

    load relDensNN.mat trainedModel
    
    relDens = trainedModel.predictFcn(X);
    
    relDensBoundaries = [0.075,0.1];
    
    idx = relDens > relDensBoundaries(1) & relDens < relDensBoundaries(2);
    
    if sum(idx) > 0
        xPred = xPred(idx,:);
        modKey = modKey(idx);    
    end
    
end