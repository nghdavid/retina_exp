cd ('0810 new video Br50\rn_workspace')
for G = [3,9,25,43,45,53,63,65,75]
        name = ['o_rntestG0',int2str(G),'.mat']
        rntest = zeros(1,36000);
        for i = 1:36000
            rntest(i) = randn;
        end
        save(name,'rntest')
end
for G = [12,20]
        name = ['o_rntestG',int2str(G),'.mat']
        rntest = zeros(1,36000);
        for i = 1:36000
            rntest(i) = randn;
        end
        save(name,'rntest')
end
