%% load original mat file to get a_data
clear all
load('D:\Yiko\Experiment\04142018\0414 mat\0414pos2_OU_UD_G19.mat')
clear Spikes TimeStamps

%% read in sorted excel file and make Spikes matrix
A = xlsread('D:\Yiko\Files for Thesis\04142018\0414_200filter_SD5_pos2_OU_UD_G19_nsort.xls');
uint=1; %pick unit x
for h=1:60
label=find(A(:,1)==h & A(:,2)==uint ); %pick channel  & pick unit 1
Spikes(h)=mat2cell(A(label,3)',1);  %Timestamp for that channel
end

sorted_Spikes=Spikes;
Spikes=cell(1,60);

% for offline number
rNumber=[59,42,46,7,10,52,...
                        55,38,21,25,28,31,14,56,...
                        13,34,17,3,49,35,18,39,...
                        9,48,30,51,60,22,4,43,...
                        6,27,45,24,15,53,11,32,...
                        2,41,58,12,26,40,57,36,...
                        20,37,54,50,47,44,1,19,...
                        16,33,29,8,5,23];

for h=1:60
    Spikes{h}=sorted_Spikes{rNumber(h)};
end


%% for single file
cd('D:\Yiko\Files for Thesis\04142018') ; % for saving
stiDir='UD';
stiDate='0414';
stiForm='OU';
name=['nsort  ',stiDate,stiForm,'_',stiDir,'_G19'];
save([name],'Spikes','a_data','Infos');


%% for separate files if needed
figure;plot(a_data(3,:))

 %take data points/ %include the last trial's datapoint !!!!

cutrange(1)=1;
cutrange(2:length(cursor_info)+1)=sort([cursor_info.DataIndex], 'ascend'); 

a_data01=[];  
a_data02=[];  
a_data03=[]; 
a_data04=[];  
a_data05=[];

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

cutrange=cutrange./20000;

Spike01=cell(1,60);  Spike02=cell(1,60);  Spike03=cell(1,60);
Spike04=cell(1,60);
Spike05=cell(1,60);
 for i =1:60
    yo1=find(Spikes{i}>=cutrange(1) & Spikes{i}<=cutrange(2));
    Spike01{i}=Spikes{i}(yo1);
    yo2=find(Spikes{i}>=cutrange(3) & Spikes{i}<=cutrange(4));
    Spike02{i}=Spikes{i}(yo2)-cutrange(3);
    yo3=find(Spikes{i}>=cutrange(5)& Spikes{i}<=cutrange(6));
    Spike03{i}=Spikes{i}(yo3)-cutrange(5);
    yo4=find(Spikes{i}>cutrange(7)& Spikes{i}<cutrange(8));
    Spike04{i}=Spikes{i}(yo4)-cutrange(7);
%     yo5=find(Spikes{i}>cutrange(9)& Spikes{i}<cutrange(10));
%     Spike05{i}=Spikes{i}(yo5)-cutrange(9);
 end

cd('D:\Yiko\Files for Thesis\04122018') ; % for saving
stiDir='UD';
stiDate='0412';
stiForm='OU';
%01
name=['nsort ',stiDate,stiForm,'_',stiDir,'_G0155_5min'];
Spikes=[]; a_data=[];
Spikes=Spike01;
a_data(3,:)= a_data01(3,:);
save([name],'Spikes','a_data','Infos');
 %02
name=['nsort ',stiDate,stiForm,'_',stiDir,'_G076_5min'];
Spikes=[]; a_data=[];
Spikes=Spike02;
a_data(3,:)= a_data02(3,:);
save([name],'Spikes','a_data','Infos');
 %03
name=['nsort ',stiDate,stiForm,'_',stiDir,'_G04_5min'];
Spikes=[]; a_data=[];
Spikes=Spike03;
a_data(3,:)= a_data03(3,:);
save([name],'Spikes','a_data','Infos');
 %04
name=['nsort ',stiDate,stiForm,'_',stiDir,'_G19_5min'];
Spikes=[]; a_data=[];
Spikes=Spike04;
a_data(3,:)= a_data04(3,:);
save([name],'Spikes','a_data','Infos');