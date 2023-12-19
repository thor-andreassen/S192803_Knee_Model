function [sol,fval,exitflag,output]=runSimplex(jobParams)

A = [];
b = [];
Aeq = [];
beq = [];

options = optimset('Display','iter' ...
                  ,'TolX',jobParams.TolX ...
                  ,'TolFun',jobParams.TolFun);

[sol,fval,exitflag,output] = fminsearchbnd(jobParams.fun,jobParams.guess,jobParams.lb,jobParams.ub,options)


end