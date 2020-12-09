function [output, croppedOriginal, images] = numImagesParamSweep(im, numImagesVec, ...
                    blurSigma, scaleFactor, lambdaL1, lambdaL2)
%Generates data needed for creating figures for studying the effect of number of LR image on the Quality of the output HR image.
%Refer to the discussion and result section of the report.
            
[ images, offsets, croppedOriginal ] = SynthDataset(im, max(numImagesVec), blurSigma, scaleFactor);

for ii = 1:length(numImagesVec)
    disp(ii / length(numImagesVec))
    [A , b, G] = formulateProblemV2(images(1:numImagesVec(ii)), offsets(1:numImagesVec(ii), :), scaleFactor, blurSigma );
    
    tic
    [highResL2QP, residualsL2QP] = solveQuadprog(A, b, G, lambdaL2, 2, size(images{1}));
    timesL2qp = toc;

    tic
    [highResL1QP, residualsL1QP] = solveQuadprog(A, b, G, lambdaL1, 1, size(images{1}));
    timesL1qp = toc;
    
    output(ii) = struct('highResL2', highResL2QP, ...
                        'runtimeL2', timesL2qp, ...
                        'residualsL2', residualsL2QP, ...
                        'highResL1', highResL1QP, ...
                        'runtimeL1', timesL1qp, ...
                        'residualsL1', residualsL1QP, ...
                        'numImages', numImagesVec(ii));

end

end

