function signals_filtered_plotting(signal, filtered_signal, timeAxis, plotName)
%SIGNALS_FILTERED_PLOTTING plot the original accelerometer signals and the filtered ones
x = signal(:,2);
y = signal(:,3);
z = signal(:,4);
x_filtered = filtered_signal(:,2);
y_filtered = filtered_signal(:,3);
z_filtered = filtered_signal(:,4);
hold on;
subplot(2, 1, 1);
plot(timeAxis, x, 'r', timeAxis, y, 'g', timeAxis, z, 'b');
title(plotName)
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})
subplot(2, 1, 2);
plot(timeAxis, x_filtered, 'r', timeAxis, y_filtered, 'g', timeAxis, z_filtered, 'b');
title(strcat(plotName,' filtered'))
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})
hold off
end

