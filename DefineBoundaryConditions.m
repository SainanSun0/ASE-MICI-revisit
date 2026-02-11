function  [UserVar,BCs]=DefineBoundaryConditions(UserVar,CtrlVar,MUA,BCs,time,s,b,h,S,B,ub,vb,ud,vd,GF)


persistent AA BB


if isempty(AA)
  
    % load points that define the line-segments along which the BCs are to be defined
    
    CP=readmatrix('DomainCornerPoints1.csv'); 
    AA=CP(1:9,:) ; BB=CP(2:10,:) ; 
    

end


% find all boundary nodes within 1m distance from the line segment.
x=MUA.coordinates(:,1);  y=MUA.coordinates(:,2); tolerance=1;
I = DistanceToLineSegment([x(MUA.Boundary.Nodes) y(MUA.Boundary.Nodes)],AA,BB,tolerance);


BCs.vbFixedNode=MUA.Boundary.Nodes(I);
BCs.ubFixedNode=MUA.Boundary.Nodes(I);

% [BCs.ubFixedValue,BCs.vbFixedValue]=EricVelocities(CtrlVar,[x(Boundary.Nodes(I)) y(Boundary.Nodes(I))]);
load(UserVar.SurfaceVelocityInterpolant);
ubFixedValue=fillmissing(FuMeas(x(BCs.ubFixedNode),y(BCs.ubFixedNode)),'linear');
vbFixedValue=fillmissing(FvMeas(x(BCs.vbFixedNode),y(BCs.vbFixedNode)),'linear');

BCs.ubFixedValue=ubFixedValue;
BCs.vbFixedValue=vbFixedValue;
% BCs.ubFixedValue=BCs.ubFixedNode*0;
% BCs.vbFixedValue=BCs.vbFixedNode*0;
%

%
FindOrCreateFigure("BCs") ; PlotBoundaryConditions(CtrlVar,MUA,BCs);

end