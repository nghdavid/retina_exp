#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Sep 22 15:35:31 2018

@author: Leo
"""

N_th_file = 2
f = open('sorting.bat','w')

#Original the 2nd data batch
    #start import.exe
    #timeout /t 10
    #start down.exe
    #timeout /t 1
    #start enter.exe
    #timeout /t 1
    #timeout /t 30
    #start filter.exe
    #timeout /t 40
    #start detect.exe
    #timeout /t 200
    #start sort.exe
    #timeout /t 
    #start export.exe



for i in range(N_th_file):    
    f.write('start import.exe')#imprt the .mcd file.
    f.write('\n')
    f.write('timeout /t 10')#time for the .exe to execute
    f.write('\n')
    
    for j in range(i): #for the n-th data press "down" n-1 times.
        f.write('start down.exe')#press the "down" button.
        f.write('\n')
        f.write('timeout /t 1')
        f.write('\n')
        
    f.write('start enter.exe')#press the "enter" button.
    f.write('\n')
    f.write('timeout /t 1')
    f.write('\n')
    
    f.write('timeout /t 30')#wait for the  import.
    f.write('\n')
    
    f.write('start filter.exe')#set up tne filer
    f.write('\n')
    f.write('timeout /t 40')
    f.write('\n')
    
    f.write('start detect.exe')
    f.write('\n')
    f.write('timeout /t 500')#detecting time
    f.write('\n')
    
    f.write('start sort.exe')
    f.write('\n')
    f.write('timeout /t 2100')#sorting time
    f.write('\n')
    
    f.write('start export.exe')#export the .Plx file
    f.write('\n')
    f.write('timeout /t 450')#export time 
    f.write('\n')

    

f.close()