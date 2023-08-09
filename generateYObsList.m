%Kelsey Snapp
%Kab Lab
%8/3/22
% Generates YObsList for Model Creation

function [yObsList,modelType,modulusAdj] = generateYObsList(yModeList,T,C)

    modulusAdj = 0.408;
    for i = 1:length(yModeList)
        yMode = yModeList(i);
        switch yMode
            case 0
                yObsList{1,i} = [];
                modelType(i) = 2; %GP
            case 1 %Printability
                yObsList{1,i} = [T{i}.Printable];
                yObsList{1,i} = double(yObsList{1,i}>0);
                modelType(i) = 1; %NN
            case 2 %Toughness/mass
                yObsList{1,i} = (T{i}.Toughness./T{i}.Mass);
                modelType(i) = 2; %GP
            case 3 %Acceleration Model
                yObsList{1,i} = T{i}.aPred;
                modelType(i) = 2; %GP
            case 4 %Critical Stress
                yObsList{1,i} = log10(T{i}.CriticalStress./(T{i}.FilamentModulus).^modulusAdj); 
                modelType(i) = 2; %GP
            case 5 %KS
                yObsOrigList{1,i} = T{i}.CriticalEfficiency;
                yObsList{1,i} = yObsOrigList{i};  
                modelType(i) = 2; %GP
            case 6 % Max Stress at 20 %Strain
                yObsList{1,i} = log10(T{i}.MaxStress20);  
                modelType(i) = 2; %GP
            case 7 %Critical Force
                radius = T{i}.MaxRadius;
                area = pi.*(radius).^2; %mm^2
                area = area .* 6 ./ (sqrt(3) .* pi); %mm^2 (Adjustment for circle packing
                yObsList{1,i} = T{i}.CriticalStress .* area; %N
                modelType(i) = 2; %GP
            case 8 %KS adjusted for parallel part
                yObsList{1,i} = T{i}.KSadjusted + 0.6015;
                modelType(i) = 2; %GP
                
                
            case 300 %Printability Squiggly Print
                yObsList{1,i} = [T{i}.Printable];
                yObsList{1,i} = double(yObsList{1,i}>0 | yObsList{1,i}==-1.1);
                modelType(i) = 1; %NN
                
            case 301 %Modulus (part) Squiggly Print
                yObsList{1,i} = C{i}.Mod;
                modelType(i) = 2; %GP
                
            case 302 %dZ error
                yObsList{1,i} = (T{i}.Height ./ C{i}.Layers)-C{i}.Dz ;
                modelType(i) = 2; %GP
                
        end
    end
end