%% clearing
clear
close all
clc

%% find odbs
files=dir('*.odb');

%% create ligament outputs
frames=[1,16];
step_num=1;
for counti=1:length(files)
    if contains(files(counti).name,'Passive')
        disp('');
    else
        system(['abaqus python GET_ELEMS_CTF1_Sn_FULL_save_v2.py ',files(counti).name]);

    end
end