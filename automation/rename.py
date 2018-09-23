#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 23 07:58:45 2018

@author: nghdavid
"""
import os
movie_list = []#Movies we played

r = open('play_list.txt','r')#Today arrangement

#Read file
for line in r:
    l = line.split(' ')
    movie_list.append(l[0][:-4])#Get file name
i = 0
mcd_path = '/test'#The directory we save our mcd file
files = os.listdir(os.getcwd()+mcd_path)#Get filename in mcd directory
os.chdir(mcd_path)#Go to mcd directory
for filename in files:
    os.rename(filename, movie_list[i]+'.mcd') 
    i+=1


