function signals_heart_rate_plotting_2(z_filtered, y_filtered, timeAxis_1, timeAxis_2, plotName)
%SIGNALS_HEART_RATE_PLOTTING_2 plot the filtered accelerometer signals of the axes of interest
hold on
subplot(2, 1, 1);
plot(timeAxis_1, z_filtered, 'b');
title(strcat('Pos1-', plotName))
xlabel('time (s)')
ylabel('Z (mg/LSB)')
subplot(2, 1, 2);
plot(timeAxis_2, y_filtered, 'g');
title(strcat('Pos2-', plotName))
xlabel('time (s)')
ylabel('Y (mg/LSB)')
hold off
end

