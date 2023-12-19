function [rmse,QCFP,experiment_laxity_trial]=LCCostFun3_S192803(jobParams)

% LC Cost Function - AP
% load('S192803_Laxity_Data_Processed.mat');
load('S192803_EBL_Laxity_Data_Processed_2.mat');
[weight_data]=readtable('S192803_EBL_Weights_test.xlsx');

kin_sim=[];
kin_exp=[];


kin_sim=zeros(numel(jobParams.jobName),6);
kin_exp=zeros(numel(jobParams.jobName),6);
experiment_laxity_trial=[];
for count_trial = 1:numel(jobParams.jobName)
    
    %% get trial kinematics
    system(['abaqus python GET_NODAL_COORDS_LAXITY_v2.py ',jobParams.jobName{count_trial},'.odb 2 4 1280001 1980001 1']);
    
    %% identify trial motion and angle
    if testCharPresentInChar(char(jobParams.jobName{count_trial}),'Anterior')
        lax_type='Anterior';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Internal')
        lax_type='Internal';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'External')
        lax_type='External';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Varus')
        lax_type='Varus';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Valgus')
        lax_type='Valgus';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Posterior')
        lax_type='Posterior';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'FullExt')
        lax_type='FullExt';
    else
        lax_type='';
    end
    
    
    temp_strings=strsplit(char(jobParams.jobName{count_trial}),'_');
    temp_angle=strsplit(char(temp_strings{end-1}),'deg');
    FE_Angle=str2num(char(temp_angle{1}));
    
    
    
    
    
    %% get kinematic data for trial
    experiment_laxity_trial(count_trial).lax_type=lax_type;
    data_raw = dlmread('data1.txt','\t');
    data_raw = data_raw(:,[1,2:2:end]);
    
    times=data_raw;
    
    for count_times=1:size(data_raw,1)
        temp_data = data_raw(count_times,2:end);
        data(:,:,count_times) = reshape(temp_data,3,size(temp_data,2)/3)';
    end
    
    for count_times=1:size(data,3)
        tib_origin=data(1,:,count_times);
        tib_plusx=data(2,:,count_times);
        tib_plusy=data(3,:,count_times);
        tib_plusz=data(4,:,count_times);
        tib_TransMat(:,:,count_times)=getTransMatFromNodes(tib_origin,tib_plusx,tib_plusy,tib_plusz);
        
        fem_origin=data(5,:,count_times);
        fem_plusx=data(6,:,count_times);
        fem_plusy=data(7,:,count_times);
        fem_plusz=data(8,:,count_times);
        fem_TransMat(:,:,count_times)=getTransMatFromNodes(fem_origin,fem_plusx,fem_plusy,fem_plusz);
        tib_to_fem_TransMat(:,:,count_times)=fem_TransMat(:,:,count_times)*inv(tib_TransMat(:,:,count_times));
        gskin_sim(count_times,:)=calculateGSKinFromTransMat(tib_to_fem_TransMat(:,:,count_times),'L');
    end
    
    kin_sim(count_trial,:)=gskin_sim(end,:);
    
    
    
    
    
    %% assign kinematic cost to cost function
    for count_processed_trial=processed_laxity_trial
        if count_processed_trial.FEAngle==FE_Angle && ...
                testCharPresentInChar(count_processed_trial.direction,lax_type)
            current_processed_trial=count_processed_trial;
            valid_trial_found=1;
            break;
        else
            valid_trial_found=0;
        end
    end
    
    
    
    if valid_trial_found==1
        kin_exp(count_trial,:)=current_processed_trial.tf_kin_step2_GS;
        experiment_laxity_trial(count_trial).kin_sim=kin_sim(count_trial,:);
        experiment_laxity_trial(count_trial).kin_exp=kin_exp(count_trial,:);
    else
        disp(['The trial at: ', num2str(count_trial),' cannot be found in the processed trials']);
    end
    
    
    
    for count_weight_trial=1:size(weight_data,1)
        if weight_data.('FEAngle')(count_weight_trial)==FE_Angle && ...
                testCharPresentInChar(weight_data.('TrialType')(count_weight_trial),lax_type)
            current_weight_trial=table2cell(weight_data(count_weight_trial,:));
            break;
        else
            current_weight_trial=num2cell(zeros(1,size(weight_data,2)));
            current_weight_trial{1}='NULL';
        end
    end
    weight_trial_group(count_trial,:)=cell2table(current_weight_trial);
    weight_trial_group.Properties.VariableNames=weight_data.Properties.VariableNames;
    
