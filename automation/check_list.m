

exp_folder =  'C:\Users\hydrolab_Retina\Desktop\code';
movie_folder = 'C:\Users\hydrolab_Retina\Desktop\code';
list_ID = fopen([exp_folder, '\play_list.txt'],'r');
formatSpec = '%c';
list_txt = textscan(list_ID,'%s','delimiter','\n'); 
num_list_files = length(list_txt{1});
movie_list_ID = fopen([movie_folder, '\movie_list.txt'],'r');
formatSpec = '%c';
movie_list_txt = textscan(movie_list_ID,'%s','delimiter','\n'); 
num_play_list_files = length(movie_list_txt{1});


movies = [];
times = [];



for i = 1:num_list_files
    movie = list_txt{1}{i}(1:end-3);   
    time = list_txt{1}{i}(end-3:end);
    pass_or_not = 0;
    for i = 1:num_play_list_files
        if strcmp(movie_list_txt{1}{i}(1:end-3),movie)
            if abs(str2num(time)-str2num(movie_list_txt{1}{i}(end-3:end))) <5
                disp([movie,' pass'])
                
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
