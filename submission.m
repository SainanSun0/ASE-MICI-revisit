%UserVar.smbfile='./FasRACMO.mat';

%% tier 1 experiments
% UserVar.experiment='CCSM4_RCP85';
% UserVar.experiment='HadGEM_RCP85';
% UserVar.experiment='CESM2_ssp585';
% UserVar.experiment='UKESM1_ssp585_norepeat';
% UserVar.experiment='UKESM1_ssp585_repeat';

%% tier 2 experiments
job1 = batch(@Ua,1);