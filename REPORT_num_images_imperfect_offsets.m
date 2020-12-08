
clear
close all

%% Prepare the reference image
source = 'mario'
switch source
    case 'mario'
        im = imread('mario.png');
        im = im(:, 1:size(im,1), :);
        im = rgb2gray(im);
        % nearest interpolation keeps things "blocky"
        im = imresize(im, [ 128 128 ], 'nearest');
        im = im2double(im);
    case 'campus'
        im = imread('campuspicture.jpg');
        im = im(:, 1:size(im,1), :);
        im = rgb2gray(im);
        im = imresize(im, [ 128 128 ], 'cubic');
        im = im2double(im);
    case 'scream'
        im = imread('scream.jpg');
        im = im((end-size(im,2)):end, :, :);
        im = rgb2gray(im);
        im = imresize(im, [ 128 128 ], 'cubic');
        im = im2double(im);
end

%% Simulate the low-resolution images
numImagesVec = 5:5:100;
blurSigma = 2;
scaleFactor = 2;

lambdaL1 = 5e-2;
lambdaL2 = 2e-1;

%% run test
rng(1)
[outputPerfect, croppedOriginal, images] = numImagesParamSweep(im, numImagesVec, blurSigma, scaleFactor, lambdaL1, lambdaL2, 0);
rng(1)
[outputImperfect, croppedOriginal, images] = numImagesParamSweep(im, numImagesVec, blurSigma, scaleFactor, lambdaL1, lambdaL2, 0.2);


%% plot results in terms of MSE of high resolution image
% plot results in terms of MSE of high res image
highResMSEL1Perfect = arrayfun(@(x) mean((x.highResL1(:) - croppedOriginal(:)).^2), outputPerfect);
highResMSEL2Perfect = arrayfun(@(x) mean((x.highResL2(:) - croppedOriginal(:)).^2), outputPerfect);

highResMSEL1Imperfect = arrayfun(@(x) mean((x.highResL1(:) - croppedOriginal(:)).^2), outputImperfect);
highResMSEL2Imperfect = arrayfun(@(x) mean((x.highResL2(:) - croppedOriginal(:)).^2), outputImperfect);

% plot results in terms of MSE of low res image
lowResMSEL1Perfect = arrayfun(@(x) mean(x.residualsL1(:).^2), outputPerfect);
lowResMSEL2Perfect = arrayfun(@(x) mean(x.residualsL2(:).^2), outputPerfect);

lowResMSEL1Imperfect = arrayfun(@(x) mean(x.residualsL1(:).^2), outputImperfect);
lowResMSEL2Imperfect = arrayfun(@(x) mean(x.residualsL2(:).^2), outputImperfect);

figure('position', [397         509        1008         420])
subplot(1,2,2)
colors = get(gca,'colororder')
hold on
plot(numImagesVec, highResMSEL1Perfect,'o-')
plot(numImagesVec, highResMSEL2Perfect,'o-')
plot(numImagesVec, highResMSEL1Imperfect,'s--', 'color', colors(1,:))
plot(numImagesVec, highResMSEL2Imperfect,'s--', 'color', colors(2,:))
legend({'$\ell$-1 Regularization - Perfect Offset','$\ell$-2 Regularization - Perfect Offset', ...
            '$\ell$-1 Regularization - Imperfect Offset','$\ell$-2 Regularization - Imperfect Offset'},'interpreter','latex')
box on
xlabel('Number of Low Resolution Images')
ylabel('MSE')
title('High Resolution MSE - Mario with Noisy Offset')
ylim_ = get(gca,'ylim')
set(gca,'ylim', [0 ylim_(2)])
% ylim([0 8e-3])

subplot(1,2,1)
hold on
plot(numImagesVec, lowResMSEL1Perfect,'o-')
plot(numImagesVec, lowResMSEL2Perfect,'o-')
plot(numImagesVec, lowResMSEL1Imperfect,'s--', 'color', colors(1,:))
plot(numImagesVec, lowResMSEL2Imperfect,'s--', 'color', colors(2,:))
box on
xlabel('Number of Low Resolution Images')
ylabel('MSE')
title('Low Resolution MSE - Mario with Noisy Offset')

% saveas(gcf, sprintf('figures/%s_vary_images_plot.png', source))


% %%
% figure('position', [397         318        1008         611])
% subplot(2,3,1)
% imagesc(croppedOriginal, [0,1])
% axis image
% axis off
% colormap gray
% title('Original High Resolution Image','interpreter','latex')
% 
% subplot(2,3,4)
% imagesc(images{1},[0,1])
% axis image
% axis off
% title('Sample Low Resolution Image','interpreter','latex')
% colormap gray
% 
% subplot(2,3,2)
% ind = 5;
% imagesc(output(ind).highResL1, [0,1])
% axis image
% axis off
% title(sprintf('SR with %d Input Images - $\\ell$-1 Reg.', numImagesVec(ind)),'interpreter','latex')
% colormap gray
% 
% subplot(2,3,5)
% imagesc(output(end).highResL1, [0,1])
% axis image
% axis off
% title(sprintf('SR with %d Input Images - $\\ell$-1 Reg.', numImagesVec(end)), 'interpreter','latex')
% colormap gray
% 
% subplot(2,3,3)
% ind = 5;
% imagesc(output(ind).highResL2, [0,1])
% axis image
% axis off
% title(sprintf('SR with %d Input Images - $\\ell$-2 Reg.', numImagesVec(ind)), 'interpreter','latex')
% colormap gray
% 
% subplot(2,3,6)
% imagesc(output(end).highResL2, [0,1])
% axis image
% axis off
% title(sprintf('SR with %d Input Images - $\\ell$-2 Reg.', numImagesVec(end)), 'interpreter','latex')
% colormap gray
% 
% saveas(gcf, sprintf('figures/%s_vary_images_examples.png', source))
