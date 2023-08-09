import socket
import urx
import time
import numpy as np
import math
from urx import Robot
from urx.urrobot import URRobot
from urx import ursecmon
import math3d as m3d

#MAY HAVE TO CHANGE THE HOME POSITIONS FOR EACH PRINTER
#UPON TESTING
#change Xlimit, a temp value is being used now



class URX_class:

    def __init__(self):
        # print("initialized")
     
        
        self.sim=0

        if(self.sim==1):
            #Simulation
            self.robbie = Robot("")
        else:
            #actual robot arm 
            self.robbie = Robot("") 

        self.velocity=0.7
        self.acceleration=0.3
               
          
        # Following is used to check if the program is connected to the robot
       
        self.robbie.set_tcp((0,-0.020,0.130,0,0,0))
        self.X_offset_array=([0,0,0,0,0])
        self.Z_offset_array=([0,0,0,0,0])

        #first 5 values represent the printers 1-5, 6-> instron, 7->scale
        self.X_rot=([0,0,0,0,0,0,0]) 
        self.Y_rot=([0,0,0,0,0,0,0])
        self.Z_rot=([0,0,0,0,0,0,0])

        self.scaleLoaded=1
        self.instronLoaded=1

        self.Xlimit = 100
        
        exit
    
    # Changing the offset values for x and y on printer
    def changeOffset(self,x,z,printer):
        printer= int(printer)
        (self.X_offset_array)[printer-1]= x
        (self.Z_offset_array)[printer-1]=z

    
    #Moves robot to the home position   
    def move2home(self): #checked
        self.move2safety()
        self.move2pt_deg(0.19,-90.02,0.22,-89.82,0.15,0) 
        self.robbie.movej((0.000349, -1.5708, -0.000349, -1.5708, -0.00017,0), acc= self.acceleration, vel= self.velocity)
        exit
        
    def home2p1(self):
        self.move2pt_deg(0.19,-90.02,0.22,-89.82,0.15,0) 
        self.move2pt_deg(80.69,-112.81,143.57,-29.43,59.27,-0.78) 
        exit
    
    def move2safety(self):
        self.move2pt_deg(80.69,-112.81,143.57,-29.43,59.27,-0.78) 
        exit


    #CHECKED
    def moveToP(self, printer_num):
        printer_num= int(printer_num)
        self.X_rot[printer_num-1]= 0
        self.Y_rot[printer_num-1]= 0
        self.Z_rot[printer_num-1]= 0
        if printer_num==1:
            self.move2pt_deg(121.73,-91.64,126.69,-34.77,123.14,0.79) 
            exit
            # print(1)
            # print(self.robbie.get_pose())
        elif printer_num ==2:
            self.move2pt_deg(115.87,-103.04,137.08,-34.58,63.65,0.39)
            exit
            # print(2)
            # print(self.robbie.get_pose())
        elif printer_num ==3:
            self.move2pt_deg(136.93,-129.9,150.54,-22.07,49.34,1.6) 
            exit
            # print(3)
            # print(self.robbie.get_pose())
        elif printer_num ==4:
            self.move2pt_deg(188.25,-104,138,-34.71,63.6,1.01)    
            exit
            # print(4)
            # print(self.robbie.get_pose())
        elif printer_num ==5:
            self.move2pt_deg(189.37,-89.82,123,-27.24,12.12,-5)
            exit
            # print(5)
            # print(self.robbie.get_pose())
        else:
            print("Invalid Printer Number")
            exit
        exit

    def move2scale(self): #checked
        self.move2pt_deg(36.96,-112.85,143.57,-29.19,59.27,-0.79)
        self.X_rot[6]= 0
        self.Y_rot[6]= 0
        self.Z_rot[6]= 0
        exit
    
    def move2instron(self): #checked
        self.move2pt_deg(-30.81,-120,123.66,-2.1,60,-0.77)
        self.X_rot[5]= 0
        self.Y_rot[5]= 0
        self.Z_rot[5]= 0
        exit

    # moves robot in x,y,z direction relative to the TCP  
    def move(self,a,b,c): #checked
        a=a/1000
        b=b/1000
        c=c/1000
        self.robbie.translate_tool((a,b,c), acc= self.acceleration, vel= self.velocity)        
        exit

    def move_wrtDev(self, a,b,c, dev):
        dev= int(dev)
        omega= self.Y_rot[dev-1]
        theta= self.X_rot[dev-1]
        phi= self.Z_rot[dev-1]
        rot_mat=([(  (math.cos(omega)* math.cos(phi))-(math.sin(omega)* math.sin(theta)* math.sin(phi))), ((math.cos(omega)*math.sin(phi))+(math.sin(omega)*math.sin(theta)*math.cos(phi))), -1*math.sin(omega)*math.cos(theta)],
        [-1*math.cos(theta)*math.sin(phi), math.cos(theta)*math.cos(phi), math.sin(theta)],
        [((math.cos(phi)* math.sin(omega))+(math.cos(omega)* math.sin(theta)* math.sin(phi))),    ((math.sin(omega)*math.sin(theta))-(math.cos(omega)*math.sin(theta)*math.cos(phi))) , math.cos(omega)*math.cos(theta)])
        mov=([a],[b],[c])
        rot_mat= np.array(rot_mat)
        mov= np.array(mov)
        new_pos= rot_mat@ mov
        a_n=new_pos[0,0]
        b_n=new_pos[1,0]
        c_n=new_pos[2,0]
        self.move(a_n, b_n, c_n)
   #ROTATIONS 

    def rotate_x(self,ang, dev):
        pose= self.robbie.get_orientation()
        dev= int(dev)
        mat= ([1 , 0, 0], [0, math.cos(ang), -math.sin(ang)], [0, math.sin(ang), math.cos(ang)])
        mat= np.array(mat)
        pose_arr=pose.get_array()
        new_orientation= np.matmul(pose_arr, mat)
        orient= m3d.Orientation(new_orientation)
        self.robbie.set_orientation(orient, acc= self.acceleration, vel= self.velocity)     
        self.X_rot[dev-1]= self.X_rot[dev-1]+ ang   
        exit()
        
    def rotate_y(self,ang, dev):
        dev= int(dev)
        pose= self.robbie.get_orientation()
        mat= ([math.cos(ang) , 0, math.sin(ang)], [0,1 ,0 ], [-math.sin(ang),0, math.cos(ang)])
        mat= np.array(mat)
        pose_arr=pose.get_array()
        new_orientation= np.matmul(pose_arr, mat)
        orient= m3d.Orientation(new_orientation)
        self.robbie.set_orientation(orient, acc= self.acceleration, vel= self.velocity)     
        self.Y_rot[dev-1]= self.Y_rot[dev-1]+ang    
        exit()

    def rotate_z(self,ang, dev):
        dev= int(dev)
        pose= self.robbie.get_orientation()
        mat= ([math.cos(ang), -math.sin(ang),0], [math.sin(ang), math.cos(ang),0], [0, 0, 1])
        mat= np.array(mat)
        pose_arr=pose.get_array()
        new_orientation= np.matmul(pose_arr, mat)
        orient= m3d.Orientation(new_orientation)
        self.robbie.set_orientation(orient, acc= self.acceleration, vel= self.velocity)     
        self.Z_rot[dev-1]= self.Z_rot[dev-1]+ang    
        exit()

    # moves the robot to any position in joint space; inputs should be 6 joint values in radians
    def move2pt_rad(self,a,b,c,d,e,f): #checked
        self.robbie.movej((a,b,c,d,e,f), acc= self.acceleration, vel= self.velocity)
        exit
    
    # moves the robot to any position in joint space; inputs should be 6 joint values in degrees
    def move2pt_deg(self,a,b,c,d,e,f):#checked
        self.robbie.movej(((a*3.1415)/180, (b*3.1415)/180, (c*3.1415)/180, (d*3.1415)/180, (e*3.1415)/180, (f*3.1415)/180), acc= self.acceleration, vel= self.velocity)
    exit


