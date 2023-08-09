%Kelsey Snapp
%Kab Lab
%6/17/21
%Applies Neural Networks to image


function [status,confidence] = applyNN(img,netName)

    if img == 0
        status = 'noImage';
        confidence = 1;
    else
        load(netName,'net','cropLimits')
        if cropLimits
            [img,~] = imcrop(img,cropLimits);
        end

        inputSize = net.Layers(1).InputSize;

        if sum(size(img) ~= inputSize)
            img = imresize(img,[inputSize(1),inputSize(2)]);
        end

        [status, confidence] = classify(net,img);
        confidence = max(confidence);
    end
    
end


