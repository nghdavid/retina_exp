for kk =1:length(xarray)
            if xarray(1,kk) > 0%Grating frame
                a = zeros(1024,1280);%Initialize each frame
                for i = 1:num_bar%Plot each bar
                    [kk i]
                    X=xarray(i,kk);
                    
                    barX=X+(mea_size_bm-1)/2-(longest_dis/2)+bar_wid;
                    barY=Y-lefty_bd;
                    Vertex = cell(4);
                    Vertex{1} = round([barX-bar_wid  barY-bar_le]);  %V1  V4
                    Vertex{2} = round([barX-bar_wid  barY+bar_le]);  %V2  V3
                    Vertex{3} = round([barX+bar_wid  barY+bar_le]);
                    Vertex{4} = round([barX+bar_wid  barY-bar_le]);
                    %rotation
                    for i = 1:4
                        Vertex{i} = R_matrix*(Vertex{i}-[(mea_size_bm+1)/2  (mea_size_bm+1)/2])'+[(mea_size_bm+1)/2  (mea_size_bm+1)/2]';
                    end
                    
                    a = write_CalBar(a,Vertex, theta,  mea_size_bm); %a = the bar
                    
                end
                %                         a(:,leftx_bd+11)=1;
                %                         a(:,leftx_bd+471)=1;
                a(500-35:500+35,1230:1280)=1;
                %writeVideo(writerObj,a);
                
                
            end
        end