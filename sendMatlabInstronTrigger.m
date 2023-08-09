%Kelsey Snapp
%Kab Lab
%8/18/21
%Sends Signal to 2nd matlab to start instron


function sendMatlabInstronTrigger(ID,altText)

    fname = 'U:\eng_research_kablab\users\ksnapp\ComFolder\communicationMat.mat';

    status = 1;
    save(fname,'ID','status','altText')

end