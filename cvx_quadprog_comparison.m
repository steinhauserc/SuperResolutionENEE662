clc
clear 
close all
%% Prepare the reference image
im = imread('exampleImage.png');
im = rgb2gray(im);
im = imresize(im, [ 128 128 ]);
im = 1 - im2double(im);
%% Simulate the low-resolution images
numImages = 10;
blurSigma = 2;
scaleFactor = 2;
[ images, offsets, croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactor);
%%

[A , b, G] = formulateProblemCOPY(images, offsets, scaleFactor, blurSigma );

%%
figure
subplot(1,2,1)
imagesc(A, [0, 0.15])
colorbar
subplot(1,2,2)
imagesc(A2, [0, 0.15])
colorbar

%% solve with CVX
tic
[highResL2CVX, residualsL2CVX] = solveCVX(A, b, G, 5e-3, 2, size(images{1}));
cvxL2runtime = toc;

tic
[highResL1CVX, residualsL1CVX] = solveCVX(A, b, G, 5e-3, 1, size(images{1}));
cvxL1runtime = toc;

%% solve with quadprog
tic
[highResL2QP, residualsL2QP] = solveQuadprog(A, b, G, 5e-3, 2, size(images{1}));
qpL2runtime = toc;

tic
[highResL1QP, residualsL1QP] = solveQuadprog(A, b, G, 5e-3, 1, size(images{1}));
qpL1runtime = toc;

%% print runtimes
fprintf('CVX Runtimes\n')
fprintf('\t L2: %f\n\t L1: %f\n', cvxL2runtime, cvxL1runtime);

fprintf('CVX Runtimes\n')
fprintf('\t L2: %f\n\t L1: %f\n', qpL2runtime, qpL1runtime);

%% visualize solutions
figure
subplot(2,3,1)
imagesc(highResL2CVX, [0, 1])
title('CVX L2 Image')
axis image

subplot(2,3,2)
imagesc(highResL2QP, [0, 1])
title('Quadprog L2 Image')
axis image

subplot(2,3,3)
imagesc(highResL2CVX - highResL2QP)
title('CVX L2 - Quadprog L2')
axis image
colorbar

subplot(2,3,4)
imagesc(highResL1CVX, [0, 1])
title('CVX L2 Image')
axis image

subplot(2,3,5)
imagesc(highResL1QP, [0, 1])
title('Quadprog L2 Image')
axis image

subplot(2,3,6)
imagesc(highResL1CVX - highResL1QP)
title('CVX L2 - Quadprog L2')
axis image
colorbar

%%
figure
subplot(2,2,1)
imagesc(croppedOriginal, [0, 1])
title('Original Image')
axis image

% subplot(2,2,2)
% imagesc(highResGradDesc, [0,1])
% title(sprintf('Gradient Descent (mse = %.1d)', mean((highResGradDesc(:) - croppedOriginal(:)).^2)))
% axis image

subplot(2,2,3)
imagesc(highResL2CVX, [0, 1])
title(sprintf('L-2 gradient regularization (mse = %.1d)', mean((highResL2CVX(:) - croppedOriginal(:)).^2)))
axis image

subplot(2,2,4)
imagesc(highResL1CVX, [0, 1])
title(sprintf('L-1 gradient regularization (mse = %.1d)', mean((highResL1CVX(:) - croppedOriginal(:)).^2)))
axis image

%% run at multiple scale factors to create plot with curves

scaleFactors = [1,2,3,4];
timesL1cvx = zeros(size(scaleFactors));
timesL2cvx = zeros(size(scaleFactors));
timesL1qp = zeros(size(scaleFactors));
timesL2qp = zeros(size(scaleFactors));

for ii = 1:length(scaleFactors)
    fprintf('Running with scale factor %d\n\n\n\n', scaleFactors(ii));
    
    im = imread('exampleImage.png');
    im = rgb2gray(im);
    im = imresize(im, [ 64 64 ] * scaleFactors(ii));
    im = 1 - im2double(im);
    
    [ images, offsets, croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactors(ii));

    [A , b, G] = formulateProblemCOPY(images, offsets, scaleFactors(ii), blurSigma );

    disp(size(A))
    disp(size(b))
    disp(size(G))
    % solve with CVX
    tic
    [highResL2CVX, residualsL2CVX] = solveCVX(A, b, G, 5e-3, 2, size(images{1}));
    timesL2cvx(ii) = toc;

    tic
    [highResL1CVX, residualsL1CVX] = solveCVX(A, b, G, 5e-3, 1, size(images{1}));
    timesL1cvx(ii) = toc;

    % solve with quadprog
    tic
    [highResL2QP, residualsL2QP] = solveQuadprog(A, b, G, 5e-3, 2, size(images{1}));
    timesL2qp(ii) = toc;

    tic
    [highResL1QP, residualsL1QP] = solveQuadprog(A, b, G, 5e-3, 1, size(images{1}));
    timesL1qp(ii) = toc;
    
    % visual inspection for each run
    figure
    subplot(2,2,1)
    imagesc(highResL1CVX)
    axis image
    subplot(2,2,2)
    imagesc(highResL2CVX)
    axis image
    subplot(2,2,3)
    imagesc(highResL1QP)
    axis image
    subplot(2,2,4)
    imagesc(highResL2QP)

end

%%
figure
subplot(1,2,1)
hold on
plot(scaleFactors, timesL1cvx,'o-','linewidth',2)
plot(scaleFactors, timesL1qp,'s-','linewidth',2)
xlabel('Scale Factor')
ylabel('Runtime')
title('L-1 Regularization Runtimes')

subplot(1,2,2)
hold on
plot(scaleFactors, timesL2cvx,'o-','linewidth',2)
plot(scaleFactors, timesL2qp,'s-','linewidth',2)
xlabel('Scale Factor')
ylabel('Runtime')
title('L-2 Regularization Runtimes')