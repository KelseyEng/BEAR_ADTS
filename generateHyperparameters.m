%Kelsey Snapp
%Kab Lab
%8/3/22
% Trains GP to save off hyperparameters

function [sigmaNL,sigmaFL,sigmaML] = generateHyperparameters(xObs,yObs)

    gprMdl = fitrgp(xObs,yObs,...
            'FitMethod','exact',...
            'BasisFunction', 'constant', ...
            'KernelFunction', 'ardsquaredexponential',...
            'Standardize',false);

    % hyperparameters: extracting GP hyperparameters

    sigmaML = gprMdl.KernelInformation.KernelParameters(1:end-1,1);

    sigmaFL = gprMdl.KernelInformation.KernelParameters(end);

    sigmaNL  = gprMdl.Sigma;
    
    % Check if hyperparameters are beyond bounds
    
    sigmaML(sigmaML>100) = 100;
    sigmaML(sigmaML<.01) = .01;
    
    if sigmaFL > 100
        sigmaFL = 100;
    elseif sigmaFL < .01
        sigmaFL = .01;
    end
    
    if sigmaNL > 100
        sigmaNL = 100;
    elseif sigmaNL < .01
        sigmaNL = .01;
    end

end