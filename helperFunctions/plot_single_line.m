function plot_single_line(data, numPanel, yLableText)

num_obs = size(data,2);
subplot(4,1,numPanel)
plot(1:num_obs, data, 'ro-', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlim([0.5, num_obs+0.5])
xlabel('Simulation number')
ylabel(yLableText)