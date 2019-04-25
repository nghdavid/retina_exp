 %% separate one mat file into several parts
 %if you record many experiments into one mcd file, then you may need to seperate them into multiple independent mat files
 clear all
 %load mat file first
 
 figure;plot(a_data(3,:))
%then take data points by yourself/ %include the last trial's datapoint !!

cutrange(1)=1;
cutrange(2:length(cursor_info)+1)=sort([cursor_info.DataIndex], 'ascend'); 

a_data01=[];  a_data02=[];  
a_data03=[]; 
a_data04=[];  a_data05=[];

a_data01(3,:)=a_data(3,cutrange(1):cutrange(2));
a_data02(3,:)=a_data(3,cutrange(3):cutrange(4));
a_data03(3,:)=a_data(3,cutrange(5):cutrange(6));
a_data04(3,:)=a_data(3,cutrange(7):cutrange(8));
a_data05(3,:)=a_data(3,cutrange(9):cutrange(10));

figure; plot(a_data01(3,:));
figure; plot(a_data02(3,:));
figure; plot(a_data03(3,:));
figure; plot(a_data04(3,:));
figure; plot(a_data05(3,:));

cutrange=cutrange./20000; %samplingrate=20000

Spike01=cell(1,60);  Spike02=cell(1,60);  Spike03=cell(1,60);
Spike04=cell(1,60); Spike05=cell(1,60);
 for i =1:60
    yo1=find(Spikes{i}>cutrange(1) & Spikes{i}<cutrange(2));
    Spike01{i}=Spikes{i}(yo1);
    yo2=find(Spikes{i}>cutrange(3) & Spikes{i}<cutrange(4));
    Spike02{i}=Spikes{i}(yo2)-cutrange(3);
    yo3=find(Spikes{i}>cutrange(5)& Spikes{i}<cutrange(6));
    Spike03{i}=Spikes{i}(yo3)-cutrange(5);
    yo4=find(Spikes{i}>cutrange(7)& Spikes{i}<cutrange(8));
    Spike04{i}=Spikes{i}(yo4)-cutrange(7);
%     yo5=find(Spikes{i}>cutrange(9)& Spikes{i}<cutrange(10));
%     Spike05{i}=Spikes{i}(yo5)-cutrange(9);
 end

 
cd('D:\Yiko\Experiment\04122018') ; % for saving
stiDir='UD';
stiDate='0412';
stiForm='OU';
%01
name=[stiDate,stiForm,'_',stiDir,'_G0155_5min'];
Spikes=[]; a_data=[];
Spikes=Spike01;
a_data(3,:)= a_data01(3,:);
save([name],'Spikes','a_data','Infos');
 %02
name=[stiDate,stiForm,'_',stiDir,'_G076_5min'];
Spikes=[]; a_data=[];
Spikes=Spike02;
a_data(3,:)= a_data02(3,:);
save([name],'Spikes','a_data','Infos');
 %03
name=[stiDate,stiForm,'_',stiDir,'_G04_5min'];
Spikes=[]; a_data=[];
Spikes=Spike03;
a_data(3,:)= a_data03(3,:);
save([name],'Spikes','a_data','Infos');
 %04
name=[stiDate,stiForm,'_',stiDir,'_G19_5min'];
Spikes=[]; a_data=[];
Spikes=Spike04;
a_data(3,:)= a_data04(3,:);
save([name],'Spikes','a_data','Infos');
