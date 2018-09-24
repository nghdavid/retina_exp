We use Diode_monitor.m to start recording of monitor via DAQ and photodiode. <br />
We use diode.bat to run Diode_monitor.m, diode.bat takes two arguments.First is name('HMM') and time(60)
If we want to record HMM.avi(300sec), we call diode bat with 'HMM' 300 two parameters.
Ex:psexec -u MEA -p hydrolab \\192.168.1.174 -s "C:\auto\diode.bat" 'HMM' 300


