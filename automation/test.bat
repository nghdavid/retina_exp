powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.WriteLine("180"); $port.Close()"

timeout /t 10


powershell "$port= new-Object System.IO.Ports.SerialPort COM3,9600,None,8,one; $port.open(); $port.Writeline("0"); $port.Close()"

psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
timeout /t 30



