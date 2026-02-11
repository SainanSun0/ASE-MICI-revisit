function [UserVar,LSF,c]=DefineCalving(UserVar,CtrlVar,MUA,F,BCs)



%%
%
%   [UserVar,LSF,c]=DefineCalving(UserVar,CtrlVar,MUA,LSF,c,F,BCs)
%
% Define calving the Level-Set Field (LSF) and the Calving Rate Field (c)
%
% Both the Level-Set Field (LSF) and the Calving-Rate Field (c) must be defined over the whole computational domain.
%
%
% The LSF should, in general, only be defined in the beginning of the run and set the initial value for the LSF. However, if
% required, the user can change LSF at any time step. The LSF is evolved by solving the Level-Set equation, so any changes
% done to LSF in this m-file will overwrite/replace the previously calculated values for LSF.
%
% The calving-rate field, c, is an input field to the Level-Set equation and needs to be defined in this m-file in each call.
%
% The variable F has F.LSF and F.c as subfields. In a transient run, these will be the corresponding values from the previous
% time step.
%
%
% In contrast to LSF, c is never evolved by Úa.  (Think of c as an input variable similar to the input as and ab for upper
% and lower surface balance, etc.)
%
% If c is returned as a NaN, ie
%
%       c=NaN;
%
% then the level-set is NOT evolved in time using by solving the level-set equation. This can be usefull if, for example, the
% user simply wants to manually prescribe the calving front position at each time step.
%
%%
LSF=-ones(MUA.Nnodes,1) ;
LSF(F.GF.node>0.5)=+1;
Xc=[] ;  % If Xc and Yc are left empty, the Xc and Yc will be calculated as the zero contorl of the LSF field
Yc=[] ;


% figure ; PlotMuaMesh(CtrlVar,MUA);   hold on ; plot(F.x(io)/1000,F.y(io)/1000,'or')

[xc,yc,LSF]=CalvingFrontLevelSetGeometricalInitialisation(CtrlVar,MUA,Xc,Yc,LSF,plot=true,ResampleCalvingFront=true);
c=nan;
