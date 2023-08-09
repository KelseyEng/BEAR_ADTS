%--------------------------------------------------------------------------   
%   Author       : Aldair E. Gongora
%   Lab          : Brown Research Group
%   Institution  : Boston University
%   Date Created : September 05, 2018          

%   Modification History     :
%   Name:           Date:        Description:

%--------------------------------------------------------------------------    
function [ xNew,yNew, maxID ] = aqstFxn_EI(xPred,yPredMu,yPredSdv,yObsPrinter,printabilityTransformation)
% max observed value 

f_max = max(yObsPrinter); 
if isempty(f_max)
    f_max = 0;
end

% compute expected improvement 

z = (yPredMu - f_max)./yPredSdv; 

PDF = normpdf(z);

CDF = normcdf(z); 

EI = (yPredMu - f_max).*(CDF) + (yPredSdv).*(PDF); 

%Shift EI upwards if below 0. This is necessary for
%printabilityTransformation.
if min(EI) < 0
    EI = EI - min(EI);
end

% maximum of EI and corresponding input ID

[~,maxID] = max(EI.*printabilityTransformation); 

% xnew 

xNew = xPred(maxID,:); 

% ynew
yNew = yPredMu(maxID);

end
