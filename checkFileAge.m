%checkFileAge
%Kelsey Snapp
%Kab Lab
%11/16/21
% Check for old files and deletes them


function checkFileAge(comPath)

    fileList = dir(comPath);
    indexDir = cell2mat({fileList.isdir});
    fileList = fileList(~indexDir);
    
    currentTime = datenum(clock);
    
    for indexVal = 1:size(fileList,1)
        %Check what type of file it is

        cutOff = 1;

        % Delete file if it is too old
        if currentTime - fileList(indexVal).datenum > cutOff
            try
                delete(fileList(indexVal).name)
            catch
                disp('Unable to delete old file')
            end
        end
    end
end


