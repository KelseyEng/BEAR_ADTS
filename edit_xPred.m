%Kelsey Snapp
%Kab Lab
%6/22/21
% Allows user to set limits on the print space dynamically.

function edit_xPred(row,column,value)

    load xPredLimits.mat xPredLimits
    
    xPredLimits(row,column) = value;
    
    disp('New xPred Limits')
    disp(xPredLimits)
    
    save xPredLimits.mat xPredLimits
    
    copyfile xPredLimits.mat U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/BEARVirtual/xPredLimits.mat

end