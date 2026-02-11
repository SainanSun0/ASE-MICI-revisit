function [UserVar,as,ab,dasdh,dabdh]=DefineMassBalance(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)

persistent Fas gamma0 Fdeltbasin Ftf

if isempty(Fas)
    load(UserVar.smbfile);
end

if isempty(Ftf)
    load(UserVar.oceanfile);
end

dasdh=0;
dabdh=0;
as=Fas(MUA.coordinates);

rhoi_SI=918.0; % ice density (kg/m^3)
rhosw_SI=1028.0; % sea water density
rhofw_SI=1000.0; % freshwater density
Lf_SI=3.34e5; % fusion latent heat of Ice (J/kg)
cpw_SI=3974.0; % specific heat of sea water (J/kg/K)
deltaT_basin=Fdeltbasin(MUA.coordinates);
thermal_forcing=Ftf([MUA.coordinates b]); % perturbing parameter

ab=-gamma0.*(rhosw_SI.*cpw_SI./rhoi_SI./Lf_SI).^2.*(max(thermal_forcing+deltaT_basin,0.0)).^2; % here is mass balance, which needs the negative sign
ab(GF.node>0.5)=0;

OceanBoundaryNodes=[]; 
NodesDownstreamOfGroundingLines="Relaxed" ;
[LakeNodes,OceanNodes,LakeElements,OceanElements] = LakeOrOcean3(CtrlVar,MUA,GF,OceanBoundaryNodes,NodesDownstreamOfGroundingLines);
ab(LakeNodes)=0;

end