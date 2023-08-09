%Kelsey Snapp
%Kab Lab
%1/17/23
%Checks to see if measured height is within tolerance


function checkHeight(dataT,testT,ID)
    targetHeight = dataT.TargetHeight + dataT.CapHeight;
    if abs(targetHeight - dataT.Height) ./ targetHeight >= .05
        msg = 'Warning: Measured Height is more than 5% different from Target Height.';
        postSlackMsg(msg,testT)
        msg = sprintf('Target Height: %.2f mm',targetHeight);
        postSlackMsg(msg,testT)
        msg = sprintf('Measured Height: %.2f mm',dataT.Height(ID));
        postSlackMsg(msg,testT)
    end

end