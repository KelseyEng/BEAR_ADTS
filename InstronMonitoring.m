%Kelsey Snapp
%Kab Lab
%8/17/21
%Runs Instron on 2nd computer and captures video

clear all
close all
clc


a = arduino();
ID = 0;
fname = 'U:\eng_research_kablab\users\ksnapp\ComFolder\communicationMat.mat';

while ID >= 0
    try

        load(fname,'ID','status','altText') %Put break here to pause program

        if ID > 0 && status == 1

            % Start Video/Crush
            
            fprintf('Crushing ID%d.\n',ID)
            
            videoname = sprintf('ID%d%s.avi',ID,altText);

            vid=startCompressionWithVideo(a,videoname);

            %While loop to check if Instron is done
            while status == 1
                status = checkInstronStatus(a);
            end

            %End Video
            if isa(vid,'videoinput')
                endVideoOfCompression(vid)
            end
            clear vid

            % While Loop outputs status = 0, which is signal to other Matlab
            % that Instron has stopped.
            save(fname,'ID','status','altText')
            
            try
                dst = sprintf('G:\\My Drive\\BEARData\\videos\\ID%d%s.avi',ID,altText);
                movefile(videoname,dst)
            catch
                disp('Unable to move video.')
            end
               

        end
    catch
        disp('Unable to load matrix')
    end
    
    pause(10)

end

clear a