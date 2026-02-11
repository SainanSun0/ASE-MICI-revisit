
function [UserVar,CtrlVar,MeshBoundaryCoordinates]=DefineInitialInputs(UserVar,CtrlVar)




%% Select the type of run by uncommenting one of the following options:

if isempty(UserVar) || ~isfield(UserVar,'RunType')
    
    % UserVar.RunType='Inverse-MatOpt';
    % UserVar.RunType='Inverse-ConjGrad';
    % UserVar.RunType='Inverse-SteepestDesent';
    % UserVar.RunType='Inverse-ConjGrad-FixPoint';
    % UserVar.RunType='Inverse-MatOpt-FixPoint';
%     UserVar.RunType='Forward-Diagnostic';
    UserVar.RunType='Forward-Transient';
%     UserVar.RunType='TestingMeshOptions';

end

if isempty(UserVar) || ~isfield(UserVar,'m')
    UserVar.m=3;
end


CtrlVar.FlowApproximation="SSTREAM" ;
%%
% This run requires some additional input files. They are too big to be kept on Github so you
% will have to get those separately. 
%
% You can https://livenorthumbriaac-my.sharepoint.com/:f:/g/personal/hilmar_gudmundsson_northumbria_ac_uk/EgrEImnkQuJNmf1GEB80VbwB1hgKNnRMscUitVpBrghjRg?e=yMZEOs
% 
% Put the OneDrive folder `Interpolants' into you directory so that it can be reaced as ../Interpolants with respect to you rundirectory. 
%
%


% Interpolant paths: this assumes you have downloaded the OneDrive folder `Interpolants'.
% UserVar.GeometryInterpolant='../../Interpolants/Bedmap2GriddedInterpolantModifiedBathymetry.mat';
UserVar.GeometryInterpolant='C:/cygwin64/home/nljn8/Interpolants/BedMachineGriddedInterpolants.mat';                       
UserVar.SurfaceVelocityInterpolant='C:/cygwin64/home/nljn8/Interpolants/SurfVelMeasures990mInterpolants.mat';
MeshBoundaryCoordinates=readmatrix('D:/Runs/Amundsen_adv_mesh/DomainCornerPoints1.csv'); 
UserVar.smbfile='C:/cygwin64/home/nljn8/Interpolants/FasRACMO.mat';
UserVar.experiment='Mesh005';
UserVar.CalvingFront0="-BMCF-"; % "-BedMachineCalvingFronts-"  ;
CtrlVar.SlidingLaw="Weertman" ; % "Umbi" ; % "Weertman" ; % "Tsai" ; % "Cornford" ;  "Umbi" ; "Cornford" ; % "Tsai" , "Budd"

switch CtrlVar.SlidingLaw
    
    case "Weertman"
        UserVar.CFile='FC-Weertman2.mat'; UserVar.AFile='FA-Weertman2.mat';
    case "Umbi"
        UserVar.CFile='FC-Umbi.mat'; UserVar.AFile='FA-Umbi.mat';
    otherwise
        error('A and C fields not available')
end


if ~isfile(UserVar.GeometryInterpolant) || ~isfile(UserVar.SurfaceVelocityInterpolant)
     
     fprintf('\n This run requires the additional input files: \n %s \n %s \n %s  \n \n',UserVar.GeometryInterpolant,UserVar.DensityInterpolant,UserVar.SurfaceVelocityInterpolant)
     fprintf('You can download these file from : https://1drv.ms/f/s!Anaw0Iv-oEHTloRzWreBMDBFCJ0R4Q \n')
     
end

%%

CtrlVar.Experiment=UserVar.RunType;

