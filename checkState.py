# Bowen Xu
# October 1, 2018
# Current edition

# the function of this file is to check the status
# Program running: true
# Program running: false

import socket
HOST = ""
PORT = 29999

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST,PORT))
data = s.recv(1024)

s.send('running' + '\n')
data = s.recv(1024)
print(data)
