%Kelsey Snapp
%Kab Lab
%3/18/21
% When you detect the Instron is done, turn off video.


function endVideoOfCompression(vid)
 
    
    % close the switch to off state
% 
%     writeDigitalPin(a,'D7',1);

    % wait for next step

    pause(1);

    disp('## Test end.');

    %% 3. stop video process

    disp('Stop recording video')
    if isa(vid,'videoinput')
        stop(vid); 
    end
    fclose('all');

end