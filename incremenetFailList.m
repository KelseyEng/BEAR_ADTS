%Kelsey Snapp
%Kab Lab
%3/9/22
% Increments the Fail List

function failList = incremenetFailList(failList,ID)

    if length(failList) < ID
        failList(ID) = 1;
    else
        failList(ID) = failList(ID) + 1;
    end

end

