%Kelsey Snapp
%Kab Lab
%6/10/21
%plots mass, ext mult, and filament length

function plotMassAndExtrusion(dataT,printerT)

    count = 0;
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    for selectedNozzle = 0:1
        for selectedPrinter = printerT.AvailablePrinters{1}
            count = count + 1;
            subplot(2,length(printerT.AvailablePrinters{1}),count)
            filamentID = printerT.Filament{1}(selectedNozzle+1,selectedPrinter);
            indexSTL = dataT.STL_Mode == 11;
            indexPrinter = dataT.PrinterNumber == selectedPrinter;
            indexNozzle = dataT.PrinterNozzle == selectedNozzle;
            indexMass = dataT.Mass > 2;
            indexFilament = dataT.FilamentID == filamentID;
            dataTemp = dataT(indexSTL & indexNozzle & indexPrinter & indexMass & indexFilament,:);
            if ~isempty(dataTemp)
                plot(dataTemp.Mass)
                hold on
                plot(dataTemp.ExtrusionMultiplier)
                plot(dataTemp.FinalFilamentLength./dataTemp.FinalFilamentLength(1))
                if count == 1
                    legend('Mass','ExtrusionMult','Filament Length','Location','best')
                end
            end
            title(sprintf('Printer %d, nozzle %d',selectedPrinter,selectedNozzle))
        end
    end

    saveas(fig,'slack.jpg')
    close(fig)
    postSlackImg('slack.jpg')
end




