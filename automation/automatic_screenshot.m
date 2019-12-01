%% This code can take screenshot in each period and then save photo
%After saving photo, it send to assigned email
close all;
clear all;
%% Go to photo directory
recording_time = 8;%Hours
time_cycle = 300;%second (5 mins)
reciever_gmail = 'nghdavid123@gmail.com';
%reciever_gmail = 'llincooi@gmail.com';
pos = [0 0 1920 1080];% Screen position [left top width height]
photo_folder = 'G:\Mc_rack_photo';
rmdir(photo_folder,'s');%Remove whole directory
mkdir(photo_folder)%Make new directory
cd(photo_folder)
%%  Email parameters
mail = 'hydrolab320@gmail.com'; % my gmail address
password = 'yourpassword';  % my gmail password 
host = 'smtp.gmail.com';
%Remember to close down antivirus software and turn off security in gmail
%% preferences
setpref('Internet','SMTP_Server', host);
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');
props.setProperty( 'mail.smtp.starttls.enable', 'true' );
time = 0;%Counting time
num = 1;%Counting numbers
%% Run a cycle until time is up
while time < recording_time*3600%Check time is up
    %% Take screenshot
    robot = java.awt.Robot();
    rect = java.awt.Rectangle(pos(1),pos(2),pos(3),pos(4));
    cap = robot.createScreenCapture(rect);
    rgb = typecast(cap.getRGB(0,0,cap.getWidth,cap.getHeight,[],0,cap.getWidth),'uint8');
    imgData = zeros(cap.getHeight,cap.getWidth,3,'uint8');
    imgData(:,:,1) = reshape(rgb(3:4:end),cap.getWidth,[])';
    imgData(:,:,2) = reshape(rgb(2:4:end),cap.getWidth,[])';
    imgData(:,:,3) = reshape(rgb(1:4:end),cap.getWidth,[])';
    imwrite(imgData,[num2str(num),'.jpeg'])
    %% load photo
    all_file = dir('*.jpeg') ; % change the type of the files which you want to select, subdir or dir. 
    n_file = length(all_file) ;
    file = all_file(n_file).name ;
    [pathstr, name, ext] = fileparts(file);
    filename = [name,ext];

    %%  Send the email
    sendmail(reciever_gmail,'Mc_rack recording screen shot',['Time is ',all_file(n_file).date],filename);
    pause(time_cycle)%Wait for five minutes
    time = time + time_cycle;
    num = num + 1;
end