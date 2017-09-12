function [dprime, Mratio, conf] = model_hierarchical(mu, sigma_sens, sigma_decision, sigma_meta, criteria, N)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate a hierarchical model of confidence. Confidence is given on the
% posterior (appropriate for when conditions are separated).
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Perform initial checks
if mu < 0
    error('Parameter mu cannot be smaller than 0.')
elseif sigma_sens < 0
    error('Parameter sigma_sens cannot be smaller than 0.')
elseif sigma_decision < 0
    error('Parameter sigma_decision cannot be smaller than 0.')
elseif sigma_meta < 0
    error('Parameter sigma_meta cannot be smaller than 0.')
elseif mod(length(criteria),2) ~= 1
    error('There should be an odd number of criteria: n-1 criteria for each of n levels of confidence + 1 decision criterion.');
elseif any(diff(criteria) < 0)
    error('The criteria should be non-decreasing values.');
end

% Number of repetitions for the simulation
if ~exist('N','var')
    N = 100000;
elseif mod(N,2) == 1
    N = N + 1; %if N is odd, make it even
end

% Number of confidence ratings
numConf = (length(criteria)+1)/2;


%% Simulate the model
% Make a variable with the stimulus identity (0 or 1)
stimulus = [zeros(N/2,1); ones(N/2,1)];

% Generate actual stimulus value for each trial
stimValue = normrnd((2*stimulus-1) * mu/2, sigma_sens, N, 1);

% Generate actual stimulus value for decision on each trial (by adding decision noise)
stimValueDecision = normrnd(stimValue, sigma_decision, N, 1);

% Compute the response
decisionCrit = -log(1/criteria(numConf)-1)*(sigma_sens^2 + sigma_meta^2) / mu;
response = stimValueDecision > decisionCrit;

% Generate actual stimulus value for confidence on each trial (by adding meta noise)
stimValueMeta = normrnd(stimValue, sigma_meta, N, 1);

% Compute the confidence
posterior = 1 ./ (1 + exp(-stimValueMeta * mu / (sigma_sens^2 + sigma_meta^2))); %goes from 0 to 1
crit_bin = ones(N, 1);
for critNum=1:length(criteria)
    crit_bin = crit_bin + (posterior > criteria(critNum));
end
confidence = crit_bin - numConf; %from -(n-1) to n
confidence(confidence <= 0) = abs(confidence(confidence <= 0)) + 1; %from n to 1 and then from 1 to n

% For all trials in which stimMetaValue moved on the other side of the
% decision criterion, give confidence of 1
confidence((stimValueDecision > decisionCrit) ~= (stimValueMeta > decisionCrit)) = 1;

% Compute Mratio
output = type2_SDT_MLE(stimulus, response, confidence, (length(criteria)+1)/2, [], 1);

% Prepare output
dprime  = output.da;
Mratio = output.M_ratio;
conf = mean(confidence);