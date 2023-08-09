%Kelsey Snapp
%Kab Lab
%8/18/22
% Calculates STL_Length (Perimeter)

function STL_Length = calcSTL_Length(targetMass,targetHeight,capHeight,wallThickness,density)

    STL_Length = targetMass./((targetHeight + capHeight./2) .* wallThickness .* density);    
    
end