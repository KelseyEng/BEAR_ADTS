%Kelsey Snapp
%Kab Lab
%8/18/22
% Checks to see if any proposed parts have a bottom perimeter of less than
% 30

function idxExclude = checkBottomP(wallAngle,targetMass,density,targetHeight,capHeight,wallThickness)

    density = density ./1000;
    STL_Length = calcSTL_Length(targetMass,targetHeight,capHeight,wallThickness,density); 
    STL_LengthVariation = calcSTL_LengthVariation(targetHeight,wallAngle);
    
    STL_LengthBottom = STL_Length - STL_LengthVariation/2;
    idxExclude = STL_LengthBottom < 30;

end