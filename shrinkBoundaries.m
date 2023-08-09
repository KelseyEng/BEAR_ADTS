%Kelsey Snapp
%Kab Lab
%8/3/23
% Shrinks boundaries before LHS if using focus radius

function boundaries = shrinkBoundaries(targetPoint,focusRad,boundaries,LHSMethod)

    rangeBound = diff(boundaries);
    offset = (rangeBound .* focusRad)./2;
    boundaries2 = targetPoint + offset .* [-1;1];
    if LHSMethod == 1
        boundaries2(1,:) = max([boundaries(1,:);boundaries2(1,:)]);
        boundaries2(2,:) = min([boundaries(2,:);boundaries2(2,:)]);
        for i = 1:size(boundaries2,2)
            if boundaries2(1,i) > boundaries2(2,i)
                boundaries2(:,i) = boundaries(:,i);
            end
        end
    end
    boundaries = boundaries2;

end