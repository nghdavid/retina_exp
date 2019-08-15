timeout /t 3000
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
timeout /t 180
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe

::1.avi
powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 1.avi
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
timeout /t 50
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
psexec -u MEA -p hydrolab \\192.168.1.171 -s "C:\auto\diode.bat" '1' 65
timeout /t 200
psexec -u MEA -p hydrolab \\192.168.1.171 -s "C:\auto\upload.bat" 1.mcd
timeout /t 70

::2.avi
powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"
timeout /t 40
START C:"\Program Files"\DAUM\PotPlayer\PotPlayerMini64.exe 2.avi
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
timeout /t 60
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"
psexec -u MEA -p hydrolab \\192.168.1.171 -s "C:\auto\diode.bat" '2' 75
timeout /t 200
psexec -u MEA -p hydrolab \\192.168.1.171 -s "C:\auto\upload.bat" 2.mcd
timeout /t 70
