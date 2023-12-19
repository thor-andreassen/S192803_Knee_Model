%% clear
clear
close all
clc


%% data
values=-100:.001:100;

%% sigmoid characteristics
inf_sig=1;
neginf_sig=2;
force_norm=12.5;
force_penalty=7.5;
norm_perc=.99;
penalty_perc=.01;
[~,~,~,~,sigmoid_func]=...
    LogisticCurveCoefficients(neginf_sig,inf_sig,penalty_perc,norm_perc,force_penalty,force_norm);
%% regular func
func_func=@(x)(sin(1*x)+1).^(sigmoid_func(x));
values_sigm=arrayfun(sigmoid_func,values);
values_func=arrayfun(func_func,values);

%% plotting
subplot(3,1,1)
plot(values,values_sigm)
subplot(3,1,2)
plot(values,values_func)
subplot(3,1,3)
plot(values(1:end-1),diff(values_func))