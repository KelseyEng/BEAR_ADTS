%Kelsey Snapp
%Kab Lab
%3/19/21
%Moves instron to P1 location and then home when the campaign is done.

function homeRobot()

    command = 'python controlUR5.py /programs/RG2/moveP1.urp';
    protectiveStop = moveUR5AndWait(command);

    command = 'python controlUR5.py /programs/RG2/moveHome.urp';
    protectiveStop = moveUR5AndWait(command);

end