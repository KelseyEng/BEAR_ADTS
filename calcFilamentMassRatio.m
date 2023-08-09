% Kelsey Snapp
% Kab Lab
% March 24, 2021
% Calculates update to extrusion multiplier


function FilamentMassRatio = calcFilamentMassRatio(T, initialFilamentMassRatio, IgainFil)

    MassAdjust = sum((T.TargetMass - T.Mass)./T.TargetMass);
    FilamentMassRatio = initialFilamentMassRatio *(1+ IgainFil*MassAdjust);

end