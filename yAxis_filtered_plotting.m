function yAxis_filtered_plotting(y, y_filtered, timeAxis, plotName)
%YAXIS_FILTERED_PLOTTING plot the original accelerometer signal and the filtered one of the axis of interest
hold on;
subplot(2, 1, 1);
plot(timeAxis, y, 'g');
title(plotName)
xlabel('time (s)')
ylabel('Y (mg/LSB)')
subplot(2, 1, 2);
plot(timeAxis, y_filtered, 'g');
title(strcat(plotName,' filtered'))
xlabel('time (s)')
ylabel('Y (mg/LSB)')
hold off
end

