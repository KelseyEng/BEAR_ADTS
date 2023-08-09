%Kelsey Snapp
%Kab Lab
%6/17/21
%Scrapes printer with spatula


function printerT = scrapePrinter(selectedPrinter,printerT)

    if selectedPrinter == 6
        disp('Printer 6 not clean. Please clear by hand.')
        return
    end
            
    readyPrinter(selectedPrinter)
    
    command = ['python controlUR5.py ','/programs/RG2/scraperPick.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    command = sprintf('python controlUR5.py /programs/RG2/scrapeP%d.urp',selectedPrinter);
    protectiveStop = moveUR5AndWait(command);
    
    command = ['python controlUR5.py ','/programs/RG2/scraperDrop.urp'];
    protectiveStop = moveUR5AndWait(command);

end