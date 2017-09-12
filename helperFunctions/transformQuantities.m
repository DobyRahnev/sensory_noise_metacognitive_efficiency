function combined = transformQuantities(measure_cont, measure_pair, measure_all)

combined(:,1) = mean(measure_cont,2); %mean measure for each single contrast
combined(:,2) = mean(measure_pair(:,[1,3]),2); %mean measure for combined close contrasts
combined(:,3) = measure_all'; %mean measure for all contrast
combined(:,4) = measure_pair(:,2); %mean measure for far contrasts (1 and 3)