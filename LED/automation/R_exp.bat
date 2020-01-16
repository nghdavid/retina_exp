timeout /t 3000
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo('cs',1);exit;" 
timeout /t 240
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'2.5;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',2.5,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'4.5;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',4.5,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'9;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',9,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'12;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',12,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'20;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',20,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'ou'3.2;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('ou',3.2,10, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'ou'7.6;lumin10
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('ou',7.6,10, 421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300
