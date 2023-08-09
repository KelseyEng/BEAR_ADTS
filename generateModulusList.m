%Kelsey Snapp
%Kab Lab
%5/4/21
% Generates List of Modulus for each printer slot based on printer loading

function printerModulusList = generateModulusList(printerFilamentList,filamentIDTable)
    printerModulusList = zeros(size(printerFilamentList));
    for i=1:size(printerFilamentList,1)
        for j = 1:size(printerFilamentList,2)
            printerModulusList(i,j) = filamentIDTable.Modulus(printerFilamentList(i,j));
        end
    end
end