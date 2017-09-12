%testFit

clear

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Select model
modelToTest = ‘full'; %choose between ’full' and 'null'

% Load the data
load dataForModeling

% Load fits
if strcmp(modelToTest, 'full')
    %load fittingResults/fittingResults_full_init
    load fittingResults/fittingResults_full
elseif strcmp(modelToTest, 'null')
    %load fittingResults/fittingResults_null_init
    load fittingResults/fittingResults_null
end

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Add decision noise for some subjects
sigma_decision = [0,0,0,.8,0,0,.4,0,.2,0,0,0];

% General parameters
pairs = {[2,3], [1,3], [1,2]};

for subject = 1:length(modelFit)
    
    % Determine the best fit
    for fitNum=1:size(params,2)
        logL_sub(fitNum) = modelFit{fitNum,subject}.logL;
    end
    [logL_min(subject), logL_minIndex(subject)] = min(logL_sub);
        
    % Define parameters
    sigma_meta          = params(1,logL_minIndex(subject),subject);
    sigma_sens_power    = params(2,logL_minIndex(subject),subject); %sigma_sense will be [.75, 1, 1.25].^sigma_sens_power
    sigma_sens = [.75, 1, 1.25].^sigma_sens_power;
    crit_init           = params(3:end,logL_minIndex(subject),subject); %parameters passed to BADS
    criteria            = cumsum(crit_init); %actual criteria
    sigma_dec = sigma_decision(subject);

    % Determine the mu for each condition
    mu = dprime_cont(subject,:) .* sqrt(sigma_sens.^2 + sigma_dec^2);
    
    % Compute response probabilities and log likelihood
    logL = 0;
    for cont=1:3
        % Simulate the model
        [stim_fit{cont}, resp_fit{cont}, conf_fit{cont}] = simulate_model(mu(cont), ...
            sigma_sens(cont), sigma_dec, sigma_meta, criteria, 1000000);
        
        % Compute Mratio
        output = type2_SDT_MLE(stim_fit{cont}, resp_fit{cont}, conf_fit{cont}, 2, [], 1);
        Mratio_cont_model(subject,cont) = output.M_ratio;
        dprime_cont_model(subject,cont) = output.da;
    end
    
    %% Compute Mratio for each pair of contrasts
    for pair=1:3
        output = type2_SDT_MLE([stim_fit{pairs{pair}(1)}, stim_fit{pairs{pair}(2)}], [resp_fit{pairs{pair}(1)}, resp_fit{pairs{pair}(2)}], ...
            [conf_fit{pairs{pair}(1)}, conf_fit{pairs{pair}(2)}], 2, [], 1);
        Mratio_pair_model(subject,pair) = output.M_ratio;
        dprime_pair_model(subject,pair) = output.da;
    end
    
    %% Compute Mratio for all contrasts combined
    output = type2_SDT_MLE([stim_fit{1},stim_fit{2},stim_fit{3}], [resp_fit{1},resp_fit{2},resp_fit{3}], [conf_fit{1},conf_fit{2},conf_fit{3}], 2, [], 1);
    Mratio_all_model(subject) = output.M_ratio;
    dprime_all_model(subject) = output.da;
end

Mratio_model(:,1) = mean(Mratio_cont_model,2); %mean Mratio for each single contrast
Mratio_model(:,2) = mean(Mratio_pair_model(:,[1,3]),2); %mean Mratio for combined close contrasts
Mratio_model(:,3) = Mratio_all_model'; %mean Mratio for all contrast
Mratio_model(:,4) = Mratio_pair_model(:,2); %mean Mratio for far contrasts

dprime_model(:,1) = mean(dprime_cont_model,2); %mean Mratio for each single contrast
dprime_model(:,2) = mean(dprime_pair_model(:,[1,3]),2); %mean Mratio for combined close contrasts
dprime_model(:,3) = dprime_all_model'; %mean Mratio for all contrast
dprime_model(:,4) = dprime_pair_model(:,2); %mean Mratio for far contrasts

%% Display results
mean(dprime)
mean(dprime_model)
mean(Mratio)
mean(Mratio_model)

Mratio
Mratio_model
dprime
dprime_model

for subject=1:12
    b_Mratio(subject,:) = regress(Mratio(subject,:)', [ones(4,1), [1:4]']);
    b_Mratio_model(subject,:) = regress(Mratio_model(subject,:)', [ones(4,1), [1:4]']);
end

Mratio_diff_between_model_and_data = mean(mean(Mratio_model,2) - Mratio(:,2))
[~, P_compare_Mratio, ~, stats] = ttest(mean(Mratio_model,2), Mratio(:,2))
MratioSlopes = [mean(b_Mratio(:,2)), mean(b_Mratio_model(:,2))]
[~, P_compare_slopes, ~, stats] = ttest(b_Mratio(:,2), b_Mratio_model(:,2))

%% Plot results
figure;
plot_lines_compare(dprime, dprime_model, [1,2], 1, 'd''', [1.5,2.5])
plot_lines_compare(Mratio, Mratio_model, [1,2], 2, 'M_{ratio}', [.7,1.2])

%% Save data
save(['Mratio_result_' modelToTest], 'Mratio_model', 'dprime_model')