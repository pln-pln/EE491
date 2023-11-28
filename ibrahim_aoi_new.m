

lambda=1;
num_of_bits = 100;
R = 200;
num_of_trials = 1e4;
p_values = 0.1:0.05:1;
average_aoi_array = zeros(2,num_of_trials);

peak_aoi_for_p = zeros(1,length(p_values));
base_aoi_for_p = zeros(1,length(p_values));

for p_index=1:1:length(p_values)
    
    peak_aoi = zeros(1,num_of_trials);
    base_aoi = zeros(1,num_of_trials);

    p_current = p_values(p_index);

    for trial_i = 1:1:num_of_trials
        

        local_time = 0;
        sent_successful = 0;
        transmission_time = 0;
        waiting_time = 0;
        age = num_of_bits/R + exprnd(lambda);
        while (sent_successful == 0)
            waiting_time = exprnd(lambda);
            transmission_time = num_of_bits/R;
            age = age + waiting_time + transmission_time;

            if rand() < p_current
                sent_successful = 1;
            end
        end
        
        peak_aoi(trial_i) = age;
        base_aoi(trial_i) = waiting_time+transmission_time;
    end
    
    peak_aoi_for_p(p_index) = mean(peak_aoi);
    base_aoi_for_p(p_index) = mean(base_aoi);
end
average_aoi_for_p = (base_aoi_for_p + peak_aoi_for_p)/2;
figure,
plot(p_values, peak_aoi_for_p,'*')
hold on
peak_aoi_for_p_theory = (num_of_bits/R + 1/lambda) * (1+1./p_values);
plot(p_values, peak_aoi_for_p_theory)
title('peak aoi')

figure,
plot(p_values, average_aoi_for_p,'*')
average_aoi_for_p_theory = (num_of_bits/R + 1/lambda) * (1+1/2./p_values);
hold on
plot(p_values, average_aoi_for_p_theory)
title('average aoi')


