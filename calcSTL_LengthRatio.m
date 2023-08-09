%Kelsey Snapp
%Kab Lab
%8/11/22
% Calculates Wall Angle from Perimeter, Perimeter Ratio, and height

function Pr = calcSTL_LengthRatio(P,theta,h)

    Pr = (P + pi.*h.*tand(theta)) ./ (P - pi.*h.*tand(theta));

end

