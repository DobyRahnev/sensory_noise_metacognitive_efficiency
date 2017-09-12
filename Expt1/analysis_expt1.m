%analysis_expt1

clear
close all

compute_metacognition = 0;
save_metacognition_data = 0;
computeMetacognitionControl1 = 0;
computeMetacognitionControl2 = 0;

% Subjects
subjects = 1:12;

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Loop over all subjects
for subject=subjects
    
    %% Load the data
    clear stim resp correct conf intensity condition
    intensity_all = [];
    stim_all = [];
    resp_all = [];
    conf_all = [];
    cond_all = [];
    for session=1:7
        
        % Load the data
        if session == 1
            file_name = ['Data/Pre_Test/' num2str(subject) '_Result_Test.mat'];
        elseif session == 7
            file_name = ['Data/Post_Test/' num2str(subject) '_Result_Test.mat'];
        else
            file_name = ['Data/Train/' num2str(subject) '_Result_Train_' num2str(session) '.mat'];
        end
        eval(['load ' file_name '']);
        
        % Loop over all runs
        totalTrials = 0;
        for run=1:length(data)
            trials = totalTrials + [1:length(data(run).SNs)];
            totalTrials = totalTrials + length(data(run).SNs);
            stim{session}(trials) = data(run).stimOrder; %1: left, 2: right
            resp{session}(trials) = data(run).response; %1: left, 2: right
            correct{session}(trials) = data(run).correct; %0: error, 1: correct
            conf{session}(trials) = data(run).confidence; %1-4
            intensity{session}(trials) = data(run).SNs; %intensity used
            intensity_reversals(run,:) = data(run).reversal;
            if any(session == [1,7])
                condition{session}(trials) = data(1).condOrder(run) * ones(1,length(data(run).SNs));
            else %in sessions 2-6, only consider the first 4 runs
                if run < 5
                    condition{session}(trials) = ones(1,length(data(run).SNs));
                else
                    condition{session}(trials) = zeros(1,length(data(run).SNs));
                end
            end
        end
        
        % Put data from all sessions in a single vector
        intensity_all = [intensity_all, intensity{session}];
        stim_all = [stim_all, stim{session}];
        resp_all = [resp_all, resp{session}];
        conf_all = [conf_all, conf{session}];
        cond_all = [cond_all, condition{session}];
        
        % Compute intensity threshold
        if any(session == [1,7])
            intensity_threshold(subject,session) = mean(geomean(intensity_reversals(data(1).condOrder==1,end-5:end),2));
        else
            intensity_threshold(subject,session) = mean(geomean(intensity_reversals(1:4,end-5:end),2));
        end
    end
    
    
    %% Create intensity filter
    intensity_cond1 = [intensity{1}(condition{1}==1),intensity{2}(condition{2}==1),intensity{3}(condition{3}==1),...
        intensity{4}(condition{4}==1),intensity{5}(condition{5}==1),intensity{6}(condition{6}==1),intensity{7}(condition{7}==1)];
        
    filterName = '35-65-prctl';
    intensity_cutoffs = prctile(intensity_cond1, [35, 65]);
    
