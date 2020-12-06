clc
clear 
close all
%% Prepare the reference image
im = imread('exampleImage.png');
im = rgb2gray(im);
im = imresize(im, [ 128 128 ]);
im = 1 - im2double(im);
%% Simulate the low-resolution images
numImagesVec = [5, 10, 15, 20];
blurSigma = 2;
scaleFactor = 2;

%% run test
[output, croppedOriginal] = numImagesParamSweep(im, numImagesVec, blurSigma, scaleFactor);

%% plot runtimes
figure
hold on
plot(numImagesVec, [output.runtimeL1], 'linewidth', 2)
plot(numImagesVec, [output.runtimeL2], 'linewidth', 2)


%% plot MSE of residuals of low resolution images
figure
hold on
l2mse = arrayfun(@(x) mean(x.residualsL2(:).^2), output);
l1mse = arrayfun(@(x) mean(x.residualsL1(:).^2), output);
plot(numImagesVec, l1mse, 'linewidth', 2)
plot(numImagesVec, l2mse, 'linewidth', 2)
legend('L1','L2')
xlabel('Number of input images')
ylabel('Low Resolution MSE')

%% plot MSE of high resolution images
figure
hold on
l2mse = arrayfun(@(x) mean((x.highResL2(:) - croppedOriginal(:)).^2), output);
l1mse = arrayfun(@(x) mean((x.highResL1(:) - croppedOriginal(:)).^2), output);
plot(numImagesVec, l1mse, 'linewidth', 2)
plot(numImagesVec, l2mse, 'linewidth', 2)
legend('L1','L2')
xlabel('Number of input images')
ylabel('High Resolution MSE')
