timeout /t 3000
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo('cs',1);exit;" 
timeout /t 240
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'2.5
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',2.5, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'4.5
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',4.5, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'9
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',9, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'12
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',12, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'hm'20
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('hm',20, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'ou'0.3
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('ou',0.3, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300

::'ou'0.6
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\start.exe
 matlab -nodisplay -nosplash -nodesktop -r DAQ_LED_leo_fixedseed('ou',0.6, 0421);exit;"
timeout /t 365
psexec -u MEA -p hydrolab \\192.168.1.171 -d -l -i C:\auto\end.exe
timeout /t 300
