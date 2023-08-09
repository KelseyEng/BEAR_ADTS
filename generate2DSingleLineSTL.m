%Kelsey Snapp
%Kab Lab
%3/25/21
%Calls Ben's STL Generator

function maxRadius = generate2DSingleLineSTL(dataT, ID, testT)
    filename = sprintf('STL\\ID%d.stl',ID);
    STL_Length = dataT.STL_Length(ID);
    C1T  = dataT.C1T(ID);
    C2T = dataT.C2T(ID);
    C1B = dataT.C1B(ID);
    C2B = dataT.C2B(ID);
    targetHeight = dataT.TargetHeight(ID);
    twist = dataT.Twist(ID);
    totalTwist = twist * targetHeight;
    wavelength = dataT.Wavelength(ID);
    period = wavelength * targetHeight;
    amplitude = dataT.Amplitude(ID);
    capHeight = dataT.CapHeight(ID);
    wallAngle = dataT.WallAngle(ID);
    STL_LengthVariation = calcSTL_LengthVariation(targetHeight,wallAngle);
    % Note: STL_LengthVariation is the total variation from top to bottom,
    % not the variation from the middle STL_Length to the top.
    
    if testT.STL
        currentPath = pwd;
        basePath = extractBefore(currentPath,'BEAR');
        pythonPath = strcat(basePath, 'SingleLineBen\2DCurves\myenv\Scripts\python.exe');
        if capHeight == 0
            pythonScript = char(strcat({' '}, basePath, 'SingleLineBen\2DCurves\TISC_cl.py'));
            pythonArguments = sprintf(' --c1_1 %f --c2_1 %f --c1_2 %f --c2_2 %f --T %f --target %f --H %d --name %s --Amp %f --Per %d --target_var %f', ...
                C1B, C2B, C1T, C2T, totalTwist, STL_Length, targetHeight, filename, amplitude, period, STL_LengthVariation);
        else
            pythonScript = char(strcat({' '}, basePath, 'SingleLineBen\2DCurves\TISC_cl_Cap.py'));
            pythonArguments = sprintf(' --c1_1 %f --c2_1 %f --c1_2 %f --c2_2 %f --T %f --target %f --H %d --name %s --Amp %f --Per %d --target_var %f --capH %f', ...
                C1B, C2B, C1T, C2T, totalTwist, STL_Length, targetHeight, filename, amplitude, period, STL_LengthVariation, capHeight);
        end

        command = strcat(pythonPath,pythonScript,pythonArguments); 

        [status,cmdout] = dos(command);
        indexStart = strfind(cmdout,'Max Radius:') + 11;
        indexEnd = strfind(cmdout(indexStart:end),':')+indexStart-2;
        maxRadius = str2num(cmdout(indexStart:indexEnd));

    end
end
