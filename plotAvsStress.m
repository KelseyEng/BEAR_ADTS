%Kelsey Snapp
%Kab Lab
%11/01/21
% Plots Critical Points

function fname = plotAvsStress(dataT,filamentIDT)

    %% Select Parts
    fList = [0];
    for i = 1:size(filamentIDT,1)
        if strcmp(filamentIDT.TypeOfFilament{i},'Cheetah')
            fList(end+1) = i;
        end
    end
    fList(1) = [];
    indexFil = any(dataT.FilamentID == fList,2);        


    idxSTL = dataT.STL_Mode > 9;
    idxToughness = dataT.Toughness > 0.1;
    idxTMass = dataT.TargetMass == 2.1;
    idxMass = dataT.Mass > 1.89 & dataT.Mass < 2.31;
    idxPrintable = dataT.Printable > -1;
    idxNozzle = dataT.NozzleSize == 0.75;

    indexCombined = idxSTL & idxToughness & idxTMass & idxMass & idxPrintable & indexFil & idxNozzle;
    T = dataT(indexCombined,:);
    
    xObs = [T.C1T,T.C2T,T.C1B,T.C2B,T.Twist,T.WallThickness,log(T.FilamentModulus),T.Period,T.Amplitude,...
        T.STL_LengthRatio,T.TargetMass,log(T.Stress25)];

    %% Get data for plotting
    maxStress = T.MaxStress20;
    
    GP_Path = 'U:/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/GPModels/GP_DP15Task2.mat';
    load(GP_Path,'gprMdl')
    aPred = predict(gprMdl,xObs);
    
    
    %% Plot

    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color','w');
    scatter(maxStress,aPred,'b','Filled')
    hold on
    set(gca,'FontSize',14,'FontName','Arial','FontWeight','Bold','LineWidth',2,'XColor','k','YColor','k') 
    xlabel('\sigma_{0.2} (MPa)')
    ylabel('a_{pred}')
    title('3.6 m/s protocol')
    set(gca, 'XScale', 'log')
    hold on
    plot([10^-4,10^2],[175,175],'r--')
    plot([10^-2,10^-2],[0,1000],'r--')


    % Find pareto front

    [pList,~] = paretoFront(maxStress,aPred,-1,-1);
    scatter(pList(:,1),pList(:,2),'r','Filled')
    
    %Plot recent
    
    timeNow = exceltime(datetime);
    timeThresh = timeNow - 1;
    IDLimit = find(timeThresh < dataT.TimeInstronCrushed,1);
    
    idx = T.ID_Number > IDLimit;
    scatter(maxStress(idx),aPred(idx),'g','Filled')


    fname = 'AvsStress.jpg';
    saveas(fig,fname)
    close(fig)

end




