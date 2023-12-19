%% clear
clear
close all
clc


%% load surface geometry
load('Tibia_Cart.mat');

%% results location
results_folder='C:\Users\Thor.Andreassen\Desktop\Thor Personal Folder\Research\Laxity FE Model\S192803_FE_Model_EBL_Data\Model\S192803_Model_calibration_EBL_v4\Results\';



%% ODB FILE
odb_name='FLEX.odb'
step_name='FLEXION'

Load_type=0;
load_index=5;

%% LOAD COP DATA

baseCMD='abaqus python GET_CONTACT_OUTPUT_surf.py '
COP_filename=[odb_name,'_COP.mat'];
jobCMD=[baseCMD,odb_name,' ',step_name];
[status,cmdout] = system(jobCMD, '-echo');
pause(2);
load(COP_filename)

%% load full pressure patch
CPRESS_filename=[odb_name,'_ContactPressureMap.mat'];
load(CPRESS_filename)

%% load contact area
Carea_filename=[odb_name,'_ContactArea.mat'];
load(Carea_filename)

%% determine COP
COP_Lat=COPTCS(:,2:4);
Force_Lat=Force_Vector_TCS(:,2:4);
[Lat_COP_pt]=getTrialCOP(COP_Lat,Force_Lat,Tib_Lat.faces,Tib_Lat.nodes);

COP_Med=COPTCS(:,5:end);
Force_Med=Force_Vector_TCS(:,5:end);
[Med_COP_pt]=getTrialCOP(COP_Med,Force_Med,Tib_Med.faces,Tib_Med.nodes);


%% Plotting
figure()
%patch surfaces
bone_color=[0.992156863212585,0.917647063732147,0.796078443527222];
patch_lat=patch('Faces',Tib_Lat.faces,'Vertices',Tib_Lat.nodes,...
    'FaceColor',bone_color,'FaceAlpha',1,'EdgeAlpha',.2);
hold on
patch_med=patch('Faces',Tib_Med.faces,'Vertices',Tib_Med.nodes,...
    'FaceColor',bone_color,'FaceAlpha',1,'EdgeAlpha',.2);



%patch the COP
map=[0 1 0;1 1 0;1 0 0];
vals=[0,(size(Med_COP_pt,1)/2)-1,size(Med_COP_pt,1)-1];

colors1=interp1(vals,map(:,1),0:size(Med_COP_pt,1)-1);
colors2=interp1(vals,map(:,2),0:size(Med_COP_pt,1)-1);
colors3=interp1(vals,map(:,3),0:size(Med_COP_pt,1)-1);

