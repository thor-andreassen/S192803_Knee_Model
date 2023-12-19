function [x_best,f_best,exitflag,output]=runParticlesSwarm(jobParams)


[x_best,f_best]=particleSwarmThor(jobParams.fun,jobParams.guess,jobParams.lb,jobParams.ub,150,1000);
exitflag=0;
output=1;
end