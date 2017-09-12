function [dprime, Mratio, conf] = model_SDT(mu, sigma, criteria, N)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Standard SDT, decision made on the posterior
% The criteria need to be difined on the posterior: [0, 1]
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Perform initial checks
if mu < 0
    error('Parameter mu cannot be smaller than 0.')
elseif sigma < 0
    error('Parameter sigma_sens cannot be smaller than 0.')
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
stimValue = normrnd((2*stimulus-1) * mu/2, sigma, N, 1);

% Compute the response
decisionCrit = -log(1/criteria(numConf)-1) * (sigma^2) / mu;
response = stimValue > decisionCrit;

% Compute the confidence
posterior = 1 ./ (1 + exp(-stimValue * mu / (sigma^2))); %goes from 0 to 1
crit_bin = ones(N, 1);
for critNum=1:length(criteria)
    crit_bin = crit_bin + (posterior > criteria(critNum));
end
confidence = crit_bin - numConf; %from -(n-1) to n
confidence(confidence <= 0) = abs(confidence(confidence <= 0)) + 1; %from n to 1 and then from 1 to n

% Compute Mratio
output = type2_SDT_MLE(stimulus, response, confidence, (length(criteria)+1)/2, [], 1);

% Prepare output
dprime  = output.da;
Mratio = output.M_ratio;
conf = mean(confidence);