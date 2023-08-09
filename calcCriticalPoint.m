%Kelsey Snapp
%Kab Lab
%10/04/21
% Compute Critical Point

function  dataT = calcCriticalPoint(FDT,dataT,stressThreshData,stressThreshLimits,ID,testT)

    [D,F,~,~] = processFDT(FDT,1); %mm and N and mm
    % Calculate area and volume
    height = dataT.Height(ID); %mm
    area = dataT.EffectiveArea(ID); %mm^2
    vol = area * height; %mm^3

    % Check for high points
    numSearch = 10;
    numD = length(D);
    idxs = round(linspace(1,numD,numSearch + 1));
    for i = 1:numSearch
        stressThreshLimitsNew(i) = max(F(idxs(i):idxs(i+1)-1)) ./ area; %MPa       
    end
    
    stressThreshDataNew = calcStressThreshData(FDT,stressThreshLimitsNew,dataT,ID);
    
    %Combine new data with standard sampling
    stressThreshDataFinal = [stressThreshData(ID,:),stressThreshDataNew];
    stressThreshLimitsFinal = [stressThreshLimits,stressThreshLimitsNew];

    % Find Critical Points
    [~, criticalIndex] = max(stressThreshDataFinal./stressThreshLimitsFinal);
    dataT.CriticalStress(ID) = stressThreshLimitsFinal(criticalIndex);
    dataT.CriticalEfficiency(ID) =  stressThreshDataFinal(criticalIndex)/dataT.CriticalStress(ID);

   
    %Post Data to Slack
    selectedPrinter = dataT.PrinterNumber(ID);
    msg = sprintf('ID: %d  Printer: %d  CriticalStress: %.1e MPa   Efficiency: %.3f',...
        ID,...
        selectedPrinter,...
        dataT.CriticalStress(ID),...
        dataT.CriticalEfficiency(ID));
    postSlackMsg(msg,testT)
    
    % Check to see if better point could exists above instron limit
    maxF = max(F); %N
    maxStress = maxF ./ area; %MPa
    
    maxD = max(D); %mm
    maxStrain = maxD ./ height; %unitless
    
    toughness = trapz(D,F)./1000; %J
    
    stressThreshFinal = toughness./vol*1000; %MJ/m^3
    
    effFinal = stressThreshFinal ./ maxStress; % Unitless
    
    effPotential = effFinal + (1-maxStrain);
    
    if effPotential > dataT.CriticalEfficiency(ID)
        msg = sprintf('Warning: Instron Force limit reached. Potential efficiency could be as high as %.3f',...
            effPotential);
        postSlackMsg(msg,testT)
    end

end