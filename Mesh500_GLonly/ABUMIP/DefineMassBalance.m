function [UserVar,as,ab,dasdh,dabdh]=DefineMassBalance(UserVar,CtrlVar,MUA,time,s,b,h,S,B,rho,rhow,GF)

persistent Fas

if isempty(Fas)
    load(UserVar.smbfile);
end

as=Fas(MUA.coordinates);
% as=0 ;
ab=0;
dasdh=0;
dabdh=0;

end