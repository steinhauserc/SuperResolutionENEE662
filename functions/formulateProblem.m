function [A , b, G] = formulateProblem(lowRes, offsets, scaleFactor, psfSigma)
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
xEval = -floor(blurSize/2):floor(blurSize/2);
hGaussian = normpdf(xEval, 0, psfSigma * scaleFactor);
hGaussianPlusPixel = conv(hGaussian, ones(1,scaleFactor));
if mod(length(hGaussianPlusPixel),2) ~= 0
    hGaussianPlusPixel(end+1) = 0;
end
h2d = hGaussianPlusPixel' * hGaussianPlusPixel;
% normalize
h2d = h2d ./ sum(h2d(:)) * scaleFactor^2;

convMat = convmtx2(h2d, highResSize);
convSize = sqrt(size(convMat,1));

centerDownsampleInds = (length(hGaussianPlusPixel)/2):scaleFactor:(convSize - length(hGaussianPlusPixel)/2);



desiredCentroid = zeros(1,2);


interpType = 'nearest'; % setup to "upgrade" to bilinear
for ii = 1:nFrames
    thisFrame = lowRes{ii};
    
    dsMat = zeros(nPxLowRes, size(convMat,1));
    displacement = (desiredCentroid - offsets(ii,:)) * scaleFactor
    for jj = 1:lowResSize(1)
        for kk = 1:lowResSize(2)
            tmp = zeros(convSize,convSize);
            switch interpType
                case 'nearest'
                    tmp(centerDownsampleInds(kk) + round(displacement(2)), centerDownsampleInds(jj)+round(displacement(1))) = 1;
                case 'bilinear'
                    xa = ceil(displacement(2)) - displacement(2);
                    xb = displacement(2) - floor(displacement(2));
                    ya = ceil(displacement(1)) - displacement(1);
                    yb = displacement(1) - floor(displacement(1));
                    tmp(centerDownsampleInds(kk) + floor(displacement(2)), centerDownsampleInds(jj) + floor(displacement(1))) = xa * ya;
                    tmp(centerDownsampleInds(kk) + floor(displacement(2)), centerDownsampleInds(jj) + ceil(displacement(1))) = xa * yb;
                    tmp(centerDownsampleInds(kk) + ceil(displacement(2)), centerDownsampleInds(jj) + floor(displacement(1))) = xb * ya;
                    tmp(centerDownsampleInds(kk) + ceil(displacement(2)), centerDownsampleInds(jj) + ceil(displacement(1))) = xb * yb;
                    
            end
            dsMat((jj-1)*lowResSize(2) + kk, :) = tmp(:);
        end
        
    end
    
    dsMat = sparse(dsMat);
    A = [A; dsMat * convMat];
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