end


%% Calculate Group Cost function

cost_trials={};
for count_cost=1:size(weight_trial_group,1)
    if ~testCharPresentInChar(char(weight_trial_group.('TrialType')(count_cost)),'NULL')
        group_num=weight_trial_group.('Group')(count_cost);
        if size(cost_trials,2)<group_num
            cost_trials{group_num}={};
        end
        cost_trials{group_num}{end+1,1}=weight_trial_group.('TrialType')(count_cost);
        cost_trials{group_num}{end,2}=kin_sim(count_cost,:);
        cost_trials{group_num}{end,3}=kin_exp(count_cost,:);
        cost_trials{group_num}{end,4}=table2array(weight_trial_group(count_cost,4:end));
    end
end

group_cost=[];
for count_cost=1:size(cost_trials,2)
    current_kin_sim=reshape([cost_trials{count_cost}{:,2}],6,[])';
    current_kin_exp=reshape([cost_trials{count_cost}{:,3}],6,[])';
    
    abs_error=abs(current_kin_sim-current_kin_exp);
    mean_abs_error=mean(abs_error,1);
    if size(current_kin_exp,1)>1
        norm_abs_error=mean_abs_error./(max(current_kin_exp)-min(current_kin_exp));
    else
        norm_abs_error=mean_abs_error;
    end
    current_cost=norm_abs_error*[cost_trials{count_cost}{1,4}]';
    group_cost=[group_cost;current_cost];
end
rmse=group_cost;

% % % % % Want to calculate ligament loading through different poses
% % % % % Extract ligament forces
% % % % 
% % % % for count_trial = 1:length(jobParams.jobName)
% % % %     system(['abaqus python GET_ELEMS_CTF1_Sn_FULL_v2.py ',jobParams.jobName{count_trial},'.odb']);
% % % %     ligforces_raw = dlmread('LigamentForces.txt');
% % % %     fiberforces(count_trial,:) = ligforces_raw(end,[2:2:end]);
% % % % end
% % % % 
% % % % combined_fiberforces = sum(fiberforces,1);
% % % % 
% % % % % Fiber Numbering and order
% % % % %            ACLam       , ACLpl       , ALS                , LCL                , MCLa , MCLm , MCLp , dMCL               , POL         , PCAPL              , PCAPM              , PCLal       , PCLpm       , PFL
% % % % fibernums = [20000, 20001, 20002, 20003, 30000, 30001, 30002, 40000, 40001, 40002, 50000, 50001, 50002, 50006, 50008, 50010, 50012, 50014, 60000, 60001, 60002, 60003, 60004, 60005, 70000, 70001, 70002, 70003, 80003, 80004, 80005];
% % % % excelcheck = [fibernums;combined_fiberforces];
% % % % 
% % % % % Lig forces
% % % % CLF(1) = sum(excelcheck(2,1:2));     %ACLam
% % % % CLF(2) = sum(excelcheck(2,3:4));     %ACLpl
% % % % CLF(3) = sum(excelcheck(2,5:7));     %ALS
% % % % CLF(4) = sum(excelcheck(2,8:10));    %LCL
% % % % CLF(5) = sum(excelcheck(2,11:13));   %sMCL
% % % % CLF(6) = sum(excelcheck(2,14:16));   %dMCL
% % % % CLF(7) = sum(excelcheck(2,17:18));   %POL
% % % % CLF(8) = sum(excelcheck(2,25:26));  %PCLal
% % % % CLF(9) = sum(excelcheck(2,27:28));  %PCLpm
% % % % CLF(10) = sum(excelcheck(2,29:31));  %PFL
% % % % % CLF(11) = sum(excelcheck(2,19:21));   %PCAPL
% % % % % CLF(12) = sum(excelcheck(2,22:24));   %PCAPM
% % % % 
% % % % % If a ligament isn't being used (<10N) add a quadratic cost function
% % % % % penalty (QCFP)
% % % % QCFP = 1;
% % % % for count_trial = 1:length(CLF)
% % % %     if CLF(count_trial)<10
% % % %         QCFP = 2;
% % % %     end
% % % % end

QCFP=1;

end