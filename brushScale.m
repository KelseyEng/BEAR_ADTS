%Kelsey Snapp
%Kab Lab
%5/27/21
%Clears Scale if there is a part there

function brushScale()

    command = ['python controlUR5.py ','/programs/RG2/brushPick.urp'];
    protectiveStop = moveUR5AndWait(command);

    command = ['python controlUR5.py ','/programs/RG2/brushScale.urp'];
    protectiveStop = moveUR5AndWait(command);
    
    command = ['python controlUR5.py ','/programs/RG2/brushDrop.urp'];
    protectiveStop = moveUR5AndWait(command);

end