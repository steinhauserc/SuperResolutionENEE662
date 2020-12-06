
clear 
close all
%% Prepare the reference image
im = imread('mario.png');
im = im(:, 1:size(im,1), :);
im = rgb2gray(im);
im = imresize(im, [ 128 128 ], 'nearest');
im = 1 - im2double(im);
%% Simulate the low-resolution images
numImages = 20;
blurSigma = 2;
scaleFactor = 2;
[ images, offsets, croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactor);
%%

[A , b, G] = formulateProblemCOPY(images, offsets, scaleFactor, blurSigma );

%%
[A2 , b2, G2] = formulateProblemV2(images, offsets, scaleFactor, blurSigma /scaleFactor );

%%
[highResv1, residualsv1] = solveQuadprog(A, b, G, 5e-3, 1, size(images{1}));
[highResv2, residualsv2] = solveQuadprog(A2, b2, G2, 5e-3, 1, size(images{1}));

%%
figure
imagesc(highResv2 - croppedOriginal)
%%
figure
imagesc(highResv1 - croppedOriginal)
%%
figure
subplot(1,3,1)
imagesc(highResv1, [0 1])
colorbar
subplot(1,3,2)
imagesc(highResv2, [0 1])
colorbar
subplot(1,3,3)
imagesc(croppedOriginal, [0 1])
colorbar