switch UserVar.RunType
    
    case {'Inverse-MatOpt','Inverse-ConjGrad','Inverse-MatOpt-FixPoint','Inverse-ConjGrad-FixPoint','Inverse-SteepestDesent'}
        
        CtrlVar.InverseRun=1;
        CtrlVar.Restart=1;
        
        CtrlVar.InfoLevelNonLinIt=0;
        CtrlVar.Inverse.InfoLevel=1;
        CtrlVar.InfoLevel=0;
        
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
        
        CtrlVar.Inverse.Iterations=2000;
        CtrlVar.Inverse.InvertFor='logA-logC' ; % '-logAGlen-logC-' ; % {'-C-','-logC-','-AGlen-','-logAGlen-'}
        CtrlVar.Inverse.Regularize.Field=CtrlVar.Inverse.InvertFor;
        
        CtrlVar.Inverse.Measurements='-uv-' ;  % {'-uv-,'-uv-dhdt-','-dhdt-'}
        
        
        
        if contains(UserVar.RunType,'FixPoint')
            
            % FixPoint inversion is an ad-hoc method of estimating the gradient of the cost function with respect to C.
            % It can produce quite good estimates for C using just one or two inversion iterations, but then typically stagnates.
            % The FixPoint method can often be used right at the start of an inversion to get a reasonably good C estimate,
            % after which in a restart step one can switch to gradient calculation using the adjoint method 
            CtrlVar.Inverse.DataMisfit.GradientCalculation='FixPoint' ;
            CtrlVar.Inverse.InvertFor='logC' ;
            CtrlVar.Inverse.Iterations=1;
            CtrlVar.Inverse.Regularize.Field=CtrlVar.Inverse.InvertFor;
          
        end
        
        
    case 'Forward-Transient'
        
        CtrlVar.InverseRun=0;
        CtrlVar.TimeDependentRun=1;
        CtrlVar.Restart=1;
        CtrlVar.InfoLevelNonLinIt=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=0;
        CtrlVar.AdaptMesh=1;
        
    case 'Forward-Diagnostic'
               
        CtrlVar.InverseRun=0;
        CtrlVar.TimeDependentRun=0;
        CtrlVar.Restart=0;
        CtrlVar.InfoLevelNonLinIt=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.ReadInitialMesh=1;
        CtrlVar.AdaptMesh=0;
        
    case 'TestingMeshOptions'
        
        CtrlVar.TimeDependentRun=0;  % {0|1} if true (i.e. set to 1) then the run is a forward transient one, if not
        CtrlVar.InverseRun=0;
        CtrlVar.Restart=0;
        CtrlVar.ReadInitialMesh=0;
        CtrlVar.AdaptMesh=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.Slipperiness.ReadFromFile=1;
        UserVar.AGlen.ReadFromFile=1;
        CtrlVar.AdaptMesh=1;
        CtrlVar.AdaptMeshInitial=1  ;      
        CtrlVar.AdaptMeshRunStepInterval=1 ; 
        CtrlVar.AdaptMeshAndThenStop=1;    % if true, then mesh will be adapted but no further calculations performed
        % useful, for example, when trying out different remeshing options (then use CtrlVar.doAdaptMeshPlots=1 to get plots)
        CtrlVar.InfoLevelAdaptiveMeshing=10;
end


CtrlVar.dt=1e-4; 
CtrlVar.time=0;
CtrlVar.TotalNumberOfForwardRunSteps=Inf; 
CtrlVar.TotalTime=250;
CtrlVar.ATSTargetIterations=6;

% time interval between calls to DefineOutputs.m
CtrlVar.DefineOutputsDt=1; 
% Element type
CtrlVar.TriNodes=3 ;

%% calving law
CtrlVar.LevelSetMethod=1;
CtrlVar.LevelSetEvolution="-By solving the level set equation-"   ; % "-prescribed-",
CtrlVar.CalvingLaw.Evaluation="-int-"; % -int- -node-
UserVar.CalvingLaw.Type="-c0isGL0-";
CtrlVar.LevelSetMethodAutomaticallyDeactivateElements=1;
CtrlVar.LevelSetMethodAutomaticallyDeactivateElementsRunStepInterval=10;
CtrlVar.LevelSetMethodStripWidth=10e3;
CtrlVar.LevelSetFABmu.Value=0.2 ;
CtrlVar.LevelSetInitialisationInterval=1 ;

CtrlVar.IncludeMelangeModelPhysics=true;
CtrlVar.DevelopmentVersion=true;
CtrlVar.ExplicitEstimationMethod="-no extrapolation-";

CtrlVar.MeshAdapt.CFrange=[20e3 2e3 ; 5e3 1e3] ; % Tmhis refines the mesh around the calving front, but must set

% CtrlVar.LevelSetMethodAutomaticallyDeactivateElements=0;
% CtrlVar.LevelSetMethodMassBalanceFeedbackCoeffLin=-10;

%%
CtrlVar.doplots=1;
CtrlVar.PlotMesh=0;  
CtrlVar.PlotBCs=1 ;
CtrlVar.PlotXYscale=1000;
CtrlVar.doAdaptMeshPlots=5; 
%%

CtrlVar.ReadInitialMeshFileName='ASE-Mesh2';
% CtrlVar.ReadInitialMeshFileName='PIG-TWG-Mesh-withThwaitesIceshelfWestDeleted.mat';
% CtrlVar.SaveInitialMeshFileName='MeshFile.mat';
CtrlVar.MaxNumberOfElements=1.0e5;




%% Meshing 


CtrlVar.MeshRefinementMethod='explicit:local:newest vertex bisection';   
%CtrlVar.MeshRefinementMethod='explicit:local:red-green';
% CtrlVar.MeshRefinementMethod='explicit:global';   

% CtrlVar.MeshGenerator='gmsh' ; % 'mesh2d';
CtrlVar.MeshGenerator='mesh2d' ; % 'mesh2d';
% CtrlVar.GmshMeshingAlgorithm=8; 
CtrlVar.MeshSizeMax=8e3;
UserVar.RefineLevel=4;
UserVar.RefineSize=CtrlVar.MeshSizeMax./2^UserVar.RefineLevel;
CtrlVar.MeshSize=CtrlVar.MeshSizeMax;
CtrlVar.MeshSizeMin=CtrlVar.MeshSizeMax./2^UserVar.RefineLevel;
UserVar.MeshSizeIceShelves=CtrlVar.MeshSizeMax;
                                         
CtrlVar.AdaptMeshInitial=1  ;   
CtrlVar.AdaptMeshMaxIterations=1;
CtrlVar.AdaptMeshRunStepInterval=100 ;
CtrlVar.MeshAdapt.GLrange=[8*UserVar.RefineSize*8 UserVar.RefineSize*8; ...
    8*UserVar.RefineSize*4 UserVar.RefineSize*4; 8*UserVar.RefineSize*2 UserVar.RefineSize*2; 8*UserVar.RefineSize UserVar.RefineSize]; % this is the same with Cornford et al., 2016 AoG

CtrlVar.SaveAdaptMeshFileName='ASE-Mesh-005';    %  file name for saving adapt mesh. If left empty, no file is written




I=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='effective strain rates';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.001;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='flotation';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.0001;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;

I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='thickness gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;


I=I+1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Name='upper surface gradient';
CtrlVar.ExplicitMeshRefinementCriteria(I).Scale=0.01;
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMin=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).EleMax=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).p=[];
CtrlVar.ExplicitMeshRefinementCriteria(I).InfoLevel=1;
CtrlVar.ExplicitMeshRefinementCriteria(I).Use=false;

