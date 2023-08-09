%Kelsey Snapp
%Kab Lab
%5/13/21


function openGripper()

%     [a,s,open,fClosed,closed,pOpen] = initializeServo();%Intialize Servo
%     writePosition(s,open)
%     pause(1)
%     clear a

    command = 'python controlUR5.py /programs/RG2/openGripper.urp';
    protectiveStop = moveUR5AndWait(command);

end