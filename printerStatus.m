function [status,dosmsg,msg] = printerStatus(selectedPrinter)
% Brown Research Group
% Author: Aldair E. Gongora 
% Date: May 28, 2018 
% printerStatus(printerID) - checks printer status 

% Note: dosmsg(1:8) returns 'state: P' or 'state: O'
% This could be used to check on the printing status of printers 
% History: while loop was added on 2/8/2019 

command = ['python2 octocmd',num2str(selectedPrinter) ,' status']; 

[status,dosmsg] = dos(command); 

% return message on execution status

if status == 0
    
    % execution success
    
    msg = ['Command ',command,' was executed successfully']; 
    
else
    
    % execution failed
    
    msg = ['Command ',command,' failed to execute'];
    
    disp(msg); 
      
end


    
end

