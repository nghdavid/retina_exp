clear all;
recording_time = 3;%Hours
time_cycle = 300;%second (5 mins)
time = 0;%Counting time
while time < recording_time*3600%Check time is up
    exp_folder ='D:\check';
    mkdir picture
    all_file = dir('data\*.mcd') ; % change the type of the files which you want to select, subdir or dir.
    n_file = length(all_file) ; 

    for m = 1:n_file
        clearvars -except all_file n_file m exp_folder time_cycle recording_time
        file = all_file(m).name ;
        [pathstr, name, ext] = fileparts(file);
        directory = [pathstr,'\'];
        filename = [name,ext];
        if name == '10001'
            continue
        end
        if exist(['data\',name,'.mat'])
           disp('analyze already') 
           continue
        else
           [a_data,Infos] = analyze_MEA_analog_data([exp_folder,'\data\',filename],1,'','david','all');%The function that only transfer adata part of mcd file
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if length(a_data)/20000 > 300 && length(a_data)/20000 < 350%Remember to check HMM video length
            type = 'normal';
            disp([name,' is normal'])
        elseif length(a_data)/20000 > 850
            type = 'short';
            disp([name,' is short HMM'])
        elseif length(a_data)/20000 > 210 && length(a_data)/20000 < 250
            type = 'cSTA';
            disp([name,' is cSTA'])
        elseif length(a_data)/20000 < 20
            disp([name,' has an error or it is too short'])
            continue;
        elseif length(a_data)/20000 < 200
             type = 'onoff';
             disp([name,' is onoff'])
             continue;
        else
            disp([name,' is unknown'])
            continue;
        end
        pass = mea_reconstruct(pwd,type,name,a_data);%Test whether adata can be reconstructed
    end
    pause(time_cycle)%Wait for five minutes
    time = time + time_cycle;
end