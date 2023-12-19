%% clearing
clear
close all
clc

%%

%[ACLam       , ACLpl       , ALS                , LCL                , MCLa , MCLm , MCLp , dMCL               , POL         , PCAPL              , PCAPM              , PCLal       , PCLpm       , PFL];

%% find files
files='S192803_MAIN_LAXITY_Passive_Flex.odbLigamentForces.txt';

%% create CSV
fid=fopen('S192803_Passive_Flex_Ligament_Forces.csv','w+');


%% create ligament outputs
frames=[1,131];
step_num=1;
for counti=1:1
        tempdata=dlmread(files,'\t');
        for count_frames=1:length(tempdata)
            ligament_data=[0,0,0,0,tempdata(count_frames,2:2:end)];
            fprintf(fid,'test');
            fprintf(fid,', ');
            fprintf(fid,'%d, ',ligament_data);
            fprintf(fid,'\r\n');
        end
end
fclose(fid);
fclose all