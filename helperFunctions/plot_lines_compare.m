function plot_lines_compare(data1, data2, panels, panel_num, plotTitle, ylimit)

num_subjects = size(data1,1);
num_conditions = size(data1,2);

P = subplot(panels(1),panels(2),panel_num); 
offset = .1;
plot([1:num_conditions]-offset, mean(data1), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
hold on
plot([1:num_conditions]+offset, mean(data2), 'bd', 'MarkerSize', 15, 'MarkerFaceColor', 'b');

for cond=1:num_conditions
    plot([cond-offset,cond-offset], [mean(data1(:,cond))-std(data1(:,cond))/sqrt(num_subjects), ...
        mean(data1(:,cond))+std(data1(:,cond))/sqrt(num_subjects)], 'k', 'LineWidth',2);
    plot([cond+offset,cond+offset], [mean(data2(:,cond))-std(data2(:,cond))/sqrt(num_subjects), ...
        mean(data2(:,cond))+std(data2(:,cond))/sqrt(num_subjects)], 'k', 'LineWidth',2);
end
plot([1:num_conditions]-offset, mean(data1), 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
plot([1:num_conditions]+offset, mean(data2), 'bd', 'MarkerSize', 15, 'MarkerFaceColor', 'b');
title(plotTitle);
xlim([0.5, num_conditions + 0.5])
legend('data', 'model')

if exist('ylimit', 'var')
    ylim(ylimit);
end