%Kelsey Snapp
%Kab Lab
%11/30/22
% Selects Type of sampling


function returnPts = getSamplePoints(numPts,boundaries,DPS,iterLHS)
    switch DPS.LHSMethod(iterLHS)
        case 1
            returnPts = LHSsampling(numPts,boundaries);
        case 2
            returnPts = HyperSphereSampling(numPts,boundaries);
    end    
end