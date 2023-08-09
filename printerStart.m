function [status,msg] = printerStart(selectedPrinter,filename)
% Brown Research Group
% Author: Aldair E. Gongora 
% Date: May 28, 2018 
% printerStart(printerID,filename) - prints file with a specific printer

    if selectedPrinter == 6
        
        for i=1:3
            msg = py.BEAR.upload_gcode(filename);
            msg = char(msg)
            if ~strcmp(msg,'File Uploaded Sucessfully!')
                pause(30)
                continue
            end
            pause(5)
            msg2 = py.BEAR.start_gcode(filename);
            msg2 = char(msg2)
            if ~strcmp(msg2,'Print Started Sucessfully!')
                pause(30)
                continue
            else
                status = 0;
                return
            end
        end
        status = 1;
        return
        
    else

        command = ['python2 octocmd',num2str(selectedPrinter) ,' print ',filename]; 

        [status,cmdout] = dos(command);

        % return message on execution status

        if status == 0

            % execution success

            msg = ['Command ',command,' was executed successfully']; 

        else

            % execution failed

            %msg = ['Command ',command,' failed to execute'];

            % while loop 

            ktrials = 0; 

            disp('The printerStart() fxn failed to execute') 

            disp('The printerStart() fxn will be re-ran') 

            while status ~= 0 && ktrials < 3

                command = ['python2 octocmd',num2str(selectedPrinter) ,' print ',filename]; 

                ktrials = ktrials+1; 

                [status,cmdout] = dos(command);  

                pause(5)

            end

            if status == 0
                msg = ['The printerStart() fxn was executed sucessfully after ',num2str(ktrials),' attempts.'];
            else
                msg = 'printerStart() fxn was unable executed sucessfully';
            end
        end

    end

end

