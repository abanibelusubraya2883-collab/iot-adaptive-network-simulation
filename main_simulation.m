clc; clear; close all;

%% ------------------ INITIAL SETUP ------------------ %%
numNodes = 50;              % Number of IoT nodes
areaSize = 100;            % Area size (100x100)
timeSteps = 50;            % Simulation time

% Node positions
nodeX = rand(1, numNodes) * areaSize;
nodeY = rand(1, numNodes) * areaSize;

% Initial Energy
initialEnergy = 100;
energy_static = ones(1, numNodes) * initialEnergy;
energy_adaptive = ones(1, numNodes) * initialEnergy;

% Transmission parameters
range = 30;
tx_interval_static = 5;
tx_interval_adaptive = 5;

tx_energy_static = 0.5;
tx_energy_adaptive = 0.5;

%% ------------------ STORAGE ------------------ %%
energy_hist_static = zeros(1, timeSteps);
energy_hist_adaptive = zeros(1, timeSteps);

PDR_static = zeros(1, timeSteps);
PDR_adaptive = zeros(1, timeSteps);

latency_static = zeros(1, timeSteps);
latency_adaptive = zeros(1, timeSteps);

throughput_static = zeros(1, timeSteps);
throughput_adaptive = zeros(1, timeSteps);

%% ------------------ SIMULATION ------------------ %%
for t = 1:timeSteps

    %% ----------- STATIC MODEL ----------- %%
    success = 0;
    total = 0;
    
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                dist = sqrt((nodeX(i)-nodeX(j))^2 + (nodeY(i)-nodeY(j))^2);
                
                if dist <= range
                    success = success + 1;
                end
                total = total + 1;
            end
        end
    end
    
    % Metrics
    PDR_static(t) = success / total;
    latency_static(t) = tx_interval_static * (numNodes / 10);
    throughput_static(t) = success / tx_interval_static;
    
    % Energy update
    energy_static = energy_static - tx_energy_static;
    energy_static(energy_static < 0) = 0;
    
    energy_hist_static(t) = sum(energy_static);
    
    
    %% ----------- ADAPTIVE MODEL ----------- %%
    
    % --- HYBRID RULES ---
    
    % Rule 1: Node density adjustment
    if numNodes > 70
        tx_interval_adaptive = 8;
    elseif numNodes < 30
        tx_interval_adaptive = 3;
    else
        tx_interval_adaptive = 5;
    end
    
    % Rule 2: Range-based power adjustment
    if range < 20
        tx_energy_adaptive = 0.7;
    else
        tx_energy_adaptive = 0.4;
    end
    
    % Rule 3: Simple protocol switching logic (simulated)
    % LoRa → long range, low energy
    % Zigbee → short range, low latency
    % NB-IoT → reliable but higher energy
    
    if range > 40
        protocol_factor = 0.8;   % LoRa-like
    elseif range < 20
        protocol_factor = 1.2;   % NB-IoT-like
    else
        protocol_factor = 1.0;   % Zigbee-like
    end
    
    success2 = 0;
    total2 = 0;
    
    for i = 1:numNodes
        for j = 1:numNodes
            if i ~= j
                dist = sqrt((nodeX(i)-nodeX(j))^2 + (nodeY(i)-nodeY(j))^2);
                
                if dist <= range
                    success2 = success2 + protocol_factor;
                end
                total2 = total2 + 1;
            end
        end
    end
    
    % Metrics
    PDR_adaptive(t) = success2 / total2;
    latency_adaptive(t) = tx_interval_adaptive * (numNodes / 12);
    throughput_adaptive(t) = success2 / tx_interval_adaptive;
    
    % Energy update
    energy_adaptive = energy_adaptive - tx_energy_adaptive;
    energy_adaptive(energy_adaptive < 0) = 0;
    
    energy_hist_adaptive(t) = sum(energy_adaptive);
    
end

%% ------------------ PLOTS ------------------ %%

% Energy Comparison
figure;
plot(energy_hist_static, '--', 'LineWidth', 2);
hold on;
plot(energy_hist_adaptive, 'LineWidth', 2);
xlabel('Time');
ylabel('Total Energy');
title('Energy Consumption Comparison');
legend('Static','Adaptive');

% PDR Comparison
figure;
plot(PDR_static, '--', 'LineWidth', 2);
hold on;
plot(PDR_adaptive, 'LineWidth', 2);
xlabel('Time');
ylabel('PDR');
title('Packet Delivery Ratio');
legend('Static','Adaptive');

% Latency Comparison
figure;
plot(latency_static, '--', 'LineWidth', 2);
hold on;
plot(latency_adaptive, 'LineWidth', 2);
xlabel('Time');
ylabel('Latency');
title('Latency Comparison');
legend('Static','Adaptive');

% Throughput Comparison
figure;
plot(throughput_static, '--', 'LineWidth', 2);
hold on;
plot(throughput_adaptive, 'LineWidth', 2);
xlabel('Time');
ylabel('Throughput');
title('Throughput Comparison');
legend('Static','Adaptive');

%% ------------------ FINAL TABLE ------------------ %%
fprintf('\n===== FINAL RESULTS =====\n');

fprintf('Static Energy Remaining: %.2f\n', energy_hist_static(end));
fprintf('Adaptive Energy Remaining: %.2f\n', energy_hist_adaptive(end));

fprintf('Static Avg PDR: %.2f\n', mean(PDR_static));
fprintf('Adaptive Avg PDR: %.2f\n', mean(PDR_adaptive));

fprintf('Static Avg Latency: %.2f\n', mean(latency_static));
fprintf('Adaptive Avg Latency: %.2f\n', mean(latency_adaptive));

fprintf('Static Avg Throughput: %.2f\n', mean(throughput_static));
fprintf('Adaptive Avg Throughput: %.2f\n', mean(throughput_adaptive));