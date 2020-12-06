function [highRes, residuals] = solveQuadprog(A, b, G, lambda, lp, lowResSize)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    % make sure input is sparse
    A = sparse(A);
    G = sparse(G);
    switch lp
        case 1
            [highRes, residuals] = solveQuadprogL1(A, b, G, lambda, lowResSize);
        case 2
            [highRes, residuals] = solveQuadprogL2(A, b, G, lambda, lowResSize);
        otherwise 
            error('not implemented')
    end
end

function [highRes, residuals] = solveQuadprogL1(A, b, G, lambda, lowResSize)
    n = size(A,2);
    m = size(G,1);

    H = [A' * A , sparse(n, m);
         sparse(m, n), sparse(m, m)];
    f = [-A' * b;
         lambda/2/m*n * ones(m,1)];
    Aineq = [G -speye(m,m);
             -G -speye(m,m);
             sparse(m,n) -speye(m,m)];
    bineq = sparse(size(Aineq,1), 1);
    
    x = quadprog(H, f, Aineq, bineq);
    
    highRes = reshape(x(1:n), sqrt(n), sqrt(n));
    residuals = reshape(A * x(1:n) - b, lowResSize(1), lowResSize(2), length(b) / prod(lowResSize));
end

function [highRes, residuals] = solveQuadprogL2(A, b, G, lambda, lowResSize)

    n = size(A,2);
    m = size(G,1);

    H = A' * A + lambda/2/m*n * (G' * G);
    f = -A' * b;
    
    x = quadprog(H, f);
    
    highRes = reshape(x, sqrt(n), sqrt(n));
    residuals = reshape(A * x - b, lowResSize(1), lowResSize(2), length(b) / prod(lowResSize));;
end

