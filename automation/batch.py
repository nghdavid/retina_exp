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
matlab = r'psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\record.exe'#Use Daq to check whether it is played normally
def play_movie(f,movie,time):
    f.write(servo_up)#Pull up board
    f.write('\n')
    f.write(sleep)#Force procedure to stop 40 sec
    f.write('40')#Adaptation time 
    f.write('\n')
    f.write(matlab)#Start recording of DAQ
    f.write('\n')
    f.write(start)#Start recording of MC_rack
    f.write('\n')
    f.write(play)#Play movie
    f.write(movie)#Name of movie
    f.write('\n')
    f.write(sleep)
    f.write(str(time+5))#Add 5 sec to prevent stop too early
    f.write('\n')
    f.write(end)#End recording
    f.write('\n')
    f.write(serve_down)#Pull down board
    f.write('\n')
    f.write(sleep)#Force procedure to stop 40 sec
    f.write('300')#Time for retina to rest
    f.write('\n')
    return

for i in range(len(movie_list)):    
    play_movie(f,movie_list[i],times[i])

    

f.close()