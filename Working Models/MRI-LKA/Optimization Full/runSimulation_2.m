function [run_flag]=runSimulation_2(jobCmd)

    while(PAUSE_SIMS())
        pause(5)
    end

    run_flag = 0;


    %% Set#1
    tic
    max_simul_threads=14;
    max_simulations=numel(jobCmd);
    completed_simulations=1;
    current_simulations=0;
    
    while completed_simulations<=max_simulations
        if current_simulations <max_simul_threads
            startInfo = System.Diagnostics.ProcessStartInfo('cmd.exe', sprintf('/c "%s"', char(jobCmd{completed_simulations})));
            startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;  %// if you want it invisible
            proc = System.Diagnostics.Process.Start(startInfo);
            completed_simulations=completed_simulations+1;
            pause(2);
        end
        pause(.2);
        current_simulations=numel(dir('*.lck'));
        if toc>1000
            break
        end
    end
    
    while numel(dir('*.lck'))>0
        pause(.5);
        if toc>1000
            break
        end
    end
    
    run_flag=1;
% %     for counti=1:6
% %         startInfo = System.Diagnostics.ProcessStartInfo('cmd.exe', sprintf('/c "%s"', char(jobCmd{counti})));
% %         startInfo.WindowStyle = System.Diagnostics.ProcessWindowStyle.Hidden;  %// if you want it invisible
% %         proc = System.Diagnostics.Process.Start(startInfo);
% %         counter=counter+1;
% %     end
% %     
% %     run_flag=1;

end