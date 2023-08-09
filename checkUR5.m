% Brown Research Group 
% Author: Bowen Xu
% Date  : July 17, 2018 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 
% Date        Author        Brief Description 
% July 17     Bowen Xu      current version before 100 test.
% October 1   Bowen Xu      current version
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: Check the running state of the UR5 robot arm.
% check the status of the moving ur5 arm, if stoped, run next matlab step.
% input is not necessary, any number can run.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function checkUR5()

    %% wait for 1s for each check

    pause(1);

    %% run initial check python script

    command2 = sprintf('python2 checkState.py');

    % get feedback cmd out from cmd window
    % two feedback option: 
    % either 'Program running: true' or 'Program running: false'

    % set comparison statement

    s1 = 'Program running: true';

    % same string for 1

    test = 1;

    %% continue check every 1 second

    while test == 1

        % wait for 1s for each check

        pause(1);

        % load check python script

        command2 = sprintf('python2 checkState.py');

        % run check python script

        [status,cmdout] = dos(command2);

        % select useful words from the full string

        robotStatus = cmdout(1:end-2);

        % compare true or false string

        test = strcmp(s1,robotStatus);

    end

end

