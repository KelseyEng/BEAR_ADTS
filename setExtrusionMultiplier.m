%Updates Extrusion multiplier of .ini file. This allows us to get the
%target weight.
function setExtrusionMultiplier(fname_ini,newValue)
    fname_temp = strrep(fname_ini,'.','temp.');

    fid = fopen(fname_ini,'rt');
    fid2 = fopen(fname_temp,'w');
    line = fgetl(fid);
    while ischar(line)
        if contains(line,'extrusion_multiplier')
           line = sprintf('extrusion_multiplier = %.02f,%.02f',newValue,newValue);
        end
        fprintf(fid2,'%s\n',line);
        line = fgetl(fid);
    end
    fclose(fid);
    fclose(fid2);

    delete(fname_ini)
    movefile(fname_temp,fname_ini)

end

