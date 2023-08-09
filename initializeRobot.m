%Kelsey Snapp
%Kab Lab
%3/19/21
%Moves instron from Home to P1 location, where it can the move elsewhere.

function initializeRobot()

    command = 'python controlUR5.py /programs/RG2/moveP1.urp';
    protectiveStop = moveUR5AndWait(command);

end