%Kelsey Snapp
%Kab Lab
%5/11/21
% Creates splot of std dev vs. distance

function createLengthScalePlot(gprMdl,sigmaML,figureID)

    fig = figure(figureID);
    hold off
    xPred = gprMdl.X;
    yPred = resubPredict(gprMdl);
    currentSize = size(xPred,1);
    if currentSize > 100
        index = randperm(currentSize,100);
        xPred = xPred(index,:);
        yPred = yPred(index,:);
    end
    
    for row = 1:(size(xPred,1)-1)

        distance = xPred((row+1):end,:) - xPred(row,:);
        distanceAdjusted = distance./(sigmaML');
        EuclidDistance = vecnorm(distanceAdjusted')';       
        yDiff = abs(yPred((row+1):end,:) - yPred(row));
        c = abs(distance(:,7));
        scatter(EuclidDistance,yDiff,[],c)
        hold on
        

    end
    xlabel('Normalized distance between 100 random points')
    ylabel('Difference in Toughness per mass (J/g)')
    title('Visualization of Length Scales for Latest GP')
    c = colorbar;
    c.Label.String = 'Normalized Modulus Distance';
    saveas(fig,'lengthScale.jpg')    


end