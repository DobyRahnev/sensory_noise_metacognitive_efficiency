%compare_fits

clear
close all

load fittingResults/fittingResults_null_best
m{1} = modelFit_best;
params(:,:,1) = params_best;

load fittingResults/fittingResults_full_best
m{2} = modelFit_best;
params(:,:,2) = params_best;

for subNum=1:length(m{1})
    for modelNum=1:length(m)
        logL(subNum,modelNum) = m{modelNum}{subNum}.logL;
        AIC(subNum,modelNum) = m{modelNum}{subNum}.AIC;
        AICc(subNum,modelNum) = m{modelNum}{subNum}.AICc;
        BIC(subNum,modelNum) = m{modelNum}{subNum}.BIC;
    end
end

mean_logL = mean(logL)
mean_AIC = mean(AIC)
AIC_difference = mean(AIC(:,1)-AIC(:,2))
mean_AICc = mean(AICc)
AICc_difference = mean(AICc(:,1)-AICc(:,2))
mean_BIC = mean(BIC)
BIC_difference = mean(BIC(:,1)-BIC(:,2))
bayesFactor = AICanalysis(mean(AIC),'e')

% Perform correlations
for param_num=2:5
    [r(param_num), p(param_num)] = corr(params(param_num,:,1)', params(param_num,:,2)');
%     figure
%     plot(params(param_num,:,1)', params(param_num,:,2)', 'o');
end

r
p