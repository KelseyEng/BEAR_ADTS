%Kelsey Snapp
%Kab Lab
%6/23/21
% Grabs brush and sweeps bed


function brushInstron()
    
    command = ['python controlUR5.py ','/programs/RG2/brushPick.urp'];
    protectiveStop = moveUR5AndWait(command);

    command = ['python controlUR5.py ','/programs/RG2/brushInstron.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    command = ['python controlUR5.py ','/programs/RG2/brushDrop.urp'];
    protectiveStop = moveUR5AndWait(command);

end