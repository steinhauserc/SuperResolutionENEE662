function [A , b, G] = formulateProblemV2(lowRes, offsets, scaleFactor, psfSigma)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

lowResSize = size(lowRes{1});
highResSize = lowResSize * scaleFactor + 1;

nPxLowRes = lowResSize(1) * lowResSize(2);

A = [];
b = [];

nFrames = length(lowRes);

% configure blur and integration over pixel 
blurSize = round(psfSigma * scaleFactor * 4 * 2) + 1;
% blurSize = ceil(psfSigma * 3) * 2 + 1;
blurSize = 2;
xEval = -floor(blurSize/2):floor(blurSize/2);
hGaussian = normpdf(xEval, 0, psfSigma * scaleFactor);
% this step is not included in SynthDataset
% hGaussianPlusPixel = conv(hGaussian, ones(1,scaleFactor)); 
hGaussianPlusPixel = hGaussian;
if mod(length(hGaussianPlusPixel),2) ~= 0
    hGaussianPlusPixel(end+1) = 0;
end
% hGaussianPlusPixel = hGaussianPlusPixel / sum(hGaussianPlusPixel);
h2d = hGaussianPlusPixel' * hGaussianPlusPixel;
% normalize
h2d = h2d ./ sum(h2d(:));

convMat = convmtx2(h2d, highResSize);
convSize = sqrt(size(convMat,1));

centerDownsampleInds = (length(hGaussianPlusPixel)/2):scaleFactor:(convSize - length(hGaussianPlusPixel)/2);

Dmat = computeDownsampleMat(highResSize, size(h2d), scaleFactor);


for ii = 1:nFrames
    thisFrame = lowRes{ii};
    
    dsMat = zeros(nPxLowRes, size(convMat,1));
    horizTrans = computeHorizontalTranslation(highResSize, -offsets(ii,1) );
    vertTrans = computeVerticalTranslation(highResSize, -offsets(ii,2) );
    
    A = [A; Dmat * convMat * horizTrans * vertTrans];
    b = [b; thisFrame(:)];
end 

horizKernel = [1, -1];
vertKernel = [1; -1];
diag1Kernel = [1 0; 0 -1];
diag2Kernel = [0 1; -1 0];

G = [convmtx2(horizKernel, highResSize); 
     convmtx2(vertKernel, highResSize);
     convmtx2(diag1Kernel, highResSize);
     convmtx2(diag2Kernel, highResSize)];


end

function [Dmat] = computeDownsampleMat(highResSize, convKernelSize, scaleFactor)

    convOutputSize = highResSize + convKernelSize - 1;
    lowResSize = (highResSize - 1) / scaleFactor;

    % initialize downsample matrix to zeros
    Dmat = sparse(prod((highResSize - 1) / scaleFactor), prod(convOutputSize));
    firstRow = ceil(convKernelSize/2) + floor(scaleFactor / 2) ;
    for ii = 1:size(Dmat)
        [m, n] = ind2sub(lowResSize, ii);

        dsInd = sub2ind(convOutputSize, firstRow(1) + (m - 1) * scaleFactor, firstRow(2) + (n - 1) * scaleFactor);
        Dmat(ii, dsInd) = 1;

    end
   

end

function [Htrans] = computeHorizontalTranslation(highResSize, horizOffset)
    Htrans = sparse(prod(highResSize), prod(highResSize));
    
    for ii = 1:size(Htrans,1)
        [m, n] = ind2sub(highResSize, ii);
        nNew = n + horizOffset;
        if floor(nNew) == nNew
            iiNew = sub2ind(highResSize, m, nNew);
            Htrans(ii, iiNew) = 1;
        else
            nFloor = max(1, min(floor(nNew), highResSize(2)));
            nCeil = max(1, min(ceil(nNew), highResSize(2)));
            iiFloor = sub2ind(highResSize, m, nFloor);
            iiCeil = sub2ind(highResSize, m, nCeil);
            weightFloor = 1 - (nNew - floor(nNew));
            weightCeil = 1 - weightFloor;
            Htrans(ii, iiFloor) = weightFloor;
            Htrans(ii, iiCeil) = Htrans(ii, iiCeil) + weightCeil; % addition to handle edge case scenarios
        end
    end
end

function [Htrans] = computeVerticalTranslation(highResSize, vertOffset)
    Htrans = sparse(prod(highResSize), prod(highResSize));
    
    for ii = 1:size(Htrans,1)
        [m, n] = ind2sub(highResSize, ii);
        mNew = m + vertOffset;
        if floor(mNew) == mNew
            iiNew = sub2ind(highResSize, mNew, mNew);
            Htrans(ii, iiNew) = 1;
        else
            mFloor = max(1, min(floor(mNew), highResSize(1)));
            mCeil = max(1, min(ceil(mNew), highResSize(1)));
            iiFloor = sub2ind(highResSize, mFloor, n);
            iiCeil = sub2ind(highResSize, mCeil, n);
            weightFloor = 1 - (mNew - floor(mNew));
            weightCeil = 1 - weightFloor;
            Htrans(ii, iiFloor) = weightFloor;
            Htrans(ii, iiCeil) = Htrans(ii, iiCeil) + weightCeil; % addition to handle edge case scenarios
        end
    end
end
