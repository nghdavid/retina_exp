function [peak_time MI_peak] = findMIpeak(MIcurve, time, baseline, num_peak)
smooth_mutual_information = smooth(MIcurve);
if num_peak == 1
    MI_peak = max(smooth_mutual_information);
    peak_time = time(find(smooth_mutual_information==MI_peak));
else
    MIdiff = diff(smooth_mutual_information);
    ind_local_extrema = find(MIdiff(1:end-1).*MIdiff(2:end) < 0)+1; %find all local extrema
    if isempty(ind_local_extrema)
        MI_peak = NaN;
        ind_peak = NaN;
        return
    end
    [a I] = sort(smooth_mutual_information(ind_local_extrema), 'descend');
    ind_local_max_n = [];
    for i = 1:num_peak %find the biggest two local extrema with deltaT in -1~1 sec.
        if (time(ind_local_extrema(I(i))) < -1000) || (time(ind_local_extrema(I(i))) > 1000) ||  smooth_mutual_information(ind_local_extrema(I(i)))-baseline < 0.1% the 100 points, timeshift is 1000
        else
            ind_local_max_n = [ind_local_max_n ind_local_extrema(I(i))]; %factor out biggest 'num_peak' local extrema
        end
    end
    if isempty(ind_local_max_n)
        MI_peak = NaN;
        ind_peak = NaN;
    else
        %sort in time order, 1st one is the rightest one
        ind_local_max_n = sort(ind_local_max_n, 'descend');
        MI_peak= smooth_mutual_information(ind_local_max_n)';
        peak_time = time(ind_local_max_n)';
    end
end
end