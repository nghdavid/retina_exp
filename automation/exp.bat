##1.avi 300sec

#Pull up board
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"

#Force procedure to stop 40 sec, 40 is adaptation time 
timeout /t 40

#Start recording of DAQ
psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" '1' 300

#Start recording of MC_rack
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe

#buffer
timeout /t 10

#Play movie
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 1.avi
#Add 5 sec to prevent stop too early
timeout /t 310

#End recording
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe

#Pull down board
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
#Time for retina to rest
timeout /t 300

##2.avi 300sec
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" '2' 300
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe
timeout /t 10
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 2.avi
timeout /t 310
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
timeout /t 300