## PRINTER ####       

    #CHECKED
    def printer_pickUp(self, printer):
        # self.moveToP(printer)
        printer= int(printer)
        if((self.X_offset_array)[printer-1]!=0 or (self.Z_offset_array)[printer-1]!=0):
            self.move(-1*(self.X_offset_array)[printer-1], 0, 0)
            self.move(1.8, -96.1, 122)
            # self.move(2.8, -115, 220)
            self.move(0,0,(self.Z_offset_array)[printer-1])
        else:
            self.move(1.8, -96.1, 122)
            # self.move(2.8, -115, 220)
        exit()
    

    #moves left and right to loosen the part
    #CHECKED
    def printer_remove(self,printer): 
        printer= int(printer)
        dist1= self.Xlimit- (self.X_offset_array)[printer-1]
        dist2= self.Xlimit+ (self.X_offset_array)[printer-1]
        if dist1<dist2:
            if ((self.X_offset_array)[printer-1]+25)<self.Xlimit:
                self.move(-23,0,0)
                self.move(51,0,0)
                self.move(-48,0,0)
            else:
                self.move(-1*(dist1-5),0,0)
                self.move(51,0,0)
                self.move(-48,0,0)
        else:
            if ((self.X_offset_array)[printer-1]-25)>(-1*self.Xlimit):
                self.move(23,0,0)
                self.move(-51,0,0)
                self.move(48,0,0)
            else:
                self.move((dist1-5),0,0)
                self.move(-51,0,0)
                self.move(48,0,0)
        self.scaleLoaded=0
        exit()


    #moves all the way to the right to loosen the part
    #CHECKED
    def printer_rip(self, printer): 
        printer= int(printer) 
        dist1= self.Xlimit- (self.X_offset_array)[printer-1]
        dist2= self.Xlimit+ (self.X_offset_array)[printer-1]
        if dist1>dist2:
            self.move(-86,0,0)
        else:
            self.move(86,0,0)
        self.scaleLoaded=0
        exit()

    
    def printer_sweep(self, printer):#checked
        self.moveToP(printer)
        self.move(-13.6, -88, 60)
        self.move(0,0,260)
        self.move(0,0,-260)
        self.moveToP(printer)
        exit()

