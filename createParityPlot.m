%Kelsey Snapp
%Kab Lab
%5/11/21
% Creates Parity Plot for model

function RMSE = createParityPlot(gprMdl,figureID)

    fig = figure(figureID);
    hold off
    yObs = gprMdl.Y;
    yPred = resubPredict(gprMdl);

    scatter(yObs, yPred)
    
    RMSE = sqrt(mean((yObs - yPred).^2));
    title(sprintf('Parity Plot: RMSE = %.2f',RMSE))
    xlabel('Observations (J/g)')
    ylabel('Model Predictions (J/g)')
    hold on
    maxP = max([yPred;yObs])*1.1;
    plot([0,maxP],[0,maxP])
    
    if figureID == 2
        saveas(fig,'parity.jpg')
    end
    
    

end