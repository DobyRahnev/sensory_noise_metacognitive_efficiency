%% Analyse all data

close all
clear

computeMetacognition = 0;

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Load the data
load data
n_subjects = length(data);

% Compile all data while removing catch trials
goodTrials = [1:39,41:79,81:99]; %catch trials: 40, 80, 100
for sub=1:n_subjects
    stim(sub,:,1) = data{sub}.stimID_high_contrast(goodTrials);
    stim(sub,:,2) = data{sub}.stimID_low_contrast(goodTrials);
    resp(sub,:,1) = data{sub}.response_high_contrast(goodTrials);
    resp(sub,:,2) = data{sub}.response_low_contrast(goodTrials);
    correct(sub,:,1) = data{sub}.correct_high_contrast(goodTrials);
    correct(sub,:,2) = data{sub}.correct_low_contrast(goodTrials);
    conf(sub,:,1) = data{sub}.confidence_high_contrast(goodTrials);
    conf(sub,:,2) = data{sub}.confidence_low_contrast(goodTrials);
    condition(sub) = data{sub}.condition; %0: HC task first, 1: LC task first
end


%% Analyses
% Compute d' and Mratio
for trial=1:size(stim,2)
    for task=1:2
        dprime(trial,task) = data_analysis_resp(stim(:,trial,task), resp(:,trial,task));
        if computeMetacognition
            output = type2_SDT_MLE(stim(:,trial,task), resp(:,trial,task), conf(:,trial,task), 4, [], 1);
            da(trial,task) = output.da;
            Mratio(trial,task) = output.M_ratio;
            Mdiff(trial,task) = output.M_diff;
        else
            load Mratio_results
        end
    end
end

% Perform linear regression on the timecourses
for task=1:2
    lm_dprime{task} = fitlm([1:size(stim,2)]', dprime(:,task), 'linear');
    lm_Mratio{task} = fitlm([1:size(stim,2)]', Mratio(:,task), 'linear');
    lm_Mdiff{task} = fitlm([1:size(stim,2)]', Mdiff(:,task), 'linear');
end
disp('----------- slope for d'' for coarse discrimination task -----------')
lm_dprime{2}
disp('----------- slope for d'' for fine discrimination task -----------')
lm_dprime{1}
disp('----------- slope for M_ratio for coarse discrimination task -----------')
lm_Mratio{2}
disp('----------- slope for M_ratio for fine discrimination task -----------')
lm_Mratio{1}

% Compare the beta coefficients directly (see https://stats.idre.ucla.edu/stata/faq/how-can-i-compare-regression-coefficients-between-2-groups/)
x = repmat([1:size(stim,2)]',2,1);
x_intercept_interaction = [zeros(size(stim,2),1); ones(size(stim,2),1)];
x_slope_interaction = [zeros(size(stim,2),1); [1:size(stim,2)]'];
y_dprime = reshape(dprime,[],1);
ln_d_compare = fitlm([x,x_intercept_interaction,x_slope_interaction], y_dprime, 'linear')
y_Mratio = reshape(Mratio,[],1);
ln_Mratio_compare = fitlm([x,x_intercept_interaction,x_slope_interaction], y_Mratio, 'linear')
y_Mdiff = reshape(Mdiff,[],1);
ln_Mdiff_compare = fitlm([x,x_intercept_interaction,x_slope_interaction], y_Mdiff, 'linear')

%% Plots
% Smooth the timecourses
window = 5; %actual window is 2*window+1
for trial=1:size(stim,2)
    beginTrial = trial - window;
    endTrial = trial + window;
    if beginTrial < 1; beginTrial = 1; end % Fix beginTrial to be minimum of 1
    if endTrial > size(stim,2); endTrial = size(stim,2); end % Fix endTrial to be maximum of size(stim,2)
    
    % Apply smoothing
    dprimeSmooth(trial,:) = mean(dprime(beginTrial:endTrial,:));
    MratioSmooth(trial,:) = mean(Mratio(beginTrial:endTrial,:));
end

% Plot the figure
figure
subplot(1,2,1)
plot(1:size(stim,2), [dprimeSmooth(:,2), MratioSmooth(:,2)], 'LineWidth', 6)
title('coarse discrimination task')
xlabel('Trial number')
ylim([.4, 1.81])
subplot(1,2,2)
plot(1:size(stim,2), [dprimeSmooth(:,1), MratioSmooth(:,1)], 'LineWidth', 6)
title('fine discrimination task')
xlabel('Trial number')
ylim([.4, 1.81])
legend('d''_{trial}', 'M_{ratio}')