#CHECKED
    def scrapeP(self,printer): 
        self.moveToP(printer)
        printer= int(printer)
        self.rotate_x(0.281, printer)
        if((self.X_offset_array)[printer-1]!=0 or (self.Z_offset_array)[printer-1]!=0):
            self.move_wrtDev(-1*(self.X_offset_array)[printer-1], 0, (self.Z_offset_array)[printer-1],printer)
        self.move_wrtDev(0,-77,124,printer)        
        # if half == 0:
        self.move_wrtDev(0,0,100,printer)
        # else:
        #   self.move_wrtDev(7,45, 73.3, printer)
        # self.move_wrtDev(0,42,-8,printer)
        # self.rotate_x(0.4, printer)
        self.moveToP(printer)
        self.scaleLoaded=0
        exit()
    
    def scrapeP_half(self,printer):
        self.moveToP(printer)
        printer= int(printer)
        self.rotate_x(0.281, printer)
        if((self.X_offset_array)[printer-1]!=0 or (self.Z_offset_array)[printer-1]!=0):
            self.move_wrtDev(-1*(self.X_offset_array)[printer-1], 0, (self.Z_offset_array)[printer-1],printer)
        self.move_wrtDev(0,-77,124,printer)        
        # if half == 0:
        #   self.move_wrtDev(7,45,146.6,printer)
        # else:
        self.move_wrtDev(0,0, 60, printer)
        # self.move_wrtDev(0,42,-8,printer)
        # self.rotate_x(0.4, printer)
        self.moveToP(printer)
        self.scaleLoaded=0
        exit()


    # old
    # def printer_scraper(self,printer,half): #needs checking
    #     self.moveToP(printer)
    #     printer= int(printer)
    #     if((self.X_offset_array)[printer-1]!=0 or (self.Z_offset_array)[printer-1]!=0):
    #         self.move(-1*(self.X_offset_array)[printer-1], 0, (self.Z_offset_array)[printer-1])
    #     self.move(0,-59.8,123.9)
    #     self.rotate_x(0.281, printer)
    #     if half == 0:
    #         self.move_wrtDev(7,45,146.6,printer)
    #     else:
    #         self.move_wrtDev(7,45, 73.3, printer)
    #     self.move_wrtDev(0,42,-8,printer)
    #     self.rotate_x(0.4, printer)
    #     self.moveToP(printer)
    #     exit()
    
    def printer_cameraPrinting(self, printer): #checked
        printer= int(printer)
        self.moveToP(printer)
        self.move(3.6,75.5,80.3)
        # self.rotate_x(+0.7034, printer) do not need this
        exit
    
    #CHECKED
    def printer_cameraDone(self, printer):  
        printer= int(printer)
        self.moveToP(printer)
        self.move(1,-18.9,99.3)
        exit



 #### INSTRON ####

    #NEEDS TESTING TO ENSURE; MAYBE IN REVERSE ORDER
    def instronPick(self):
        self.move2instron()
        self.move(-23.5,19.5,194)
        self.rotate_y((-7/180)*3.1415, 6)
        self.move_wrtDev(0,-34.6,0,6)
        #close gripper
        self.move2instron()
        exit()

    #CHECKED
    def instron_sweep(self): 
        self.move2instron()
        self.move(-15,5,59)
        self.move(0,0,192)
        self.move2instron()
        exit
    
    #CHECKED
    def instron_drop(self): 
        self.move2instron()
        self.move(-21,-10,199)
        if(self.instronLoaded==1):
            self.move(0,-9,0)
        #open/close gripper
        if(self.instronLoaded==0):
            self.instronLoaded=1
        exit()
    
    # Clears instron, testing needed
    def instronClean(self):
        self.move2instron()
        self.move(-22.5, -172, 195.4)
        self.move(0,33.6,0)
        self.move2instron()
        exit()
        
    #CHECKED
    def instronCamera(self): 
        self.move2pt_deg(-25.53,-98.85,90.8,19.52,65.71,-4.77)
        # self.move2instron()
        # self.move(1.8,4.3,160)
        # self.move(-34.8, 96, -57.4)
        # self.rotate_x((9.1/180)*3.1415, 6)
        # use camera to take picture
        # self.move2instron()
        exit

    def instronSweepAlt(self):
        self.move2instron()
        self.move2pt_deg(-26.35,-97.36,111.92,-11.23,59.54,0.21)
        self.move2pt_deg(-26.35,-95.02,111.51,-15.86,69.29,0.24)
        self.move2pt_deg(-13.8,-86.83,101.64,-11.98,69.26,0.24)
        self.move2pt_deg(-24.94,-83.53,97.37,-9.17,69.34,0.23)
        self.move2pt_deg(-12.53,-79.5,96.28,-18.71,69.29,-1.01)
        self.move2pt_deg(-22.67,-72.52,85.47,-11.31,69.34,-1.03)
        self.move(0,15,-15)
        self.move2instron()
        self.instronLoaded=0
        exit()




