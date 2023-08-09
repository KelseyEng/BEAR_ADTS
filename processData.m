
% KAB Lab
% Kelsey Snapp
% 6/6/2023
% Process data for GP use alter



function [dataT,printerT,filamentIDT,stressThreshData,dataC] = processData(FDT,dataT,...
    testT,ID,filamentIDT,printerT,stressThreshData,stressThreshLimits,dataC)


    dataT.Height(ID) = calcHeight(FDT); %mm
    checkHeight(dataT,testT,ID);

    if dataT.STL_Mode(ID) == 1 || dataT.STL_Mode(ID) == 301
        filamentID = dataT.FilamentID(ID);
        r = filamentIDT.CylinderDiameter(filamentID)/2;
        H = filamentIDT.CylinderHeight(filamentID);
        A = pi*r.^2; 
        [filamentIDT.CylinderModulus(filamentID),~,filamentIDT.Stress25(filamentID)] = ...
            calcModulusYield(ID,FDT,H,A,testT);
        selectedPrinter = dataT.PrinterNumber(ID);
        selectedNozzle = dataT.PrinterNozzle(ID);
        printerT.Modulus{1}(selectedNozzle+1,selectedPrinter) = ...
            filamentIDT.CylinderModulus(filamentID);
        printerT.Stress25{1}(selectedNozzle+1,selectedPrinter) = ...
            filamentIDT.Stress25(filamentID);
        writetable(filamentIDT,'FilamentLog.xlsx');                                
    elseif dataT.STL_Mode(ID) == 7
        fname = plotFD(dataT,ID);
        postSlackImg(fname)
    elseif dataT.STL_Mode(ID) == 13
        fname = plotFD(dataT,ID);
        postSlackImg(fname)
        stressThreshData(ID,:) = calcStressThreshData(FDT,stressThreshLimits,dataT,ID);
        dataT = calcCriticalPoint(FDT,dataT,stressThreshData,stressThreshLimits,ID,testT);
        dataT.DensificationStrain(ID) = calcDensificationStrain(FDT,dataT,ID); %unitless
        dataT.ReboundHeight(ID) = calcReboundHeight(FDT); %mm
        % Save data to G drive
        toPrintFname = 'G:/My Drive/PrivateData/Adedire/ToPrintGcodeList.xlsx';
        if ~exist(toPrintFname,'file')
            postSlackMsg('ToPrintGcodeList.xlsx file found')
        else
            try
                toPrintTable = readtable(toPrintFname);
                row = find(toPrintTable.CurrentBearID == ID);
                toPrintTable.CritStress_MPa(row) = dataT.CriticalStress(ID);
                toPrintTable.CritEff(row) = dataT.CriticalEfficiency(ID);
                writetable(toPrintTable,toPrintFname)
                clear toPrintTable
            catch
                postSlackMsg('Unable to save ToPrintGcodeList.xlsx file.')
            end
        end
    else
        dataT.Toughness(ID) = calcToughness(FDT); %J
        dataT.aPred(ID) = calcAPred(FDT); % g
        dataT.MaxD(ID) = calcMaxDisplacement(FDT);
        
        dataT.MaxStress20(ID) = calcMaxStressBeforeStrain(FDT,dataT,ID,.2); %MPa
        dataT.Stress20(ID) = calcStressAtStrain(FDT,dataT,ID,.2); %MPa
        stressThreshData(ID,:) = calcStressThreshData(FDT,stressThreshLimits,dataT,ID);
        dataT = calcCriticalPoint(FDT,dataT,stressThreshData,stressThreshLimits,ID,testT);
        dataT.DensificationStrain(ID) = calcDensificationStrain(FDT,dataT,ID); %unitless
        dataT.ReboundHeight(ID) = calcReboundHeight(FDT); %mm
        if dataT.Campaign(ID) == 1
            dataT.KSadjusted(ID) =  calcKSa(ID); %
            if dataT.MaxD(ID)/dataT.Height(ID) < 0.3
                dataT.Printable(ID) = -1.1;
            end
            plotDecisionPolicy(ID,dataT,testT)
        end
        if dataT.Campaign(ID) == 3
            [mod,~,~] = calcModulusYieldC3(ID,FDT,dataT.Height(ID),dataT.EffectiveArea(ID),testT);
            dataC_Row = find(dataC{3}.ID == ID,1);
            dataC{3}.Mod(dataC_Row) = mod;
        end
        dataT.SimulatedData(ID) = 0;
    end
    
end