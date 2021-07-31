% Additional experiment: respiration rate of signals collected with the smartphone placed at position 2
% with a respiratory frequency of 0.16 Hz for 12 cycles of inhalation and exhalation 

%% Recording of LSM6DS3 accelerometer (STMicroelectronics) signals
% datasheet: https://www.st.com/resource/en/datasheet/lsm6ds3.pdf
% file: signals/pos2_accelerometer_data_6sbreathing.txt
%
% They were recorded with a sampling rate of 202 Hz and 
% a resolution of 0.244 mg/LSB

fprintf('Loading of pos2_accelerometer_data_6sbreathing.txt  \n');
load signals/pos2_accelerometer_data_6sbreathing.txt % data composed by the following columns: time, gFx, gFy, gFz, TgF

%% Data acquisition step
fprintf('*Data acquisition step*  \n');

% remove time values duplicated
[~,uidx] = unique(pos2_accelerometer_data_6sbreathing(:,1),'stable');
pos2_accelerometer_data = pos2_accelerometer_data_6sbreathing(uidx,:);

% remove first 1010 rows (first 5 seconds of recording)
pos2_accelerometer_data(1:1010,:) = [];

% length of accelerometer_data
pos2_accelerometer_data_length = length(pos2_accelerometer_data);

% remove last 1010 rows (last 5 seconds of recording)
pos2_accelerometer_data(pos2_accelerometer_data_length-1010:pos2_accelerometer_data_length,:) = [];

% take the time axis
pos2_timeAxis = pos2_accelerometer_data(:,1);

% we want the signal in mG:
resolution = 0.244; % mg/LSB
fprintf('Application resolution: %.3f mg/LSB \n', resolution);
pos2_accelerometer_data= pos2_accelerometer_data * resolution;

%% Pre-processing step
% Plotting all the signals collected

fprintf('*Pre-processing step*  \n');

figure(1)
signals_plotting(pos2_accelerometer_data, pos2_timeAxis, 'Pos2-accelerometer-data-6sbreathing')

%% Respiratory frequency detection step
% reference: https://doi.org/10.22489/CinC.2017.137-402

fprintf('*RESPIRATORY FREQUENCY DETECTION*  \n');

%% Design a 4th-order lowpass Butterworth filter with a cut-off frequency of 0.5 Hz

fs = 202; % sampling rate at which the application samples the signals
fc = 0.5;  % cut frequency fixed at 0.5 Hz
fc_rad = fc/(fs/2); % cut frequency converted into 0.00495 rad/sample
n_order = 4; % order of the Butterworth filter

fprintf('Design of %d order Butterworth filter with %d Hz as sampling rate and %.1f Hz as cut frequency \n', n_order, fs, fc);
[b,a] = butter(n_order, fc_rad, 'low'); % get Transfer function coefficients of the 
                                        % 4th-order lowpass Butterworth filter

% plot magnitude and phase
figure(2)                                    
freqz(b, a) 
                                    
pos2_accelerometer_data_filtered = filter(b, a, pos2_accelerometer_data); % apply the filter                                                                            

% plot the original data and the filtered data
figure(3)
signals_filtered_plotting(pos2_accelerometer_data, pos2_accelerometer_data_filtered, pos2_timeAxis, 'Pos2-accelerometer-data-6sbreathing')

% plot the y axis of the original and the filtered data
pos2_y = pos2_accelerometer_data(:,3);
pos2_y_filtered = pos2_accelerometer_data_filtered(:,3);
figure(4)
yAxis_filtered_plotting(pos2_y, pos2_y_filtered, pos2_timeAxis, 'Pos2-accelerometer-data-6sbreathing')


%% Time domain analysis: Detection of minima of y axis of the filtered acceleration data

half_breath_duration = 3; % 3 seconds represent half of the entire breath duration

fprintf('*Time-domain analysis* \n');
fprintf('Detection of minima of y axis of the filtered acceleration data \n');
local_minima_indexes = islocalmin(pos2_y_filtered, 'MinSeparation', half_breath_duration, 'SamplePoints', pos2_timeAxis);
local_minima = pos2_y_filtered(local_minima_indexes);
time_local_minima = pos2_timeAxis(local_minima_indexes);

figure(5)
plot(pos2_timeAxis,pos2_y_filtered,'g', time_local_minima, local_minima,'r.', 'MarkerSize',20)
title('Pos1-accelerometer-data-6sbreathing filtered - minima detection')
xlabel('time (s)')
ylabel('Y (mg/LSB)')

%% Time domain analysis: respiratory frequency computation

fprintf('Detection of respiratory intervals \n');
respiratory_intervals = abs(diff(time_local_minima));

respiratory_frequency = 1/mean(respiratory_intervals);
fprintf('Respiratory frequency detected: %.4f Hz \n', respiratory_frequency);

breath_duration = 1/respiratory_frequency;
fprintf('Breath duration detected: %.4f s \n', breath_duration);

%% Frequency domain analysis: computation of PSDls (Lomb-Scargle Power Spectral Density)

fprintf('*Frequency-domain analysis* \n');

figure(6)
plomb(pos2_y_filtered, pos2_timeAxis, fs) % include frequencies up to 202 Hz

df = 1/fs; % fine grid with a spacing of 1/202 (0.00495)s 
fvec = 0.05:df:0.5; % input frequencies (only frequencies we want to consider for zooming)
figure(7)
plomb(pos2_y_filtered,pos2_timeAxis,fvec)
df_str = sprintf('df = %.4f',df);
legend(df_str)
hold off

fprintf('Computation of PSDls (Lomb-Scargle Power Spectral Density) \n');
[pxx,f] = plomb(pos2_y_filtered,pos2_timeAxis,fvec); 

%% Frequency domain analysis: respiratory frequency computation

fprintf('Detection of the maximum peak of the Lomb-Scargle Periodogram of y axis of the filtered acceleration data \n');
[maximum_peak, maximum_peak_index] = max(plomb(pos2_y_filtered,pos2_timeAxis,fvec));

figure(8)
semilogy(f,pxx,'c', f(maximum_peak_index), maximum_peak, 'r.', 'MarkerSize',20)
title('Lomb-Scargle Power Spectral Density estimate - maximum peak detection')
xlabel('Frequency (Hz)')
ylabel('PSD')

breath_duration = 1/f(maximum_peak_index);
fprintf('Breath duration detected: %.4f s \n', breath_duration);