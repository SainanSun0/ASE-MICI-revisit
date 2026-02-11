function [UserVar,as,ab,dasdh,dabdh]=DefineMassBalance(UserVar,CtrlVar,MUA,F)
         
as=zeros(size(F.x)) ;
dasdh=zeros(size(F.x)) ;
dabdh=zeros(size(F.x)) ;

% Flux include density
if isempty(F.ub)
    load('../IR-Inverse-MatOpt3-MatlabOptimization-Nod3-M-Adjoint-Cga1k000000-Cgs25000k000000-Aga1k000000-Ags25000k000000-m3-logA-logC.mat','F');
end
qx=F.rho.*(F.ub+F.ud).*F.h;
qy=F.rho.*(F.vb+F.vd).*F.h;
% calculate flux gradients at integrial points
[dqxdx,dqxdy]=calcFEderivativesMUA(qx,MUA,CtrlVar);
[dqydx,dqydy]=calcFEderivativesMUA(qy,MUA,CtrlVar);
% Project onto nodes
dqxdx(isnan(dqxdx))=0;dqydy(isnan(dqydy))=0;
[dqxdx,dqydy]=ProjectFintOntoNodes(MUA,dqxdx,dqydy);

% Now cauculate basal melt, note that we want to have dhdt=0
ab=(dqxdx+dqydy)./F.rho-as;
ab=ab.*(1-F.GF.node); % make sure no melt occurs on grounded nodes
end