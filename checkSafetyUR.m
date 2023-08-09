% Brown Research Group 
% Author: Bowen Xu
% Date  : March 13, 2018 
% Description: 
% check the UR5e is under normal mode and no safety popup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 
% Date        Author        Brief Description 
% March 13    Bowen Xu      first version
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function ProtectiveStop = checkSafetyUR()

%% load the cmd python file and check the safety state

command = sprintf('python2 safetyMode.py');

% run the cmd python file

[status,cmdout] = dos(command);

% capture the retun message

robotStatus = cmdout(13:end-2);

% compare the return massage with "NORMAL"

check = strcmp('NORMAL',robotStatus);

%% if same string, output 1; different string, output 0

if check == 0
    
    % load the cmd python file and unlock the safety

    command = sprintf('python2 unlockSafety.py');

    % run the cmd python file

    [status,cmdout] = dos(command);
    
    % output the skip test signal, 2 means skip the rest ur5 control
    
    ProtectiveStop = 1;
    
else
    
    % tell the ur5 do not skip
    
    ProtectiveStop = 0;

end

end

