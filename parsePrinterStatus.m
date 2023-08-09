%Kelsey Snapp
%Kab Lab
%3/18/21
%Parses the string return from octocomand

function readyStatus = parsePrinterStatus(dosmsg)

    readyStart = strfind(dosmsg, 'ready=');
    readyStart = readyStart(1) + 6;
    if dosmsg(readyStart) == 'T'
        readyStatus = 3; %if ready is true, set state to 3 for done printing
    else
        readyStatus = 2; %If false, set to 2 for still printing.
    end
end