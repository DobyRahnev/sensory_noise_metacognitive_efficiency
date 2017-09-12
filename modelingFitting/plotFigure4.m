%plotFigure4

clear
%close all

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Load the data
load dataForModeling
load Mratio_result_full
Mratio_full = Mratio_model;
dprime_full = dprime_model;
load Mratio_result_null
Mratio_null = Mratio_model;
dprime_null = dprime_model;


%% Display results and do stats
mean(dprime)
mean(dprime_full)
mean(dprime_null)
mean(Mratio)
mean(Mratio_full)
mean(Mratio_null)

for subject=1:12
    b_Mratios(1,subject,:) = regress(Mratio(subject,:)', [ones(4,1), [1:4]']);
    b_Mratios(2,subject,:) = regress(Mratio_full(subject,:)', [ones(4,1), [1:4]']);
    b_Mratios(3,subject,:) = regress(Mratio_null(subject,:)', [ones(4,1), [1:4]']);
end

MratioSlopes = squeeze(mean(b_Mratios(:,:,2),2));
[~, P_dataVSfull, ~, stats] = ttest(b_Mratios(1,:,2), b_Mratios(2,:,2))
[~, P_dataVSnull, ~, stats] = ttest(b_Mratios(1,:,2), b_Mratios(3,:,2))

%% Plot results
figure;
plot_lines_2models(dprime, dprime_full, dprime_null, [1,2], 1, 'd''', [1.6,2.401])
plot_lines_2models(Mratio, Mratio_full, Mratio_null, [1,2], 2, 'M_{ratio}', [.7,1.4])