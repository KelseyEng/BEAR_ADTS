%Kelsey Snapp
%Kab Lab
%8/11/22
% Calculates Wall Angle from Perimeter, Perimeter Ratio, and height

function theta = calcTheta(P,Pr,h)

    theta = atand(P./(pi*h).*(Pr-1)./(Pr+1));
    
end

