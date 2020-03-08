function plot_all_channel(type,save_photo,xarray,yarray,roi,exp_folder,sorted,name)
    load('rr.mat')
    figure('units','normalized','outerposition',[0 0 1 1])
    ha = tight_subplot(8,8,[.04 .02],[0.07 0.02],[.02 .02]);
    for channelnumber=roi
        axes(ha(rr(channelnumber)));
        plot(xarray,yarray(channelnumber,:),'LineWidth',2,'LineStyle','-');hold on;
        grid on
        title(channelnumber)
    end
    set(gcf,'units','normalized','outerposition',[0 0 1 1])
    fig = gcf;
    fig.PaperPositionMode = 'auto';
    if save_photo
        if sorted
            saveas(fig,[exp_folder,'\FIG\',type,'\sort\',name,'.tiff'])
        else
            saveas(fig,[exp_folder,'\FIG\',type,'\unsort\',name,'.tiff'])
        end
    end    
end