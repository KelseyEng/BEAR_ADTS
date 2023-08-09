% Brown Research Group 
% Author: Bowen Xu
% Date  : October 10, 2018 
% Description: 
% read the scale reading and store the value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Revision: 
% Date        Author        Brief Description 
% October 10  Bowen Xu      current version
% January 2   Bowen Xu      solved "NaN" value issue
% February 18 Bowen Xu      add time count function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [weight] = readWeightQuick

%% find the serial port and connect the scale

s = serial('COM5');

% adjust the communication settings (same on the scale side)

s.Baudrate = 9600;
s.DataBits = 7;
s.Parity = 'odd';
s.StopBits = 1;
s.Terminator = 'CR/LF';
s.FlowControl = 'hardware';

% extend the timeout time to 1800 seconds

s.Timeout = 1800;

% set the initial weight value


%% establish serial communication

% start time count

i = 0;

% check if the scale records the reading



% open the serial communication

fopen(s);

% send the print command 'P' to the scale

fprintf(s,'\x1B%s\n','P');

% receive the value from the scale

str = fscanf(s,'%s');

% cut the string to number only

value = str(3:end-1);

% convert the number string to numbers

weight = str2double(value);

%% check if the value has an error

if isnan(weight)

    % if the reading is wrong, reset and read again

    weight = -99;

    disp('Reading error! Weigh again...');

end

%% close the serial communication

fclose(s);

% pause for 2 seconds

pause(2);


%% delete and clear serial from matlab

delete(s);
clear s

end

