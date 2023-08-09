%Kelsey Snapp
%Kab Lab
%6/20/23
% get position of robot

function pos = getPosition()

pos = py.checkPosition.get_current_pos();
pos = double(pos);

end