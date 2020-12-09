function [L1mat,L2mat,lam] = multilamsol(A,b,G,lowResSize,max,itermax)
%multilamsol Creates matrices with highresolution images generated at
%different lamdas.
%   max: The largest value you want lamda to ineherit, itermax: maximum
%   iterations you want the cvx algorithm to process.

%Generating linearly spaced lamdas
lam=logspace(max,-4,itermax);


for i=1:itermax
    [highResL1, ~] = solveQuadprog(A, b, G, lam(i), 1, lowResSize);
    [highResL2, ~] = solveQuadprog(A, b, G, lam(i), 2, lowResSize);
    L1mat{i}=highResL1;
    L2mat{i}=highResL2;
    fprintf('Iteration %d is complete\n',i)
end
end

