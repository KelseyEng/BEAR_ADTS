%Kelsey Snapp
%Kab Lab
%3/18/21
%Removes part from instron and stores in storage location.


function storePart(storageNumber,testT,location)

    openGripper()
    
    if location == 1

        command = ['python controlUR5.py ','/programs/RG2/discardInstron.urp'];
        protectiveStop = moveUR5AndWait(command);

    
    elseif location == 2
%         command = ['python controlUR5.py ','/programs/helmetpads/sl_moveToScale.urp'];
%         protectiveStop = moveUR5AndWait(command);
% 
%         command = ['python controlUR5.py ','/programs/helmetpads/sl_dropScale.urp'];
%         protectiveStop = moveUR5AndWait(command);
% 
%         closeGripper()
% 
%         command = ['python controlUR5.py ','/programs/helmetpads/sl_clearScale.urp'];
%         protectiveStop = moveUR5AndWait(command);
    
    end
    

%     
%     command = sprintf('python controlUR5.py /programs/helmetpads/sl_drop%d.urp',storageNumber);
%     protectiveStop = moveUR5AndWait(command);

    if protectiveStop
        protectiveStopHelp(testT)
    end
    
end