%Kelsey Snapp
%Kab Lab
%3/18/21
%Parses the string return from octocomand

function bedTemp = parseBedTemp(dosmsg)
    try
        tempStart = strfind(dosmsg, 'bed: actual=');
        tempStart = tempStart(1) + 12;
        tempEnd = strfind(dosmsg, ',');
        tempEnd(tempEnd<tempStart) = [];
        tempEnd = tempEnd(1)-1;
        bedTemp = str2num(dosmsg(tempStart:tempEnd));
    catch
        disp('Unable to parse bed temp')
        bedTemp = NaN;
    end
end