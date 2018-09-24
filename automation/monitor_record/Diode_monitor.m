function x = Diode_monitor(name,time)
rate=4200; 
du=time; %sec
daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', du*rate);
daq_in.read;
lumin=daq_in.data;
figure(2) ; plot(lumin);title(['lumin v.s. time']);
saveas(gcf,strcat(name,'.jpg'))
end