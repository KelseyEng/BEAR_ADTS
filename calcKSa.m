function ksa = calcKSa(ID_New)
    % Process FDTn
    FDTn = sprintf('Instron/ID%d.csv',ID_New);
    FDTnint = process_csv_file(FDTn);

    % Process FDTb
    FDTb = 'Instron/ID25839.csv';
    FDTbint = process_csv_file(FDTb);

    % Combine the matrices
    FDTcomb = [FDTnint(:,1) + FDTbint(:,1), FDTbint(:,2), FDTnint(:,3) + FDTbint(:,3)];

    % Assign height and area
    area = 1142.2; %mm^2

    % Assign desired Stress Values
    stressThreshLimits = logspace(-5, 2, 1400);

    % Call the new function processMultipleFDTs
    [criticalEfficiencyn, criticalEfficiencyb, criticalEfficiencycomb] = processMultipleFDTs(FDTnint, FDTbint, FDTcomb, stressThreshLimits, area);

    ksa = criticalEfficiencyn - criticalEfficiencyb;

    function FDTint = process_csv_file(filename)
        % Load the data from the CSV file
        T = csvread(filename, 3, 0);
    
        diffD = diff(T(:,2));
        [minD, latchOne] = min(diffD);
        if isscalar(latchOne) && isscalar(minD) && latchOne > 1 && minD < -5
            T = T(1:latchOne,:);
        end
        Time = T(:,1);
        D = T(:,2); 
        F = T(:,3);
        idx = find(F>0.003);
        Time = Time(idx:end);
        D = D(idx:end);
        F = F(idx:end);
    
        % New code starts here
        [D, idx_unique] = unique(D); % Remove duplicates from D
        Time = Time(idx_unique); % Remove corresponding entries from Time
        F = F(idx_unique); % Remove corresponding entries from F
        D_interp = 181.1:0.01:223.1; % Create the interpolated D values
        Time_interp = interp1(D, Time, D_interp); % Interpolate Time at the new D values
        F_interp = interp1(D, F, D_interp); % Interpolate F at the new D values
    
        % Replace NaN values with zeros
        Time_interp(isnan(Time_interp)) = 0;
        F_interp(isnan(F_interp)) = 0;
    
        % Combine the interpolated Time, D, and F values into a single matrix
        FDTint = [Time_interp', D_interp', F_interp'];
    end
    

    function [criticalEfficiencyn, criticalEfficiencyb, criticalEfficiencycomb] = processMultipleFDTs(FDTn, FDTb, FDTcomb, stressThreshLimits, area)
        % Process each dataset separately
        criticalEfficiencyn = processData(FDTn, stressThreshLimits, area);
        criticalEfficiencyb = processData(FDTb, stressThreshLimits, area);
        criticalEfficiencycomb = processData(FDTcomb, stressThreshLimits, area);
    end
    

    function criticalEfficiency = processData(FDT, stressThreshLimits, area)
           [D,F,PS,FDT2] = processFDT(FDT);
        height = PS(1);
        if ~isempty(FDT2)
            [~,~,PS2,~] = processFDT(FDT2);
            reboundHeight = min(PS2);
        end
    
        % Calculate stress thresh data
        stressThreshData = calcStressThreshData(D,F,stressThreshLimits,area,height);
    
        % calculate critical point
        [~,criticalEfficiency,~] = calcCriticalPoint(D,F,stressThreshData,stressThreshLimits,area,height); %critical stress = MPa
    
        % The function now returns only the criticalEfficiency value
    end

    function stressThreshData = calcStressThreshData(D, F, stressThreshLimits, area, height)
            % Calculate area and volume
        volume = area * height; %mm^3
        
        % Calculate Threshold Data
        count = 1;
        toughness = zeros(1,size(stressThreshLimits,2));
        for thresh = stressThreshLimits.*area %N
            idx = find(F > thresh,1) -1;
            if isempty(idx)
                idx = length(D);
            end
            if idx < 2
                toughness(count) = 0;
            else
                toughness(count) = trapz(D(1:idx),F(1:idx))./1000; %J
            end
            count = count + 1;
        end
    
        stressThreshData = toughness./volume*1000; %MJ/m^3
    
    end

    function [D, F, PS, FDT2] = processFDT(FDT)
          fThresh = 0.3; %N
    
        %Exclude Tap Data
        diffD = diff(FDT(:,2));
        [minD,latchOne] = min(diffD);
        if latchOne > 1 && minD < -5
            FDT2 = FDT(latchOne+1:end,:);
            FDT = FDT(1:latchOne,:);
        else
            FDT2 = [];
        end    
        
        % Separate Data into Force and Displacement
        D = FDT(:,2) - min(FDT(:,2)); %mm
        F = FDT(:,3) * 1000; %N
        
        % Remove force data below threshold
    
        Ftrail = movmedian(F,[0,19]);
        idxContact = find(Ftrail > fThresh,1); 
        idxContact2 = find(F(idxContact:end) > fThresh,1);
        idxContact = idxContact + idxContact2;
        D = D(idxContact:end); %1 N threshold
        F = F(idxContact:end);    
        D = D - min(D); 
    
        
        PS = 223.1 - FDT(:,2);
        PS = PS(idxContact:end);
    
    end
    

    function [criticalStress, criticalEfficiency, effPotential] = calcCriticalPoint(D, F, stressThreshData, stressThreshLimits, area, height)
            numSearch = 10;
        numD = length(D);
        idxs = round(linspace(1, numD, numSearch + 1));
    
        stressThreshLimitsNew = max(reshape(F(idxs(1:end-1)), [], 1) ./ area); 
    
        stressThreshDataNew = calcStressThreshData(D,F,stressThreshLimitsNew,area,height);
    
        stressThreshDataFinal = [stressThreshData,stressThreshDataNew];
        stressThreshLimitsFinal = [stressThreshLimits,stressThreshLimitsNew];
    
        [~, criticalIndex] = max(stressThreshDataFinal./stressThreshLimitsFinal);
        criticalStress = stressThreshLimitsFinal(criticalIndex);
        criticalEfficiency =  stressThreshDataFinal(criticalIndex)/criticalStress;
    
        maxF = max(F); %N
        maxStress = maxF ./ area; %MPa
    
        maxD = max(D); %mm
        maxStrain = maxD ./ height; %unitless
    
        toughness = trapz(D,F)./1000; %J
        vol = area * height; %mm^3
        stressThreshFinal = toughness./vol*1000; %MJ/m^3
    
        effFinal = stressThreshFinal ./ maxStress; % Unitless
        effPotential = effFinal + (1-maxStrain);
    end
end