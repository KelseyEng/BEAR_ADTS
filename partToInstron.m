
%Kelsey Snapp
%Kab Lab
%6/22/21
%Moves Part to Instron from Scale

function partToInstron()

    command = ['python controlUR5.py ','/programs/RG2/scaleToInstron.urp'];
    protectiveStop = moveUR5AndWait(command);
    
end