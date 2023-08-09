%--------------------------------------------------------------------------   
%   Author       : Aldair E. Gongora
%   Lab          : Brown Research Group
%   Institution  : Boston University
%   Date Created : September 05, 2018          

%   Modification History     :
%   Name:           Date:        Description:

%--------------------------------------------------------------------------    
function [ xNew,yNew, minID ] = aqstFxn_EI_min(xPred,yPredMu,yPredSdv,yObsPrinter,printabilityTransformation)
% max observed value 

f_min = min(yObsPrinter); 
if isempty(f_min)
    f_min = 1E100;
end

% compute expected improvement 

z = (f_min- yPredMu)./yPredSdv; 

PDF = normpdf(z);

CDF = normcdf(z); 

EI = (f_min- yPredMu).*(CDF) + (yPredSdv).*(PDF); 

%Shift EI upwards if below 0. This is necessary for
%printabilityTransformation.
if min(EI) < 0
    EI = EI - min(EI);
end

% maximum of EI and corresponding input ID

[~,minID] = max(EI.*printabilityTransformation); 

% xnew 

xNew = xPred(minID,:); 

% ynew
yNew = yPredMu(minID);

end
