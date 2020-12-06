clc
clear 
close all

setupPaths
%% Prepare the reference image
im = imread('exampleImage.png');
im = rgb2gray(im);
im = imresize(im, [ 128 128 ]);
im = im2double(im);
im = 1 - im;
%% Simulate the low-resolution images
numImages = 4;
blurSigma = 2;
scaleFactor = 2;

[ images offsets croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactor);
%%
[A , b, G] = formulateProblemV2(images, offsets, scaleFactor, blurSigma );

%% Solve using average interpoloation

avgimg=averageimage(images, offsets,im);

%% solve with gradient descent for comparison

[ lhs, rhs  ] = SREquations(images, offsets, blurSigma);
K = sparse(1 : size(lhs, 2), 1 : size(lhs, 2), sum(lhs, 1));
initialGuess = K \ lhs' * rhs; % This is an 'average' image produced from the LR images.

HR = GradientDescent(lhs, rhs, initialGuess);
highResGradDesc = reshape(HR, sqrt(numel(HR)), sqrt(numel(HR)));

%%
[highResL2, residualsL2] = solveQuadprog(A, b, G, 1e-2, 2, size(images{1}));

%%
[highResL1, residualsL1] = solveQuadprog(A, b, G, 1e-3, 1, size(images{1}));

%% Generate data for lamda vs MSE plot

max_lam=1;
itermax=4;

[L1mat,L2mat,lam]=multilamsol(A,b,G,size(images{1}),max_lam,itermax);


%%
figure
subplot(2,2,1)
imagesc(croppedOriginal, [0, 1])
title('Original Image')
axis image

subplot(2,2,2)
imagesc(highResGradDesc, [0,1])
title(sprintf('Gradient Descent (mse = %.1d)', mean((highResGradDesc(:) - croppedOriginal(:)).^2)))
axis image

subplot(2,2,3)
imagesc(highResL2, [0, 1])
title(sprintf('L-2 gradient regularization (mse = %.1d)', mean((highResL2(:) - croppedOriginal(:)).^2)))
axis image

subplot(2,2,4)
imagesc(highResL1, [0, 1])
title(sprintf('L-1 gradient regularization (mse = %.1d)', mean((highResL1(:) - croppedOriginal(:)).^2)))
axis image
%% Visulaise the lamda vs MSE plot as well as the High res images generated at each lamda
[errorL1,errorL2]=multilamvis(L1mat,L2mat,croppedOriginal,lam);

%% Visulise the average image as well as calculate the MSE error
avgerror= visualiseavg(avgimg,croppedOriginal)