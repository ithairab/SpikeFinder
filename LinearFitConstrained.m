function [a b] = LinearFitConstrained(x,y, K)

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
a = (x'*y + N*x(K)*y(K) - y(K)*sum(x) - x(K)*sum(y)) / (x'*x - 2*x(K)*sum(x) + N*x(N)^2);
b = y(K) - a*x(K);