%     for cond=2:3
%         intensity_cond{cond} = [intensity{1}(condition{1}==cond),intensity{7}(condition{7}==cond)];
%         cutoffs_untrained{cond} = prctile(intensity_cond{cond}, [35, 65]);
%     end
    
    %% Apply the filter and compute metrics
    for session=1:7
        
        % Only consider trials conforming to the filter
        stim_sess = stim{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
        resp_sess = resp{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
        corr_sess = correct{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
        conf_sess = conf{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
        cond_sess = condition{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
        intensity_sess = intensity{session}(intensity{session} > intensity_cutoffs(1) & intensity{session} < intensity_cutoffs(2));
%         
%         for cond=2:3
%             stim_untr{cond} = stim{session}(intensity{session} > cutoffs_untrained{cond}(1) & intensity{session} < cutoffs_untrained{cond}(2));
%             resp_untr{cond} = resp{session}(intensity{session} > cutoffs_untrained{cond}(1) & intensity{session} < cutoffs_untrained{cond}(2));
%             conf_untr{cond} = conf{session}(intensity{session} > cutoffs_untrained{cond}(1) & intensity{session} < cutoffs_untrained{cond}(2));
%             cond_untr{cond} = condition{session}(intensity{session} > cutoffs_untrained{cond}(1) & intensity{session} < cutoffs_untrained{cond}(2));
%         end
        
        % Compute performance across all intensitys
        dprime(subject,session) = data_analysis_resp(stim_sess(cond_sess==1), resp_sess(cond_sess==1));
        meanConf(subject,session) = mean(conf_sess(cond_sess==1));
        trialCounts(subject,session) = sum(cond_sess==1);
        
        % Compute metacognition scores
        if compute_metacognition
            output = type2_SDT_MLE(stim_sess(cond_sess==1)-1, resp_sess(cond_sess==1)-1, conf_sess(cond_sess==1), 4, [], 1);
            Mratio(subject,session) = output.M_ratio;
            Mdiff(subject,session) = output.M_diff;
            meta_dprime(subject,session) = output.meta_da;
            
%             % Compute Mratio for untrained conditions
%             if any(session == [1,7])
%                 for cond=2:3
%                     output = type2_SDT_MLE(stim_untr{cond}(cond_untr{cond}==cond)-1, resp_untr{cond}(cond_untr{cond}==cond)-1, ...
%                         conf_untr{cond}(cond_untr{cond}==cond), 4, [], 1);
%                     dprime_untrained(subject,session,cond-1) = output.da;
%                     Mratio_untrained(subject,session,cond-1) = output.M_ratio;
%                     Mdiff_untrained(subject,session,cond-1) = output.M_diff;
%                 end
%             end
        end
        
        % Compute intensity standard deviation
        std_intensity(subject,session) = std(intensity_sess(cond_sess==1));
    end
    
    %% Perform control analyses
    stim_all = stim_all(cond_all==1);
    resp_all = resp_all(cond_all==1);
    conf_all = conf_all(cond_all==1);
    intensity_all = intensity_all(cond_all==1);   
    
    % High vs. low intensity
    if computeMetacognitionControl1
        [dprime_control1(subject,1), Mratio_control1(subject,1)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [5,50]);
        [dprime_control1(subject,2), Mratio_control1(subject,2)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [50,95]);
    end
    
    % Increasingly larger intensity spread leads to increasing Mratio
    if computeMetacognitionControl2
        [dprime_control2(subject,1), Mratio_control2(subject,1)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [35,65]);
        [dprime_control2(subject,2), Mratio_control2(subject,2)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [25,75]);
        [dprime_control2(subject,3), Mratio_control2(subject,3)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [15,85]);
        [dprime_control2(subject,4), Mratio_control2(subject,4)] = ...
            computeM_prctl(stim_all-1, resp_all-1, conf_all, intensity_all, [5,95]);
    end
end

%% Display basic performance measures
intensity_threshold_mean = mean(intensity_threshold)
dprime_mean = mean(dprime)
confidence_mean = mean(meanConf)


%% Do stats on the performance improvement
% If Mratio was not computed, load the pre-computed data
if ~compute_metacognition; load(['Data/Mratio/Mratio_' filterName]); end

% Fit linear regression across the 7 sessions
dataPoints = 1:7;
for subject=1:12
    b_intensity_thr(subject,:) = regress(intensity_threshold(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    b_dprime(subject,:) = regress(dprime(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    b_conf(subject,:) = regress(meanConf(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    b_Mratio(subject,:) = regress(Mratio(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    b_Mdiff(subject,:) = regress(Mdiff(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    %b_std_intensity(subject,:) = regress(std_intensity(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
end
[~, P_intensity_slope, ~, stats] = ttest(b_intensity_thr(:,2))
[~, P_dprime_slope, ~, stats] = ttest(b_dprime(:,2))
[~, P_conf_slope, ~, stats] = ttest(b_conf(:,2))
[~, P_Mratio_slope, ~, stats] = ttest(b_Mratio(:,2))
[~, P_Mdiff_slope, ~, stats] = ttest(b_Mdiff(:,2))
%[~, P_std_intensity_slope, ~, stats] = ttest(b_std_intensity(:,2))
% mean(std_intensity)
% mean(Mratio)

% Correlated the
[r_intensity, p] = corr(b_Mratio(:,2), b_intensity_thr(:,2))
[r_dprime, p] = corr(b_Mratio(:,2), b_dprime(:,2))


%% Plot basic performance (Figure 3)
plot_lines(intensity_threshold, 'intensity threshold')
plot_lines(dprime, 'd''')
plot_lines(meanConf, 'Average confidence')
plot_lines(Mratio, 'M_{ratio}')
plot_scatterplot(b_Mratio(:,2), b_intensity_thr(:,2), [-.3, .101], 'M_{ratio} slope', 'intensity threshold slope')
plot_scatterplot(b_Mratio(:,2), b_dprime(:,2), [-.3, .101], 'M_{ratio} slope', 'd'' slope')


%% Control analyses
% High vs. low intensity
if ~computeMetacognitionControl1
    load Data/Mratio/control1
end
mean(dprime_control1)
mean(Mratio_control1)
[~, P_dprime_control1, ~, stats] = ttest(dprime_control1(:,2), dprime_control1(:,1))
[~, P_Mratio_control1, ~, stats] = ttest(Mratio_control1(:,2), Mratio_control1(:,1))
plot_4bars([dprime_control1, Mratio_control1]);

% Increasingly larger intensity spread leads to increasing Mratio
if ~computeMetacognitionControl2
    load Data/Mratio/control2
end
mean(dprime_control2)
mean(Mratio_control2)
dataPoints = 1:4;
for subject=1:12
    b_Mratio_control2(subject,:) = regress(Mratio_control2(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
    b_dprime_control2(subject,:) = regress(dprime_control2(subject,dataPoints)', [ones(length(dataPoints),1), [1:length(dataPoints)]']);
end
mean(b_Mratio_control2(:,2))
[~, P_M_control2_slope, ~, stats] = ttest(b_Mratio_control2(:,2))
mean(b_dprime_control2(:,2))
[~, P_d_control2_slope, ~, stats] = ttest(b_dprime_control2(:,2))
plot_lines(Mratio_control2, 'M_{ratio}');
plot_lines(dprime_control2, 'd''');


%% Save meta data and call analysis file
if save_metacognition_data
    save(['Data/Mratio/Mratio_' filterName], 'Mratio*', 'Mdiff*', 'dprime*', 'meanConf*');
    save('Data/Mratio/control1', 'dprime_control1', 'Mratio_control1');
    save('Data/Mratio/control2', 'dprime_control2', 'Mratio_control2');
end