####  SCALE ####

    #CHECKED
    # def dropScale(self):
    #     self.move2scale()
    #     self.move(21,-13,205)
    #     # open gripper
    #     # self.move(-16,-7.7,-205)
    #     exit

    #CHECKED
    def scaleCamera(self):
        # self.move2scale()
        self.move2pt_deg(52.94 ,-89.62 ,120.23,-29.25 ,75.32 ,-0.41)
        exit

    #CHEKCED
    def dropScale(self): 
        self.move2scale()
        self.move(20.8,-14,205.4)
        #CLOSE GRIPPER
        if(self.scaleLoaded==1):
            self.move(0,-2,0)
        if(self.scaleLoaded==0):
            self.scaleLoaded=1
        else:
            self.scaleLoaded=0
        exit

    #CHEKCED
    def clearScale(self):
        self.move(0,21.6,0)
        self.move2scale() 

    #CHECKED
    def cleanScale(self): 
        self.move2scale()
        self.move(20,10,110)
        self.move(0,0,120)
        self.move(0,0,-120)
        self.move2scale()
        exit()

    def pickScale(self):
        self.move2scale()
        self.move(26.6,23,7.8)
        self.move(-2.8,-5.4,194)
        self.move(0,-30.6,7)
        self.move(0,30.6,-200)
        self.move2scale()
        exit()

    def scaleSweepAlt(self):
        self.move2scale()
        self.move2pt_deg(49,-83.84,121.26,-33.68,72.5,-0.49)
        self.move2pt_deg(49.23,-83.3,120.67,-31.16,57.27,-0.47)
        self.move2pt_deg(53.32,-72.98,111.28,-38.32,57.33,0.64)
        self.move2pt_deg(52.48,-72.95,110.91,-37.34,81.56,0.63)
        self.move2pt_deg(59.32,-67.44,103.87,-37.41,77.84,0.62)
        self.move2pt_deg(59.24,-67.41,103.84,-37.41,92.57,0.62)
        self.move2pt_deg(59.24,-72.73,104.51,-34.82,92.57,0.63)
        self.move(0,0,-15)
        self.move2scale()
        exit()

    
    #CHECKED
    def scraper_grab(self):
        self.move2safety()
        self.move2pt_deg(78.37,-84.64,135.82,-49.09,167.65,0.83)
        self.move(0,-105,65)
        exit

    #CHECKED
    def scraper_return(self):
        self.move(0,105,-65)
        self.move2safety()
        exit


    #checked
    def scraper_drop(self):
        self.move2safety()
        self.move2pt_deg(65.46,-88.21,136.62,-47.33,154.58,-0.26)
        self.move(-1,-121,0)
        exit



    #CHECKED
    def grab_brush(self):
        self.move2pt_deg(-30.81,-120,123.66,-2.1,60.04,-0.77) #could do without this line checking needed
        self.move2pt_deg(-19.89,-102.44,150.72,-41.87,144.78,6.91)
        self.move(0,-96,0)
        self.move(-2.8, -1, 56.5)
        #close gripper
        # self.move2pt_deg(-30.81,-120,123.66,-2.1,60.04,-0.77) #could do without this line checking needed
        # self.move2safety()
        exit

    #CHECKED
    def brush_return(self):
        #needs to be made
        self.move(2.8, 1, -56.5)
        self.move(0,96,0)
        self.move2pt_deg(-30.81,-120,123.66,-2.1,60.04,-0.77) 
        exit

    #CHECKED
    def drop_brush(self):
        self.move2pt_deg(-30.81,-120,123.66,-2.1,60.04,-0.77) #could do without this line checking needed
        self.move2pt_deg(-36.8,-113.54,144.1,-25.82,128.42,4.61)
        self.move(0,-166.9,0)
        # self.move2pt_deg(-30.81,-120,123.66,-2.1,60.04,-0.77) #could do without this line checking needed
        exit


    def returnTempStorage(self):
        self.robbie.movej((-0.5475097864,-1.883384796,2.579422102, -0.6721262949,2.320240708,-0.01361356817), acc= self.acceleration, vel= self.velocity)
        #open gripper

    def drop(self,num):
        if(num == 1000):
            self.move2pt_deg(240.7,-78.87,130.68,-50.42,68.76,0)


    def getJoints(self):
        joints= self.robbie.getj()
        joints = np.array(joints)
        joints_deg= joints*(180/3.1415)
        return joints_deg


    def checkUR5(self):
        return self.robbie.secmon.is_program_running()
    
    def protectiveStop(self):
        dict_data= self.robbie.secmon.get_all_data()
        stopped = dict_data['RobotModeData']['isSecurityStopped']
        if stopped == True:
            return 1
        else:
            return 0

    def disable_protectiveStop(self):
        # self.robbie.secmon.get_all_data()['RobotModeData']['isSecurityStopped']=False
        # used for actual robot
        # HOST = "192.168.0.114"
        if (self.sim==1):
            HOST="192.168.117.128"
        else:
             HOST="192.168.0.114"

        PORT = 29999

        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((HOST,PORT))
        data = s.recv(1024)

        d = 'unlock protective stop' + '\n'
        s.send(d.encode())
        data = s.recv(1024)

    def commandsFromMatlab(self, text,num):
        command_dict={
            "initializeToP": self.move2safety,
             "moveToScale": self.move2scale,
             "grabScraper": self.scraper_grab,
             "returnFromScraperUp": self.scraper_return,
             "moveToP":self.moveToP,
             "scrapeP":self.scrapeP,
             "scrapeP_half":self.scrapeP_half,
             "dropScraper":self.scraper_drop,
             "returnFromScraper":self.scraper_return,
             "pToHome":self.move2home,
             "pCameraDone":self.printer_cameraDone,
             "p_pick":self.printer_pickUp,
             "p_remove": self.printer_remove,
             "p_rip":self.printer_rip,
             "dropScale" : self.dropScale,
             "scaleCamera":self.scaleCamera,
             "moveToInstron": self.move2instron,
             "grabBrush":self.grab_brush,
             "returnFromBrushUp": self.brush_return,
             "cleanScale": self.cleanScale,
             "dropBrush": self.drop_brush,
             "returnFromBrush":self.brush_return,
             "clearScale": self.clearScale,
             "dropInstron": self.instron_drop,
             "instronCamera": self.instronCamera,
             "sweepInstron": self.instron_sweep,
             "drop":self.drop,
             "cleanScaleAlt":self.scaleSweepAlt,
             "sweepInstronAlt":self.instronSweepAlt
        }

        if text=="pToHome" or text=="initializeToP":
            num=0

        if(num==0):
            command_dict[text]()
        else:
            command_dict[text](num)
        
        print(text)
        return 0


    
    def close(self):
        self.robbie.close()
        exit







        

 



