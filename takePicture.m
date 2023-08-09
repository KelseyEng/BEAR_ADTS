%Kelsey Snapp
%Kab Lab
%3/18/21
% Takes a picture using the Camera specified and saves to path Specified

function img = takePicture(camName,path,required,rotate)
    img = 1;
    pause(15)
    global robotCam
    while img == 1
        try
            img = snapshot(robotCam);
            if rotate
                img = rot90(img,rotate);
            end
            imwrite(img,path);
            figure(4)
            imshow(img)
            strStart = strfind(path,'//') + 2;
            strEnd = strfind(path,'.') - 1;
            title(gca,path(strStart:strEnd))
        catch e
            disp('Camera failed to take picture.')
            fprintf(1,'The identifier was:\n%s',e.identifier);
            fprintf(1,'There was an error! The message was:\n%s',e.message);
            if required == 0 && img == 1
                img = 0;
            end
        end
    end

end