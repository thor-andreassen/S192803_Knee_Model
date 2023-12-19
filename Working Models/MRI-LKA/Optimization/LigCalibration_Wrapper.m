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
%     jobParams.guess=[0.95,65.412,1.0,59.671,1.0,68.876,.9,150.49,0.7,0.8,0.8,50.39,0.8,40,0.95,34.078,0.9,90,0.92,90,0.85,37.43,0.85,69,1.025,34.283];
%     jobParams.guess=[0.950710000000000,86.4520000000000,0.896070000000000,51.1440000000000,0.979500000000000,78.6830000000000,0.895690000000000,156.430000000000,0.650000000000000,0.784010000000000,0.783000000000000,79.7630000000000,0.881760000000000,40.1810000000000,1.11080000000000,49.5020000000000,0.874710000000000,87.9390000000000,0.970070000000000,56.8160000000000,0.850630000000000,30.0180000000000,0.850260000000000,80.8210000000000,1.23340000000000,39.0460000000000];
%     jobParams.guess=[1.25000000000000,140,1.14180000000000,108.660000000000,1.15000000000000,53.7160000000000,1.01350000000000,200,0.906460000000000,0.757900000000000,0.766980000000000,157.210000000000,0.836290000000000,180,0.750000000000000,43.7680000000000,0.750000000000000,52.9220000000000,1.25000000000000,100,1.11390000000000,94.9460000000000,1.11300000000000,30,1.11430000000000,10]';
%     jobParams.guess = [0.972260000000000,131.680000000000,0.850000000000000,68.4230000000000,0.858800000000000,119.180000000000,0.879070000000000,82.4920000000000,0.941220000000000,0.795210000000000,0.841230000000000,88.0770000000000,0.950000000000000,159.940000000000,0.990180000000000,94.3290000000000,0.926920000000000,87.5350000000000,0.843450000000000,52.6980000000000,1.05740000000000,77.4730000000000,1.08650000000000,74.2570000000000,1.07130000000000,48.7180000000000];
%     jobParams.guess= [0.981490000000000,137.400000000000,0.850010000000000,72.6150000000000,0.869090000000000,128.570000000000,0.874420000000000,80.5860000000000,0.945990000000000,0.781460000000000,0.834130000000000,99.3120000000000,0.950000000000000,164.270000000000,1.09360000000000,94.4340000000000,0.898090000000000,87.9470000000000,0.859170000000000,52.3800000000000,0.975720000000000,70.6430000000000,1.03070000000000,64.6630000000000,1.14270000000000,57.0960000000000]'
%     jobParams.guess=[1.06990000000000,40.6280000000000,1.10000000000,127.860000000000,1.10000000000,71.8080000000000,0.860000000000,111.400000000000,0.60000000000000,0.70000000000,0.700000000000,116.530000000000,0.879710000000000,60.6050000000000,0.880700000000000,57.9590000000000,0.769860000000000,85.3260000000000,0.90000000000,75.1160000000000,0.919010000000000,97.9930000000000,0.990460000000000,65.9620000000000,1.07930000000000,47.2930000000000]';
%     jobParams.guess=[0.872490000000000	34.7090000000000	1.06190000000000	139.860000000000	1.03560000000000	73.7230000000000	0.65000000000000	100.360000000000	0.591130000000000	0.666630000000000	0.650460000000000	164.890000000000	0.862010000000000	57.1550000000000	1.11190000000000	82.4260000000000	0.806600000000000	68.1360000000000	1.18690000000000	95.3190000000000	1.10560000000000	82.4680000000000	1.13580000000000	65.5770000000000	1.08560000000000	31.1910000000000]';
%     jobParams.guess=[1.22520000000000,127.930000000000,1.01410000000000,74.9060000000000,0.970840000000000,51.5060000000000,0.591170000000000,81.2500000000000,0.748740000000000,0.653450000000000,0.685800000000000,160.350000000000,0.902040000000000,57.6360000000000,1.08610000000000,74.5490000000000,1.16360000000000,93.1720000000000,0.909280000000000,79.6810000000000,0.880760000000000,35.4370000000000,1.08650000000000,62.5990000000000,1.13840000000000,63.9300000000000]';
    jobParams.guess=[0.90000000000	108.380000000000	1.06330000000000	73.3100000000000	1.11440000000000	66.9000000000000	0.983360000000000	83.3640000000000	0.624800000000000	0.756640000000000	1.01820000000000	110.750000000000	0.835830000000000	161.110000000000	0.918130000000000	80.7460000000000	1.18420000000000	68.2390000000000	0.546650000000000	62.7120000000000	1.07710000000000	98.4470000000000	0.985810000000000	37.0580000000000	0.95000000000000	90];
    jobParams.ub =    [1.05,    140,       1.15,    150,       1.15,    150,       1.1,     120,       1.1,     1.1,     1.1,     180,       0.95,     180,      1.25,     95,      1.25,      100,       1.25,      100,       1.15,     100,       1.15,     100,     1.05,    90];
    jobParams.lb =    [0.75,    20,        0.85,    50,        0.85,    50,        0.65,     40,        0.6,     0.6,     0.6,     40,        0.75,     40,       0.75,     30,       0.75,      50,        0.5,      50,        0.85,     30,        0.85,     30,      0.75,    10];



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