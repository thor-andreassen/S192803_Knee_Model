function [sol,fval,exitflag,output]=runGlobal(jobParams)

A = [];
b = [];
Aeq = [];
beq = [];


options = optimoptions('simulannealbnd','Display','iter','HybridFcn','fmincon',...
    'InitialTemperature',1000,...
    'PlotFcn',{'saplotbestf','saplotf','saplottemperature'});


[sol,fval,exitflag,output] = simulannealbnd(jobParams.fun,jobParams.guess,jobParams.lb,jobParams.ub,options)


end