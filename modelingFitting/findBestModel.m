%findBestModel

clear

% Select model
modelToTest = ‘full’; %choose between ’full' and 'null'

% Load fits
if strcmp(modelToTest, 'full')
    %load fittingResults/fittingResults_full_init
    load fittingResults/fittingResults_full
elseif strcmp(modelToTest, 'null')
    %load fittingResults/fittingResults_null_init
    load fittingResults/fittingResults_null
end

for subject = 1:length(modelFit)
    
    % Determine the best fit
    for fitNum=1:size(params,2)
        logL_sub(fitNum) = modelFit{fitNum,subject}.logL;
    end
    [logL_best(subject), logL_minIndex(subject)] = min(logL_sub);
    params_best(:,subject) = params(:,logL_minIndex(subject),subject);
    modelFit_best{subject} = modelFit{logL_minIndex(subject),subject};
    AIC_best(subject) = modelFit{logL_minIndex(subject),subject}.AIC;
    AICc_best(subject) = modelFit{logL_minIndex(subject),subject}.AICc;
    BIC_best(subject) = modelFit{logL_minIndex(subject),subject}.BIC;
end

% Save best model
if strcmp(modelToTest, 'full')
    save fittingResults/fittingResults_full_best params_best logL_best AIC_best AICc_best BIC_best modelFit_best
elseif strcmp(modelToTest, 'null')
    save fittingResults/fittingResults_null_best params_best logL_best AIC_best AICc_best BIC_best modelFit_best
end