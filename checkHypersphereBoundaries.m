%Kelsey Snapp
%Kab Lab
%8/2/23
% Checks to see if boundaries of sampling space exceed sampling space
% boundaries

function xPred = checkHypersphereBoundaries(targetPoint,focusRad,boundaries,xPred)

    rangeBoundaries = range(boundaries);
    rho = vecnorm((xPred-targetPoint)./rangeBoundaries,2,2);
    idxExclude = rho > focusRad;
    xPred(idxExclude,:) = [];     

end
