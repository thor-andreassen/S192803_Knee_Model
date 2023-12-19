function [run_flag]=runSimulations_lin(jobCmds,jobName)


while(PAUSE_SIMS)
    pause(5)
end
       
run_flag=0;

tic




for i = 1:10 %length(jobCmds)
    [status,cmdout] = system([jobCmds{i}]);
    pause(.5)
end
pause(5)


for i = 1:length(jobCmds)
    while (exist([jobName{i} '.lck'],'file')==2)
        pause(1)
        
        %let's blow this popcicle stand if longer than 5 min
        if (toc>500)
            fprintf(['Toc>300 for JobCmd: ' jobCmds{i}])
            return
        end
    end
end





for i = 11:20
    [status,cmdout] = system([jobCmds{i}]);
    pause(.5)
end
pause(5)


for i = 1:length(jobCmds)
    while (exist([jobName{i} '.lck'],'file')==2)
        pause(1)
        
        %let's blow this popcicle stand if longer than 5 min
        if (toc>500)
            fprintf(['Toc>300 for JobCmd: ' jobCmds{i}])
            return
        end
    end
end



for i = 21:length(jobCmds)
    [status,cmdout] = system([jobCmds{i}]);
    pause(.5)
end
pause(5)


for i = 1:length(jobCmds)
    while (exist([jobName{i} '.lck'],'file')==2)
        pause(1)
        
        %let's blow this popcicle stand if longer than 5 min
        if (toc>500)
            fprintf(['Toc>300 for JobCmd: ' jobCmds{i}])
            return
        end
    end
end




run_flag=1;

% Give simulation a bit of time to pack up
pause(3)

end