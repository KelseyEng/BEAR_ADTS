%Kelsey Snapp
%Kab Lab
%9/26/22
%Hypersphere sampling
% Algorithm taken from two sites:
%http://extremelearning.com.au/how-to-generate-uniformly-random-points-on-n-spheres-and-n-balls/
%https://baezortega.github.io/2018/10/14/hypersphere-sampling/


function returnPts = HyperSphereSampling(numPts,boundaries)

    rng('shuffle')
    
    dim = size(boundaries,2);
    

    u = normrnd(0,1,[numPts,dim]);
    uNorm = vecnorm(u,2,2);
    r = rand([numPts,1]).^(1/dim);
    returnPts = r.*u./uNorm;
    returnPts = returnPts./2+.5;
    
    % Scale to final Shape
    returnPts = returnPts .* (boundaries(2,:)-boundaries(1,:)) + boundaries(1,:);

end




