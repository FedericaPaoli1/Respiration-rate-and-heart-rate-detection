% Respiration rate and heart rate detection of signals collected with a respiratory frequency 
% of 0.125 Hz for 12 cycles of inhalation and exhalation 

%% Recording of LSM6DS3 accelerometer (STMicroelectronics) signals
% datasheet: https://www.st.com/resource/en/datasheet/lsm6ds3.pdf
% file: signals/pos1_accelerometer_data_8sbreathing.txt
%
% They were recorded with a sampling rate of 202 Hz and 
% a resolution of 0.244 mg/LSB

fprintf('Loading of pos1_accelerometer_data_8sbreathing.txt  \n');
load signals/pos1_accelerometer_data_8sbreathing.txt % data composed by the following columns: time, gFx, gFy, gFz, TgF

fprintf('Loading of pos2_accelerometer_data_8sbreathing.txt  \n');
load signals/pos2_accelerometer_data_8sbreathing.txt % data composed by the following columns: time, gFx, gFy, gFz, TgF

%% Data acquisition step
fprintf('*Data acquisition step*  \n');

% remove time values duplicated
[~,uidx] = unique(pos1_accelerometer_data_8sbreathing(:,1),'stable');
pos1_accelerometer_data = pos1_accelerometer_data_8sbreathing(uidx,:);

[~,uidx] = unique(pos2_accelerometer_data_8sbreathing(:,1),'stable');
pos2_accelerometer_data = pos2_accelerometer_data_8sbreathing(uidx,:);

% remove first 1010 rows (first 5 seconds of recording)
pos1_accelerometer_data(1:1010,:) = [];
pos2_accelerometer_data(1:1010,:) = [];

% length of accelerometer_data
pos1_accelerometer_data_length = length(pos1_accelerometer_data);
pos2_accelerometer_data_length = length(pos2_accelerometer_data);

% remove last 1010 rows (last 5 seconds of recording)
pos1_accelerometer_data(pos1_accelerometer_data_length-1010:pos1_accelerometer_data_length,:) = [];
pos2_accelerometer_data(pos2_accelerometer_data_length-1010:pos2_accelerometer_data_length,:) = [];

% take the time axis
pos1_timeAxis = pos1_accelerometer_data(:,1);
pos2_timeAxis = pos2_accelerometer_data(:,1);

% we want the signal in mG:
resolution = 0.244; % mg/LSB
fprintf('Application resolution: %.3f mg/LSB \n', resolution);
pos1_accelerometer_data= pos1_accelerometer_data * resolution;
pos2_accelerometer_data= pos2_accelerometer_data * resolution;

%% Pre-processing step
% Plotting all the signals collected

fprintf('*Pre-processing step*  \n');

figure(1)
signals_plotting(pos1_accelerometer_data, pos1_timeAxis, 'Pos1-accelerometer-data-8sbreathing')

figure(2)
signals_plotting(pos2_accelerometer_data, pos2_timeAxis, 'Pos2-accelerometer-data-8sbreathing')

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
figure(3)                                    
freqz(b, a) 
                                    
pos1_accelerometer_data_filtered = filter(b, a, pos1_accelerometer_data); % apply the filter                                                                            

% plot the original data and the filtered data
figure(4)
signals_filtered_plotting(pos1_accelerometer_data, pos1_accelerometer_data_filtered, pos1_timeAxis, 'Pos1-accelerometer-data-8sbreathing')

% plot the y axis of the original and the filtered data
pos1_y = pos1_accelerometer_data(:,3);
pos1_y_filtered = pos1_accelerometer_data_filtered(:,3);
figure(5)
yAxis_filtered_plotting(pos1_y, pos1_y_filtered, pos1_timeAxis, 'Pos1-accelerometer-data-8sbreathing')


%% Time domain analysis: Detection of minima of y axis of the filtered acceleration data

half_breath_duration = 4; % 4 seconds represent half of the entire breath duration

fprintf('*Time-domain analysis* \n');
fprintf('Detection of minima of y axis of the filtered acceleration data \n');
local_minima_indexes = islocalmin(pos1_y_filtered, 'MinSeparation', half_breath_duration, 'SamplePoints', pos1_timeAxis);
local_minima = pos1_y_filtered(local_minima_indexes);
time_local_minima = pos1_timeAxis(local_minima_indexes);

figure(6)
plot(pos1_timeAxis,pos1_y_filtered,'g', time_local_minima, local_minima,'r.', 'MarkerSize',20)
title('Pos1-accelerometer-data-8sbreathing filtered - minima detection')
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

figure(7)
plomb(pos1_y_filtered, pos1_timeAxis, fs) % include frequencies up to 202 Hz

df = 1/fs; % fine grid with a spacing of 1/202 (0.00495)s 
fvec = 0.05:df:0.5; % input frequencies (only frequencies we want to consider for zooming)
figure(8)
plomb(pos1_y_filtered,pos1_timeAxis,fvec)
df_str = sprintf('df = %.4f',df);
legend(df_str)
hold off

