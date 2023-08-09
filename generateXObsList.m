%Kelsey Snapp
%Kab Lab
%8/3/22
% Generates xObs for training

function xObsList = generateXObsList(T,xMode,C)

    for i = 1:length(T)
        if isempty(T{i})
            xObsList{i} = [];
        else
            switch xMode % GCS Default
                case {1,4,5}
                    xObsList{1,i} = [T{i}.C1T,T{i}.C2T,T{i}.C1B,T{i}.C2B,T{i}.Twist,T{i}.WallThickness,...
                        log(T{i}.FilamentModulus),T{i}.Wavelength,T{i}.Amplitude,T{i}.WallAngle,...
                        T{i}.TargetMass./T{i}.TargetHeight,log(T{i}.Stress25),T{i}.Density,T{i}.TargetHeight];
                case 2 % Cylinders/Cones
                    xObsList{1,i} = [T{i}.WallThickness, T{i}.WallAngle,log(T{i}.FilamentModulus),...
                        log(T{i}.Stress25),T{i}.Density];
                    
                case 3 % Capped Parts
                    xObsList{1,i} = [T{i}.C1T,T{i}.C2T,T{i}.C1B,T{i}.C2B,T{i}.Twist,T{i}.WallThickness,...
                        log(T{i}.FilamentModulus),T{i}.Wavelength,T{i}.Amplitude,T{i}.WallAngle,...
                        T{i}.TargetMass./(T{i}.TargetHeight+T{i}.CapHeight),log(T{i}.Stress25),T{i}.Density,...
                        T{i}.TargetHeight+T{i}.CapHeight,T{i}.CapHeight./(T{i}.TargetHeight+T{i}.CapHeight),...
                        T{i}.CapExtMult];
                    
                    
                    
                case 301 %Squiggly Prints
                    xObsList{1,i} = [C{i}.Dl,...
                                    C{i}.Dz,...
                                    C{i}.H,...
                                    C{i}.L];
            end
        end
    end

end