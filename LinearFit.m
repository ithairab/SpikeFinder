function [a b] = LinearFit(x,y)
% linear regression according to the model y = b + a*x;


[m n] = size(x);
N = m;
if m==1
    x = reshape(x, n, m);
    N = n;
end
[m n] = size(y);
if m==1
    y = reshape(y, n, m);
end
a = (N*x'*y - sum(x)*sum(y)) / (N*x'*x - sum(x)^2);
b = (sum(y) - a*sum(x)) / N;