%%
                                                        
%%  Bounds on C and AGlen
%CtrlVar.AGlenmin=1e-10; CtrlVar.AGlenmax=1e-5;

CtrlVar.Cmin=1e-20;  CtrlVar.Cmax=1e20;        
CtrlVar.AGlenmin=AGlenVersusTemp(-20);

%CtrlVar.CisElementBased=0;   
%CtrlVar.AGlenisElementBased=0;   


%% Testing adjoint parameters, start:
CtrlVar.Inverse.TestAdjoint.isTrue=0; % If true then perform a brute force calculation 
                                      % of the directional derivative of the objective function.  
CtrlVar.Inverse.TestAdjointFiniteDifferenceType='second-order' ; % {'central','forward'}
CtrlVar.Inverse.TestAdjointFiniteDifferenceStepSize=1e-8 ;
CtrlVar.Inverse.TestAdjoint.iRange=[100,121] ;  % range of nodes/elements over which brute force gradient is to be calculated.
                                         % if left empty, values are calulated for every node/element within the mesh. 
                                         % If set to for example [1,10,45] values are calculated for these three
                                         % nodes/elements.
% end, testing adjoint parameters. 


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


%%
CtrlVar.ThicknessConstraints=0;
% CtrlVar.ThicknessConstraintsItMax=0  ;
CtrlVar.ResetThicknessToMinThickness=1;  % change this later on
CtrlVar.ThickMin=1;

%% Filenames

CtrlVar.NameOfFileForSavingSlipperinessEstimate="C-Estimate"+CtrlVar.SlidingLaw+".mat";
CtrlVar.NameOfFileForSavingAGlenEstimate=   "AGlen-Estimate"+CtrlVar.SlidingLaw+".mat";

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
    CtrlVar.Experiment="PIG-TWG-Forward-"...
        +CtrlVar.ReadInitialMeshFileName;
end


filename=sprintf('ASE-%s-%s-Nod%i-%s-%s-Cga%f-Cgs%f-Aga%f-Ags%f-m%i-%s',...
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

CtrlVar.NameOfRestartFiletoRead=filename;
CtrlVar.NameOfRestartFiletoWrite=filename;

end
