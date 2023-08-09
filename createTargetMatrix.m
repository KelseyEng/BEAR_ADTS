%Kelsey Snapp & Rashid Kolaghassi
%Kab Lab
%7/29/22
% Generates GP and runs Predict for a single task

function t_matrix = createTargetMatrix(yObs)

    t_matrix = zeros(2,length(yObs));
    t_matrix(1,:) = yObs > 0;
    t_matrix(2,:) = yObs == 0;

end