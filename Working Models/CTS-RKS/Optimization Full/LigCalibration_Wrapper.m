%% Clear workspace
clear all; close all; clc;

%% Add path for Optimization routine
% if ispc
%     addpath('C:\Users\Thor.Andreassen\Desktop\Thor Personal Folder\Research\Don FE Model Calibration Code\MATLAB files\FMINSEARCHBND\')
% elseif isunix
%     addpath('FMINSEARCHBND')
% end

%% Initialize User Settings
jobParams.task = 'LC'; 
jobParams.stepNum = 1;
jobParams.model = 'S192803';

% % Define number of cores for jobQueue API
% numCores = dlmread('numCores.txt');

% Define stopping criteria
jobParams.TolX = 1e-2;
jobParams.TolFun = 1e-2;

% Define scaling factors for 3-part cost function

% original scaling
jobParams.SCALE_A90=100;
jobParams.SCALE_AIE90=50;
jobParams.SCALE_A30=100;
jobParams.SCALE_AIE30=50;
jobParams.SCALE_I90=100;
jobParams.SCALE_IIE90=50;
jobParams.SCALE_I30=100;
jobParams.SCALE_IIE30=50;
jobParams.SCALE_E90=100;
jobParams.SCALE_EIE90=50;
jobParams.SCALE_E30=100;
jobParams.SCALE_EIE30=50;


jobParams.DVWEIGHT=100;
% % Define Linux Path to ABAQUS
% jobParams.LinABQPath = 'abaqus';

%% Load iGuess and Optimization Bounds
% Set iGuess
%                 [ALSe,    ALSk,      ACLple,  ACLplk,    ACLame,  ACLamk,    LCLe,    LCLk,      MCLAe,    MCLMe,    MCLPe,    MCLk,      dMCLe,    dMCLk,    POLe,     POLk,     PCAPLe,    PCAPLk,    PCAPMe,    PCAPMk,    PCLale,   PCLalk,    PCLpme,   PCLpmk,   PFLe,    PFLk];
%     jobParams.guess=[0.95,65.412,1.0,59.671,1.0,68.876,.9,150.49,0.7,0.8,0.8,50.39,0.8,40,0.95,34.078,0.9,90,0.92,90,0.85,37.43,0.85,69,1.025,34.283];
    
%     jobParams.guess=[0.981490000000000,137.400000000000,0.850010000000000,72.6150000000000,0.869090000000000,128.570000000000,0.874420000000000,80.5860000000000,0.945990000000000,0.781460000000000,0.834130000000000,99.3120000000000,0.950000000000000,164.270000000000,1.09360000000000,94.4340000000000,0.898090000000000,87.9470000000000,0.859170000000000,52.3800000000000,0.975720000000000,70.6430000000000,1.03070000000000,64.6630000000000,1.14270000000000,57.0960000000000]';
%     jobParams.guess=[0.993230000000000,114.130000000000,0.996630000000000,114.170000000000,1.06170000000000,67.4930000000000,0.958260000000000,95.9910000000000,0.753180000000000,0.916870000000000,0.848780000000000,101.460000000000,0.933600000000000,146.090000000000,0.943610000000000,67.0990000000000,1.23070000000000,63.7940000000000,1.24930000000000,73.4720000000000,0.914510000000000,77.0620000000000,0.950080000000000,84.5100000000000,1.14630000000000,30.1700000000000];
    jobParams.guess=[0.995210000000000,115.530000000000,0.988260000000000,115.840000000000,1.06600000000000,68.7220000000000,0.956360000000000,92.4740000000000,0.801210000000000,0.913240000000000,0.847820000000000,101.930000000000,0.942640000000000,153.140000000000,0.960920000000000,65.2930000000000,1.22050000000000,60.6010000000000,1.24920000000000,74.3300000000000,0.917780000000000,77.5790000000000,0.940860000000000,85.3100000000000,1.13630000000000,31.2920000000000];
    jobParams.ub =    [1.25,    140,       1.15,    150,       1.15,    150,       1.15,     200,       0.95,     0.95,     0.95,     180,       0.95,     180,      1.25,     95,      1.25,      100,       1.25,      100,       1.15,     100,       1.15,     100,     1.25,    90];
    jobParams.lb =    [0.75,    20,        0.85,    50,        0.85,    50,        0.85,     60,        0.65,     0.75,     0.75,     40,        0.75,     40,       0.75,     30,       0.75,      50,        0.75,      50,        0.85,     30,        0.85,     30,      0.75,    10];



% % Check if guess exceeds bounds, warn.
if sum(jobParams.guess > jobParams.ub)>0 || sum(jobParams.guess < jobParams.lb)>0
    f = msgbox('Initial Guess(es) exceeds optimization bounds.');
end

%% Load Job Command List and Job Name List
% Load job list
filename = 'S192803_JOBLIST.txt';
readfile = fopen(filename);
tline = fgetl(readfile);
counter = 1;

while ischar(tline)
    jobCmd{counter} = tline;
    counter = counter+1;
    
    tline = fgetl(readfile);
end
fclose(readfile);

% Load name list
filename = 'S192803_JOBNAME.txt';
readfile = fopen(filename);
tline = fgetl(readfile);
counter = 1;

while ischar(tline)
    jobName{counter} = tline;
    counter = counter+1;
    
    tline = fgetl(readfile);
end
fclose(readfile);

jobParams.jobNameTemp = jobName;
jobParams.jobCmdTemp = jobCmd;

%% Run optimization
% Setup optimization step function
setGlobalCount(0);

jobParams.fun = @(x)runLCEBLStep_matlab(x,jobParams);

% Start optimization
%runLCStep_matlab(jobParams.guess,jobParams)
[sol,fval,exitflag,output]=runSimplex(jobParams)


% [x_best,f_best,exitflag,output]=runParticlesSwarm(jobParams)


% [sol,fval,exitflag,output]=runGlobal(jobParams)
