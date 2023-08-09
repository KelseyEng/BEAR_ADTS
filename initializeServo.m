%Kelsey Snapp
%Kab Lab
%3/18/21
%Initialized servo and assorted variables for controlling gripper.


function [a,s,open,fClosed,closed,pOpen] = initializeServo()

    a = arduino();
    s = servo(a, 'D4', 'MinPulseDuration', 750*10^-6,...
    'MaxPulseDuration', 2250*10^-6);
    open = 0.50;
    fClosed = 0.0;
    closed = 0.10;
    pOpen = 0.35;
    
end 