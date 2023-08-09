%Kelsey Snapp
%Kab Lab
%3/18/21
% Send Move command to UR5 and then waits for UR5 to stop. 


function protectiveStop = moveUR5AndWait(command)

    %Manner is a flag that chooses to run
    %either the python script or the UR5 commands

    global UR5Connection
    global arm
    
    if UR5Connection
        [~,~] = dos(command);
        pause(3); %This ensures that the robot has time to start moving.
        checkUR5();
        protectiveStop = checkSafetyUR;
    else
        pause on
        num = 0;
        
        % Just get end of python command
        com = strsplit(command,'/');
        com = com{4};
        com = com(4:end-4);
        
        % String manipulation if moveP command
        if(any('P'==com)) && (any(isstrprop(com,'digit')))
            num = str2num(com(isstrprop(com,'digit')));
            com = erase(com,com(isstrprop(com,'digit')));        
        elseif (any('p'==com)) && (any(isstrprop(com,'digit')))
            num = str2num(com(isstrprop(com,'digit')));
            com = erase(com,com(isstrprop(com,'digit')));
        end
        
        disp(com)
        disp(num)
        
        % Send command to Python
        try
            arm.commandsFromMatlab(com,num);
            pause(3);
%             while(arm.checkUR5()==1)
%                 pause(3);
%             end
            protectiveStop = 0;
        catch e
            protectiveStop = 1;
            if(arm.protectiveStop() == 1)
                pause(3);
                disp("Protective Stop")
                pause(6)
                arm.disable_protectiveStop();
                pause(6)
                arm = pythonArmConnection();
                pause(2)
            else
                disp("Error has occurred")
                fprintf(1, "The error was the following:\n%s\n", e); 
                in = input("Arm stopped, please check what is wrong before proceeding and press any key ");
            end
            
        end
        
    end

end