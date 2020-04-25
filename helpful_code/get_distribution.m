function [pd,x_values,y] = get_distribution(pos)
    pd = fitdist(pos,'Normal');
    x_values = min(pos):1: max(pos);
    y = pdf(pd,x_values);
end