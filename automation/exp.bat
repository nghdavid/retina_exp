powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" '1' 300
timeout /t 10
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe
timeout /t 5
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 1.avi
timeout /t 310
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
timeout /t 300
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" '2' 300
timeout /t 10
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\start.exe
timeout /t 5
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 2.avi
timeout /t 310
psexec -u MEA -p hydrolab \\192.168.1.174 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM7,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
timeout /t 300
