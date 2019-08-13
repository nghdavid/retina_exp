clear all;close all

rate=10000;  
du=2;
daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);
%%%%%%%%%%%% step1:background lumin %%%%%%%%%%%
% daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
% daq_out.write(0);
% daq = daqmx_Task('Dev1/ai0');
% bk = daq.read;


%%%%%%%%%%%% step2:calibration line %%%%%%%%%%%
% daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', du*rate);
% daq_in = daqmx_Task('chan','Dev1/ai0' ,'rate',rate, 'SampleNum', length(ey));
volt = linspace(0,3,du*rate);

daq_out.write(volt); 
daq_in.read;
[b,a]=butter(2,20/rate,'low');
lumin=daq_in.data;
lumin_filter=filter(b,a,lumin) ;
daq_in.wait;
% figure(1) ; plot(volt);title(['voltage v.s. time']);
figure(2) ; plot(lumin);title(['lumin v.s. time']);
% figure(3) ; plot(lumin_filter);title(['lumin v.s. time']);
% figure(4) ; plot(volt,lumin_filter);title(['voltage v.s. lumin']);

daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);
