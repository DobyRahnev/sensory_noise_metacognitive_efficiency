%analysis_expt3

%close all
clear
compute_metacognition = 0;

% Subjects
subjects = 1:12;
runsPerSession = 10;
trialsPerRun = 140;

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Loop over all subjects
subject = 0;
for subject_number=subjects
    subject = subject + 1;
    
    % Loop over the 3 sessions
    for session=1:3
        
        % Load the data
        if session == 1
            file_name = ['data/results_V1_s' num2str(subject_number) ''];
        elseif session == 2
            file_name = ['data/results_Pz_s' num2str(subject_number) ''];
        else
            file_name = ['data/results_Sham_s' num2str(subject_number) ''];
        end
        eval(['load ' file_name '']);
        
        % Create variables with the different types of data
        for run=1:runsPerSession
            trials = (session-1)*runsPerSession*trialsPerRun + (run-1)*trialsPerRun + [1:trialsPerRun];
            stim_orig(trials) = data{run}.right_tilt; %0: left, 1: right
            resp_orig(trials) = data{run}.answer > 2; %0: left, 1: right
            conf_orig(trials) = (abs(data{run}.answer - 2.5) > 1) + 1; %1: low, 2: high
            contrasts_orig(trials) = data{run}.which_contrast;
            noResponse(trials) = data{run}.answer == -10;
        end
    end
    
    % Remove trials with no response
    stim = stim_orig(noResponse==0);
    resp = resp_orig(noResponse==0);
    conf = conf_orig(noResponse==0);
    contrasts = contrasts_orig(noResponse==0);
    
    if compute_metacognition
        % LEVEL 1: Compute performance for each contrast
        for contr_num=1:3
            accuracy_cont(subject,contr_num) = mean(stim(contrasts==contr_num) == resp(contrasts==contr_num));
            meanConf_cont(subject,contr_num) = mean(conf(contrasts==contr_num));
            output = type2_SDT_MLE(stim(contrasts==contr_num), resp(contrasts==contr_num), ...
                conf(contrasts==contr_num), 2, [], 1);
            dprime_cont(subject,contr_num) = output.da;
            Mratio_cont(subject,contr_num) = output.M_ratio;
            Mdiff_cont(subject,contr_num) = output.M_diff;
        end
        
        % LEVELS 2 & 4: Compute performance for pairs of contrasts
        for contr_missing=1:3
            accuracy_pair(subject,contr_missing) = mean(stim(contrasts~=contr_missing) == resp(contrasts~=contr_missing));
            meanConf_pair(subject,contr_missing) = mean(conf(contrasts~=contr_missing));
            output = type2_SDT_MLE(stim(contrasts~=contr_missing), resp(contrasts~=contr_missing), ...
                conf(contrasts~=contr_missing), 2, [], 1);
            dprime_pair(subject,contr_missing) = output.da;
            Mratio_pair(subject,contr_missing) = output.M_ratio;
            Mdiff_pair(subject,contr_missing) = output.M_diff;
        end
        
        % LEVEL 4: Compute  performance across all contrasts together
        accuracy_all(subject) = mean(stim == resp);
        meanConf_all(subject) = mean(conf);
        output = type2_SDT_MLE(stim, resp, conf, 2, [], 1);
        dprime_all(subject) = output.da;
        Mratio_all(subject) = output.M_ratio;
        Mdiff_all(subject) = output.M_diff;
    end
    
    % Save data for later modeling
    dataForModeling{subject}.stim = stim;
    dataForModeling{subject}.resp = resp;
    dataForModeling{subject}.conf = conf;
    dataForModeling{subject}.contrasts = contrasts;
end

if ~compute_metacognition; 
    load('data/Mratio'); 
else
    save data/Mratio Mratio* Mdiff* dprime* accuracy* meanConf*
end

%% Transform all measures into the 4 levels of contrast variability
accuracy = transformQuantities(accuracy_cont, accuracy_pair, accuracy_all);
meanConf = transformQuantities(meanConf_cont, meanConf_pair, meanConf_all);
dprime = transformQuantities(dprime_cont, dprime_pair, dprime_all);
Mratio = transformQuantities(Mratio_cont, Mratio_pair, Mratio_all);
Mdiff = transformQuantities(Mdiff_cont, Mdiff_pair, Mdiff_all);


%% Fit regressions
for subject=1:12
    b_accuracy(subject,:) = regress(accuracy(subject,:)', [ones(4,1), [1:4]']);
    b_meanConf(subject,:) = regress(meanConf(subject,:)', [ones(4,1), [1:4]']);
    b_dprime(subject,:) = regress(dprime(subject,:)', [ones(4,1), [1:4]']);
    b_Mratio(subject,:) = regress(Mratio(subject,:)', [ones(4,1), [1:4]']);
    b_Mdiff(subject,:) = regress(Mdiff(subject,:)', [ones(4,1), [1:4]']);

    b_dprime_cont(subject,:) = regress(dprime_cont(subject,:)', [ones(3,1), [1:3]']);
    b_Mratio_cont(subject,:) = regress(Mratio_cont(subject,:)', [ones(3,1), [1:3]']);
end


%% Do stats
accuracySlope = mean(b_accuracy)
[~, P_accuracy_slope, ~, stats] = ttest(b_accuracy(:,2))

meanConfSlope = mean(b_meanConf)
[~, P_conf_slope, ~, stats] = ttest(b_meanConf(:,2))

dprimeSlope = mean(b_dprime)
[~, P_dprime_slope, ~, stats] = ttest(b_dprime(:,2))

MratioSlope = mean(b_Mratio)
[~, P_Mratio_slope, ~, stats] = ttest(b_Mratio(:,2))

MdiffSlope = mean(b_Mdiff)
[~, P_Mdiff_slope, ~, stats] = ttest(b_Mdiff(:,2))


%% Control analysis: the influence of contrast increase
mean_dprime_for_each_contrast = mean(dprime_cont)
control_dprimeSlope = mean(b_dprime_cont)
[~, P_control_dprime_slope, ~, stats] = ttest(b_dprime_cont(:,2))
mean_Mratio_for_each_contrast = mean(Mratio_cont)
control_Mratio_contSlope = mean(b_Mratio_cont)
[~, P_control_Mratio_slope, ~, stats] = ttest(b_Mratio_cont(:,2))

mean(dprime_cont(:,3)-dprime_cont(:,1))
mean(dprime(:,1)-dprime(:,4))
[~, P_compare_dprime_diffs, ~, stats] = ttest(dprime_cont(:,3)-dprime_cont(:,1), dprime(:,1)-dprime(:,4))


%% Plot graphs
plot_lines(accuracy, '% correct')
plot_lines(meanConf, 'confidence')
plot_lines(dprime, 'd''')
plot_lines(Mratio, 'M_{ratio}')


%% Save data for modeling
%save dataForModeling dataForModeling accuracy* meanConf* dprime* Mratio* Mdiff*