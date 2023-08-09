%Kelsey Snapp
%Kab Lab
%2/21/2023
%Checks validity of input



function validInput = checkInputBounds(INT,Bounds,inputVar)
    if INT
        % Requires Integer selected from list of options (bounds)
        if isempty(inputVar) || ~(mod(inputVar,1) == 0)
            validInput = 0;
        elseif ~any(inputVar == Bounds) && ~isempty(Bounds)
            validInput = 0;
        else
            validInput = 1;
        end
    else
        % Requires number between lower bound and upper bound
        if isempty(inputVar) || ~isnumeric(inputVar)
            validInput = 0;
        elseif inputVar < Bounds(1) || inputVar > Bounds(2)
            validInput = 0;
        else
            validInput = 1;
        end
    end
end