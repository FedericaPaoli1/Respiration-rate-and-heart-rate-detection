function zAxis_filtered_plotting(z, z_filtered, timeAxis, plotName)
%YAXIS_FILTERED_PLOTTING plot the original accelerometer signal and the filtered one of the axis of interest
hold on;
subplot(2, 1, 1);
plot(timeAxis, z, 'b');
title(plotName)
xlabel('time (s)')
ylabel('Z (mg/LSB)')
subplot(2, 1, 2);
plot(timeAxis, z_filtered, 'b');
title(strcat(plotName,' filtered'))
xlabel('time (s)')
ylabel('Z (mg/LSB)')
hold off
end

