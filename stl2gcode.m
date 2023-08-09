function [len,fname_gcode] = stl2gcode(fname_stl,fname_ini)
%Description: The following function generates a gcode file given and stl
%file. 
%   The function generates a gcode file by using the command prompt to call
%   slic3r and run the .ini config file
%   string is the input .stl
%   Edit the ini file to change have the desired fill density
%   text = ['slic3r-console.exe ',string,' --load [configFile].ini',' --output C:\Users\wyatt\Desktop\RESEARCH_BROWN\MATLAB\ParameterSpace\PrinterControl'];
%   Example: string = 'file.stl';

   text = ['C:\Coding\Slic3r\slic3r-console.exe ',fname_stl,' --load ',fname_ini];


%   Find the approximated mass using the generic ini file 
temp = erase(fname_stl,'.stl');
fname_gcode = [temp,'.gcode'];

[status,cmdout] = dos(text);

%   Checks the status and kicks out if it didnt work
if status == 0
%   disp('The test file was successfully created.')
else
   error('The test file was not successfully created.')
end  

%   Find the filament length that the command prompt returns
out = cmdout;
k = strfind(out,': ');
str = out(k+2:end-1);
k = strfind(str,'mm');
len = str2double(str(1:k-1));


end
