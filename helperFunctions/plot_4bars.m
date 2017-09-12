function plot_4bars(data)

number_subjects = size(data,1);
locations = [1,2,4,5];

figure
ax = axes;
bar(locations(1), mean(data(:,1)), 'r');
hold
bar(locations(2), mean(data(:,2)), 'w');
bar(locations(3), mean(data(:,3)), 'r');
bar(locations(4), mean(data(:,4)), 'w');

%Plot confidence intervals
shift=0;
for i=1:size(data,2)  
    plot([locations(i),locations(i)], [mean(data(:,i))-std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))+std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
    plot([locations(i)-.05,locations(i)+.05], [mean(data(:,i))-std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))-std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
    plot([locations(i)-.05,locations(i)+.05], [mean(data(:,i))+std(data(:,i))/sqrt(number_subjects), ...
        mean(data(:,i))+std(data(:,i))/sqrt(number_subjects)], 'k', 'LineWidth',2);
end

%ylabel('Value','FontSize',40);
xlim([.5, locations(end)+.5]);
set(ax,'XTick',[1.5, 4.5]);
xlabel('Measure', 'FontSize',20);
legend('low contrast', 'high contrast')