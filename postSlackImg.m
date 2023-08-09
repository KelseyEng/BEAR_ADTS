%Kelsey Snapp
%Kab Lab
%5/11/21
%Posts file to Slack

function postSlackImg(fname_file)
    
    try
        currentPath = pwd;
        basePath = extractBefore(currentPath,'BEAR');
        pythonPath = strcat(basePath, 'SlackAPI\myenv\Scripts\python.exe');
        pythonScript = char(strcat({' '}, basePath, 'SlackAPI\sendFileToSlack.py'));

        command = strcat(pythonPath,pythonScript," ", fname_file);
        [~,~] = dos(command);
    catch
        disp('Unable to post image to slack.')
    end

end