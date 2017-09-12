%runFitting

clear

% Select model to fit
modelToFit = ‘full’; %choose between ’full' and 'null'
numFittings = 5;

% Add helper functions
currentDir = pwd;
parts = strsplit(currentDir, '/');
addpath(genpath(fullfile(currentDir(1:end-length(parts{end})), 'helperFunctions')));

% Load the data
global data_sub
load dataForModeling
if strcmp(modelToFit, 'full')
    load fittingResults/fittingResults_full_init
elseif strcmp(modelToFit, 'null')
    load fittingResults/fittingResults_null_init
end
timeInit = clock;

% Add decision noise for some subjects
decision_noise = [0,0,0,.8,0,0,.4,0,.2,0,0,0];

for subNum = 1:length(dataForModeling)
    disp('----------')
    disp(['Fitting subject ' num2str(subNum) ', Model: ' modelToFit])
    disp(['Time taken so far: ' num2str(clock - timeInit)]);
    disp('----------')
    
    % Make the data visible to all functions
    data_sub = dataForModeling{subNum};
    data_sub.dprime = dprime_cont(subNum,:);
    data_sub.sigma_decision = decision_noise(subNum);
    
    % Determine starting parameters
    [~, logL_minIndex] = min(logL(:,subNum));
    startingParamSet = params(:,logL_minIndex,subNum)';
    
    % Full model
    if strcmp(modelToFit, 'full')
        for iter=1:numFittings
            [params(:,iter,subNum), logL(iter,subNum), modelFit{iter,subNum}] = fitOneSub_full(startingParamSet);
        end
        save fittingResults/fittingResults_full.mat params logL modelFit
    end
    
    % Null model
    if strcmp(modelToFit, 'null')
        for iter=1:numFittings
            [params(:,iter,subNum), logL(iter,subNum), modelFit{iter,subNum}] = fitOneSub_null(startingParamSet);
        end
        save fittingResults/fittingResults_null.mat params logL modelFit
    end
    
    timeSubDone{subNum} = clock;
end