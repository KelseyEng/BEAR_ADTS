%Kelsey Snapp
%Kab Lab
%10/18/21
%Train GP


function gprMdlC = trainGP(xObs,yObs,yMode,xMode,comPath,retrain) 

    % Load or generate hyperparameters
    fnameHyper = strcat(comPath,sprintf('HyperParam/hyperXmode%dYmode%d.mat',xMode,yMode));
    if ~isfile(fnameHyper) || retrain
        [sigmaNL,sigmaFL,sigmaML] = generateHyperparameters(xObs,yObs);  
        if ~retrain
            save(fnameHyper,'sigmaNL','sigmaFL','sigmaML')
        end
    else
        load(fnameHyper,'sigmaNL','sigmaFL','sigmaML')
    end

    gprMdl = fitrgp(xObs,yObs,...
        'FitMethod','none',...
        'PredictMethod','exact',...
        'BasisFunction', 'constant', ...
        'KernelFunction', 'ardsquaredexponential',...
        'KernelParameters',[sigmaML',sigmaFL],...
        'Sigma',sigmaNL,...
        'Standardize',false);

    gprMdlC = compact(gprMdl);

end