MeshBoundaryCoordinates=readmatrix('DomainCornerPoints1.csv'); 
UserVar=[];
CtrlVar=Ua2D_DefaultParameters(); %

CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';

%% step 1: generate uniform mesh
CtrlVar.MeshBoundaryCoordinates=MeshBoundaryCoordinates;

CtrlVar.MeshSizeMax=16e3;
CtrlVar.MeshSize=CtrlVar.MeshSizeMax/2;
CtrlVar.MeshSizeMin=CtrlVar.MeshSizeMax/32;

[UserVar,MUA]=genmesh2d(UserVar,CtrlVar);

FindOrCreateFigure("Mesh") ; PlotMuaMesh(CtrlVar,MUA); drawnow

save('ASE-mesh0','MUA');