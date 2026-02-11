
function [UserVar,CtrlVar,MeshBoundaryCoordinates]=DefineInitialInputs(UserVar,CtrlVar)

UserVar.GeometryInterpolant='C:/cygwin64/home/nljn8/Interpolants/BedMachineGriddedInterpolants.mat';                       
MeshBoundaryCoordinates=readmatrix('DomainCornerPoints1.csv'); 
UserVar.SurfaceVelocityInterpolant='C:/cygwin64/home/nljn8/Interpolants/SurfVelMeasures990mInterpolants.mat';

if ~isfile(UserVar.GeometryInterpolant) || ~isfile(UserVar.SurfaceVelocityInterpolant)
     
     fprintf('\n This run requires the additional input files: \n %s \n %s \n %s  \n \n',UserVar.GeometryInterpolant,UserVar.DensityInterpolant,UserVar.SurfaceVelocityInterpolant)
     fprintf('You can download these file from : https://1drv.ms/f/s!Anaw0Iv-oEHTloRzWreBMDBFCJ0R4Q \n')
     
end


% UserVar.RunType='TestingMeshOptions';
UserVar.RunType='Inverse-MatOpt';
CtrlVar.Experiment=UserVar.RunType;

switch UserVar.RunType
    
    case {'Inverse-MatOpt','Inverse-ConjGrad','Inverse-MatOpt-FixPoint','Inverse-ConjGrad-FixPoint','Inverse-SteepestDesent'}
        
        CtrlVar.InverseRun=1;
        CtrlVar.Restart=0;
        
        CtrlVar.InfoLevelNonLinIt=0;
        CtrlVar.Inverse.InfoLevel=1;
        CtrlVar.InfoLevel=0;
        
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
        
        CtrlVar.Inverse.Iterations=1000;
        CtrlVar.Inverse.InvertFor='logA-logC' ; % '-logAGlen-logC-' ; % {'-C-','-logC-','-AGlen-','-logAGlen-'}
        CtrlVar.Inverse.Regularize.Field=CtrlVar.Inverse.InvertFor;
        
        CtrlVar.Inverse.Measurements='-uv-' ;  % {'-uv-,'-uv-dhdt-','-dhdt-'}
        
        
    case 'TestingMeshOptions'

        CtrlVar.TimeDependentRun=0;  % {0|1} if true (i.e. set to 1) then the run is a forward transient one, if not
        CtrlVar.InverseRun=0;
        CtrlVar.Restart=0;
        CtrlVar.ReadInitialMesh=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.AdaptMesh=1;
        CtrlVar.AdaptMeshInitial=1  ;
        CtrlVar.AdaptMeshRunStepInterval=1 ;
        CtrlVar.AdaptMeshMaxIterations=10;
        CtrlVar.AdaptMeshAndThenStop=1;    % if true, then mesh will be adapted but no further calculations performed
        % useful, for example, when trying out different remeshing options (then use CtrlVar.doAdaptMeshPlots=1 to get plots)
        CtrlVar.InfoLevelAdaptiveMeshing=10;
end

%% sliding law, viscosity parameter
UserVar.m=3;
CtrlVar.SlidingLaw="Weertman"; % "Umbi" ; % "Weertman" ; % "Tsai" ; % "Cornford" ;  "Umbi" ; "Cornford" ; % "Tsai" , "Budd"

switch CtrlVar.SlidingLaw
    case "Weertman"
        UserVar.CFile='FC-Weertman3.mat'; UserVar.AFile='FA-Weertman3.mat';
    case "Umbi"
        UserVar.CFile='FC-Umbi.mat'; UserVar.AFile='FA-Umbi.mat';
    otherwise
        error('A and C fields not available')
end

CtrlVar.ReadInitialMeshFileName='ASE-Mesh3.mat'; %'ASE-Mesh0.mat';
CtrlVar.SaveInitialMeshFileName='MeshFile.mat';
% CtrlVar.SaveAdaptMeshFileName='ASE-Mesh3';    %  file name for saving adapt mesh. If left empty, no file is written


% Meshing parameters

CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';
CtrlVar.MeshSizeMax=16e3;
CtrlVar.MeshSize=CtrlVar.MeshSizeMax/2;
CtrlVar.MeshSizeMin=CtrlVar.MeshSizeMax/32;
UserVar.MeshSizeIceShelves=CtrlVar.MeshSizeMax/4;


CtrlVar.MeshRefinementMethod='explicit:global';    % can have any of these values:
                                                   % 'explicit:global' 
                                                   % 'explicit:local:red-green'
                                                   % 'explicit:local:newest vertex bisection';
                                         


I=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='effective strain rates';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.001;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=true;

%% Inversion parameters

%  Bounds on C and AGlen
%  CtrlVar.AGlenmin=1e-10; CtrlVar.AGlenmax=1e-5;
CtrlVar.Cmin=1e-20;  CtrlVar.Cmax=1e20;        
CtrlVar.AGlenmin=AGlenVersusTemp(-30);

if contains(UserVar.RunType,'MatOpt')
    CtrlVar.Inverse.MinimisationMethod='MatlabOptimization';
else
    CtrlVar.Inverse.MinimisationMethod='UaOptimization';
    if contains(UserVar.RunType,'ConjGrad')
        CtrlVar.Inverse.GradientUpgradeMethod='ConjGrad' ; %{'SteepestDecent','ConjGrad'}
    else
        CtrlVar.Inverse.GradientUpgradeMethod='SteepestDecent' ; %{'SteepestDecent','ConjGrad'}
    end
    
end

CtrlVar.Inverse.Regularize.C.gs=1;
CtrlVar.Inverse.Regularize.C.ga=1;
CtrlVar.Inverse.Regularize.logC.ga=1;  % testing for Budd
CtrlVar.Inverse.Regularize.logC.gs=2.5e4 ; % testing for Budd

CtrlVar.Inverse.Regularize.AGlen.gs=1;
CtrlVar.Inverse.Regularize.AGlen.ga=1;
CtrlVar.Inverse.Regularize.logAGlen.ga=1;
CtrlVar.Inverse.Regularize.logAGlen.gs=2.5e4 ;

%% calculation parameters
CtrlVar.ThickMin=10;
CtrlVar.ThicknessConstraints=1;             % set to 1 to use the active-set method (Option 2 above, and the recommended option).
CtrlVar.ThicknessConstraintsItMax=10  ;     % maximum number of active-set iterations.
                                            % if the maximum number of active-set
                                            % iterations is reached, a warning is given,
                                            % but the calculation is not stopped. (In many
                                            % cases there is no need to wait for full
                                            % convergence of the active-set method for
                                            % each time step.)
                                            %
                                            % If set to 0, then the active set is updated
                                            % once at the beginning of the uvh step, but
                                            % no iteration is done.
                                            %
                                            % In many cases, such as long transient runs,
                                            % performing only one iteration per time step
                                            % is presumably going to be OK.
%% Output 
CtrlVar.NameOfFileForSavingSlipperinessEstimate="C-Estimate"+CtrlVar.SlidingLaw+"4.mat";
CtrlVar.NameOfFileForSavingAGlenEstimate=   "AGlen-Estimate"+CtrlVar.SlidingLaw+"4.mat";

if CtrlVar.InverseRun
    CtrlVar.Experiment="PIG-TWG-Inverse-"...
        +CtrlVar.ReadInitialMeshFileName...
        +CtrlVar.Inverse.InvertFor...
        +CtrlVar.Inverse.MinimisationMethod...
        +"-"+CtrlVar.Inverse.AdjointGradientPreMultiplier...
        +CtrlVar.Inverse.DataMisfit.GradientCalculation...
        +CtrlVar.Inverse.Hessian...
        +"-"+CtrlVar.SlidingLaw...
        +"-"+num2str(CtrlVar.DevelopmentVersion);
else
    CtrlVar.Experiment="PIG-TWG-Forward"...
        +CtrlVar.ReadInitialMeshFileName;
end

filename=sprintf('IR-%s4-%s-Nod%i-%s-%s-Cga%f-Cgs%f-Aga%f-Ags%f-m%i-%s',...
    UserVar.RunType,...
    CtrlVar.Inverse.MinimisationMethod,...
    CtrlVar.TriNodes,...
    CtrlVar.Inverse.AdjointGradientPreMultiplier,...
    CtrlVar.Inverse.DataMisfit.GradientCalculation,...
    CtrlVar.Inverse.Regularize.logC.ga,...
    CtrlVar.Inverse.Regularize.logC.gs,...
    CtrlVar.Inverse.Regularize.logAGlen.ga,...
    CtrlVar.Inverse.Regularize.logAGlen.gs,...
    UserVar.m,...
    CtrlVar.Inverse.InvertFor);

CtrlVar.Experiment=replace(CtrlVar.Experiment," ","-");
filename=replace(filename,'.','k');

CtrlVar.Inverse.NameOfRestartOutputFile=filename;
CtrlVar.Inverse.NameOfRestartInputFile=CtrlVar.Inverse.NameOfRestartOutputFile;

%% Plotting parameters
CtrlVar.doplots=1;
CtrlVar.PlotMesh=0;  
CtrlVar.PlotBCs=1 ;
CtrlVar.PlotXYscale=1000;
CtrlVar.doAdaptMeshPlots=5; 

end
