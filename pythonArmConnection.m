function output = pythonArmConnection()
        pause on;
        % Importing URX_class library
        URX_class = py.importlib.import_module('URX_class');
        pause(2)
        global UR5Connection
        
        %Tries to connect to UR5 via python, if it does not work 
        %in 5 tries, then goes back to the old code
        for i=1:5
            try
                robot= py.URX_class.URX_class;
                disp("Connected to UR5e arm")
                UR5Connection = 0;
                output = robot;
                break;
            catch
                disp("Trying to connect to UR again");
                output = 0;
                UR5Connection = 1;
                pause(3)
            end
        end
        
        if (UR5Connection == 1)
            disp("Could not connect to UR5 via Python, continuing with the old implementation");
        end
end