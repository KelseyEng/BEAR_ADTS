%Kelsey Snapp
%Kab Lab
%5/27/22
%Plots visual representation of Decision Policy


function plotDecisionPolicy(ID,dataT,testT)

fnameLoad = sprintf('G:/My Drive/BEARData/GPRModel/ID%d.mat',ID);
fnameLoad2 = sprintf('U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/BEARVirtual/GPRModel/ID%d.mat',ID);

try
    load(fnameLoad2,'DP','yMuListOrig','stressThreshLimits','compLine','idxNewList','zMuList','xNew','xPredList','xObsList','yObsList','MdlList','zSdvList','DPS')
catch
    try
        load(fnameLoad,'DP','yMuListOrig','stressThreshLimits','compLine','idxNew','zMuList','xNew','xPredList','xObsList','yObsList','MdlList','zSdvList','DPS')
    catch
        disp('Unable to load GP Model')
        return
    end
end


fnameOut = 'slack.jpg';
LWidth = .5;
fontSize = 14;
limits = [10^-5.1 10^2.1 10^-10 10^2];
modulusAdj = 0.408;

%% Compute Rel Dens

vol = dataT.Height(ID) .* pi .* dataT.MaxRadius(ID).^2 / 1000; %cm^3
massRef = dataT.Density(ID).*vol; %g
relDens = dataT.Mass(ID)./massRef; %g
msg = sprintf('Measured Relative Density: %.2f',relDens);
postSlackMsg(msg,testT)


%% Get key information
% Define other parameters

for i = 1:length(DPS.yModeList)
    yMode = DPS.yModeList(i);
    switch yMode
        case 1 %Printability
            PTF = vertcat(yMuListOrig{:,i});
            PTFEnd = yMuListOrig{end,i};
        case 2 %Toughness/mass
            TM = vertcat(yMuListOrig{:,i});
            TMEnd = yMuListOrig{end,i};
        case 3 %Acceleration Model
            A = vertcat(yMuListOrig{:,i});
            AEnd = yMuListOrig{end,i};
        case 4 %Critical Stress
            critStress = vertcat(yMuListOrig{:,i});
            critStressEnd = yMuListOrig{end,i};
            critStressAll = yMuListOrig(:,i);
        case 5 %KS
            KS = vertcat(yMuListOrig{:,i});   
            KSEnd = yMuListOrig{end,i};
            KSAll = yMuListOrig(:,i);
        case 6 % Max Stress at 20 %Strain
            maxStress20 = vertcat(yMuListOrig{:,i});   
            maxStress20End = yMuListOrig{end,i};
            maxStress20All = yMuListOrig(:,i);  
        case 7 %Critical Force
            critForce = vertcat(yMuListOrig{:,i});
            critForceEnd = yMuListOrig{end,i};
            critForceAll = yMuListOrig(:,i);  
        case 8 % KSadjusted (Adedire)
            KSa = vertcat(yMuListOrig{:,i}); 
            KSaAll = yMuListOrig(:,i); 
            
    end
end
zMu = vertcat(zMuList{:}); 


%% Plot Decision Policy
if exist('critStress','Var') && exist('KS','Var')
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color','w');
    hold on
    grid on
    
    startNum = 1;
    for i = 1:length(xPredList)
        len = size(xPredList{i},1);
        endNum = startNum + len - 1;
        scatter(critStress(startNum:endNum),KS(startNum:endNum),5,'filled')
        startNum = endNum + 1;
    end
    
    plot(stressThreshLimits,compLine,'c','LineWidth',2)

    if exist('idxNewList','Var')
        for i = 1:length(idxNewList)
            switch i
                case 1
                    pcolor = 'g*';
                case 2
                    pcolor = 'y*';
                otherwise
                    pcolor = 'b*';
            end
            if DPS.RestrictGP == 1
                plot(critStressAll{i}(idxNewList{i}),KSAll{i}(idxNewList{i}),pcolor,'LineWidth',20)
            else
                plot(critStress(idxNew),KS(idxNew),pcolor,'LineWidth',20)
            end
        end
    end

    if dataT.CriticalEfficiency(ID) > 0
        plot(dataT.CriticalStress(ID),dataT.CriticalEfficiency(ID),'r*',...
            'LineWidth',20)
    end
    
    %Format plot
    selectedPrinter = dataT.PrinterNumber(ID);
    title(sprintf('Critical Points: Printer %d',selectedPrinter))
    set(gca,'XScale','log')
    xlabel('\sigma_{t} (MPa)')
    ylabel('K_s')
    axis([10^-5.1,10^2.1,0,.8])
    set(gca,'FontSize',14,'FontName','Arial','FontWeight','Bold','LineWidth',...
        2,'XColor','k','YColor','k')
    
    % Print how many samples in Zoomed in GP
    if length(yObsList) > 1
        numExp = length(yObsList{end,2});
        msg = sprintf('ID: %d  Number of Exp in Final GP: %d',ID,numExp);
        postSlackMsg(msg,testT)
    end

    saveas(fig,fnameOut)
    close(fig)
    postSlackImg(fnameOut)
