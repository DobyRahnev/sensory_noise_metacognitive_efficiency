function logL = logL_func(parameters)

% Get data from the workspace
global data_sub

sigma_meta          = parameters(1);
sigma_sens_power    = parameters(2); %sigma_sense will be [.75, 1, 1.25].^sigma_sens_power
sigma_sens = [.75, 1, 1.25].^sigma_sens_power;
crit_init           = parameters(3:end); %parameters passed to BADS
criteria            = cumsum(crit_init); %actual criteria

% Determine the mu for each condition
mu = data_sub.dprime .* sqrt(sigma_sens.^2 + data_sub.sigma_decision^2);

% Compute response probabilities and log likelihood
logL = 0;
for contrast=1:3
    % Simulate the model
    [stim_fit, resp_fit, conf_fit] = simulate_model(mu(contrast), sigma_sens(contrast), data_sub.sigma_decision, sigma_meta, criteria, 100000);
    
    % Update the log likelihood
    for stimNum=0:1
        for respNum=0:1
            for confNum=1:(length(criteria)+1)/2

                % Compute the logL for the condition
                logL_cond = log(sum(stim_fit==stimNum & resp_fit==respNum & conf_fit==confNum) / length(stim_fit)) * ...
                    sum(data_sub.stim==stimNum & data_sub.resp==respNum & data_sub.conf==confNum & data_sub.contrasts==contrast);
                
                % Replaced NaN values with 0
                if isnan(logL_cond)
                    logL_cond = 0;
                end
                
                % Update total logL value
                logL = logL - logL_cond;
            end
        end
    end
end

% Deal with possible NaN values of the log likelihood
if logL == inf, logL=100000000; end

end