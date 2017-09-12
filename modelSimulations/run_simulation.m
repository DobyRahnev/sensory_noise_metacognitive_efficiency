%run_simulation

clear
close all

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

sigma = [1, .83, .7, .6, .55, .52, .5];

%% Simulate hierarchical model
for sess=1:length(sigma)
    [dprime(sess), Mratio(sess), conf(sess)] = model_hierarchical(1, sigma(sess), 0, .3, [.3, .5, .7], 1000000);
end
figure
plot_single_line(sigma, 1, 'simga_{sens}')
plot_single_line(dprime, 2, 'd''')
plot_single_line(conf, 3, 'Average confidence')
plot_single_line(Mratio, 4, 'M_{ratio}')


%% Simulate standard SDT
for sess=1:length(sigma)
    [dprime(sess), Mratio(sess), conf(sess)] = model_SDT(1, sigma(sess), [.3, .5, .7], 1000000);
end
figure
plot_single_line(sigma, 1, 'simga_{sens}')
plot_single_line(dprime, 2, 'd''')
plot_single_line(conf, 3, 'Average confidence')
plot_single_line(Mratio, 4, 'M_{ratio}')