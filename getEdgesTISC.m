%Kelsey Snapp
%Kab Lab
%5/9/21
% Assumptions: Assumes distance between sampling points for C2 are evenly
% spaced

clear all
close all
clc

%import 
if isfolder('U:\eng_research_kablab\users\ksnapp\NatickCollabHelmetPad\TSCTestData')
        fname = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150w01.csv';
else
    fname = '/ad/eng/research/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150w01.csv';
end
T= readtable(fname);
T = [T.c1,T.c2];
topTop = [];
middleTop = [];
middleBottom = [];
bottomBottom = [];

count = 1;
for c1 = unique(T(:,1))'
    Temp = T(T(:,1)==c1,2);
    diffTemp = diff(Temp);
    deltaC = mode(diffTemp);
    idx = find(diffTemp>deltaC);
    %Inner Polygon
    if ~isempty(idx)
        c2 = Temp(idx(1));
        middleTop = [middleTop; [c1,c2]];
        c2 = Temp(idx(1)+1);
        middleBottom = [middleBottom; [c1,c2]];
    end
    %Outer Polygon
    c2 = Temp(1);
    topTop = [topTop; [c1,c2]];
    c2 = Temp(end);
    bottomBottom = [bottomBottom; [c1,c2]];
end
tOutline = [topTop;flip(bottomBottom);middleBottom;flip(middleTop);topTop(1,:)];

%Verification
all(inpolygon(T(:,1),T(:,2),tOutline(:,1),tOutline(:,2)))
plot(tOutline(:,1),tOutline(:,2),'r','LineWidth',2)
hold on
scatter(T(:,1),T(:,2))
axis([-.1,1.1,-1.1,1.1])

%Save to file
if isfolder('U:\eng_research_kablab\users\ksnapp\NatickCollabHelmetPad\TSCTestData')
        fname = 'U:/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150e01.mat';
else
    fname = '/ad/eng/research/eng_research_kablab/users/ksnapp/NatickCollabHelmetPad/TSCTestData/TISC/TISC150e01.mat';
end

save(fname,'tOutline')
