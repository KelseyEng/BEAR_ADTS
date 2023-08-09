%Kelsey Snapp
%Kab Lab
%3/25/21
%Calls Ben's STL Generator

function [targetMass,filamentLength,layers] = generateSquiglyGcode(dataC,ID,testT)
    row = find(dataC{3}.ID == ID);
    vStar = dataC{3}.Vstar(row); 
    hStar = dataC{3}.Hstar(row);
    dL = dataC{3}.Dl(row); %mm
    dZ = dataC{3}.Dz(row); %mm 
    L = dataC{3}.L(row); %mm
    H = dataC{3}.H(row); %mm
    eDot = dataC{3}.Edot(row); %mm/min
    eMult = dataC{3}.Emult(row); % unitless
    alpha = dataC{3}.Alpha(row); %unitless
    filename = sprintf('ID%d',ID);
    
    
    if testT.STL
        currentPath = pwd;
        basePath = extractBefore(currentPath,'BEAR');
        pythonPath = strcat(basePath, 'vtp-foams\myenv\Scripts\python.exe');
        prePath = strcat(basePath, 'BEAR\PreAppend.txt');
        postPath = strcat(basePath, 'BEAR\PostAppend.txt');

        
        pythonScript = char(strcat({' '}, basePath, 'vtp-foams\foam_gcode.py'));
        pythonArguments = ...
            sprintf(' %f %f %f %f -H %f -L %f -Edot %d -alpha %f -t %s --header %s --footer %s --path %s --bedX %d --bedY %d --Emult %.3f',...
            vStar,...
            hStar,...
            dL,...
            dZ,...
            H,...
            L,...
            eDot,...
            alpha,...
            filename,...
            prePath,...
            postPath,...
            currentPath,...
            250,...
            210,...
            eMult);


        command = strcat(pythonPath,pythonScript,pythonArguments); 

        [status,cmdout] = dos(command);
        
        idxStart = strfind(cmdout,'Length of Filament Fed = ') + 25;
        idxEnd = strfind(cmdout(idxStart:end),' ') + idxStart - 2;
        idxEnd = idxEnd(1);
        filamentLength = str2double(cmdout(idxStart:idxEnd)); %mm
        
        
        idxStart = strfind(cmdout,'Part Mass = ') + 12;
        idxEnd = strfind(cmdout(idxStart:end),' ') + idxStart - 2;
        idxEnd = idxEnd(1);
        targetMass = str2double(cmdout(idxStart:idxEnd)); %g
        
        idxStart = strfind(cmdout,'Layers In Cube = ') + 17;
        idxEnd = strfind(cmdout(idxStart:end),' ') + idxStart - 2;
        idxEnd = idxEnd(1);
        layers = str2double(cmdout(idxStart:idxEnd)); %g


    end
end
