%Kelsey Snapp
%Kab Lab
%3/20/23
% Saves Squigly Campaign data to dataC


function dataC = saveSquiglyData(dataC,ID,vStar,hStar,dL,dZ,L,H,eDot,eMult,alpha)

    row = find(dataC{3}.ID == ID);
    if isempty(row)
        row = size(dataC{3},1)+1;
        dataC{3}.ID(row) = ID;
    end
    
    dataC{3}.Vstar(row) = vStar;
    dataC{3}.Hstar(row) = hStar;
    dataC{3}.Dl(row) = dL; %mm
    dataC{3}.Dz(row) = dZ; %mm 
    dataC{3}.L(row) = L; %mm
    dataC{3}.H(row) = H; %mm
    dataC{3}.Edot(row) = eDot; %mm/min
    dataC{3}.Emult(row) = eMult; % unitless
    dataC{3}.Alpha(row) = alpha; % unitless
    
end