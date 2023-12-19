%% clearing
clear
close all
clc

%%

%[ACLam       , ACLpl       , ALS                , LCL                , MCLa , MCLm , MCLp , dMCL               , POL         , PCAPL              , PCAPM              , PCLal       , PCLpm       , PFL];

data=dlmread('MAIN_OKS03_LAX_VV_5_123.odbLigamentForces.txt','\t');

data_index=[1,2:2:length(data)];
data=data(1:16,data_index);

times=data(:,1);
ACLam_indices=(1:2)+1;
ACLpl_indices=(3:4)+1;
ALS_indices=(5:7)+1;
LCL_indices=(8:10)+1;
MCL_indices=(11:13)+1;
dMCL_indices=(14:16)+1;
POL_indices=(17:18)+1;
PCAPL_indices=(19:21)+1;
PCAPM_indices=(22:24)+1;
PCLal_indices=(25:26)+1;
PCLpm_indices=(27:28)+1;
PFL_indices=(29:31)+1;

figure()

plot(times,data(:,ACLam_indices))
hold on
plot(times,data(:,ACLpl_indices))
title('ACL')
figure()

plot(times,data(:,PCLal_indices))
hold on
plot(times,data(:,PCLpm_indices))
title('PCL')
figure()

plot(times,data(:,LCL_indices))
title('LCL')
figure()

plot(times,data(:,MCL_indices))
hold on
plot(times,data(:,dMCL_indices))
title('MCL')
legend()

figure()
plot(times,data(:,ALS_indices))
hold on
title('ALS')

figure()
plot(times,data(:,PFL_indices))
hold on
title('PFL')