%Kelsey Snapp
%Kab Lab
%11/01/21
% Plots Critical Points

function fname = plotCriticalPoints(dataT,stressThreshData,stressThreshLimits,filamentIDT)

    idxSTL = dataT.STL_Mode > 9;
    idxToughness = dataT.Toughness > 0.1;
    idxMass = abs(dataT.TargetMass - dataT.Mass) ./ dataT.TargetMass < .33;
    idxPrintable = dataT.Printable > -1;
    idxTHeight = dataT.TargetHeight > 0; 
    idxHeight = abs(dataT.TargetHeight - dataT.Height) ./ dataT.TargetHeight < .1;
    idxDensity = dataT.Density == 1.2;
    idxCombined = idxSTL & idxToughness & idxMass & idxPrintable & idxHeight & idxDensity & idxTHeight;
    T = dataT(idxCombined,:);


    LWidth = .5;
    fontSize = 14;
    limits = [10^-5.1 10^2.1 10^-10 10^2];
    blue = [57 106 177]./255;
    red = [204 37 41]./255;
    black = [83 81 84]./255;
    green = [62 150 81]./255;
    purple = [107 76 154]./255;


    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    hold on
    grid on
    [yMax, ~] = max(stressThreshData(idxCombined,:)); 
    plot(stressThreshLimits,yMax./stressThreshLimits,'c','LineWidth',9*LWidth)
    
    %Calculate Last Day ID
    timeNow = exceltime(datetime);
    timeThresh = timeNow - 1;
    IDLimit = find(timeThresh < dataT.TimeInstronCrushed,1);

    

    %Plot Top Performers

    for ID = T.ID_Number'
        filamentID = dataT.FilamentID(ID);
        filamentType = filamentIDT.TypeOfFilament{filamentID};
        switch filamentType
            case 'Armadillo'
                style = red;
            case 'Cheetah'
                style = blue;
            case 'Ninjaflex'
                style = black;
            case 'PLA'
                style = green;
            otherwise
                style = purple;
        end
        if ID < IDLimit
            style = [175 175 175]/255;
        end
        if dataT.TargetMass(ID) == 3.3
            markerStyle = 'o';
        elseif dataT.TargetMass(ID) == 4
            markerStyle = 's';
        else
            markerStyle = 'd';
        end
        plot(dataT.CriticalStress(ID),dataT.CriticalEfficiency(ID),...
            'Marker',markerStyle,'MarkerFaceColor',style,'LineWidth',.5,'Color',style)
    end
    % plot(limits(1:2),[1,1],'r--')
    axis([limits(1:2),0,.8])
    %Format plot
    % set(gca,'YScale','log')
    set(gca,'XScale','log')

    % legend('NinjaFlex','Cheetah','Armadillo','Durable Resin','PLA','Location','best')
    xlabel('\sigma_{t} (MPa)')
    ylabel('K_s')
    title('Critical Points')
    set(gca,'FontSize',fontSize,'FontName','Arial','FontWeight','Bold','LineWidth',2,'XColor','k','YColor','k') 
    fname = 'CriticalPoints.jpg';
    saveas(fig,fname)
    close(fig)

end




