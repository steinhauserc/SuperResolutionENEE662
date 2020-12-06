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
for i=1:iter
    subplot(iter,2,2*i-1)
    imagesc(L1mat{i}, [0,1])
    title(sprintf('L-1 regularization Lamda=%.1d (mse = %.1d)', lamda(i),errorL1(i)))
    axis image
    
    subplot(iter,2,2*i)
    imagesc(L2mat{i}, [0,1])
    title(sprintf('L-2 regularizationLamda=%.1d (mse = %.1d)',lamda(i), errorL2(i)))
    axis image
end
suptitle('Qualitiative comparison L-1 vs L-2')
%Plotting the MSE vs lamda plot
    figure 
    plot(lamda,errorL1)
    hold on
    plot(lamda,errorL2)
    xlabel('lamda')
    ylabel('error')
    legend('mse for L1','mse for L2')
end

