%% Code for clustering STA into two groups and calculate two kinds of STA from different clusters
close all;
clear all;
exp_folder = '\\LEO\Leo\0823exp\';
name = 'csta';%Name that used to save photo and data
cd(exp_folder);
load(['Analyzed_data\PCA\',name,'.mat'])
roi = 46;%Channels that has two clusters. You have to choose manually
%% Cluster using threshold
%Threshold is whether projection to PCA1 is bigger or smaller than 0

figure(1)
%Red represents positive, blue represents negative
scatter(total_PCA1{roi}(find(total_PCA1{roi}>0)),total_PCA2{roi}(find(total_PCA1{roi}>0)),'r');hold on
scatter(total_PCA1{roi}(find(total_PCA1{roi}<0)),total_PCA2{roi}(find(total_PCA1{roi}<0)),'b');
xlabel('Stimulus*PCA1')
ylabel('Stimulus*PCA2')
title('Results of two cluster')

figure(2)
STA = total_STA{roi};
positive_PCA = STA(find(total_PCA1{roi}>0),:);
negative_PCA = STA(find(total_PCA1{roi}<0),:);
plot(time,mean(positive_PCA,1),'r');hold on%Red is positive_PCA
plot(time,mean(negative_PCA,1),'b');%Blue is negative_PCA
xlabel('time before spike(sec)')
ylabel('STA from two kinds of clusters')
title('STA of two different clusters using threshold')

%% K means clustering 
cluster_data = [total_PCA1{roi}',total_PCA2{roi}'];%Merge PCA1 and PCA2
idx = kmeans(cluster_data,2);%Results of which clusters(1 or 2), and clustered into 2 groups

figure(3)
%Red represents group 1, blue represents group 2
scatter(total_PCA1{roi}(find(idx==1)),total_PCA2{roi}(find(idx==1)),'r');hold on
scatter(total_PCA1{roi}(find(idx==2)),total_PCA2{roi}(find(idx==2)),'b');
xlabel('Stimulus*PCA1')
ylabel('Stimulus*PCA2')
title('Results of two cluster')

figure(4)
STA = total_STA{roi};
positive_PCA = STA(find(idx==1),:);
negative_PCA= STA(find(idx==2),:);
plot(time,mean(positive_PCA,1),'r');hold on%Red is positive_PCA
plot(time,mean(negative_PCA,1),'b');%Blue is negative_PCA
xlabel('time before spike(sec)')
ylabel('STA from two kinds of clusters')
title('STA of two different clusters using k means')