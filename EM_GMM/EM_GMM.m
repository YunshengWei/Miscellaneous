function [pi, mu, cova] = EM_GMM(X, class, maxIter)
% X should be a m * n matrix, where n is number of features, m is number of
% examples, class is number of hidden classes
% This function is highly optimized and generalized
% *Attention*: The result may be NAN due to certain bad initialization!!!

% Initialize
if ~exist('maxIter', 'var') || isempty(maxIter)
    maxIter = 15;
end
m = size(X, 1);
index = randperm(m, class);
mu = X(index,:)';
pi = ones(class, 1) / class;
init_cova = cov(X, 1);
cova = cell(class, 1);
for i = 1:class
    cova{i} = init_cova;
end

eps = 1e-10;
f = zeros(m, class);
last_log_likelihood = -inf;
for k = 1:maxIter
    % Expectation Step
    for i = 1:class
        f(:,i) = gaussian_distribution(X, mu(:,i), cova{i});
    end
    f_sum = f*pi;
    f_middle = bsxfun(@(x, y) x.*y, f, pi');
    p = bsxfun(@(x, y) x./y, f_middle, f_sum);
    
    % Display iteration information
    new_log_likelihood = sum(log(sum(f_middle, 2)));
    fprintf('Before %dth iteration, log likelihood value is %.14f\n', k, new_log_likelihood);
    if new_log_likelihood - last_log_likelihood < eps
        return
    end
    last_log_likelihood = new_log_likelihood;
        
    % Maximization Step
    pi = sum(p, 1)' / m;
    mu = bsxfun(@(x, y) x./y, X'*p, pi') / m;
    for i = 1:class
        X_cen = bsxfun(@minus, X, mu(:,i)');
        cova{i} = (X_cen'/m * bsxfun(@(x, y) x.*y, X_cen, p(:,i)/pi(i)));
    end
end

for i = 1:class
    f(:,i) = gaussian_distribution(X, mu(:,i), cova{i});
end
f_middle = bsxfun(@(x, y) x.*y, f, pi');
new_log_likelihood = sum(log(sum(f_middle, 2)));
fprintf('After %dth iteration, log likelihood value is %.14f\n', k, new_log_likelihood);
end
