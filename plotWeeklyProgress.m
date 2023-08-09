%Kelsey Snapp
%Kab Lab
%6/30/21
%Sends to Slack Graph of weekly count

function plotWeeklyProgress(dataT)

    LWidth = 2;
    fontSize = 14;

    dates = dataT.TimePrintStarted;
    timeOfDay = dates - fix(dates); 
    dates = floor(dates);
    startDate = 44326;
    dayCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    nightCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    notPrintableInstronCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    notPrintableCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    failedInstronProtocolCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    notPrintedCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    notWeighedCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    calibrationPrintCount = zeros(1,floor((max(dates)-startDate)/7)+1);
    CLS_PrintCount = zeros(1,floor((max(dates)-startDate)/7)+1);

    for i = 1:length(dates)
       week = floor((dates(i)-startDate)/7)+1;

       if dataT.TimePrintStarted(i) == 0
           %get week from previous print
           temp = dates(i);
           iter = 0;
           while temp == 0
               iter = iter + 1;
               temp = dates(i-iter);
           end  
           week = floor((temp-startDate)/7)+1;
           notPrintedCount(week) = notPrintedCount(week) + 1;

       elseif dataT.STL_Mode(i) < 6
           calibrationPrintCount(week) = calibrationPrintCount(week) + 1;

       elseif dataT.STL_Mode(i) == 8
           CLS_PrintCount(week) = CLS_PrintCount(week) + 1;

       elseif dataT.Printable(i) == -1
           if dataT.Toughness(i)>0
               notPrintableInstronCount(week) = notPrintableInstronCount(week) + 1;
           else
               notPrintableCount(week) = notPrintableCount(week) + 1;
           end

       elseif dataT.Mass(i) <= 0 
           notWeighedCount(week) = notWeighedCount(week) + 1;

       elseif dataT.Toughness(i)>0 && dataT.TimeInstronCrushed(i) > 0 
           if mod(dates(i)-startDate,7)>5
               nightCount(week) = nightCount(week) + 1;
           elseif timeOfDay(i)<.29 || timeOfDay(i) > .75
               nightCount(week) = nightCount(week) + 1;
           else
               dayCount(week) = dayCount(week) + 1;
           end

       elseif dataT.Toughness(i) <= 0
           failedInstronProtocolCount(week) = failedInstronProtocolCount(week) + 1;

       else 
           disp('Unable to categorize part')
           disp(i)
       end    
    end


    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    bar(1:length(dayCount),[dayCount;nightCount;calibrationPrintCount;CLS_PrintCount;failedInstronProtocolCount;notPrintableInstronCount;notPrintableCount;notWeighedCount;notPrintedCount],'stacked','LineWidth',LWidth); 
    set(gca,'FontSize',fontSize,'FontName','Arial','FontWeight','Bold','LineWidth',2,'XColor','k','YColor','k')  
    title('Samples Tested per Week')
    xlabel('Week')
    ylabel('Samples Tested by Week')
    legend('Printable Samples Tested Between 7am and 6pm','Printable Samples Tested During Night/Weekend', ...
        'Calibration Parts','Impact Parts','Failed Testing Protocol','Not Printable: Tested','Not Printable: Not Tested',...
        'Not Weighed','Not Printed','Location','Best')

    saveas(fig,'slack.jpg')
    close(fig)
    postSlackImg('slack.jpg')

end