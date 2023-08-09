%Kelsey Snapp
%Kab Lab
%11/01/21
% Plots Critical Points

function fname = plotFD(dataT,ID)
    LWidth = 2;
    fontSize = 14;
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    try
        fullpath = ['Instron\\ID',num2str(ID),'.csv'];  
        FDT = csvread(fullpath,3,0);
        FDT(1,:) = [];
        diffD = diff(FDT(:,2));
        [minD,latchOne] = min(diffD);
        if latchOne > 1 && minD < -5
            FDT = FDT(1:latchOne,:);
        end
        D = 223.1 - FDT(:,2); 
        F = FDT(:,3)*1000;

        p = plot(D,F,'k','LineWidth',LWidth, 'DisplayName','Experimental Data'); 
        set(gca,'Layer','Top', 'xdir', 'reverse')
        set(gcf,'color','white')
        hold on        
        set(gca,'FontSize',fontSize,'FontName','Arial','FontWeight','Bold','LineWidth',LWidth,'XColor','k','YColor','k')   
        yline(4500,'r-.','LineWidth',LWidth,'DisplayName','Maximum Force')
        set(gca,'Layer','Top')
        area = dataT.EffectiveArea(ID);
        if area > 0
            cutoffPoint = dataT.CriticalStress(ID)*area;
            yline(cutoffPoint,'b--','LineWidth',LWidth,'DisplayName','Most Efficient Force')
        end
        hold off
        set(gca,'Layer','Top')
        set(gca,'YScale','log')
        legend('Location','southeast')
        xlabel('Platen Separation (mm)')
        ylabel('Force (N)')
        ylim([1,10000]);
        t= sprintf("Uniaxial Compression of ID %d", ID);
        title(t)
    catch
        img = 0;
        imshow(img)
    end
    fname = 'FD.jpg';
    saveas(fig,fname)
    close(fig)

end




