%% clearing
clear
close all
clc

%% load procesed data
load('S192803_Laxity_Data_Processed.mat')

%% Load Trials
fid = fopen('S192803_JOBNAME.txt');

counter=1;
tline = fgetl(fid);
job_name=strsplit(tline,'_%SEED%');
job_name=char(job_name{1});
jobParams.jobName{counter}=job_name;
counter=counter+1;
while ischar(tline)
    disp(tline)
    tline = fgetl(fid);
    if tline==-1
        break;
    else
        job_name=strsplit(tline,'_%SEED%');
        job_name=char(job_name{1});
        jobParams.jobName{counter}=job_name;
        counter=counter+1;
    end
end

%% Load bounds
jobParams.guess=[0.95,65.412,1.0,59.671,1.0,68.876,.9,150.49,0.7,0.8,0.8,50.39,0.8,40,0.95,34.078,0.9,90,0.92,90,0.85,37.43,0.85,69,1.025,34.283];
jobParams.ub =    [1.25,    140,       1.15,    150,       1.15,    150,       1.15,     200,       0.95,     0.95,     0.95,     180,       0.95,     180,      1.25,     95,      1.25,      100,       1.25,      100,       1.15,     100,       1.15,     100,     1.25,    90];
jobParams.lb =    [0.75,    20,        0.85,    50,        0.85,    50,        0.85,     60,        0.65,     0.75,     0.75,     40,        0.75,     40,       0.75,     30,       0.75,      50,        0.75,      50,        0.85,     30,        0.85,     30,      0.75,    10];


%% Get Kinematics
[err,quad_cost,experimental_laxity_trials]=LCCostFun3_S192803(jobParams);
save('laxity_calibration_data.mat','err','quad_cost','experimental_laxity_trials');
%% Create Plot Categories
unique_angle=unique([experimental_laxity_trials.angle]);
unique_lax_type=unique({experimental_laxity_trials.lax_type});

unique_categories=[];
counter=1;
for count_angle=1:numel(unique_angle)
    for count_lax_type=1:numel(unique_lax_type)
        unique_categories(counter).lax_type=char(unique_lax_type{count_lax_type});
        unique_categories(counter).angle=unique_angle(count_angle);
        counter=counter+1;
    end
end


%% Create Plots
for count_plot_cat=1:numel(unique_categories)
    trial_name=['S192803_Laxity_Calibration_Accuracy_',unique_categories(count_plot_cat).lax_type,...
        num2str(unique_categories(count_plot_cat).angle)];
    fig(count_plot_cat)=figure('name',trial_name);
    for count_trial=1:numel(experimental_laxity_trials)
        if testCharPresentInChar(experimental_laxity_trials(count_trial).lax_type,...
                unique_categories(count_plot_cat).lax_type) && experimental_laxity_trials(count_trial).angle==...
                unique_categories(count_plot_cat).angle
            current_trial=experimental_laxity_trials(count_trial);
            if testCharPresentInChar(current_trial.lax_type,'erior')
                angle_type=0;
            else
                angle_type=1;
            end
            load=current_trial.weight*4.44822;
            if angle_type
                load=load*2.5*0.0254;
            end
            if testCharPresentInChar(current_trial.lax_type,'Post') || ...
                    testCharPresentInChar(current_trial.lax_type,'Int')
                load=-load;
            end
            
            subplot(2,1,1);
            title('Anterior/Posterior Translation');
            xlabel('load');
            ylabel('Translation (mm)');
            hold on
            plot(load,current_trial.kin_sim(5),'bo');
            hold on
            plot(load,current_trial.kin_exp(5),'rx');
            plot([load;load],...
                [current_trial.kin_sim(5);...
                current_trial.kin_exp(5);],'-.')
            legend('Simulation','Experiment','Location','southeast','NumColumns',2);
            
            subplot(2,1,2);
            title('Internal/External Rotation');
            xlabel('load');
            ylabel('Rotation (deg)');
            hold on
            plot(load,current_trial.kin_sim(3),'bo');
            hold on
            plot(load,current_trial.kin_exp(3),'rx');
            plot([load;load],...
                [current_trial.kin_sim(3);...
                current_trial.kin_exp(3);],'-.')
            legend('Simulation','Experiment','Location','southeast','NumColumns',2);

            
        end
    end
    
    subplot(2,1,1)
    x=xlim;
    y=ylim;
    y_size=(y(2)-y(1))*.05;
    if angle_type==0
        str = 'Primary DOF';
        text(x(1),y(1)+y_size,str);
    else
        str = 'Secondary DOF';
        text(x(1),y(1)+y_size,str);
    end
    
    subplot(2,1,2)
    x=xlim;
    y=ylim;
    y_size=(y(2)-y(1))*.05;
    if angle_type==0
        str = 'Secondary DOF';
        text(x(1),y(1)+y_size,str);
    else
        str = 'Primary DOF';
        text(x(1),y(1)+y_size,str);
    end
    
    saveas(fig(count_plot_cat),[trial_name,'.png']);
    saveas(fig(count_plot_cat),[trial_name,'.fig']);
end