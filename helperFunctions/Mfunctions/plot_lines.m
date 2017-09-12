function plot_lines(data, yLableText)

num_subjects = size(data,1);
num_sess = size(data,2);

figure
plot(1:num_sess, mean(data), 'ro-', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
hold on
for sess=1:num_sess
    plot([sess,sess], [mean(data(:,sess))-std(data(:,sess))/sqrt(num_subjects), ...
        mean(data(:,sess))+std(data(:,sess))/sqrt(num_subjects)], 'r', 'LineWidth',2);
end
xlim([0.5, num_sess+.5])
xlabel('Session number')
ylabel(yLableText)