%Kelsey Snapp
%Kab Lab
%3/25/21

function img = imageBed(ID,selectedPrinter,status,required,testT)

    camName = camNameFunction();

    command = sprintf('python controlUR5.py /programs/RG2/moveP%d.urp',selectedPrinter);
    protectiveStop = moveUR5AndWait(command);
    
    command = sprintf('python controlUR5.py /programs/RG2/cameraBedP%d.urp',selectedPrinter);
    protectiveStop = moveUR5AndWait(command);
    
    %Get Picture on bed
    if strcmp(status,'bedEmptyPre') || strcmp(status,'manual')
        picName = strcat('pictures//',sprintf('%sP%dN%d.png', status,selectedPrinter, ID));
    else
        picName = strcat('pictures//',sprintf('%s%d.png', status,ID));
    end
    
    img = takePicture(camName, picName, required,0); 
        
    if strcmp(status,'bedEmptyPre') || strcmp(status,'manual')
        command = sprintf('python controlUR5.py /programs/RG2/moveP%d.urp',selectedPrinter);
        protectiveStop = moveUR5AndWait(command);
    end
    
    if protectiveStop
        protectiveStopHelp(testT)
    end
    
end