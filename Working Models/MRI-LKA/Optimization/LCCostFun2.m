function [rmse,QCFP]=LCCostFun2(jobParams)

% LC Cost Function - AP
TargetAP = dlmread('Target-AP.txt');
TargetAPIE = dlmread('Target-APIE.txt');
TargetIE = dlmread('Target-IE.txt');
TargetIEAP = dlmread('Target-IEAP.txt');
TargetVV = dlmread('Target-VV.txt');
TargetVVIE = dlmread('Target-VVIE.txt');

for i = 1:18
    system(['abaqus python GET_NODAL_COORDS_S1.py ',jobParams.jobName{i},'.odb 1 15 1']);
    junk = dlmread(['data1.txt']);
    gs_nodes(i,:) = junk(end,[2:2:90]);
    
    % Build T,F,P Mats
    gsdata = reshape(gs_nodes(i,:),3,15)';
    
    Ff = gsdata([1,2,5,6],:); Ff = [ones(4,1) Ff];
    Tf = gsdata(7:10,:); Tf = [ones(4,1) Tf];
    Pf = gsdata(11:15,:); Pf = [ones(5,1) Pf];
    
    [F(:,:,i),T(:,:,i),P(:,:,i),Fpts,Tpts,Ppts] = Build_GS_TMAT_DU02(Ff, Tf, Pf);

    % Calculate TF matrix and G&S kinematics
    TF(:,:,i)=(inv(F(:,:,i))*T(:,:,i));
    kin(i,1)=atan(TF(2,3,i)/TF(3,3,i)); %FE angle
    if kin(i,1)<-.5 %To flip sign when flexion goes past 90 degrees
        kin(i,1)=kin(i,1)+pi;
    end
    kin(i,2)=acos(TF(1,3,i))-pi/2; %VV angle
    kin(i,3)=atan(TF(1,2,i)/TF(1,1,i)); %IE angle
    kin(i,4)=TF(1,4,i); %ML translation
    kin(i,5)=TF(2,4,i)*cos(kin(i,1))-TF(3,4,i)*sin(kin(i,1)); %AP translation (text has TF(1,4))
    kin(i,6)=(TF(1,3,i)*TF(1,4,i)+TF(2,3,i)*TF(2,4,i)+TF(3,3,i)*TF(3,4,i)); %SI translation

    kin(i,1:3) = kin(i,1:3).*(180/pi);
    
end

SimAP(1:6) = kin(1:6,5);
SimAPIE(1:6) = kin(1:6,3);
SimIE(1:6) = kin(7:12,3);
SimIEAP(1:6) = kin(7:12,5);
SimVV(1:6) = kin(13:18,2);
SimVVIE(1:6) = kin(13:18,3);

errAP = SimAP - TargetAP;
errAPIE = SimAPIE - TargetAPIE;
errIE = SimIE - TargetIE;
errIEAP = SimIEAP - TargetIEAP;
errVV = SimVV - TargetVV;
errVVIE = SimVVIE - TargetVVIE;
sqerrAP = errAP.^2;
sqerrAPIE = errAPIE.^2;
sqerrIE = errIE.^2;
sqerrIEAP = errIEAP.^2;
sqerrVV = errVV.^2;
sqerrVVIE = errVVIE.^2;

rmse(1) = sqrt(mean(sqerrAP))/(max(TargetAP)-min(TargetAP));
rmse(2) = sqrt(mean(sqerrIE))/(max(TargetIE)-min(TargetIE));
rmse(3) = sqrt(mean(sqerrVV))/(max(TargetVV)-min(TargetVV));
rmse(4) = sqrt(mean(sqerrAPIE))/(max(TargetAPIE)-min(TargetAPIE));
rmse(5) = sqrt(mean(sqerrIEAP))/(max(TargetIEAP)-min(TargetIEAP));
rmse(6) = sqrt(mean(sqerrVVIE))/(max(TargetVVIE)-min(TargetVVIE));

TO_PLOT = 0;

if TO_PLOT
    % 
    FE = [    8.8928, 36.343, 58.242, 55.838, 40.197, 6.7222];
    FE = [FE, 11.109, 40.753, 65.298, 58.685, 35.052, 12.356];
    FE = [FE, 10.047, 41.055, 57.220, 61.002, 41.760, 11.485];
    
    % AP Figure
    f1 = figure(1); 
    subplot(1,2,1); hold on;
    scatter(FE(1:6),SimAP);
    scatter(FE(1:6),TargetAP, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('AP Displacement (mm)')
    title('AP Calibration Targets/Results');
    subplot(1,2,2); hold on;
    scatter(FE(1:6),SimAPIE);
    scatter(FE(1:6),TargetAPIE, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results during AP Lax');
    set(f1,'Position',[200 200 1000 500])
    
    % IE Figure
    f2=figure(2); 
    subplot(1,2,1); hold on;
    scatter(FE(7:12),SimIE);
    scatter(FE(7:12),TargetIE, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results');
    subplot(1,2,2); hold on;
    scatter(FE(7:12),SimIEAP);
    scatter(FE(7:12),TargetIEAP, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('AP Position (mm)')
    title('AP Calibration Targets/Results during IE Laxity');
    set(f2,'Position',[200 200 1000 500])
    
    
    % VV Figure
    f3 = figure(3); 
    subplot(1,2,1); hold on;
    scatter(FE(13:18),SimVV);
    scatter(FE(13:18),TargetVV, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('VV Rotation (deg)')
    title('VV Calibration Targets/Results');
    subplot(1,2,2); hold on;
    scatter(FE(13:18),SimVVIE);
    scatter(FE(13:18),TargetVVIE, ...
              'MarkerEdgeColor',[0 .5 .5],...
              'MarkerFaceColor',[0 .7 .7],...
              'LineWidth',1.5)
    xlabel('FE (deg)');ylabel('IE Rotation (deg)')
    title('IE Calibration Targets/Results during VV Laxity');
    set(f3,'Position',[200 200 1000 500])
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