function name = SF_Path2Name(pathname, depth)

name = [];
N = length(pathname);
k1 = strfind(pathname, '/');
k2 = strfind(pathname, '\');
if ~isempty(k1)
    k = k1;
else
    k = k2;
end

if ~isempty(k) && N
    Nk = length(k);
    n = min(Nk, depth);
    name = pathname(k(Nk-n+1):N);
end