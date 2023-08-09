# Bowen Xu
# October 22, 2018
# Current edition

# the function of this file is to unlock the safety status
# send "unlock protective stop"
# return value is "Protective stop releasing"
# Closes the current popup and unlocks protective stop

import socket
HOST = ""
PORT = 29999

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST,PORT))
data = s.recv(1024)

s.send('unlock protective stop' + '\n')
data = s.recv(1024)