elseif exist('maxStress20','Var') && exist('critForce','Var') && exist('KS','Var')
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color','w');
    hold on
    grid on
    
    startNum = 1;
    for i = 1:length(xPredList)
        len = size(xPredList{i},1);
        endNum = startNum + len - 1;
        scatter(maxStress20(startNum:endNum),KS(startNum:endNum).*critForce(startNum:endNum),5,'filled')
        startNum = endNum + 1;
    end

    
    if exist('idxNewList','Var')
        for i = 1:length(idxNewList)
            switch i
                case 1
                    pcolor = 'g*';
                case 2
                    pcolor = 'y*';
                otherwise
                    pcolor = 'b*';
            end
            if DPS.RestrictGP == 1
                plot(maxStress20All{i}(idxNewList{i}),KSEnd{i}(idxNewList{i}).*critForceEnd{i}(idxNewList{i}),pcolor,'LineWidth',20)
            else
                plot(maxStress20(idxNew),KS(idxNew).*critForce(idxNew),pcolor,'LineWidth',20)
            end
        end
    end
    

    if dataT.CriticalEfficiency(ID) > 0
        radius = dataT.MaxRadius(ID);
        area = pi.*(radius).^2; %mm^2
        area = area .* 6 ./ (sqrt(3) .* pi); %mm^2 (Adjustment for circle packing
        critForcePart = dataT.CriticalStress(ID) .* area; %N
        plot(dataT.MaxStress20(ID),dataT.CriticalEfficiency(ID).*critForcePart,...
            'r*','LineWidth',20)
    end
    
    %Format plot
    selectedPrinter = dataT.PrinterNumber(ID);
    title(sprintf('Printer %d',selectedPrinter))
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    xlabel('F_t * K_s (N)')
    ylabel('Max \sigma_{20} (MPa)')
    ylim([0,.8])
    set(gca, 'YDir','reverse')
    set(gca,'FontSize',14,'FontName','Arial','FontWeight','Bold','LineWidth',...
        2,'XColor','k','YColor','k')
    
    % Print how many samples in Zoomed in GP
    if length(yObsList) > 1
        numExp = length(yObsList{end,2});
        msg = sprintf('ID: %d  Number of Exp in Final GP: %d',ID,numExp);
        postSlackMsg(msg,testT)
    end

    saveas(fig,fnameOut)
    close(fig)
    postSlackImg(fnameOut)    
    
elseif exist('KSa','Var') %DP 24
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    set(gcf,'color','w');
    hold on
    histogram(KSa)
    if exist('idxNewList','Var')
        for i = 1:length(idxNewList)
            switch i
                case 1
                    pcolor = 'g--';
                case 2
                    pcolor = 'y--';
                otherwise
                    pcolor = 'b--';
            end
            if DPS.RestrictGP == 1
                xline(KSaAll{i}(idxNewList{i}),pcolor,'LineWidth',2)
            else
                xline(KSa(idxNewList{i}),pcolor,'LineWidth',2)
            end
        end
    end
    xline(dataT.KSadjusted(ID)+0.6015,'r--','LineWidth',2)
    saveas(fig,fnameOut)
    close(fig)
    postSlackImg(fnameOut)
end


%% Plot Distance Plot

fig = figure();
set(gcf,'color','w');
idx = DPS.FocusIdx;

xObsFull = xObsList{1,end};

minVal = min(xObsFull);
rangeVal = range(xObsFull);
rangeVal(rangeVal == 0) = 1;

if DP == 17 || DP == 25 || DP == 26 || DP == 27 || DP == 28
    rangeVal([7,12,13]) = inf;
end

for i = 1:size(xObsList,1)
    xObs = xObsList{i,idx};
    xObsNorm = (xObs-minVal)./rangeVal;
    xNewNorm = (xNew-minVal)./rangeVal;
    distVec = vecnorm(xObsNorm-xNewNorm,2,2);

    if DP == 16
        yObs = yObsList{i,2}.*yObsList{i,1};
    else
        yObs = yObsList{i,idx};
    end

    scatter(distVec,yObs,'filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
    hold on
end

xlabel('Normalized Distance')
if DP == 16
    ylabel('K_s * F_t')
    set(gca,'YScale','Log')
elseif exist('KSa','Var')
    ylabel('K_sa')
else
    ylabel('K_s')
end    
title('Normalized Distance from Selected Sample to Previously Tested Samples.')
set(gca, 'XScale', 'log')

saveas(fig,fnameOut)
close(fig)
postSlackImg(fnameOut)

%% Parity Plot
%Last GP 
idx = DPS.FocusIdx;
mdl = MdlList{end,idx};
yObs = yObsList{end,idx};
xObs = xObsList{end,idx};
yPred = predict(mdl,xObs);

rsEAE = corrcoef(yPred,yObs);
rsEAE = rsEAE(1,2)^2;

fig = figure();
set(gcf,'color','w');
scatter(yObs,yPred,10,'Filled','MarkerFaceAlpha',.2,'MarkerEdgeAlpha',.2)
hold on
maxAxis = max([yPred;yObs])*1.05;
minAxis = min([yPred;yObs])*0.95;
plot([minAxis,maxAxis],[minAxis,maxAxis],'--','Color',[.7,.7,.7],'LineWidth',2)
axis([minAxis,maxAxis,minAxis,maxAxis])
if exist('KSa','Var')
    xlabel('\boldmath$$K_sa$$','Interpreter','Latex')
    ylabel('\boldmath$$\hat{K_sa}$$','Interpreter','Latex')
else
    xlabel('\boldmath$$K_s$$','Interpreter','Latex')
    ylabel('\boldmath$$\hat{K_s}$$','Interpreter','Latex')
end
title(['R^2 = ',num2str(rsEAE)])
set(gca,'FontSize',fontSize,'FontName','Arial','FontWeight','Bold','LineWidth',2,'XColor','k','YColor','k') 
set(gcf,'color','w');
set(gca,'Layer','top');

saveas(fig,fnameOut)
close(fig)
postSlackImg(fnameOut)



end


