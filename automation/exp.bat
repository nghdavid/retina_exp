##test.avi 60

#Pull up board
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"

#Force procedure to stop 40 sec, 40 is adaptation time 
timeout /t 40

#Start recording of DAQ
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\record.exe

#Start recording of MC_rack
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe

#Play movie
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe test.avi

#Add 5 sec to prevent stop too early
timeout /t 65

#End recording
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe

#Pull down board
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"

#Time for retina to rest
timeout /t 300




##HMM.avi 300
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\record.exe
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe HMM.avi
timeout /t 305
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
timeout /t 300




##OU.avi 400
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\record.exe
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe OU.avi
timeout /t 405
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
timeout /t 300
