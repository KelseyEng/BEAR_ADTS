%Kelsey Snapp
%Kab Lab
%3/18/21
% Starts Instron and Video But does not wait to finish.


function vid=startCompressionWithVideo(a,videoname)

    

    %% 1. initiate video capture 
    try 
        % establish connection 

        vid = videoNameFunction();

        src = getselectedsource(vid);

        % video camera settings 

        vid.FramesPerTrigger = Inf; 

        vid.LoggingMode = 'disk'; 

        src.Exposure = 0.02; 

        src.WhiteBalanceGainBlue = 1.34;

        src.WhiteBalanceGainGreen = 1.01; 

        src.WhiteBalanceGainRed = 1.52; 

        %src.ColorTemperature = 3500; 

        triggerconfig(vid,'manual'); 

        % start video 

        disp('Starting video') 

        diskLogger = VideoWriter(videoname, 'Motion JPEG AVI');

        vid.DiskLogger = diskLogger; 

        start(vid); 

        trigger(vid); 

        pause(2)
    catch
        vid = 0;
        disp('Unable to start video recording')
    end

    %% 2. initiate instron testing 

    % step ## start the test

    % start the instron test, 0 means LOW in instron <input> = turn on switch
    % D7 is the digital output from arduino

    writeDigitalPin(a,'D7',0);

    % wait for next step

    pause(1);

    % activate the first hold in Instron, turn off

    writeDigitalPin(a,'D7',1);

    % wait for next step

    pause(1);

    % activate the second hold in Instron, turn back on, head moves now

    writeDigitalPin(a,'D7',0);

    disp('## Test start.');
    
    % turn off digital pin

    pause(1);
    
    writeDigitalPin(a,'D7',1);




end
