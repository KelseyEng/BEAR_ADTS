% Aldair E. Gongora
% March 12, 2020 

function [modulus,yield,stress25] = calcModulusYieldC3(ID,FDT,H,A,testT)

    %Returns modulus in MPa and yield in MPa

    fig = figure;


    %% Process Raw Force/Displacement Data 
       
    % force (N);
    [D,F,~] = processFDT(FDT,1); %mm and N and mm
    
    % displacement (m) 
    D = D ./ 1000;


    %% stress vs strain
    A = A./1e6; %m^2
    stress = (F)./A; %N/m^2

    H = H./1e3; %m
    strain = (D)./H; %m/m

    % stress (MPa) vs strain (mm/mm)

    colorvec = [169,169,169]./255;

    xq = 0:0.0001:0.6;

    plot(strain,stress./1e6,'LineWidth',4,'Color',colorvec);
    hold on


    set(gca,'FontSize',20,'LineWidth',2,'GridColor','k','XColor','k','YColor','k','ticklength',1*get(gca,'ticklength'))

    %% Find modulus
    sampleStart = 0.05;
    sampleSize = 0.1;
    strain_mod = strain(strain > sampleStart & strain <= sampleStart + sampleSize);
    stress_mod = stress(strain > sampleStart & strain <= sampleStart + sampleSize);

    % Fit a polynomial p of degree 1 to the (x,y) data:

    p = polyfit(strain_mod,stress_mod,1);

    % modulus (GPa)

    modulus = p(1)./1e6; %MPa


    % Evaluate the fitted polynomial p and plot:

    stress_mod_pred = polyval(p,strain_mod);

    color_orange = [224,146,28]./255;

    %plot(strain_mod,stress_mod_pred./1e6,'-','color',color_orange,'LineWidth',4)
    plot(strain_mod,stress_mod_pred./1e6,'-','color',[244,212,164]./255,'LineWidth',4)

    %% Plot yield stress (dotted Red Line

    % compute 0.2% offset
    x_modulus = -p(2)/p(1);
    x_offset = linspace(0.002+x_modulus,0.6,2);
    c = -p(1)*(0.002+x_modulus);
    y_offset = p(1)*x_offset + c;

    % plot 0.2% offset
    plot(x_offset,y_offset./1e6,'LineStyle','--','Color','r')
    hold on

    %% compute and plot yield stress point

    % compute yield stress point
    y_offset_check = p(1)*strain(strain>=mean(strain_mod)) + c;
    idxcheck1 = find(y_offset_check>=stress(strain>=mean(strain_mod)),1);
    stress_yieldcr = y_offset_check(idxcheck1);
    if ~isempty(stress_yieldcr)
        idxcheck = find(stress >= stress_yieldcr,1);

        % plot yield stress point

        scatter(strain(idxcheck),stress(idxcheck)./1e6,250,'Marker','o','MarkerFaceColor',color_orange,'MarkerFaceAlpha',0.4,'MarkerEdgeColor',colorvec,'LineWidth',0.5);

        yield = stress(idxcheck)./1e6; %MPa  
    else
        yield = -99;
    end
        xlim([0,0.5])
%         ylim([0,max(stress)./1e6*1.1])
%     set(gca, 'YScale', 'log')
    %% Plot 25% Stress
    index25 = find(strain>.25,1);
    stress25 = stress(index25)./1e6;
    plot(strain(index25),stress(index25)./1e6,'r*')

    %% figure formatting

    set(gca,'FontSize',20,'LineWidth',2,'GridColor','k','XColor','k','YColor','k','ticklength',1*get(gca,'ticklength'))
    xlabel('Strain')
    ylabel('Stress (MPa)')
    title(sprintf('Stress vs. Strain for ID %d',ID))
    fname = 'slack.jpg';
    saveas(fig,fname)   
    close(fig)
    if testT.Slack
        postSlackImg(fname)
    end

end