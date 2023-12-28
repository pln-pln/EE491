% Parameters
lambda = 0.5;
e = 0.2;
p_values = 0.1: 0.1: 1;  % p values from 0.1 to 1 in steps of 0.1
num_iterations = 1000;
max_battery = 10;
threshold = 1;  % single threshold
    % Simulate the system to calculate the average Age of Information (AoI)
    % for varying energy harvesting probability (p) values.
    %
    % Parameters:
    % - p_values: array of energy harvesting probability values.
    % - num_iterations: number of iterations for the Monte Carlo simulation.
    % - threshold: AoI difference threshold for packet transmission btw transmitter and receiver.
    % - e = channel erasure prob. 1-e means successful delivery
    % - lambda = package arrival rate
    %
    % Returns:
    % - avg_aoi_values: average AoI for each p value.

avg_aoi_values_best_effort = zeros(size(p_values));
avg_aoi_values_single_threshold = zeros(size(p_values));
    
for idx = 1:length(p_values)
    p = p_values(idx);
    total_aoi_best_effort = 0;
    total_aoi_single_threshold = 0;

    for i = 1:num_iterations
        battery_best = 1;
        battery_single = 1;
        aoiT_b = 0;
        aoiT_s = 0;
        aoiR_best_effort = 0;
        aoiR_single_threshold = 0;
        packet_waiting_b = false;
        packet_waiting_s = false;
        total_aoi_for_this_iteration_best_effort = 0;
        total_aoi_for_this_iteration_single_threshold = 0;
       
      
        for t = 1:1000  % assuming 1000 time slots
            % Energy harvesting
            if (rand() < p) && (battery_best < max_battery)
                battery_best = battery_best + 1;
            end
            % Energy harvesting
            if (rand() < p) && (battery_single < max_battery)
                battery_single = battery_single + 1;
            end

            % Packet arrival at the transmitter
            if rand() < lambda
                packet_waiting_b = true;
                aoiT_b = 0; % Reset AoI at the transmitter upon packet arrival
            else
                aoiT_b = aoiT_b + 1; % Increment AoI at the transmitter
            end
            % Packet arrival at the transmitter
            if rand() < lambda
                packet_waiting_s = true;
                aoiT_s = 0; % Reset AoI at the transmitter upon packet arrival
            else
                aoiT_s = aoiT_s + 1; % Increment AoI at the transmitter
            end
            
            
            % Best Effort Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Increase AoI at the receiver
            aoiR_best_effort = aoiR_best_effort + 1;
            if packet_waiting_b && (battery_best > 0)
                if rand() >= e % Successful transmission
                    aoiR_best_effort = aoiT_b; % AoI at receiver is synchronized with the transmitter
                end
                battery_best = battery_best - 1;
                packet_waiting_b = false; % Packet is transmitted, reset packet waiting status
            end
            total_aoi_for_this_iteration_best_effort = total_aoi_for_this_iteration_best_effort + aoiR_best_effort;
            
            
            % Solving for gamma_optimal using Lambert W function (Equation 13)
            c = (1 - lambda) * e;
            phi = (1 - p * e) / (p * (1 - e)) - ...
                  (1 - e) * (1 - lambda) / ((1 - e + lambda * e) * lambda);
            log_c = log(c);
            argument = c * phi / log_c * (1 - e + lambda * e);
            W_val = lambertw(argument); % Lambert W function
            gamma_optimal = phi - 1 / log_c * W_val;

            % Single Threshold Policy %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Increase AoI at the receiver
            aoiR_single_threshold = aoiR_single_threshold + 1;
            if packet_waiting_s && ((aoiR_single_threshold - aoiT_s) >= gamma_optimal )&& (battery_single > 0)
                if rand() >= e % Successful transmission
                    aoiR_single_threshold = aoiT_s; % AoI at receiver is synchronized with the transmitter
                end
                battery_single = battery_single - 1;
                packet_waiting_s = false; % Packet is transmitted, reset packet waiting status
            end
            total_aoi_for_this_iteration_single_threshold = total_aoi_for_this_iteration_single_threshold + aoiR_single_threshold;
           
        end
        
        % Accumulate total AoI for this iteration for both policies
        total_aoi_best_effort = total_aoi_best_effort + total_aoi_for_this_iteration_best_effort / 1000;
        total_aoi_single_threshold = total_aoi_single_threshold + total_aoi_for_this_iteration_single_threshold / 1000;
    end

    % Calculate average AoI for this p value for both policies
    avg_aoi_values_best_effort(idx) = total_aoi_best_effort / num_iterations;
    avg_aoi_values_single_threshold(idx) = total_aoi_single_threshold / num_iterations;
end

% Plotting the results
figure;
plot(p_values, avg_aoi_values_best_effort, 'b-o', p_values, avg_aoi_values_single_threshold, 'r-x');
title('Average AoI vs Energy Harvesting Probability');
xlabel('Energy Harvesting Probability (p)');
ylabel('Average Age of Information (AoI)');
legend('best effort', "optimum threshold");
grid on;
