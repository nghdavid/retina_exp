set name=%1
set time=%2
matlab -nodisplay -nosplash -nodesktop -r Diode_monitor(%name%,%time%);exit;"