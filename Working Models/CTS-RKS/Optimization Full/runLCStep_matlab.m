function [err]=runLCStep_matlab(x,jobParams)
%% Debug // Analyze Optimal Solution
if (1==1)
    
    % Get optimal solution
    currOpti = dlmread('designVector_LC_S192803.txt');
    [y,i] = min(currOpti(:,end)); 
    best = currOpti(i,:); bestDV = best(1:26);
    
    % Update ligament Params
    jobParams.seed = 123;
    jobParams.jobCmd = strrep(jobParams.jobCmdTemp, '%SEED%', num2str(jobParams.seed));
    jobParams.jobName = strrep(jobParams.jobNameTemp, '%SEED%', num2str(jobParams.seed));
    updateLigParams(bestDV);
%     updateLigParams(jobParams.guess);
    
    % Run simulations slowly so we don't blow the license server up
    % unnecessarily
    [runflag] = runSimulation_2(jobParams.jobCmd);
%     for i = 1:length(jobParams.jobCmd)
%         system([jobParams.jobCmd{i},' interactive']);
%     end
    
    % Calculate Error
    [rmse,QCFP]=LCCostFun3_S192803(jobParams)
    
    % Scale error for optimization
    err = (jobParams.SCALE_A90*rmse(1)+...
    jobParams.SCALE_AIE90*rmse(2)+...
    jobParams.SCALE_A30*rmse(3)+...
    jobParams.SCALE_AIE30*rmse(4)+...
    jobParams.SCALE_I90*rmse(5)+...
    jobParams.SCALE_IIE90*rmse(6)+...
    jobParams.SCALE_I30*rmse(7)+...
    jobParams.SCALE_IIE30*rmse(8)+...
    jobParams.SCALE_E90*rmse(9)+...
    jobParams.SCALE_EIE90*rmse(10)+...
    jobParams.SCALE_E30*rmse(11)+...
    jobParams.SCALE_EIE30*rmse(12))^QCFP+jobParams.DVWEIGHT*rms((x-jobParams.lb)./(jobParams.ub-jobParams.lb));

    % Delete job seed files
    for i = 1:length(jobParams.jobName)
        temp_files=dir([jobParams.jobName{i},'.*']);
        for counti=1:length(temp_files)
            if contains(temp_files(counti).name,'.odb')
                
            else
                delete(char(temp_files(counti).name))
            end
        end
    end
    error('End of ODB Jobs for Best Design Vector has finished');
end
%% Build Design Vector
% x =
% [(1)ALS_EREF,(2)ALS_K2,(3)ACLpl_EREF,(4)ACLpl_K2,(5)ACLam_EREF,(6)ACLam_K2,(7)LCL_EREF,(8)LCL_K2
% ,(9)MCLA_EREF,(10)MCLM_EREF,(11)MCLP_EREF,(12)MCL_K2,(13)dMCL_EREF,(14)dMCL_K2,(15)POL_EREF,(16)POL_K2
% ,(17)PCAPL_EREF,(18)PCAPL_K2,(19)PCAPM_EREF,(20)PCAPM_K2,(21)PCLal_EREF,(22)PCLal_K2
% ,(23)PCLpm_EREF,(24)PCLpm_K2,(25)PFL_EREF,(26)PFL_K2]
% x = [0.90,36,0.99,108,1.02,106,1.0,197,1.01,1.0,1.0,149,1.0,40,1.01,50 ...
%     ,1.0,90,1.0,90,1.01,36,0.96,42,0.904,31];

DV = x;

jobParams.seed = randi(1e6,1);
jobParams.jobCmd = strrep(jobParams.jobCmdTemp, '%SEED%', num2str(jobParams.seed));
jobParams.jobName = strrep(jobParams.jobNameTemp, '%SEED%', num2str(jobParams.seed));


%% Update Ligament Parameter .inp File
updateLigParams(DV);

%% Run simulations
% Step 1
optim_start_time=tic
if ispc
    [runflag] = runSimulation_2(jobParams.jobCmd);
elseif isunix
    [runflag] = runSimulations_lin(jobParams.jobCmd,jobParams.jobName);
end
toc(optim_start_time)
%% Calculate Error
try
    [rmse,QCFP]=LCCostFun3_S192803(jobParams);
catch 
    warning(['Could not calculate cost function for seed: ' num2str(jobParams.seed) ' assigning err 1e10'])
    QCFP = 1;
    rmse(1)=1e10; %AP
    rmse(2)=1e10; %IE
    rmse(3)=1e10; %VV
    rmse(4)=1e10; %APIE
    rmse(5)=1e10;
    rmse(6)=1e10;
    rmse(7)=1e10; %AP
    rmse(8)=1e10; %IE
    rmse(9)=1e10; %VV
    rmse(10)=1e10; %APIE
    rmse(11)=1e10;
    rmse(12)=1e10;
end

%% Delete job seed files
% Step 1
for i = 1:length(jobParams.jobName)
    delete([jobParams.jobName{i},'.*'])
end

%% Scale error for optimization


err = (jobParams.SCALE_A90*rmse(1)+...
    jobParams.SCALE_AIE90*rmse(2)+...
    jobParams.SCALE_A30*rmse(3)+...
    jobParams.SCALE_AIE30*rmse(4)+...
    jobParams.SCALE_I90*rmse(5)+...
    jobParams.SCALE_IIE90*rmse(6)+...
    jobParams.SCALE_I30*rmse(7)+...
    jobParams.SCALE_IIE30*rmse(8)+...
    jobParams.SCALE_E90*rmse(9)+...
    jobParams.SCALE_EIE90*rmse(10)+...
    jobParams.SCALE_E30*rmse(11)+...
    jobParams.SCALE_EIE30*rmse(12))^QCFP+jobParams.DVWEIGHT*rms((x-jobParams.lb)./(jobParams.ub-jobParams.lb));

%% Write out job vector for debugging purposes
dlmwrite(['designVector_' jobParams.task '_' num2str(jobParams.model) '.txt'],[DV rmse(1) rmse(2) rmse(3) rmse(4) rmse(5) rmse(6) rmse(7) rmse(8) rmse(9) rmse(10) rmse(11) rmse(12) err],'-append')


%% thors debugging and email notification section
    dlmwrite('current_trial_metadata.txt',[fix(clock), rmse(1) rmse(2) rmse(3) rmse(4) rmse(5) rmse(6) rmse(7) rmse(8) rmse(9) rmse(10) rmse(11) rmse(12) err],'-append')
    current_iter=getGlobalCount();
    setGlobalCount(current_iter+1);
    
    bestDV=getGlobalBest();
    if isempty(bestDV)
        bestDV=[DV,err];
        setGlobalBest(bestDV);
    elseif err <= bestDV(end) 
        bestDV=[DV,err];
        setGlobalBest(bestDV);
    end
    dlmwrite('current_trial_metadata.txt',[bestDV],'-append');