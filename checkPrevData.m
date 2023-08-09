%Kelsey Snapp
%Kab Lab
%6/7/22
% Checks each row in to print table. If there is a row with a previousID
% but not a C1T value, it fills in data needed from previous sample id.





function toPrintTable = checkPrevData(toPrintTable,dataT,toPrintFname,filamentIDT)
    anythingChange = 0;
    for row = 1:size(toPrintTable,1)
        if ~isnan(toPrintTable.C1T(row)) || isnan(toPrintTable.PreviousID(row))
            continue
        else
            prevID = toPrintTable.PreviousID(row);
            toPrintTable.TargetMass(row) = dataT.TargetMass(prevID);
            toPrintTable.NozzleSize(row) = dataT.NozzleSize(prevID);
            filamentID = dataT.FilamentID(prevID);
            toPrintTable.FilamentType(row) = filamentIDT.TypeOfFilament(filamentID);
            toPrintTable.C1T(row) = dataT.C1T(prevID);
            toPrintTable.C2T(row) = dataT.C2T(prevID);
            toPrintTable.C1B(row) = dataT.C1B(prevID);
            toPrintTable.C2B(row) = dataT.C2B(prevID);
            toPrintTable.Twist(row) = dataT.Twist(prevID);
            toPrintTable.Wavelength(row) = dataT.Wavelength(prevID);
            toPrintTable.Amplitude(row) = dataT.Amplitude(prevID);
            toPrintTable.WallAngle(row) = dataT.WallAngle(prevID);
            toPrintTable.WallThickness(row) = dataT.WallThickness(prevID);
            toPrintTable.TargetHeight(row) = dataT.TargetHeight(prevID);
            toPrintTable.CapHeight(row) = dataT.CapHeight(prevID);
            toPrintTable.CapExtMult(row) = dataT.CapExtMult(prevID);
            anythingChange = 1;
        end    
    end
    if anythingChange
        writetable(toPrintTable,toPrintFname)
    end 
end
    
    




