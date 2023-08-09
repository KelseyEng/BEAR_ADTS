%Kelsey Snapp
%Kab Lab
%2/21/2023
%Load new filament into printer


function [filamentIDT,printerT] = loadNewFilament(filamentIDT,printerT)

    % Check if new Filament
    msg = 'Has this filament roll been used before? 1 for yes, 0 for no: ';
    oldFil = input(msg);

    while 1
        validInput = checkInputBounds(1,0:1,oldFil);
        if validInput
            break
        end
        msg2 = 'Invalid input.\n';
        oldFil = input(strcat(msg2,msg));
    end

    
    if oldFil == 1
        %% Loading Old Filament
        msg = 'Please input Filament ID (written on side of roll): ';
        filamentID = input(msg);

        while 1
            validInput = checkInputBounds(1,[],filamentID);
            if validInput
                break
            end
            msg2 = 'Invalid input.\n';
            filamentID = input(strcat(msg2,msg));
        end

        %Check if loading into same nozzle
        prevRow = find(filamentIDT.FilamentID == filamentID);
        selectedPrinter = filamentIDT.Printer(prevRow);
        selectedNozzle = filamentIDT.Nozzle(prevRow);
        fprintf('This filament was previously loaded into:\nPrinter: %d\nNozzle:%d\n',...
            selectedPrinter,selectedNozzle)
        
        msg = 'Do you want to load it into the same printer and nozzle? 1 for yes, 0 for no: ';
        sameSlot = input(msg);
        while 1
            validInput = checkInputBounds(1,0:1,sameSlot);
            if validInput
                break
            end
            msg2 = 'Invalid input.\n';
            sameSlot = input(strcat(msg2,msg));
        end
        
        if sameSlot == 1
            row = prevRow;
        else
            % Select Printer
            msg = 'Which printer will you load the filament into? ';
            selectedPrinter = input(msg);
            while 1
                validInput = checkInputBounds(1,1:6,selectedPrinter);
                if validInput
                    break
                end
                msg2 = ' Number must be an integer between 1 and 6: ';
                selectedPrinter = input(strcat(msg,msg2));
            end           

            % Select Nozzle
            msg = 'Which Nozzle will you load the filament into? (0 or 1)';
            selectedNozzle = input(msg);
            while 1
                validInput = checkInputBounds(1,0:1,selectedNozzle);
                if validInput
                    break
                end
                msg2 = ' Number must be an integer between 0 and 1: ';
                selectedNozzle = input(strcat(msg,msg2));
            end     
            
            filamentID = max(filamentIDT.FilamentID) + 1;            
            disp('A new filament ID will be assigned to the roll.')
            fprintf('The new filament ID is %d.\n',filamentID)
            disp('Please write this number on the side of the roll with a sharpie')
            disp('Press any key to continue')
            pause

            % Assign new data to ID
            row = size(filamentIDT,1) + 1;
            filamentIDT.FilamentID(row) = filamentID;
            filamentIDT.Printer(row) = selectedPrinter;
            filamentIDT.Nozzle(row) = selectedNozzle;
            
            % get remaining  filament information from previous ID
            filamentIDT.TypeOfFilament(row) = filamentIDT.TypeOfFilament(prevRow);
            filamentIDT.Color(row) = filamentIDT.Color(prevRow);
            filamentIDT.DateOpened(row) = filamentIDT.DateOpened(prevRow);
            filamentIDT.Modulus(row) = filamentIDT.Modulus(prevRow);
            filamentIDT.Density(row) = filamentIDT.Density(prevRow);
            filamentIDT.NozzleTemp(row) = filamentIDT.NozzleTemp(prevRow);
            filamentIDT.BedTemp(row) = filamentIDT.BedTemp(prevRow);
            filamentIDT.RemovalTemp(row) = filamentIDT.RemovalTemp(prevRow);
            filamentIDT.FanOn(row) = filamentIDT.FanOn(prevRow);
            filamentIDT.Lot(row) = filamentIDT.Lot(prevRow);
            filamentIDT.ProductID(row) = filamentIDT.ProductID(prevRow);   
        end

    
    elseif oldFil == 0
        %% Loading New Filament
        % Select Printer
        msg = 'Which printer will you load the filament into? ';
        selectedPrinter = input(msg);
        while 1
            validInput = checkInputBounds(1,1:6,selectedPrinter);
            if validInput
                break
            end
            msg2 = ' Number must be an integer between 1 and 6: ';
            selectedPrinter = input(strcat(msg,msg2));
        end           

        % Select Nozzle
        msg = 'Which Nozzle will you load the filament into? (0 or 1)';
        selectedNozzle = input(msg);
        while 1
            validInput = checkInputBounds(1,0:1,selectedNozzle);
            if validInput
                break
            end
            msg2 = ' Number must be an integer between 0 and 1: ';
            selectedNozzle = input(strcat(msg,msg2));
        end     

        % Select Filament Type
        filTypes = unique(filamentIDT.TypeOfFilament);
        disp('These are the types of filaments available:')
        for i = 1:length(filTypes)
            fprintf('%d: %s\n',i,filTypes{i})
        end
        msg = 'Enter the number of the filament type you want to load: ';
        filTypeNum = input(msg);
        while 1
            validInput = checkInputBounds(1,1:length(filTypes),filTypeNum);
            if validInput
                break
            end
            msg2 = 'Invalid input\n';
            filTypeNum = input(strcat(msg2,msg));
        end  
        filType = filTypes{filTypeNum};
        fprintf('You have selected %s.\n',filType)
        prevRow = find(strcmp(filamentIDT.TypeOfFilament,filType) == 1,1,'last');

        % Get information about roll
        colorFil = input('What is the color of the filament? ','s');

        openedToday = input('Was the roll opened today? 1 for yes, 0 for no: ');
        while 1
            validInput = checkInputBounds(1,0:1,openedToday);
            if validInput
                break
            end
            msg2 = 'Invalid input.\n';
            openedToday = input(strcat(msg2,msg));
        end
        if openedToday
            dateOpened = datetime('now','Format','MMMM d, yyyy');
        else
            dateOpened = input("Please enter date opened in format 'MM/DD/YYYY'",'s');
            try
                dateOpened = datetime(dateOpened,'Format','MMMM d, yyyy','InputFormat','MM/dd/yyyy');
            catch
                disp('Invalid date. Will set date opened to today.')
                dateOpened = datetime('now','Format','MMMM d, yyyy');
            end
        end

        lot = input('What is the lot number of the filament? (must be number) ');

        productID = input('What is the product ID of the filament roll? ','s');

        filamentID = max(filamentIDT.FilamentID) + 1;

        fprintf('The new filament ID is %d.\n',filamentID)
        disp('Please write this number on the side of the roll with a sharpie')
        disp('Press any key to continue')
        pause

        % Save data to filamentIDT
        row = size(filamentIDT,1) + 1;
        filamentIDT.FilamentID(row) = filamentID;
        filamentIDT.TypeOfFilament(row) = {filType};
        filamentIDT.Color(row) = {colorFil};
        filamentIDT.Printer(row) = selectedPrinter;
        filamentIDT.Nozzle(row) = selectedNozzle;
        filamentIDT.DateOpened(row) = dateOpened;
        filamentIDT.Lot(row) = lot;
        filamentIDT.ProductID(row) = {productID};   
        
        % Pull filament data from previous sample       
        filamentIDT.Modulus(row) = filamentIDT.Modulus(prevRow);
        filamentIDT.Density(row) = filamentIDT.Density(prevRow);
        filamentIDT.NozzleTemp(row) = filamentIDT.NozzleTemp(prevRow);
        filamentIDT.BedTemp(row) = filamentIDT.BedTemp(prevRow);
        filamentIDT.RemovalTemp(row) = filamentIDT.RemovalTemp(prevRow);
        filamentIDT.FanOn(row) = filamentIDT.FanOn(prevRow);
        
    end
    
    % Display data for selected filament
    disp('Here are some stats about the filament you have selected')

    fprintf('Modulus: %.0f MPa\n',filamentIDT.Modulus(row))
    fprintf('Density: %.2f g/cm^3\n',filamentIDT.Density(row))
    fprintf('Nozzle Print Temperature: %.0f C\n',filamentIDT.NozzleTemp(row))
    fprintf('Bed Print Temperature: %.0f C\n',filamentIDT.BedTemp(row))
    fprintf('Bed Removal Temperature: %.0f C\n',filamentIDT.RemovalTemp(row))

    if filamentIDT.FanOn(row) == 0
        disp('Fan cooling: off')
    else
        disp('Fan cooling: on')
    end
        
    % Save Filament data to printer Table
    printerT.Filament{1}(selectedNozzle+1,selectedPrinter) = filamentIDT.FilamentID(row);
    printerT.Modulus{1}(selectedNozzle+1,selectedPrinter) = filamentIDT.CylinderModulus(row);
    printerT.InitialFilamentMassRatio{1}(selectedNozzle+1,selectedPrinter) = ...
        filamentIDT.InitialFilamentMassRatio(row);
    printerT.Stress25{1}(selectedNozzle+1,selectedPrinter) = ...
        filamentIDT.Stress25(row);
    printerT.Density{1}(selectedNozzle+1,selectedPrinter) = filamentIDT.Density(row);
    
    if selectedPrinter == 6
        printerT.STL_Mode{1}(selectedPrinter) = 301; %Set STL_Mode to go through checklist
    else
        printerT.STL_Mode{1}(selectedPrinter) = 1; %Set STL_Mode to go through checklist
    end
    
    disp('Please load filament roll into printer. Press any key when done')
    pause
end