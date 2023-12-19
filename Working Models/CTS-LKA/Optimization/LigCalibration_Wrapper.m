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

% % original scaling
% jobParams.SCALE_A90=200;
% jobParams.SCALE_AIE90=50;
% jobParams.SCALE_A30=200;
% jobParams.SCALE_AIE30=50;
% jobParams.SCALE_I90=100;
% jobParams.SCALE_IIE90=50;
% jobParams.SCALE_I30=100;
% jobParams.SCALE_IIE30=50;
% jobParams.SCALE_E90=100;
% jobParams.SCALE_EIE90=50;
% jobParams.SCALE_E30=100;
% jobParams.SCALE_EIE30=50;


% original scaling
jobParams.SCALE_A90=200;
jobParams.SCALE_AIE90=100;
jobParams.SCALE_A30=200;
jobParams.SCALE_AIE30=100;
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

jobParams.fun = @(x)runLCStep_matlab(x,jobParams);

% Start optimization
%runLCStep_matlab(jobParams.guess,jobParams)

% [x_best,f_best,exitflag,output]=runParticlesSwarm(jobParams)
[sol,fval,exitflag,output]=runSimplex(jobParams)





%[sol,fval,exitflag,output]=runGlobal(jobParams)
