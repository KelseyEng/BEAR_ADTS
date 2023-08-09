% Function that outputs the position and the orientaion of the end effector
% wrt the global reference frame (base of UR5e)

function [toolCoordinate, toolOrientation] = toolPosition()
    global arm
    
    % Gives the position of the end effector from global refernce frame in
    % mm
    temp = arm.toolCoordinate();
    temp = cell(temp);
    toolCoordinate = [temp{1}, temp{2}, temp{3}];
    
    % Gives the direction the end effector is pointing in with respect to
    % the global reference frame
    temp = arm.toolOrientation();
    temp = cell(temp);
    toolOrientation = [round(temp{1},1), round(temp{2}, 1), round(temp{3}, 1)];


end