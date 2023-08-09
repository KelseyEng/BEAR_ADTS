%Kelsey Snapp
%Kab Lab
%8/2/2023
%Updates temperatures of gcode.


function changeGcode(fname,nozTemp,removalTemp)
    fname_temp = strrep(fname,'.','temp.');

    fid = fopen(fname,'rt');
    fid2 = fopen(fname_temp,'w');
    line = fgetl(fid);
    while ischar(line)
        
        % Set nozzle temp
        if isempty(line)
            
        elseif strcmp(line(1),';')
            
        elseif contains(line,'M109')
           index = strfind(line,'M109') + 6;
           line(index:index+2) = num2str(nozTemp);
           
        % Set bed removal temp (note: M190 is used to set bed print temp, M140
        % is used to set bed removal temp)
        elseif contains(line,'M140')
            index = strfind(line,'M140') + 5;
            index2 = strfind(line(index:end),' ');
            index2 = index2(1) + index-1;
            line = strcat(line(1:index),num2str(removalTemp),line(index2:end));
            
        end
        fprintf(fid2,'%s\n',line);
        line = fgetl(fid);
    end
    fclose(fid);
    fclose(fid2);

    delete(fname)
    movefile(fname_temp,fname)

end

