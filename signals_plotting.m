function signals_plotting(signal, timeAxis, plotName)
%SIGNALS_PLOTTING plot the original accelerometer signals
x = signal(:,2);
y = signal(:,3);
z = signal(:,4);
tot = signal(:,5);
hold on;
subplot(2, 1, 1);
plot(timeAxis, x, 'r', timeAxis, y, 'g', timeAxis, z, 'b');
xlabel('time (s)')
ylabel('mg/LSB')
var = {{'x','y','z'},'Location','bestoutside'};
legend(var{:})
subplot(2, 1, 2);
plot(timeAxis, tot, 'm', 'DisplayName','tot');
xlabel('time (s)')
ylabel('TOT (mg/LSB)')
sgtitle(plotName)
hold off
end

