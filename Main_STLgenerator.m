%Main_STLgenerator
%Kelsey Snapp
%Kab Lab
%9/17/21
%Alternate compute node of BEAR that selects next experiment. This can be
%computationally expensive due to multidimensional modeling. Therefore, it
%is beneficial to offload work to other compute nodes.

clear all
close all
clc

createFolder('GPRModel')

comPath = '/ad/eng/research/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
if ~exist(comPath,'dir')
    comPath = 'U:\eng_research_kablab\users\ksnapp\ComFolder\STLGenerator\';
end

%comPath = 'U:\eng_research_kablab\users\ksnapp\ComFolder\Debug\';

failList = 0;

% Start infinite loop
while true 
    % Get file list from directory and filter for GenerateID
    fileList = dir(comPath);
    indexDir = cell2mat({fileList.isdir});
    indexCom = contains({fileList.name},'GenerateID');
    fileList = fileList((~indexDir & indexCom));
    
    % Pause if no Generate Files
    if isempty(fileList)
        pause(15)
        continue
    end
    
    % Run through Generate Files looking for tasks
    indexVal = 1;
    status = 1;
    while status
        
        fnameGenerateShort = fileList(indexVal).name;
        
        % Get ID Number for current file
        indexP = strfind(fnameGenerateShort,'.');
        ID = str2double(fnameGenerateShort(11:indexP-1));
        
        % Check if file has exceeded fail limit        
        if length(failList) >=  ID
            if failList(ID) > 20
                indexVal = indexVal + 1;
                if indexVal > size(fileList,1)
                    pause(15)             
                    status = 0;
                end
                continue
            end
        end
        
        % Run Experiment Dispatcher
        fnameGenerate = strcat(comPath,fnameGenerateShort);
        status = decideExperimentDispatcher(ID,comPath,fnameGenerate);
        
        % Check status of experiment Dispatcher
        if status == -1
            failList = incremenetFailList(failList,ID);
        end
        if status ~= 0
            indexVal = indexVal + 1;
            if indexVal > size(fileList,1)
                pause(15)             
                status = 0;
            end
        end      
    end
    
    dice = randi(10);
    if dice > 9
        checkFileAge(comPath)
    end
    
end




