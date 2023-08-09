% KAB Lab
% Kelsey Snapp
% 6/30/2023
% Process data on its side

function dataC = processSideTest(dataT,dataC,ID,instronCountOffset,instronPath,testT)
    dataC_Row = find(dataC{3}.ID == ID,1);
    if isempty(dataC_Row)
        return
    end
    instronTestNumber = dataC{3}.InstronTestNumber(dataC_Row) -instronCountOffset;
    fnameClipped = sprintf('SampleData_1_%d.csv',instronTestNumber);
    fnameSrc = strcat(instronPath,fnameClipped);
    if isfile(fnameSrc)
        fnameDst = sprintf('Instron\\ID%d_Side.csv',ID);
        fnameDst2 = sprintf('G:/My Drive/BEARData//Instron/ID%d_Side.csv',ID);
        try
            copyfile(fnameSrc,fnameDst)
            try
                copyfile(fnameSrc,fnameDst2)
            end
            pause(.5)
            FDT = csvread(fnameDst,3,0);
            FDT(1,:) = [];
            if size(FDT,1) < 10
                return
            end
            height = calcHeight(FDT); %mm
            dataC{3}.SideHeight(dataC_Row) = height;
            EffectiveArea = height * dataT.Height(ID); %mm^2 (Assume second side is same as first height)
            dataC{3}.SideEffectiveArea(dataC_Row) = EffectiveArea;
            [mod,~,~] = calcModulusYieldC3(ID,FDT,height,EffectiveArea,testT);
            dataC{3}.SideMod(dataC_Row) = mod;
        catch
            fprintf('Unable to process side test for ID%d.\n',ID)
        end

end