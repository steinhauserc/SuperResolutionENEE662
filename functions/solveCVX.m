function [highRes, residuals] = solveCVX(A, b, G, lambda, lp, lowResSize)
%Implements the super resolution CVX
%  lp - parameter that determines the regression method.

n = size(A,2);
m = size(G,1);
switch lp
    case 1
        cvx_begin quiet
            variable x(n)
            minimize( sum_square( A * x - b ) + lambda/m*n * norm(G * x, 1 ))
        cvx_end
    case 2
        cvx_begin quiet
            variable x(n)
            minimize( sum_square( A * x - b ) + lambda/m*n * sum_square(G * x ))
        cvx_end
    otherwise 
        error('not implemented')
end

highRes = reshape(x, sqrt(n), sqrt(n));
residuals = reshape(A * x - b, lowResSize(1), lowResSize(2), length(b) / prod(lowResSize));;

end
