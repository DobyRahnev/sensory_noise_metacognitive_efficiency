function plot_lines_2models(data, model1, model2, panels, panel_num, plotTitle, ylimit)

num_subjects = size(data,1);
num_conditions = size(data,2);

P = subplot(panels(1),panels(2),panel_num); 
offset = .2;
plot([1:num_conditions]-offset, mean(data), 'ko', 'MarkerSize', 15, 'MarkerFaceColor', [.6,.2,0]);
hold on
plot([1:num_conditions], mean(model1), 'kd', 'MarkerSize', 15, 'MarkerFaceColor', [.47,.67,.19]);
plot([1:num_conditions]+offset, mean(model2), 'kd', 'MarkerSize', 15, 'MarkerFaceColor', [1,.6,.78]);

for cond=1:num_conditions
    plot([cond-offset,cond-offset], [mean(data(:,cond))-std(data(:,cond))/sqrt(num_subjects), ...
        mean(data(:,cond))+std(data(:,cond))/sqrt(num_subjects)], 'k', 'LineWidth',2);
%     plot([cond,cond], [mean(model1(:,cond))-std(model1(:,cond))/sqrt(num_subjects), ...
%         mean(model1(:,cond))+std(model1(:,cond))/sqrt(num_subjects)], 'k', 'LineWidth',2);
%     plot([cond+offset,cond+offset], [mean(model2(:,cond))-std(model2(:,cond))/sqrt(num_subjects), ...
%         mean(model2(:,cond))+std(model2(:,cond))/sqrt(num_subjects)], 'k', 'LineWidth',2);
end
plot([1:num_conditions]-offset, mean(data), 'ko', 'MarkerSize', 15, 'MarkerFaceColor', [.6,.2,0]);
plot([1:num_conditions], mean(model1), 'kd', 'MarkerSize', 15, 'MarkerFaceColor', [.47,.67,.19]);
plot([1:num_conditions]+offset, mean(model2), 'kd', 'MarkerSize', 15, 'MarkerFaceColor', [1,.6,.78]);
title(plotTitle);
xlim([0.5, num_conditions + 0.5])
legend('data', 'hierarchical model', 'standard SDT model')
xlabel('Sensory variability level');
ylabel(plotTitle)

if exist('ylimit', 'var')
    ylim(ylimit);
end