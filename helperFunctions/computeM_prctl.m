function [dprime, Mratio] = computeM_prctl(stim, resp, conf, SNR, cutoffs_prctl)

cutoffs = prctile(SNR, cutoffs_prctl);
output = type2_SDT_MLE(stim(SNR>cutoffs(1) & SNR<cutoffs(2)), ...
    resp(SNR>cutoffs(1) & SNR<cutoffs(2)), ...
    conf(SNR>cutoffs(1) & SNR<cutoffs(2)), 4, [], 1);
dprime = output.da;
Mratio = output.M_ratio;