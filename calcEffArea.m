% KAB Lab
% Kelsey Snapp
% 1/6/2023
% Calculates the area for circle packing

function area = calcEffArea(radius)

    area = pi.*(radius).^2; %mm^2
    area = area .* 6 ./ (sqrt(3) .* pi); %mm^2 (Adjustment for circle packing)
    
end