fprintf('Computation of PSDls (Lomb-Scargle Power Spectral Density) \n');
[pxx,f] = plomb(pos1_y_filtered,pos1_timeAxis,fvec); 

%% Frequency domain analysis: respiratory frequency computation

fprintf('Detection of the maximum peak of the Lomb-Scargle Periodogram of y axis of the filtered acceleration data \n');
[maximum_peak, maximum_peak_index] = max(plomb(pos1_y_filtered,pos1_timeAxis,fvec));

figure(9)
semilogy(f,pxx,'c', f(maximum_peak_index), maximum_peak, 'r.', 'MarkerSize',20)
title('Lomb-Scargle Power Spectral Density estimate - maximum peak detection')
xlabel('Frequency (Hz)')
ylabel('PSD')

breath_duration = 1/f(maximum_peak_index);
fprintf('Breath duration detected: %.4f s \n', breath_duration);

%% Heart rate detection step
% reference: https://doi.org/10.1109/EMBC.2016.7590755

fprintf('*HEART RATE DETECTION*  \n');

%% Design a 4th-order bandpass Butterworth filter with a band of 5-25 Hz for the z component of the accelerometer in position 1

low_fc = 5;
high_fc = 25;
low_fc_rad = low_fc/(fs/2); % lower cut frequency converted into 0.00495 rad/sample
high_fc_rad = high_fc/(fs/2);  % higher cut frequency converted into 0.2475 rad/sample

fprintf('Design of %d order Butterworth bandpass filter with %d Hz as sampling rate and a band of %d - %d Hz  \n', n_order, fs, low_fc, high_fc);
[b1,a1] = butter(n_order, [low_fc_rad high_fc_rad], 'bandpass'); % get Transfer function coefficients of the 
                                                                 % 4th-order bandpass Butterworth filter

% plot magnitude and phase
figure(10)                                    
freqz(b1, a1) 
                                    
pos1_accelerometer_data_bandpassed = filter(b1, a1, pos1_accelerometer_data); % apply the filter                                                                            

% plot the original data and the filtered data
figure(11)
signals_filtered_plotting(pos1_accelerometer_data, pos1_accelerometer_data_bandpassed, pos1_timeAxis, 'Pos1-accelerometer-data-8sbreathing')

% plot the y axis of the original and the filtered data
pos1_z = pos1_accelerometer_data(:,4);
pos1_z_filtered = pos1_accelerometer_data_bandpassed(:,4);
figure(12)
zAxis_filtered_plotting(pos1_z, pos1_z_filtered, pos1_timeAxis, 'Pos1-accelerometer-data-8sbreathing')

%% Design a 4th-order bandpass Butterworth filter with a band of 1-25 Hz for the y component of the accelerometer in position 2

low_fc = 1;
high_fc = 25;
low_fc_rad = low_fc/(fs/2); % lower cut frequency converted into 0.0099 rad/sample
high_fc_rad = high_fc/(fs/2);  % higher cut frequency converted into 0.2475 rad/sample

fprintf('Design of %d order Butterworth bandpass filter with %d Hz as sampling rate and a band of %d - %d Hz  \n', n_order, fs, low_fc, high_fc);
[b2,a2] = butter(n_order, [low_fc_rad high_fc_rad], 'bandpass'); % get Transfer function coefficients of the 
                                                                 % 4th-order bandpass Butterworth filter

% plot magnitude and phase
figure(13)                                    
freqz(b2, a2) 
                                    
pos2_accelerometer_data_bandpassed = filter(b2, a2, pos2_accelerometer_data); % apply the filter                                                                            

% plot the original data and the filtered data
figure(14)
signals_filtered_plotting(pos2_accelerometer_data, pos2_accelerometer_data_bandpassed, pos2_timeAxis, 'Pos2-accelerometer-data-8sbreathing')

% plot the y axis of the original and the filtered data
pos2_y = pos2_accelerometer_data(:,3);
pos2_y_filtered = pos2_accelerometer_data_bandpassed(:,3);
figure(15)
yAxis_filtered_plotting(pos2_y, pos2_y_filtered, pos2_timeAxis, 'Pos2-accelerometer-data-8sbreathing')

%% Plotting the signals filtered to detect the heart rate

figure(16)
signals_heart_rate_plotting_1(pos1_accelerometer_data, pos1_accelerometer_data_bandpassed, pos2_accelerometer_data, pos2_accelerometer_data_bandpassed, pos1_timeAxis, pos2_timeAxis, 'Pos1-accelerometer-data-8sbreathing', 'Pos2-accelerometer-data-8sbreathing')

figure(17)
signals_heart_rate_plotting_2(pos1_z_filtered, pos2_y_filtered, pos1_timeAxis, pos2_timeAxis, 'accelerometer-data-8sbreathing')
