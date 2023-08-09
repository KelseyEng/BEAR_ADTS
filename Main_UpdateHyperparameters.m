%Kelsey Snapp
%Kab Lab
%8/3/22
% Updates hyperparameters for GP

clear all
close all
clc

comPath = '/ad/eng/research/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
testMatPath = '/ad/eng/research/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/test.mat';
if ~exist(comPath,'dir')
    comPath = 'U:/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
    testMatPath = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/test.mat';
end

load(testMatPath)

comPath = '/ad/eng/research/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
testMatPath = '/ad/eng/research/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/test.mat';
if ~exist(comPath,'dir')
    comPath = 'U:/eng_research_kablab/users/ksnapp/ComFolder/STLGenerator/';
    testMatPath = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/test.mat';
end

%%
DP = 22;

DPS = defineDPS(DP,testT);

T = generateT(DPS,stressThreshData,dataT,filamentIDT);
xObsList = generateXObsList(T,DPS.xMode);
[yObsList,~,~] = generateYObsList(DPS.yModeList,T);


for task = 1:size(yObsList,2)
    
    xObs = xObsList{1,task};
    yObs = yObsList{1,task};
    fnameHyper = strcat(comPath,sprintf('HyperParam/hyperXmode%dYmode%d.mat',DPS.xMode,DPS.yModeList(task)));
    [sigmaNL,sigmaFL,sigmaML] = generateHyperparameters(xObs,yObs);
    save(fnameHyper,'sigmaNL','sigmaFL','sigmaML')
    sprintf('Finished task %d.',task)
    
end




