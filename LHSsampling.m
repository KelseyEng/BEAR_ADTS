%Kelsey Snapp
%Kab Lab
%3/15/22
%LHS Sampling of space Space
% boundaries should be in the form of a 2 by dim matrix. Row 1 is the lower
%bound of that dimension, Row 2 is the higher bound of that dimension.
%Example: boundaries = [0 1 -1; 2,2,2]. 
% numPts is the approximate number of samples you want. Because it must
% have equal number of samples in each direction, the return value can vary
% wildly depending on size of dimensions, etc.
% example call:
% boundaries = [0 1 -1; 2,2,2]
% returnPts = LHSsampling(5^3,boundaries)
% returnPts in shape of n by dim

function returnPts = LHSsampling(numPts,boundaries)

    rng('shuffle')
    
    dim = size(boundaries,2);
    % Divide space into equal boxes
    ptsPerDim = round(numPts.^(1/dim));
    boundPts = linspace(0,1,ptsPerDim+1);
    deltaPts = boundPts(2)-boundPts(1);
    
    % Create combvec input as comma separated list
    combIn = {boundPts(1:end-1)};
    for i = 1:(dim-1)
        combIn{end+1} = boundPts(1:end-1);
    end

    % Get list of initial points (lower left) for each square
    returnPts = combvec(combIn{:})';

    % Apply random offset 
    offSet = rand(size(returnPts));
    returnPts = returnPts+offSet.*deltaPts;
    
    % Scale to final Shape
    returnPts = returnPts .* (boundaries(2,:)-boundaries(1,:)) + boundaries(1,:);

end


