clear all;
close all;
all_file = subdir('*.tiff') ; % change the type of the files which you want to select, subdir or dir. 
n_file = length(all_file) ;
writerObj = VideoWriter(['example.avi']);
writerObj.FrameRate = 10;
open(writerObj);
for z =1:n_file %choose file
    fig=figure;
    imshow([int2str(z),'.tiff']);
    int2str(z)
    MOV=getframe(fig);
    writeVideo(writerObj,MOV);
    close(fig)
end

close(writerObj);