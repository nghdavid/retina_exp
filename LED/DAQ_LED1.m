clear all;
close all;
rate=10000;  
du=5;
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
volt = linspace(4,0,du*rate);

daq_out.write(volt); 
daq_in.read;
lumin=daq_in.data;
lumin = lumin(fliplr(1:length(lumin)));
% [b,a]=butter(2,20/rate,'low');
% lumin_filter=filter(b,a,lumin) ;
span=500;
lumin_filter=smooth(lumin,span); % smooth looks better
lumin_filter(1:span)=mean(lumin_filter(span+1:2*span));
daq_in.wait;

volt = linspace(0,4,du*rate);
daq_out.write(volt); 
daq_in.read;
lumin2=daq_in.data;
% [b,a]=butter(2,20/rate,'low');
% lumin_filter=filter(b,a,lumin) ;
lumin_filter2=smooth(lumin2,span); % smooth looks better
lumin_filter2(1:span)=mean(lumin_filter2(span+1:2*span));
daq_in.wait;

lumin3 = (lumin+lumin2)/2;
lumin_filter3 = (lumin_filter+lumin_filter2)/2;


figure(2) ; plot(lumin3);title(['lumin v.s. time']);
hold on; plot(lumin_filter3);title(['filtered lumin v.s. time']);
meature2true_transformer = 1/2*350;
true_lumin = lumin_filter3*meature2true_transformer; %mW/m^2
figure(4) ;hold on; plot(volt,true_lumin);title(['voltage v.s. lumin']);

daq_out = daqmx_Task('chan','Dev1/ao1' ,'rate',rate, 'Mode', 'f');
daq_out.write(0);

ddd=date;
diode_path_cal=['D:\leo\stimulus saving\',ddd,'\calibration'];
mkdir(diode_path_cal)
save([diode_path_cal,'\calibration',ddd],'lumin_filter','rate','volt', 'true_lumin', 'meature2true_transformer')
