function [rmse,QCFP]=LCCostFun(jobParams)

% LC Cost Function - AP
TargetAP = dlmread('Target-AP.txt');
TargetAPIE = dlmread('Target-APIE.txt');
TargetIE = dlmread('Target-IE.txt');
TargetVV = dlmread('Target-VV.txt');
APCONN = 1980011;
IECONN = 1980010;
VVCONN = 1980011;

for i = 1:6
    system(['abaqus python GET_ELEM_CTF1_Sn.py ',jobParams.jobName{i},'.odb ',num2str(APCONN),' 1 > junk.txt']);
    junk = dlmread('junk.txt'); SimAP(i)=junk(end,2);
    
    system(['abaqus python GET_ELEM_CTM1_Sn.py ',jobParams.jobName{i},'.odb ',num2str(IECONN),' 1 > junk.txt']);
    junk = dlmread('junk.txt'); SimAPIE(i)=-1*junk(end,2);
end

ind = 1;
for i = 7:12
    system(['abaqus python GET_ELEM_CTM1_Sn.py ',jobParams.jobName{i},'.odb ',num2str(IECONN),' 1 > junk.txt']);
    junk = dlmread('junk.txt'); SimIE(ind)=-1*junk(end,2);
    ind = ind+1;
end

ind = 1;
for i = 13:18
    system(['abaqus python GET_ELEM_CTM1_Sn.py ',jobParams.jobName{i},'.odb ',num2str(VVCONN),' 1 > junk.txt']);
    junk = dlmread('junk.txt'); SimVV(ind)=-1*junk(end,2);
    ind = ind+1;
end

errAP = SimAP - TargetAP;
errAPIE = SimAPIE - TargetAPIE;
errIE = SimIE - TargetIE;
errVV = SimVV - TargetVV;
sqerrAP = errAP.^2;
sqerrAPIE = errAPIE.^2;
sqerrIE = errIE.^2;
sqerrVV = errVV.^2;

rmse(1) = sqrt(mean(sqerrAP));
rmse(2) = sqrt(mean(sqerrIE));
rmse(3) = sqrt(mean(sqerrVV));
rmse(4) = sqrt(mean(sqerrAPIE));

TO_PLOT = 0;

if TO_PLOT
    % 
    FE = [    8.8928, 36.343, 58.242, 55.838, 40.197, 6.7222];
    FE = [FE, 11.109, 40.753, 65.298, 58.685, 35.052, 12.356];
    FE = [FE, 10.047, 41.055, 57.220, 61.002, 41.760, 11.485];
    
    % AP Figure
    figure(1); hold on;
    scatter(FE(1:6),SimAP);
    scatter(FE(1:6),TargetAP, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('AP Reaction Force (N)')
    title('AP Calibration Targets/Results');
    
    % IE Figure
    figure(2); hold on;
    scatter(FE(7:12),SimIE./1000);
    scatter(FE(7:12),TargetIE./1000, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Reaction Torque (Nm)')
    title('IE Calibration Targets/Results');
    
    % VV Figure
    figure(3); hold on;
    scatter(FE(13:18),SimVV./1000);
    scatter(FE(13:18),TargetVV./1000, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('VV Reaction Torque (Nm)')
    title('VV Calibration Targets/Results');
    
     % APIE Figure
    figure(4); hold on;
    scatter(FE(1:6),SimAPIE./1000);
    scatter(FE(1:6),TargetAPIE./1000, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Reaction Torque(Nm)')
    title('IE Calibration Targets/Results during AP Lax');
    
    
end

% Want to calculate ligament loading through different poses
% Extract ligament forces
nFrames = 126;

for i = 1:length(jobParams.jobName)
    system(['abaqus python GET_ELEMS_CTF1_Sn_FULL.py ',jobParams.jobName{i},'.odb 1 ',num2str(nFrames)]);
    ligforces_raw = dlmread('LigamentForces.txt');
    
    for j = 2:size(ligforces_raw,1)
        if (ligforces_raw(j,1)==0)
            fiberforces(i,:) = ligforces_raw(j-1,[2:2:end]);
            break
        end
        
    end
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
for i = 1:length(CLF)
   if CLF(i)<10
       QCFP = 2;
   end
end

end