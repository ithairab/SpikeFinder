% Make a Gaussian distribution vector of width N length L centered at 1
% Normalized to sum to 1.

function z = gaussian(N,L)

Ld2 = ceil(L/2);
y = [ exp( -(((1:Ld2)-1)/N).^2 ) exp( -(((1:(L-Ld2))-(1+L-Ld2))/N).^2) ];
z = y' / sum(y);