function p = gaussian_distribution(X, mu, cova)
% X is a m*n matrix, m is number of examples, n is number of features
% mu is a n*1 matrix
% cova is a n*n matrix
    X_cen = bsxfun(@minus, X, mu');
    p = 1/((2*pi)^(size(X,2)/2)*sqrt(det(cova))) * ...
        exp(-0.5* sum(X_cen .* (X_cen/cova), 2));   
end