function MI_width = findMIwidth(MIcurve, baseline)
mutual_information = MIcurve;
mean_MI_distr = 0;
sq_MI_distr = 0;
for j = 1:length(mutual_information)
    if mutual_information(j) > baseline
        mean_MI_distr =  mean_MI_distr+j*(mutual_information(j)-baseline)/sum(mutual_information);
        sq_MI_distr =sq_MI_distr+ j^2*(mutual_information(j)-baseline)/sum(mutual_information);
    end
end
MI_width =sqrt(sq_MI_distr-mean_MI_distr^2);
end