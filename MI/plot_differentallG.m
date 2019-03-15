
%Load calculated MI first(Need to run Calculate_MI.m first to get)
cd G:\0215\sort_merge_spike\MI\HMM_RL
all_file = dir('*.mat') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;
%Tina orientation
rr =[9,17,25,33,41,49,...
          2,10,18,26,34,42,50,58,...
          3,11,19,27,35,43,51,59,...
          4,12,20,28,36,44,52,60,...
          5,13,21,29,37,45,53,61,...
          6,14,22,30,38,46,54,62,...
          7,15,23,31,39,47,55,63,...
            16,24,32,40,48,56];
h3=figure;
hL = subplot(8,8,1);
poshL = get(hL,'position');     % Getting its position

for channelnumber=1:60
    
    for     z =1:n_file 
        file = all_file(z).name ;
        [pathstr, name, ext] = fileparts(file);
        directory = [pathstr,'\'];
        filename = [name,ext];
        load([filename]);
        
        h=subplot(8,8,rr(channelnumber)); hold on;

        plot(time,Mutual_infos{channelnumber}-Mutual_shuffle_infos{channelnumber});
        
        xlim([ -3000 3000])
        ylim([0 inf+0.1])
        title(channelnumber)
    end
    
end
lgd = legend('G20','G3','G9')
set(lgd,'position',poshL);      % Adjusting legend's position
axis(hL,'off');                 % Turning its axis off