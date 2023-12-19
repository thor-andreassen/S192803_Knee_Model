%% clearing
clear
close all
clc

%% Get passive flex data

system(['abaqus python GET_ELEMS_CTF1_Sn_FULL_save_v2.py ','S192803_MAIN_LAXITY_Passive_Flex.odb']);
% system(['abaqus python GET_ELEMS_CTF1_Sn_FULL_NOACL.py ','S192803_MAIN_LAXITY_Passive_Flex.odb',' 2 181']);