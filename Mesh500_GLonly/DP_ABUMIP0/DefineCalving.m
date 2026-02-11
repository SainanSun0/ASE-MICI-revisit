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

% initialize LSF
if F.time<1.1   % Do I need to initialize the level set function?
    LSF=-ones(MUA.Nnodes,1) ;
    LSF(F.GF.node>0.5)=+1;
    Xc=[] ;  % If Xc and Yc are left empty, the Xc and Yc will be calculated as the zero contorl of the LSF field
    Yc=[] ;
    [xc,yc,LSF]=CalvingFrontLevelSetGeometricalInitialisation(CtrlVar,MUA,Xc,Yc,LSF,plot=true,ResampleCalvingFront=true);
else
    LSF=F.LSF;
end

%% DefineCalving rate (if needed)
if CtrlVar.LevelSetEvolution=="-Prescribed-"
    c=nan;   % setting the calving rate to nan implies that the level set is not evolved
elseif CtrlVar.CalvingLaw.Evaluation=="-int-"
    c=DefineCalvingAtIntegrationPoints(UserVar,CtrlVar,nan,nan,F);
    if isnan(c)
        c=0;
    end
elseif CtrlVar.CalvingLaw.Evaluation=="-node-" % this is by default
    c=0*F.LSF; 
    switch UserVar.CalvingLaw.Type
        case "Pollard2015Hydrofracture"
            %% Calving including hydrofracture due to surface melt.
            % ds, db depending on divergence/strain rate
            [~,~,txx,tyy,txy,exx,eyy,exy,e,eta]=CalcNodalStrainRatesAndStresses(CtrlVar,UserVar,MUA,F);
            % Pollard2015 adjusted ice thickness, i.e. thinning grids adjacent to open ocean.
            % I didn't, only calculate edot differently at the calving front, according to Pollard2015.
            % edot=max(0,(exx+eyy)./2+sqrt((exx-eyy).^2./4+exy.^2)); % principal strain rate emax
            [pv,~,~]=CalcPrincipalValuesOfSymmetricalTwoByTwoMatrices(exx,exy,eyy);
            edot=exx.*0;
            edot=max(edot,pv(:,2));% principal strain rate emax
            edot=max(0,exx+eyy); % Pollard2015 instead of principle strain rate to avoid noise and error, questionable
            edot(F.LSF==0)=F.AGlen(F.LSF==0).*(F.rho(F.LSF==0).*F.g(F.LSF==0).*F.h(F.LSF==0)./4).^3; %F.n=3
            ds=2./F.rho./F.g.*(edot./F.AGlen).^(1/3); % F.n=3
            db=2*F.rho./(F.rhow-F.rho)./F.rho./F.g.*(edot./F.AGlen).^(1/3); % F.n=3
            db(F.GF.node>0)=0;
            % da, dependence on accumulation strain (addational crevasse
            % deepening); NOTICE: h should be adjusted thickness here
            u=sqrt((F.ub+F.ud).^2+(F.vb+F.vd).^2); % speed
            da=F.h.*max(0,log(u./1600))./log(1.2);
            % dt, dependence on ice thickness, necessary???
            dt=F.h.*max(0,min(1,(150-F.h)./50)); % remove floating ice thinner than 100m
            % dw, dependence on surface water. Here we need a PDD model
            R=0; % R is the annual surface melt+rainfall available after refreezing in smb
            dw=100.*R.^2;
            % combined calving parameterization
            r=(ds+db+da+dt+dw)./F.h; % add up all the crevass depth component
            rc=0.75; % critical value for calving onset, 0.75 in Pollard2015
            c=3000.*max(0,min(1,(r-rc)./(1-rc)));
            % cliff failure
        case "-DP-"
            % [GLgeo,GLnodes,GLele]=GLgeometry(MUA.connectivity,MUA.coordinates,F.GF,CtrlVar);
            % xGL=GLgeo(:,7) ; yGL=GLgeo(:,8);
            % nxGL=GLgeo(:,9); nyGL=GLgeo(:,10);
            % if isempty(F.txx)
            %     F.txx=txx; F.txy=txy; F.tyy=tyy;
            %     GLQ=GroundingLineQuantities(F,xGL,yGL,nxGL,nyGL);
            %     F.txx=[];F.txy=[];F.tyy=[];
            % else
            %     GLQ=GroundingLineQuantities(F,xGL,yGL,nxGL,nyGL);
            % end
            CliffHeight=min((F.s-F.S),F.h).*F.rho./1000;  % OK, so it is a bit unclear what the "cliff height" should be
            % But presumably the idea is that the CliffHeight is a proxy
            % for the stresses at the calving front, so it appears likley that it should
            % involve rho*g*CliffHeight
            % For this to be comparable with values in the litterature
            % this will most likely need to be adjusted to water equivalent height.


            k1=-12000 ; k2=150 ;
            c=k1+k2*CliffHeight;  % c(CliffHeight=80 m)=0 and c(CliffHeight=100 m) = 3000 m/yr

            c(CliffHeight<80)= 0;
            c(CliffHeight>100)=3000;
            % 
            % dcddphidx=0;
            % dcddphidy=0;

            % hc=80; % critical cliff height
            % c=3000*max(0,min(1,(F.s-hc)./20));
            % hc=80; % critical cliff height
            % c=3000*max(0,min(1,(F.s-hc)./20));
            % c=max(c,9000.*(1-F.GF.node));
    end
    
end