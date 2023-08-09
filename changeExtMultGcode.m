%Kelsey Snapp
%Kab Lab
%8/4/22
% Edits gcode to change the extrusion multiplier based on height

function ETotal = changeExtMultGcode(fname_Original,capExtMult2,heightTarget)
    fname_temp = 'temp.gcode';
    change = 0;
    ETotal = 0;
    EOld = 0;
    ENew = 0;
    capExtMult = 1;
    fid = fopen(fname_Original,'rt');
    fid2 = fopen(fname_temp,'w');
    line = fgetl(fid);
    while ischar(line)
        if isempty(line)
            line = fgetl(fid);
            continue
        end
        if contains(line,';')
            idx = strfind(line,';');
            line2 = line(idx:end);
            line = line(1:idx-1);
            commentLine = 1;
        else
            commentLine = 0;
        end
        if isempty(line)
        else
            if contains(line,'G92')
                if contains(line,'E')
                    EOld = getVal(line,'E');
                end
            end
            if change == 0 && contains(line,'Z') 
                % Check if height above threshold
                height = getVal(line,'Z');
                if height >= heightTarget
                    change = 1;
                    capExtMult = capExtMult2;
                end
            end
            if contains(line,'E') && contains(line,'G1')
                ECurrent = getVal(line,'E');
                EDiff = ECurrent - EOld;    
                EDiff = EDiff*capExtMult;
                ETotal = ETotal + EDiff;
                ENew = ENew + EDiff;
                line = replaceVal(line,'E',ENew);
                EOld = ECurrent;
            end         
        end
        if commentLine
            line = strcat(line,line2);
        end   
        fprintf(fid2,'%s\n',line);
        line = fgetl(fid);
    end
    fclose(fid);
    fclose(fid2);
    
    delete(fname_Original)
    movefile(fname_temp,fname_Original)
end



function val = getVal(line,letter)
    idx = strfind(line,letter) + 1;
    idx2 = strfind(line(idx:end),' ');
    if isempty(idx2)
        idx2 = length(line);
    else
        idx2 = idx2(1) + idx-1;
    end
    val = str2double(line(idx:idx2));
end

function line = replaceVal(line,letter,val)
    idx = strfind(line,letter) + 1;
    idx2 = strfind(line(idx:end),' ');
    if isempty(idx2)
        idx3 = [];
    else
        idx3 = idx2(1) + idx;
    end
    line = strcat(line(1:idx-1),num2str(val),line(idx2:end));
end

