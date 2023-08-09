%%Kelsey Snapp
%Kab Lab
%6/16/21
%Shows how the sigmoid cutoff is working

function plotSigmoidCutoff(sigmoidCutoff)

x = 0:.01:1;
y = x;

fig = figure(101);
plot(x,y)
hold on
y = 1./(1+exp(-20*(x-sigmoidCutoff)));
plot(x,y)
xlabel('Input')
ylabel('Output')
title(sprintf('Sigmoid Cutoff = %.03f',sigmoidCutoff))
plot([sigmoidCutoff,sigmoidCutoff],[0,1],'--')
legend('Original','Transformation','Cutoff')

saveas(fig,'slack.jpg')
close(fig)




end