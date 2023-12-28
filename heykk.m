% Function to calculate average AoI for varying battery sizes


% Common parameters
num_iterations = 1000;
threshold = 1;
max_battery_values = 1:1:30;  % Battery sizes from 0 to 30 in steps of 2

% First Graph: e=0.2, p=0.5, lambda= 0.5, 0.8, 1
e = 0.2; p = 0.5; lambda_values = [0.5, 0.8, 1];
figure; hold on;
for lambda = lambda_values
    avg_aoi_values = calculate_avg_aoi_battery(lambda, e, p, num_iterations, max_battery_values, threshold);
    plot(max_battery_values, avg_aoi_values, 'o-', 'DisplayName', sprintf('lambda = %.1f', lambda));
end
title('Graph 1: Average AoI vs Max Battery Size (e=0.2, p=0.5)');
xlabel('Maximum Battery Size'); ylabel('Average Age of Information (AoI)');
legend; grid on;

% Second Graph: lambda= 0.5, e=0.2, p= 0.2, 0.4, 0.6
lambda = 0.5; e = 0.2; p_values = [0.2, 0.4, 0.6];
figure; hold on;
for p = p_values
    avg_aoi_values = calculate_avg_aoi_battery(lambda, e, p, num_iterations, max_battery_values, threshold);
    plot(max_battery_values, avg_aoi_values, 'o-', 'DisplayName', sprintf('p = %.1f', p));
end
title('Graph 2: Average AoI vs Max Battery Size (lambda=0.5, e=0.2)');
xlabel('Maximum Battery Size'); ylabel('Average Age of Information (AoI)');
legend; grid on;

% Third Graph: lambda= 0.5, p=0.5, e= 0.1, 0.3, 0.5
lambda = 0.5; p = 0.5; e_values = [0.1, 0.3, 0.5];
figure; hold on;
for e = e_values
    avg_aoi_values = calculate_avg_aoi_battery(lambda, e, p, num_iterations, max_battery_values, threshold);
    plot(max_battery_values, avg_aoi_values, 'o-', 'DisplayName', sprintf('e = %.1f', e));
end
title('Graph 3: Average AoI vs Max Battery Size (lambda=0.5, p=0.5)');
xlabel('Maximum Battery Size'); ylabel('Average Age of Information (AoI)');
legend; grid on;
% Function to calculate average AoI for varying battery sizes
function avg_aoi_values = calculate_avg_aoi_battery(lambda, e, p, num_iterations, max_battery_values, threshold)
    avg_aoi_values = zeros(size(max_battery_values));
    for idx = 1:length(max_battery_values)
        max_battery = max_battery_values(idx);
        total_aoi = 0;
        for i = 1:num_iterations
            battery = max_battery;  % Initialize battery to max capacity
            aoiT = 0;
            aoiR = 0;
            packet_waiting = false;
            for t = 1:1000
                if rand() < p && battery < max_battery
                    battery = battery + 1;
                end
                if rand() < lambda
                    packet_waiting = true;
                    aoiT = 0;
                else
                    aoiT = aoiT + 1;
                end
                aoiR = aoiR + 1;
                if packet_waiting && (aoiR - aoiT) >= threshold && battery > 0
                    if rand() >= e
                        aoiR = aoiT;
                    end
                    battery = battery - 1;
                    packet_waiting = false;
                end
                total_aoi = total_aoi + aoiR;
            end
        end
        avg_aoi_values(idx) = total_aoi / (num_iterations * 1000);
    end
end

% Rest of the code for plotting graphs remains the same
