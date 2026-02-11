MeshBoundaryCoordinates=readmatrix('DomainCornerPoints1.csv'); 
UserVar=[];
CtrlVar=Ua2D_DefaultParameters(); %

CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';

%% step 1: generate uniform mesh
CtrlVar.MeshBoundaryCoordinates=MeshBoundaryCoordinates;
% 
% CtrlVar.MeshSizeMax=16e3;
% CtrlVar.MeshSize=CtrlVar.MeshSizeMax/2;
% CtrlVar.MeshSizeMin=CtrlVar.MeshSizeMax/32;


% Mesh Refinement
CtrlVar.TimeDependentRun=0;  % {0|1} if true (i.e. set to 1) then the run is a forward transient one, if not
CtrlVar.ReadInitialMesh=1;
% UserVar.Slipperiness.ReadFromFile=1;
% UserVar.AGlen.ReadFromFile=1;
% CtrlVar.AdaptMesh=1;
% CtrlVar.AdaptMeshInitial=1  ;
% CtrlVar.AdaptMeshRunStepInterval=1 ;
% CtrlVar.AdaptMeshMaxIterations=10;
% CtrlVar.AdaptMeshAndThenStop=1;    % if true, then mesh will be adapted but no further calculations performed
% % useful, for example, when trying out different remeshing options (then use CtrlVar.doAdaptMeshPlots=1 to get plots)
% CtrlVar.InfoLevelAdaptiveMeshing=10;
CtrlVar.ReadInitialMeshFileName='ASE-Mesh2.mat'; %'ASE-Mesh0.mat';
CtrlVar.SaveInitialMeshFileName='MeshFile_Uniform1000m.mat';
% Meshing parameters

CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';
CtrlVar.MeshSizeMax=4000;
CtrlVar.MeshSize=4000;
CtrlVar.MeshSizeMin=4000;


CtrlVar.MeshRefinementMethod='explicit:local:newest vertex bisection';    % can have any of these values:
                                                            % 'explicit:global' 
                                                            % 'explicit:local:red-green'
                                                            % 'explicit:local:newest vertex bisection';


                                                   
[UserVar,MUA]=genmesh2d(UserVar,CtrlVar);
FindOrCreateFigure("Mesh") ; PlotMuaMesh(CtrlVar,MUA); drawnow
