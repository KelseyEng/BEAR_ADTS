%Kelsey Snapp
%Kab Lab
%8/18/22
% Calculates the different in perimeters from top and bottom

function STL_LengthVariation = calcSTL_LengthVariation(targetHeight,wallAngle)

    STL_LengthVariation = 2.*pi.*targetHeight.*tand(wallAngle);

end