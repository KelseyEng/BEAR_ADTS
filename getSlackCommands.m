% Parse Conversation History

function conversation = getSlackCommands()

    try
        currentPath = pwd;
        basePath = extractBefore(currentPath,'BEAR');
        pythonPath = strcat(basePath, 'SlackAPI\myenv\Scripts\python.exe');
        pythonScript = char(strcat({' '}, basePath, 'SlackAPI\getSlackMessages.py'));

        command = strcat(pythonPath,pythonScript); 

        [status,cmdout] = dos(command);

        pause(1)
        load('conversations.mat')
        if ~exist('conversation','var')
            conversation = [];
        end
    catch
        conversation = [];
    end

end
