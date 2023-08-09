%Kelsey Snapp
%Kab Lab
%6/14/2023
% Gets Search Space for Squiggly Print


function output = getSpaceSquiggly(DPS,iterLHS)

    vStar = [0.2;0.4];
    hStar = [5;15];
    dL = [1.25;3.5];
    dZ = [0.85;1.5];
    boundaries = [vStar,hStar,dL,dZ];
    numPts = 1e6;
    output = getSamplePoints(numPts,boundaries,DPS,iterLHS);

            
end