%Kelsey Snapp
%Kab Lab
%8/3/22
% Generates T Cell Array that contains the right samples


function [T,idxCombined,C] = generateT(DPS,stressThreshData,dataT,filamentIDT,selectedPrinter,printerT,dataCamp)
    C = [];

    if any(DPS.yModeList == [4;5],'all')
        if size(dataT,1) > size(stressThreshData,1)
            dataT = dataT(1:size(stressThreshData,1),:);
        end
    end
    
    
    % Ignore samples from calibration portion
    for i = 1:length(DPS.tModeList)
        tMode = DPS.tModeList(i);
        switch tMode
            case 0
                T{i} = [];
            case 1 % Standard Campaign
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxFailed = dataT.Failed < 1;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable > -.5;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxCH = dataT.CapHeight == 0;
                idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .05;
                idxCombined = idxCampaign & idxFailed & idxSTL & idxMass & idxToughness & idxPrintable & idxCrit & idxCH & idxHeight;
                T{i} = dataT(idxCombined,:);
            case 2
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxFailed = dataT.Failed < 1;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxDP = dataT.DecisionPolicy == 11 | dataT.DecisionPolicy == 13;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable > -.5;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxCH = dataT.CapHeight == 0;
                idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .05;
                idxCombined = idxCampaign & idxFailed & idxSTL & idxMass & idxDP & idxToughness & idxPrintable & idxCrit & idxCH & idxHeight;
                T{i} = dataT(idxCombined,:);
            case 3 % Standard Campaign Printability
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable ~= 0;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxCH = dataT.CapHeight == 0;
                idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .05;
                idxCombined2 = idxCampaign  & idxSTL & idxMass & idxToughness & idxPrintable & idxCrit & idxCH & idxHeight;
                T{i} = dataT(idxCombined2,:);
            case 4 % Cylinder Printability
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxDP = dataT.DecisionPolicy == 11 | dataT.DecisionPolicy == 13;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable ~= 0;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxCH = dataT.CapHeight == 0;
                idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .05;
                idxCombined2 = idxCampaign & idxSTL & idxMass & idxDP & idxToughness & idxPrintable & idxCrit & idxCH & idxHeight;
                T{i} = dataT(idxCombined2,:);
            case 5 % Max Stress pareto front impact (deprecated?)
                fList = [0];
                for j = 1:size(filamentIDT,1)
                    if strcmp(filamentIDT.TypeOfFilament{j},'Cheetah')
                        fList(end+1) = j;
                    end
                end
                fList(1) = [];
                idxFil = any(dataT.FilamentID == fList,2);   
                
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxFailed = dataT.Failed < 1;
                idxSTL = dataT.STL_Mode > 9;
                idxToughness = dataT.Toughness > 0.1;
                idxTMass = dataT.TargetMass == 2.1;
                idxMass = dataT.Mass > 1.89 & dataT.Mass < 2.31;
                idxPrintable = dataT.Printable > -1;
                idxNozzle = dataT.NozzleSize == 0.75;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxStress = dataT.MaxStress20 > 0;
                idxAPred = dataT.aPred > 0;
                idxCH = dataT.CapHeight == 0;
                idxCombined = idxCampaign & idxFailed & idxSTL & idxToughness & idxTMass & ...
                    idxMass & idxPrintable & idxFil & idxNozzle &...
                    idxCrit & idxAPred & idxStress & idxCH;
                T{i} = dataT(idxCombined,:);
            case 6 % Printability for pareto front impact (deprecated)
                fList = [0];
                for j = 1:size(filamentIDT,1)
                    if strcmp(filamentIDT.TypeOfFilament{j},'Cheetah')
                        fList(end+1) = j;
                    end
                end
                fList(1) = [];
                idxFil = any(dataT.FilamentID == fList,2);  
                
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxSTL = dataT.STL_Mode > 9;
                idxToughness = dataT.Toughness > 0.1;
                idxTMass = dataT.TargetMass == 2.1;
                idxMass = dataT.Mass > 1.89 & dataT.Mass < 2.31;
                idxPrintable = dataT.Printable ~= 0;
                idxNozzle = dataT.NozzleSize == 0.75;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxStress = dataT.MaxStress20 > 0;
                idxAPred = dataT.aPred > 0;
                idxCH = dataT.CapHeight == 0;
                idxCombined2 = idxCampaign  & idxSTL & idxToughness & idxTMass &...
                    idxMass & idxPrintable & idxFil & idxNozzle &...
                    idxCrit & idxAPred & idxStress & idxCH;
                T{i} = dataT(idxCombined2,:);
                
            case 7 %Cap Mode
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxFailed = dataT.Failed < 1;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable > -.5;
                idxCrit = dataT.CriticalEfficiency > 0;
                targetHeight = dataT.TargetHeight + dataT.CapHeight;
                idxHeight = abs(targetHeight - dataT.Height) ./ targetHeight < .05;
                idxCombined = idxCampaign & idxFailed & idxSTL & idxMass & idxToughness &...
                    idxPrintable & idxCrit & idxHeight;
                T{i} = dataT(idxCombined,:);
            case 8 %Printability Cap Mode
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable ~= 0;
                idxCrit = dataT.CriticalEfficiency > 0;
                targetHeight = dataT.TargetHeight + dataT.CapHeight;
                idxHeight = abs(targetHeight - dataT.Height) ./ targetHeight < .05;
                idxCombined2 = idxCampaign  & idxSTL & idxMass & idxToughness & ...
                    idxPrintable & idxCrit & idxHeight;
                T{i} = dataT(idxCombined2,:);
                
            case 9 % Filter to Loaded filament only
                % Get loaded filament (If more than 1, gets only the first
                % loaded filament. This case is designed for when only 1
                % filament is loaded
                count = 1;
                for selectedNozzle = 0:1
                    if printerT.NozzleActive{1}(selectedNozzle+1,selectedPrinter)
                        filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
                        break
                    end
                end
                filType = filamentIDT.TypeOfFilament{filamentID};

                fList = [];
                for j = 1:size(filamentIDT,1)
                    if strcmp(filamentIDT.TypeOfFilament{j},filType)
                        fList(end+1) = j;
                    end
                end
                idxFil = any(dataT.FilamentID == fList,2);   
                
                idxCampaign = dataT.Campaign == DPS.campaignMode;
                idxFailed = dataT.Failed < 1;
                idxSTL = dataT.STL_Mode > 9;
                idxMass = abs((dataT.Mass - dataT.TargetMass)./dataT.TargetMass)<.1;
                idxToughness = dataT.Toughness > 0.1;
                idxPrintable = dataT.Printable > -.5;
                idxCrit = dataT.CriticalEfficiency > 0;
                idxCH = dataT.CapHeight == 0;
                idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .05;
                idxCombined = idxFil & idxCampaign & idxFailed & idxSTL & idxMass & idxToughness & idxPrintable & idxCrit & idxCH & idxHeight;
                T{i} = dataT(idxCombined,:);
                
                
            case 300 %Squiggly Print Printability
                fList = [0];
                for j = 1:size(filamentIDT,1)
                    if strcmp(filamentIDT.TypeOfFilament{j},'NinjaflexSQG')
                        fList(end+1) = j;
                    end
                end
                fList(1) = [];
                idxFil = any(dataT.FilamentID(dataCamp.ID) == fList,2);  
                
                idxH = dataCamp.H == 30;
                idxPrintable = dataT.Printable(dataCamp.ID) ~= 0;
                idxCombined2 = idxFil & idxH & idxPrintable; 
                C{i} = dataCamp(idxCombined2,:);
                idxCombined = zeros(size(dataT,1),1,'logical');
                idxCombined(C{i}.ID,:) = 1;
                T{i} = dataT(idxCombined,:);
            
            case 301 % Squiggly Print
                fList = [0];
                for j = 1:size(filamentIDT,1)
                    if strcmp(filamentIDT.TypeOfFilament{j},'NinjaflexSQG')
                        fList(end+1) = j;
                    end
                end
                fList(1) = [];
                idxFil = any(dataT.FilamentID(dataCamp.ID) == fList,2);  
                
                idxH = dataCamp.H == 30;
                idxMod = dataCamp.Mod > 0;
                idxCombined2 = idxFil & idxH & idxMod; 
                C{i} = dataCamp(idxCombined2,:);
                idxCombined = zeros(size(dataT,1),1,'logical');
                idxCombined(C{i}.ID,:) = 1;
                T{i} = dataT(idxCombined,:);
                
        end
    end
end