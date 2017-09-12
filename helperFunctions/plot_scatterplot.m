function plot_scatterplot(data1, data2, yLim, xLableText, yLableText)

figure
plot(data1, data2, 'o')
hold on
b = regress(data2, [ones(length(data1),1), data1]);
plot(yLim, b(1) + yLim.*b(2), 'k')
xlabel(xLableText)
ylabel(yLableText)