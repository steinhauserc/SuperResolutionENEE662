function [errorL1,errorL2] = multilamvis(L1mat,L2mat,croppedOriginal,lamda)
%multilamvis Creates subplots of the Highres images at different lamdas for
%4 or less iterations and also generates a mse vs lamda plot
%   Detailed explanation goes here

iter=length(L1mat);

%Generating MSE for each lamda
for i=1:iter
    highResL1=L1mat{i};
    highResL2=L2mat{i};
    errorL1(i)=mean((highResL1(:) - croppedOriginal(:)).^2);
    errorL2(i)=mean((highResL2(:) - croppedOriginal(:)).^2);
end

%Qualitative comparison L-1 vs L-2
figure
n=0
itermax=length(L1mat);
factor=itermax/3;
m=itermax/factor;

for i=1:factor:itermax
    n=n+1;
    subplot(2,m,n)
    imagesc(L1mat{i})
    title(sprintf('L-1 reg Lamda=%.3f (mse = %.1d)', double(lamda(i)),errorL1(i)))
    axis image
    
    subplot(2,m,m+n)
    imagesc(L2mat{i})
    colormap(gray)
    title(sprintf('L-2 reg Lamda=%.3f (mse = %.1d)',double(lamda(i)), errorL2(i)))
    axis image
end

suptitle('Qualitiative comparison L-1 vs L-2')
%Plotting the MSE vs lamda plot
    [minL1,locL1]= min(errorL1);
    [minL2,locL2]=min(errorL2);
    figure 
    semilogx(lamda,errorL1,'-o')
    hold on
    semilogx(lamda,errorL2,'-o')
    hold on
    scatter(lamda(locL1),minL1,'r*')
    hold on
    scatter(lamda(locL2),minL2,'b*')
    xlabel('lamda')
    ylabel('MSE')
    legend('MSE for L1','mse for L2','min L1','min L2')
end

