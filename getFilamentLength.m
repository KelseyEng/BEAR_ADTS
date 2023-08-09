%Gets filament Length from GCode

function filamentLength = getFilamentLength(ID)

    fname = sprintf('gcode\\ID%d.gcode',ID);

    fid = fopen(fname,'r');
    line = fgetl(fid);
    while ischar(line)
        if contains(line,'filament used')
            startVal = strfind(line,'=')+2;
            endVal = strfind(line,'mm')-1;
            filamentLength = str2double(line(startVal:endVal));
           break
        end
        
        line = fgetl(fid);
    end
    fclose(fid);
end