colors=[colors1',colors2',colors3'];

for count_pt=1:size(Med_COP_pt,1)
    plot3(Med_COP_pt(count_pt,1),Med_COP_pt(count_pt,2),Med_COP_pt(count_pt,3),'o','Color',colors(count_pt,:),'LineWidth',5);
    hold on
    plot3(Lat_COP_pt(count_pt,1),Lat_COP_pt(count_pt,2),Lat_COP_pt(count_pt,3),'o','Color',colors(count_pt,:),'LineWidth',5);

end
axis equal

colorbar
colormap(colors)
caxis([0,100])





%% load dynamics
baseCMD='abaqus python GET_FORCE_DISPLACEMENT.py '
load_filename=[odb_name,'_GSDynamics.mat'];

jobCMD=[baseCMD,odb_name,' ',step_name,' 0'];
[status,cmdout] = system(jobCMD);



pause(2);
load(load_filename)
Loads(:,5)=-Loads(:,5);
Loads(:,4)=-Loads(:,4);
Loads(:,2)=-Loads(:,2);
Loads(:,1:3)=Loads(:,1:3)/1000;
%% plot motion

fig_cop_kin=figure();
subplot(2,1,1)
plot(gskin(:,1),Lat_COP_pt(:,1),'r')
hold on
plot(gskin(:,1),Med_COP_pt(:,1),'b')
if Load_type==0
    xlabel('F(+)/E (deg)');
else
    if load_index==5
        xlabel('A(+)/P (N)');
    elseif load_index==3
        xlabel('I/E(+) (N*m)');
    elseif load_index==2
        xlabel('Vr/Vl(+) (N*m)');
    end  
end
ylabel('M/L(+) COP (mm)');

subplot(2,1,2)
plot(gskin(:,1),Lat_COP_pt(:,2),'r')
hold on
plot(gskin(:,1),Med_COP_pt(:,2),'b')
legend('Lateral','Medial');
if Load_type==0
    xlabel('F(+)/E (deg)');
else
    if load_index==5
        xlabel('A(+)/P (N)');
    elseif load_index==3
        xlabel('I/E(+) (N*m)');
    elseif load_index==2
        xlabel('Vr/Vl(+) (N*m)');
    end
end
ylabel('A(+)/P COP (mm)');

saveas(fig_cop_kin,[results_folder,odb_name,'_COP_KIN.png']);
saveas(fig_cop_kin,[results_folder,odb_name,'_COP_KIN.fig']);
%% Calculate max values

LAT_PRESS_Max=max(LAT_CP,[],2);
MED_PRESS_Max=max(MED_CP,[],2);

%% max pressure
fig_max_cop=figure();

if Load_type==0
    subplot(2,1,1)
    plot(gskin(:,1),LAT_PRESS_Max,'r')
    hold on
    plot(gskin(:,1),MED_PRESS_Max,'b')
    ylabel('Max Contact Pressure (MPa)');
    legend('Lateral','Medial');

    subplot(2,1,2)
    plot(gskin(:,1),CAREA_LAT(:,2),'r')
    hold on
    plot(gskin(:,1),CAREA_MED(:,2),'b')
    ylabel('Contact Area (mm)');
    legend('Lateral','Medial');
else
    subplot(2,1,1)
    plot(Loads(:,load_index),LAT_PRESS_Max,'r')
    hold on
    plot(Loads(:,load_index),MED_PRESS_Max,'b')
    xlabel('F(+)/E (deg)');
    ylabel('Max Contact Pressure (MPa)');
    legend('Lateral','Medial');
    
    subplot(2,1,2)
    plot(Loads(:,load_index),CAREA_LAT(:,2),'r')
    hold on
    plot(Loads(:,load_index),CAREA_MED(:,2),'b')
    xlabel('F(+)/E (deg)');
    ylabel('Contact Area (mm)');
    legend('Lateral','Medial');
end
if Load_type==0
        xlabel('F(+)/E (deg)');
    else
        if load_index==5
            xlabel('A(+)/P (N)');
        elseif load_index==3
            xlabel('I/E(+) (N*m)');
        elseif load_index==2
            xlabel('Vr/Vl(+) (N*m)');
        end
    end


saveas(fig_max_cop,[results_folder,odb_name,'_COP_CAREA_KIN.png']);
saveas(fig_max_cop,[results_folder,odb_name,'_COP_CAREA_KIN.fig']);
% axis([0,100,0,10])


%% load Ligament loads patch
baseCMD='abaqus python GET_ELEMS_CTF1_Full.py '
lig_filename=[odb_name,'_LigForce.mat'];

jobCMD=[baseCMD,odb_name,' ',step_name,' 0'];
[status,cmdout] = system(jobCMD);

pause(2);



%% Plot Kinematics
fig_kin=figure();
subplot(3,2,1);
plot(gskin(:,1),gskin(:,2));
xlim([0,Inf]);
xlabel('F(+)/E (deg)')
ylabel('Vr/Vl(+) (deg)')

subplot(3,2,3);
plot(gskin(:,1),gskin(:,3));
xlim([0,Inf]);
xlabel('F(+)/E (deg)')
ylabel('I/E(+) (deg)')

subplot(3,2,2);
plot(gskin(:,1),gskin(:,4));
xlim([0,Inf]);
xlabel('F(+)/E (deg)')
ylabel('M/L(+) (mm)')

subplot(3,2,4);
plot(gskin(:,1),gskin(:,5));
xlim([0,Inf]);
xlabel('F(+)/E (deg)')
ylabel('A(+)/P (mm)')

subplot(3,2,6);
plot(gskin(:,1),gskin(:,6));
xlim([0,Inf]);
xlabel('F(+)/E (deg)')
ylabel('S(+)/I (mm)')

saveas(fig_kin,[results_folder,odb_name,'_GSKIN.png']);
saveas(fig_kin,[results_folder,odb_name,'_GSKIN.fig']);


%% Plot Joint Force-Displacement
fig_lax=figure();
subplot(3,1,1);
plot(gskin(:,2),Loads(:,2));
xlabel('Vr/Vl(+) (deg)')
ylabel('Vr/Vl(+) (N*m)')

subplot(3,1,2);
plot(gskin(:,3),Loads(:,3));
xlabel('I/E(+) (deg)')
ylabel('I/E(+) (N*m)')

subplot(3,1,3);
plot(gskin(:,5),Loads(:,5));
xlabel('A(+)/P (deg)')
ylabel('A(+)/P (N)')

saveas(fig_lax,[results_folder,odb_name,'_LAX.png']);
saveas(fig_lax,[results_folder,odb_name,'_LAX.fig']);
%% plot ligament loads
load(lig_filename)
Ligament_Labels.Bundle_Group_Number=str2num(Ligament_Labels.Bundle_Group_Number);
[~,unique_ind]=unique(Ligament_Labels.Bundle_Group_Number);
unique_bundle_names=Ligament_Labels.Bundle(unique_ind,:);
Ligament_Labels.Ligament_Group=str2num(Ligament_Labels.Ligament_Group);


fig_lig=figure()
current_major=0;
symbol=1;
for count_lig=1:size(Ligament_Loads_Combined,2)
    major_lig_number=Ligament_Labels.Ligament_Group(unique_ind(count_lig));
    if current_major==major_lig_number
        symbol=symbol+1;
    else
        symbol=1;
    end
    current_major=major_lig_number;
    if Load_type ==0
        plot(gskin(:,1),Ligament_Loads_Combined(:,count_lig),'Color',getDifferentColor(major_lig_number),'LineWidth',3,'LineStyle',getUniqueLineType(symbol));
    else
        plot(Loads(:,load_index),Ligament_Loads_Combined(:,count_lig),'Color',getDifferentColor(major_lig_number),'LineWidth',3,'LineStyle',getUniqueLineType(symbol));
    end
        hold on
end

    if Load_type==0
        xlabel('F(+)/E (deg)');
    else
        if load_index==5
            xlabel('A(+)/P (N)');
        elseif load_index==3
            xlabel('I/E(+) (N*m)');
        elseif load_index==2
            xlabel('Vr/Vl(+) (N*m)');
        end
    end


ylabel('Ligament Load (N)')
if Load_type==0
    ylim([0,Inf]);
    xlim([0,Inf]);
else
    ylim([0,Inf]);
    xlim([-Inf,Inf]);
end
legend(unique_bundle_names,'Interpreter','none')

saveas(fig_lig,[results_folder,odb_name,'_LigLoad.png']);
saveas(fig_lig,[results_folder,odb_name,'_LigLoad.fig']);






%% resampled Plotting

%patch surfaces
fig_cop_patch=figure();
bone_color=[0.992156863212585,0.917647063732147,0.796078443527222];
patch_lat2=patch('Faces',Tib_Lat.faces,'Vertices',Tib_Lat.nodes,...
    'FaceColor',bone_color,'FaceAlpha',1,'EdgeAlpha',.2);
hold on
patch_med2=patch('Faces',Tib_Med.faces,'Vertices',Tib_Med.nodes,...
    'FaceColor',bone_color,'FaceAlpha',1,'EdgeAlpha',.2);

if Load_type ==0
    FEangles=linspace(ceil(min(gskin(:,1))),floor(max(gskin(:,1))),100);
    FE_min=min(FEangles);
    FE_max=max(FEangles);
    gskin_order=sortrows(gskin,1);
    
    [~,unique_gskin_row]=unique(gskin_order(:,1));
    Med_COP_pt_resamp=interp1(gskin_order(unique_gskin_row,1),Med_COP_pt(unique_gskin_row,:),FEangles);
    Lat_COP_pt_resamp=interp1(gskin_order(unique_gskin_row,1),Lat_COP_pt(unique_gskin_row,:),FEangles);
    
else
    Load_vals=linspace(ceil(min(Loads(:,load_index))),floor(max(Loads(:,load_index))),100);
    if Loads(1,load_index)>0
        Load_vals=fliplr(Load_vals);
    end
    Load_min=min(Load_vals);
    Load_max=max(Load_vals);
    Loads_order=sortrows(Loads,load_index);
    
    [~,unique_load_row]=unique(Loads_order(:,load_index));
    Med_COP_pt_resamp=interp1(Loads_order(unique_load_row,load_index),Med_COP_pt(unique_load_row,:),Load_vals);
    Lat_COP_pt_resamp=interp1(Loads_order(unique_load_row,load_index),Lat_COP_pt(unique_load_row,:),Load_vals);
end

%patch the COP
map=[0 1 0;1 1 0;1 0 0];
vals=[0,(size(Med_COP_pt_resamp,1)/2)-1,size(Med_COP_pt_resamp,1)-1];

colors1=interp1(vals,map(:,1),0:size(Med_COP_pt_resamp,1)-1);
colors2=interp1(vals,map(:,2),0:size(Med_COP_pt_resamp,1)-1);
colors3=interp1(vals,map(:,3),0:size(Med_COP_pt_resamp,1)-1);

colors=[colors1',colors2',colors3'];

for count_pt=1:size(Med_COP_pt_resamp,1)
    plot3(Med_COP_pt_resamp(count_pt,1),Med_COP_pt_resamp(count_pt,2),Med_COP_pt_resamp(count_pt,3),'o','Color',colors(count_pt,:),'LineWidth',5);
    hold on
    plot3(Lat_COP_pt_resamp(count_pt,1),Lat_COP_pt_resamp(count_pt,2),Lat_COP_pt_resamp(count_pt,3),'o','Color',colors(count_pt,:),'LineWidth',5);

end
axis equal

cbar=colorbar;
colormap(colors)


if Load_type ==0
    caxis([FE_min,FE_max])
    ylabel(cbar,'F(+)/E (deg)');
else
    caxis([Load_min,Load_max])
        if load_index==5
            ylabel(cbar,'A(+)/P (N)');
        elseif load_index==3
            ylabel(cbar,'I/E(+) (N*m)');
        elseif load_index==2
            ylabel(cbar,'Vr/Vl(+) (N*m)');
        end
end
saveas(fig_cop_patch,[results_folder,odb_name,'_COPPATH.png']);
saveas(fig_cop_patch,[results_folder,odb_name,'_COPPATH.fig']);

% set(gca, 'XDir','reverse')


