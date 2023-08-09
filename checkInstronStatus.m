%Kelsey Snapp
%Kab Lab
%3/18/21
% Checks to see if Instron has finished Crushing.


function instronStatus = checkInstronStatus(a)

    try
        status = readDigitalPin(a,'D8'); % 0 means running, 1 means test ended. 
        instronStatus = ~status;
    catch
        postSlackMsg('Unable to check Instron Status. Will try again')
        instronStatus = 0;
    end

end