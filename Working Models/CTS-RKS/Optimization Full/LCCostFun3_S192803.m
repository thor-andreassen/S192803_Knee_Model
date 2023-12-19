function [rmse,QCFP,experiment_laxity_trial]=LCCostFun3_S192803(jobParams)

% LC Cost Function - AP
load('S192803_Laxity_Data_Processed.mat');

kin_sim=[];
kin_exp=[];


A30=[];
AIE30=[];
E30=[];
EAP30=[];
I30=[];
IAP30=[];
A90=[];
AIE90=[];
E90=[];
EAP90=[];
I90=[];
IAP90=[];

kin_sim=zeros(numel(jobParams.jobName),6);
kin_exp=zeros(numel(jobParams.jobName),6);
experiment_laxity_trial=[];
for count_trial = 1:numel(jobParams.jobName)
    system(['abaqus python GET_NODAL_COORDS_LAXITY_v2.py ',jobParams.jobName{count_trial},'.odb 2 4 1280001 1980001 1']);
    if testCharPresentInChar(char(jobParams.jobName{count_trial}),'30deg')
        angle=30;
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'90deg')
        angle=90;
    else
        angle=NaN;
    end
    experiment_laxity_trial(count_trial).angle=angle;
    
    
    temp_str=strsplit(char(jobParams.jobName{count_trial}),'.inp');
    temp_str=strsplit(char(temp_str(1)),'_');
    weight_load=str2num(char(temp_str(6)));
    experiment_laxity_trial(count_trial).weight=weight_load;
    
    if testCharPresentInChar(char(jobParams.jobName{count_trial}),'Anterior')
        lax_type='Anterior';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Internal')
        lax_type='Internal';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'External')
        lax_type='External';
    elseif testCharPresentInChar(char(jobParams.jobName{count_trial}),'Posterior')
        lax_type='Posterior';
    else
        lax_type='';
    end
    
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
    for count_processed_trial=processed_laxity_trial
        if count_processed_trial.angle==angle && ...
                count_processed_trial.weight_load==weight_load && ...
                testCharPresentInChar(count_processed_trial.laxity_type,lax_type)
            current_processed_trial=count_processed_trial;
            break;
        end
    end
    
    
    %% assign kinematic cost to cost function
    
    kin_exp(count_trial,:)=current_processed_trial.tf_kin_step2_GS;
    if testCharPresentInChar(lax_type,'Anterior')
        if angle==90
            A90=[A90,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
            AIE90=[AIE90,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
        elseif angle==30
            A30=[A30,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
            AIE30=[AIE30,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
        end
    elseif testCharPresentInChar(lax_type,'Internal')
        if angle==90
            I90=[I90,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
            IAP90=[IAP90,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
        elseif angle==30
            I30=[I30,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
            IAP30=[IAP30,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
        end
    elseif testCharPresentInChar(lax_type,'External')
        if angle==90
            E90=[E90,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
            EAP90=[EAP90,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
        elseif angle==30
            E30=[E30,abs(kin_sim(count_trial,3)-kin_exp(count_trial,3))];
            EAP30=[EAP30,abs(kin_sim(count_trial,5)-kin_exp(count_trial,5))];
        end
    end
    experiment_laxity_trial(count_trial).kin_sim=kin_sim(count_trial,:);
    experiment_laxity_trial(count_trial).kin_exp=kin_exp(count_trial,:);
end
FE=kin_sim(:,1);

rmse(1) = sqrt(mean(A90))/(max(kin_exp(:,5))-min(kin_exp(:,5)));
rmse(2) = sqrt(mean(AIE90))/(max(kin_exp(:,3))-min(kin_exp(:,3)));
rmse(3) = sqrt(mean(A30))/(max(kin_exp(:,5))-min(kin_exp(:,5)));
rmse(4) = sqrt(mean(AIE30))/(max(kin_exp(:,3))-min(kin_exp(:,3)));

rmse(5) = sqrt(mean(I90))/(max(kin_exp(:,3))-min(kin_exp(:,3)));
rmse(6) = sqrt(mean(IAP90))/(max(kin_exp(:,5))-min(kin_exp(:,5)));
rmse(7) = sqrt(mean(I30))/(max(kin_exp(:,3))-min(kin_exp(:,3)));
rmse(8) = sqrt(mean(IAP30))/(max(kin_exp(:,5))-min(kin_exp(:,5)));

rmse(9) = sqrt(mean(E90))/(max(kin_exp(:,3))-min(kin_exp(:,3)));
rmse(10) = sqrt(mean(EAP90))/(max(kin_exp(:,5))-min(kin_exp(:,5)));
rmse(11) = sqrt(mean(E30))/(max(kin_exp(:,3))-min(kin_exp(:,3)));
rmse(12) = sqrt(mean(EAP30))/(max(kin_exp(:,5))-min(kin_exp(:,5)));

error_fid=fopen('trial_error_S192803.txt','a+');
out_vals=[A90,A30,I90,I30,E90,E30];
fprintf(error_fid, [repmat('%f,', 1, length(out_vals)),'\r\n'], out_vals);
fclose(error_fid);

TO_PLOT = 0;

if TO_PLOT
    %
    
    
    
    % AP Figure
    f1 = figure(1);
    clf(f1)
    subplot(3,2,1); hold on;
    scatter(FE(1:8),SimAP);
    scatter(FE(1:8),TargetAP, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5);
    xlabel('FE (deg)');ylabel('AP Displacement (mm)')
    title('AP Calibration Targets/Results');
    subplot(3,2,2); hold on;
    scatter(FE(1:8),SimAPIE);
    scatter(FE(1:8),TargetAPIE, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5);
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results during AP Lax');
    set(f1,'Position',[150 150 750 750])
    
    % IE Figure
    subplot(3,2,3); hold on;
    scatter(FE(9:16),SimIE);
    scatter(FE(9:16),TargetIE, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results');
    subplot(3,2,4); hold on;
    scatter(FE(9:16),SimIEAP);
    scatter(FE(9:16),TargetIEAP, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5);
    xlabel('FE (deg)');ylabel('AP Position (mm)')
    title('AP Calibration Targets/Results during IE Laxity');
    
    
    % VV Figure
    subplot(3,2,5); hold on;
    scatter(FE(17:24),SimVV);
    scatter(FE(17:24),TargetVV, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5);
    xlabel('FE (deg)');ylabel('VV Rotation (deg)')
    title('VV Calibration Targets/Results');
    subplot(3,2,6); hold on;
    scatter(FE(17:24),SimVVIE);
    scatter(FE(17:24),TargetVVIE, ...
        'MarkerEdgeColor',[0 .5 .5],...
        'MarkerFaceColor',[0 .7 .7],...
        'LineWidth',1.5);
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results during VV Laxity');
end

% Want to calculate ligament loading through different poses
% Extract ligament forces

for count_trial = 1:length(jobParams.jobName)
    system(['abaqus python GET_ELEMS_CTF1_Sn_FULL_v2.py ',jobParams.jobName{count_trial},'.odb']);
    ligforces_raw = dlmread('LigamentForces.txt');
    fiberforces(count_trial,:) = ligforces_raw(end,[2:2:end]);
end

combined_fiberforces = sum(fiberforces,1);

% Fiber Numbering and order
%            ACLam       , ACLpl       , ALS                , LCL                , MCLa , MCLm , MCLp , dMCL               , POL         , PCAPL              , PCAPM              , PCLal       , PCLpm       , PFL
fibernums = [20000, 20001, 20002, 20003, 30000, 30001, 30002, 40000, 40001, 40002, 50000, 50001, 50002, 50006, 50008, 50010, 50012, 50014, 60000, 60001, 60002, 60003, 60004, 60005, 70000, 70001, 70002, 70003, 80003, 80004, 80005];
excelcheck = [fibernums;combined_fiberforces];

% Lig forces
CLF(1) = sum(excelcheck(2,1:2));     %ACLam
CLF(2) = sum(excelcheck(2,3:4));     %ACLpl
CLF(3) = sum(excelcheck(2,5:7));     %ALS
CLF(4) = sum(excelcheck(2,8:10));    %LCL
CLF(5) = sum(excelcheck(2,11:13));   %sMCL
CLF(6) = sum(excelcheck(2,14:16));   %dMCL
CLF(7) = sum(excelcheck(2,17:18));   %POL
CLF(8) = sum(excelcheck(2,25:26));  %PCLal
CLF(9) = sum(excelcheck(2,27:28));  %PCLpm
CLF(10) = sum(excelcheck(2,29:31));  %PFL
% CLF(11) = sum(excelcheck(2,19:21));   %PCAPL
% CLF(12) = sum(excelcheck(2,22:24));   %PCAPM

% If a ligament isn't being used (<10N) add a quadratic cost function
% penalty (QCFP)
QCFP = 1;
for count_trial = 1:length(CLF)
    if CLF(count_trial)<10
        QCFP = 2;
    end
end

end