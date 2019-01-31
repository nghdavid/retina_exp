function x = Diode_monitor(name,time)
rate=20000; 
du=time; %sec
daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', du*rate);
daq_in.read;
lumin=daq_in.data;

path = 'E:\picture\';
figure(1) ; plot(lumin);title(['lumin v.s. time']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveas(gcf,strcat(path,name,'.jpg'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pass = check(lumin,name);
if pass
    save([path,name,'_success.mat'],'lumin');
else
    save([path,name,'_fail.mat'],'lumin');
end

end