import random
l =[]
r = open('play_list.txt','r')#Today arrangement
for line in r:
    l.append(line)
random.shuffle(l)

f = open('play_list.txt','w')

for i in range(len(l)):
    f.write(l[i])


f.close()
