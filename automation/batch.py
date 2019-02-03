#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 22 15:35:31 2018

@author: nghdavid
"""
movie_list = []#Movies we are going to play
times = []#Each movie time
r = open('play_list.txt','r')#Today arrangement

#Read file
for line in r:
    l = line.split(' ')
    movie_list.append(l[0])
    times.append(int(l[1]))
    
f = open('exp.bat','w')
#Pull up board
servo_up = 'powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"'
#Pull down board
serve_down = 'powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"'
start = r'psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe'#Start recording
end = r'psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe'#End recording
sleep = 'timeout /t '#Force procedure to stop for a few second(need + 'time')
play = 'START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe '#Play movie(need + 'movie_name')
matlab = r'psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" ' #Use Daq to check whether it is played normally
dot = "'"

#Function that make each movie's batch
def play_movie(f,movie,time):
    f.write(servo_up)#Pull up board
    f.write('\n')

    f.write(sleep)#Force procedure to stop 40 sec
    f.write('40')#Adaptation time 
    f.write('\n')

    f.write(matlab)#Diode
    f.write(dot)
    f.write(movie[:-4])#stimulation name
    f.write(dot)
    f.write(' ')#space
    f.write(str(time+25))#Add 25 sec to prevent record too short
    f.write('\n')

    f.write(sleep)
    f.write(str(10))
    f.write('\n')

    f.write(play)#Play movie
    f.write(movie)#Name of movie
    f.write('\n')

    f.write(start)#Start recording
    f.write('\n')

    f.write(sleep)
    f.write(str(time+10))#Add 10 sec to end recording too quick
    f.write('\n')

    f.write(end)#End recording
    f.write('\n')

    f.write(serve_down)#Pull down board
    f.write('\n')

    f.write(sleep)#Force procedure to stop 40 sec
    f.write('300')#Time for retina to rest
    f.write('\n')
    return
    
#Make all batches
#Record spontaneous
f.write(sleep)
f.write('3000')
f.write('\n')

f.write(play)#Make screens all black
f.write('\n')

f.write(start)#Start recording
f.write('\n')

f.write(sleep)
f.write('180')#Re
f.write('\n')

f.write(end)#End recording
f.write('\n')

for i in range(len(movie_list)):
    f.write(movie_list[i])
    play_movie(f,movie_list[i],times[i])
    f.write('\n')

    

f.close()