# Bowen Xu
# October 12, 2018
# Current edition

# the function of this file is to check the safety status
# send "safetymode"
# "Safetymode: <mode>", where <mode> is
# NORMAL
# REDUCED
# PROTECTIVE_STOP
# RECOVERY
# SAFEGUARD_STOP
# SYSTEM_EMERGENCY_STOP
# ROBOT_EMERGENCY_STOP
# VIOLATION
# FAULT

import socket
#HOST = "192.168.0.100"
HOST = "192.168.0.114"
PORT = 29999

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST,PORT))
data = s.recv(1024)

s.send('safetymode' + '\n')
data = s.recv(1024)
print(data)
