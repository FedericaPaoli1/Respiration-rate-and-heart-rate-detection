function signals_heart_rate_plotting_1(signal_1, signal_1_filtered, signal_2, signal_2_filtered, timeAxis_1, timeAxis_2, plotName_1, plotName_2)
%SIGNALS_HEART_RATE_PLOTTING_1 plot the original accelerometer signals and the filtered ones
x_1 = signal_1(:,2);
y_1 = signal_1(:,3);
z_1 = signal_1(:,4);
x_1_filtered = signal_1_filtered(:,2);
y_1_filtered = signal_1_filtered(:,3);
z_1_filtered = signal_1_filtered(:,4);

x_2 = signal_2(:,2);
y_2 = signal_2(:,3);
z_2 = signal_2(:,4);
x_2_filtered = signal_2_filtered(:,2);
y_2_filtered = signal_2_filtered(:,3);
z_2_filtered = signal_2_filtered(:,4);

hold on;
subplot(2, 2, 1);
plot(timeAxis_1, x_1, 'r', timeAxis_1, y_1, 'g', timeAxis_1, z_1, 'b');
title(plotName_1)
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})

subplot(2, 2, 2);
plot(timeAxis_2, x_2, 'r', timeAxis_2, y_2, 'g', timeAxis_2, z_2, 'b');
title(plotName_2)
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})

subplot(2, 2, 3);
plot(timeAxis_1, x_1_filtered, 'r', timeAxis_1, y_1_filtered, 'g', timeAxis_1, z_1_filtered, 'b');
title(strcat(plotName_1,' filtered'))
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})

subplot(2, 2, 4);
plot(timeAxis_2, x_2_filtered, 'r', timeAxis_2, y_2_filtered, 'g', timeAxis_2, z_2_filtered, 'b');
title(strcat(plotName_2,' filtered'))
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})
hold off
end