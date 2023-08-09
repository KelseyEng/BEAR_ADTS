%Kelsey Snapp
%Kab Lab
%5/11/21
%Post custom message to slack

function postSlackMsg(msg,testT)
    
    disp(msg)
    
    if testT.Slack
        try
            currentPath = pwd;
            basePath = extractBefore(currentPath,'BEAR');
            pythonPath = strcat(basePath, 'SlackAPI\myenv\Scripts\python.exe');
            pythonScript = char(strcat({' '}, basePath, 'SlackAPI\sendSlackMessage.py'));

            writematrix(msg,'outSlackMessage.txt')

            command = strcat(pythonPath,pythonScript);
            [~,~] = dos(command);
        catch
            disp('Unable to post agove message to slack.')
        end
    end
end