# Bowen Xu 
# Aldair Gongora
# October 1, 2018 
###########################################################################
# Description: Script enables communication with UR5 via TCP 
# Note: Be aware of IP address
# Reference: http://www.zacobria.com/universal-robots-zacobria-forum-hints-tips-how-to/script-via-socket-connection/
###########################################################################
# Revision: 
# Date           Author             Brief Description 
# Dec. 15, 2020   AEG               Modified script to treat the path of the 
#                                   .urp code as a variable (passable to .py)
###########################################################################

import socket
import sys 

# save path as a variable 
filename_urp = sys.argv[1]

# IP Address 
HOST = ""
PORT = 29999

# create and connect to socket 
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((HOST,PORT))

# receive data from UR5 
data = s.recv(1024)

# create command based on filename 
command_ur5 = 'load ' + filename_urp +'\n'

# send load command to UR5 
s.send(command_ur5.encode())

# receive data from UR5 
data = s.recv(1024)

# send play command to UR5 
s.send('play\n'.encode())
data = s.recv(1024)