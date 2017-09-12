function [params, logL, modelFit] = fitOneSub_full(startingParamSet)

global data_sub

%% Make initial guess at parameter values
if ~exist('startingParamSet','var')
    sigma_meta          = .5;
    sigma_sens_power    = .6; %sigma_sense will be [.75, 1, 1.25].^sigma_sens_power
    criteria            = [-1, 0, 1]; %actual criteria locations
    crit_params         = [criteria(1), diff(criteria)]; %parameters to pass to BADS
    startingParamSet    = [sigma_meta, sigma_sens_power, crit_params];
end


%% Perform maximum likelihood estimation and store parameters
op           = anneal();
op.Verbosity = 2;
op.Generator = @newsol;
% op.InitTemp  = 10;
% op.CoolSched = @(T)(.9*T);
% op.MaxConsRej = 3000;

[params, fval] = anneal(@logL_func, startingParamSet, op);


logL = -fval;
k    = length(startingParamSet);
n    = length(data_sub.stim);

modelFit.logL = logL;
modelFit.k    = k;
modelFit.n    = n;
modelFit.AIC  = -2*logL + 2*k;
modelFit.AICc = -2*logL + (2*k*n)/(n-k-1);
modelFit.BIC  = -2*logL + k*log(n);

end