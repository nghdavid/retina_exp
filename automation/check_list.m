%% This code can check your play_list is okay or not
%It check it has this movie or not
%It also check the movie length is correct or not

exp_folder =  'C:\Users\hydrolab_Retina\Desktop\code';%directory that save your play_list
movie_folder = 'C:\Users\hydrolab_Retina\Desktop\code';%directory that save stimulus movie

%Read your play_list
list_ID = fopen([exp_folder, '\play_list.txt'],'r');
formatSpec = '%c';
list_txt = textscan(list_ID,'%s','delimiter','\n'); 
num_list_files = length(list_txt{1});
%Read current movie_list
movie_list_ID = fopen([movie_folder, '\movie_list.txt'],'r');
formatSpec = '%c';
movie_list_txt = textscan(movie_list_ID,'%s','delimiter','\n'); 
num_play_list_files = length(movie_list_txt{1});

movies = [];
times = [];

%Run all names in play_list
for i = 1:num_list_files
    movie = list_txt{1}{i}(1:end-3);%Movie name in play_list
    time = list_txt{1}{i}(end-3:end);%Movie time in play_list
    pass_or_not = 0;
    %Run all names in movie_list
    for i = 1:num_play_list_files
        if strcmp(movie_list_txt{1}{i}(1:end-3),movie)%Check it has movie or not
            if abs(str2num(time)-str2num(movie_list_txt{1}{i}(end-3:end))) <5%Check the time length is correct or not
                disp([movie,' pass'])%All pass
                pass_or_not = 1;
                break
            else
                disp([movie,' time is not correct'])
                disp(['time should be',movie_list_txt{1}{i}(end-3:end)])
                break
            end
        end
    end
    if ~pass_or_not
         disp([movie,'not pass'])
         disp(' ')
    end
end
