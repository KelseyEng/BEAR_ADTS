%Kelsey Snapp
%Kab Lab
%3/9/22
% Defines GP models to Run
% Status key: 
    % -1: Failed to accomplish assignment: Go to next ID
    % 0: Accomplished assignment
    % 1: Not ready to perform next assignment: Go to next ID
    % 2: Finished last assignment: Go to next ID

function status = decideExperimentDispatcher(ID,comPath,fnameGenerate)

    
    %% Define Decision Policies and GP tasks
    fnameTasker = [comPath,sprintf('TaskerID%d.mat',ID)];
    fnameTaskerClaim = [comPath,sprintf('TaskerClaimID%d.mat',ID)];
    if ~isfile(fnameTaskerClaim)
        save(fnameTaskerClaim,'ID')
        try
            fprintf('Definining Tasks for ID%d\n',ID)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            defineTasks(fnameTasker,fnameGenerate)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fprintf('Tasks for ID%d Defined.\n',ID)
            status = 0;
            return
        catch
            fprintf('Unable to define Tasks for ID%d\n',ID)
            delete(fnameTaskerClaim)
            status = -1;
            return
        end
    end
    
    %% Check if tasker is ready
    if ~isfile(fnameTasker)
        status = 1;
        return
    end
    
    %% Run each GP and Prediction
    
    %Find number of tasks
    loadFailed = 1;
    for i = 1:5
        try
            load(fnameTasker,'numTasks')
            if ~exist('numTasks','Var')
                continue
            end
            loadFailed = 0;
            break
        catch
            pause(15)
        end
    end
    
    % Return if unable to load fnameTask
    if loadFailed
        fprintf('Unable to Load Tasks for ID%d\n',ID)
        status = -1;
        return
    end
    
    % Otherwise, check if there is an unclaimed task
    for task = 1:numTasks
        fnameTask = [comPath,sprintf('Task%dID%d.mat',task,ID)];
        fnameTaskClaim = [comPath,sprintf('Task%dClaimID%d.mat',task,ID)];
        if ~isfile(fnameTaskClaim)
            save(fnameTaskClaim,'ID')
            try
                fprintf('Working on Task%d for ID%d\n',task,ID)
                
                % Load variables
                load(fnameTasker,'xObsList','yObsList','xPredList','DP','DPS','modelType')
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [mdl,yMu,ySdv] = TrainAndPredict(task,comPath,xObsList,yObsList,xPredList{1},DP,DPS,modelType,DPS.RetrainGP(1,task),1);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Save data back
                save(fnameTask,'mdl','yMu','ySdv','-v7.3')    
                
                fprintf('Task%d for ID%d Complete.\n',task,ID)
                status = 0;
                return
            catch
                fprintf('Unable to complete Task%d for ID%d\n',task,ID)
                delete(fnameTaskClaim)
                status = -1;
                return
            end
        end
    end
    
    %% Check if all tasks are done
    
    for task = 1:numTasks
        fnameTask = [comPath,sprintf('Task%dID%d.mat',task,ID)];
        if ~isfile(fnameTask)
            status = 1;
            return
        end
    end
    
    
    
    %% Apply final decision policy
    
    fnameResponse = [comPath,sprintf('responseID%d.mat',ID)];
    fnameResponseClaim = [comPath,sprintf('responseClaimID%d.mat',ID)];
    
    if ~isfile(fnameResponseClaim)
        save(fnameResponseClaim,'ID')
        try
            fprintf('Applying Decision Policy for ID%d\n',ID)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            applyDP(fnameResponse,numTasks,fnameTasker,ID,comPath)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            status = 2;
            fprintf('ID%d Completed!\n',ID)
            
            %Delete files that are no longer needed
            if ID > 20320
                delete(fnameGenerate)
            end
            for task = 1:numTasks
                fnameTask = [comPath,sprintf('Task%dID%d.mat',task,ID)];
                fnameTaskClaim = [comPath,sprintf('Task%dClaimID%d.mat',task,ID)];
                delete(fnameTask)
                delete(fnameTaskClaim)
            end
            delete(fnameTaskerClaim)
            delete(fnameTasker)
            delete(fnameResponseClaim)
            return
        catch
            fprintf('Unable to Apply Decision Policy for ID%d\n',ID)
            delete(fnameResponseClaim)
            status = -1;
            return
        end
    end

    %% No tasks left to do on this ID
    status = 1;
    
    

end