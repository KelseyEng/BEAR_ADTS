%Updates Extrusion multiplier of .ini file. This allows us to get the
%target weight.
function changeINI(fname_ini,newNozTemp,fanOn,newRemovalTemp,newBedTemp)
    fname_temp = strrep(fname_ini,'.','temp.');

    fid = fopen(fname_ini,'rt');
    fid2 = fopen(fname_temp,'w');
    line = fgetl(fid);
    while ischar(line)
        if contains(line,'M109')
           index = strfind(line,'M109') + 6;
           line(index:index+2) = num2str(newNozTemp);
        elseif contains(line,'cooling')
            line = sprintf('cooling = %d',fanOn);
        elseif contains(line,'first_layer_bed_temperature =')
            line = sprintf('first_layer_bed_temperature = %d',newBedTemp);
        elseif contains(line,'bed_temperature =')
            line = sprintf('bed_temperature = %d',newBedTemp);
        elseif contains(line,'M140')
            index = strfind(line,'M140') + 5;
            index2 = strfind(line(index:end),' ');
            index2 = index2(1) + index-1;
            line = strcat(line(1:index),num2str(newRemovalTemp),line(index2:end));
        end
        fprintf(fid2,'%s\n',line);
        line = fgetl(fid);
    end
    fclose(fid);
    fclose(fid2);

    delete(fname_ini)
    movefile(fname_temp,fname_ini)

end

