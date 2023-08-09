%Kelsey Snapp
%Kab Lab
%8/17/21
%Checks 2nd matlab has stated that instron is done


function instronStatus = checkMatlabInstronStatus(testT)
    if testT.Instron
        fname = 'U:\eng_research_kablab\users\ksnapp\ComFolder\communicationMat.mat';
        try
            load(fname,'status')

            if status == 0
                instronStatus = 3;
            else
                instronStatus = 2;
            end
        catch
            disp('Unable to check matlab instron status. Will try again later.')
            instronStatus = 2;
        end
    else
        instronStatus = randi(2) + 1;
    end
end

