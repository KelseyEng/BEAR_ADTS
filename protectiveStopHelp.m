

function protectiveStopHelp(testT)

    message = 'A protective stop has occured in an unexpected location. BEAR will pause until a researcher can check the situation.';
    postSlackMsg(message,testT)
    musicHelp()
    pause
    
end