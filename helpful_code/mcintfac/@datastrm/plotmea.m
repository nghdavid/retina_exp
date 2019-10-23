function plotmea(d)
% plotmea- plot the channels in this recording (datastream method)
% plotmea(d) plots the channels in an MCRack file

	cellplot(reshape(d.ChannelNames([1:64]),8,8));
