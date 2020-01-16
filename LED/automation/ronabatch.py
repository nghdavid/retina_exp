#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 22 15:35:31 2018

@author: Leo
"""
stimuli_list = []#Movies we are going to play
G = []#Each movie time
mean_lumin =[]
seeddate = []
r = open('rona_list.txt','r')#Today arrangement

#Read file
for line in r:
    l = line.split(' ')
    stimuli_list.append(l[0])
    G.append(l[1])
    mean_lumin.append(l[2])
    seeddate.append(l[3][:-1])

print(stimuli_list)
f = open('R_exp.bat','w')
start = r'psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe'#Start recording
end = r'psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe'#End recording
sleep = 'timeout /t '#Force procedure to stop for a few second(need + 'time')
#stimuli = r' matlab -nodisplay -nosplash -nodesktop -r check;exit;" '

#Function that make each movie's batch
def whole_field_stimuli(f,stimu,G,m,seeddate):
    stimuli = r' matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('+stimu+','+ G +','+ m +', '+seeddate+');exit;"'
    
    f.write(start)#Start recording
    f.write('\n')

    f.write(stimuli)
    f.write('\n')

    f.write(sleep)
    f.write(str(300+65))#Add 20 sec to end recording too quick
    f.write('\n')

    f.write(end)#End recording
    f.write('\n')

    f.write(sleep)#Force procedure to stop 40 sec
    f.write('300')#Time for retina to rest
    f.write('\n')

    return

#Make all batches
#Record csta
f.write(sleep)
f.write('3000')
f.write('\n')

#stimuli = r' matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('cs',1);exit;" '
    
f.write(start)#Start recording
f.write('\n')

#f.write(stimuli)
f.write(' matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo(')
l = r"'"
f.write(l)
f.write('cs')

f.write(l)

f.write(',1);exit;" ')
f.write('\n')

f.write(sleep)
f.write(str(180+60))#Add 20 sec to end recording too quick
f.write('\n')

f.write(end)#End recording
f.write('\n')

f.write(sleep)#Force procedure to stop 40 sec
f.write('300')#Time for retina to rest
f.write('\n')

for i in range(len(stimuli_list)):
    f.write('\n')
    f.write('::')
    f.write(stimuli_list[i]+G[i]+';lumin'+mean_lumin[i])
    f.write('\n')
    whole_field_stimuli(f,stimuli_list[i],G[i],mean_lumin[i],seeddate[i])
    


f.close()




    
