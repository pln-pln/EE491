
mc_mean_all_p = [];
for p_current=0.1:0.1:1;
    p_current
    bits = 1:200;
    mc_means = [];
    for mc = 1:200
        
        lambda=1;
        global_time = 0;
        times = zeros(200,2);
        
        for bit=bits;
            local_time = 0;
            sent_successful = 0;
            transmission_time = 0;
            waiting_time = 0;
            while (sent_successful == 0)
                transmission_time = transmission_time + 0.5;
                rnd_waitingtime = exprnd(lambda);
                waiting_time = waiting_time + rnd_waitingtime;
                if rand() < p_current;
                    sent_successful = 1;
                end
                local_time = local_time + 0.5 + rnd_waitingtime;
            end
            times(bit,:) = [transmission_time, waiting_time];
            global_time = global_time+local_time;
        end

        t = 0;
        
        %plot(aol_x, aol);
        
        res = [];
        global_time_arr_x = 0:0.1:global_time;
        global_time_arr_y = 0:0.1:global_time;
        checks = cumsum(sum(times,2));
        checks = checks(1:end-1);
        for i_idx = 1:numel(checks)
            i = checks(i_idx);
            transmission_time = times(i_idx, 1);
            [~, global_idx] = min(abs(global_time_arr_x-i-transmission_time));
            global_time_arr_y(global_idx: end) = global_time_arr_y(global_idx: end) - (global_time_arr_y(global_idx) - (transmission_time));
        
        end
        
        %plot(global_time_arr_x, global_time_arr_y)
        mc_mean = mean(global_time_arr_y(:));
        mc_means(end+1) = mc_mean;
    end
    mc_mean_all = mean(mc_means);
    mc_mean_all_p(end+1) = mc_mean_all; 
end
% global_time_arr_y(global_idx) -
figure; plot(global_time_arr_x, global_time_arr_y); hold on; 
figure; plot(0.1:0.1:1, mc_mean_all_p); grid on; hold on; plot(0.1:0.001:1, mc_mean_all_p(end)./(0.1:0.001:1))