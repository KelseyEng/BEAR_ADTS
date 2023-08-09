% KabLab
% Author: Kelsey Snapp
% Date  : 9/27/21
% Description: Function computes A pred using model

function aPred = calcAPred(FDT)



    %% Calculate Force Limits
 
    forceThreshLimits = logspace(log10(1),log10(4499),1000);
    forceThreshData = calcForceThreshData(FDT,forceThreshLimits);
    forceThreshData2 = log(forceThreshData./(forceThreshLimits.*0.019));
    
    %% Run Accel Model
    idxForce = [718,605,638,649;
            962,724,1000,860];   
        
    weights = [-89.8368572376977;98.8196167324440;-17.3866190863086;21.0047119891545;-21.0368997342930];

    AT = zeros(1,size(idxForce,2));
    for i = 1:size(AT,2)
        if idxForce(1,i) == 0
            AT(i) = forceThreshData2(idxForce(2,i));
        else
            AT(i) = forceThreshData2(idxForce(1,i)) .* forceThreshData2(idxForce(2,i));
        end
    end
    
    aPred = sum(AT.*weights(2:end)',2) + weights(1);
    
    
    
    
    
    
end