%UserVar.smbfile='./FasRACMO.mat';

%% tier 1 experiments
% UserVar.experiment='CCSM4_RCP85';
% UserVar.experiment='HadGEM_RCP85';
% UserVar.experiment='CESM2_ssp585';
% UserVar.experiment='UKESM1_ssp585_norepeat';
% UserVar.experiment='UKESM1_ssp585_repeat';

%% meshes

job1 = batch(@Ua,1,'Pool',2);
% 
% UserVar.experiment='Mesh16';
% CtrlVar.ReadInitialMeshFileName='ASE-Mesh-16';
% CtrlVar.MeshSizeMax=32e3;
% job2 = batch(@Ua,1);
% 
% UserVar.experiment='Mesh8';
% CtrlVar.ReadInitialMeshFileName='ASE-Mesh-8';
% CtrlVar.MeshSizeMax=32e3;
% job3 = batch(@Ua,1);
