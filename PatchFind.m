% Finds nonzero elements returned as a series of ranges
%   result = patchfind( data )
%
% result(:,1) = left index of each range
% result(:,2) = right index of each range

function z = PatchFind(x)

sx = size(x);

y = (x~=0);
dy = diff(y);

if (sx(2) > sx(1))
  zl = find(dy>0)';
  zr = find(dy<0)';
else
  zl = find(dy>0);
  zr = find(dy<0);
end

if (isempty(zl))
  if (isempty(zr))
    if (y(1)==1)
      z = [1 length(x)];
    else
      z = [];
    end
  else
    z = [1 zr];
  end
else
  if (isempty(zr))
    z = [zl+1 length(x)];
  else
    zl = zl+1;
    if (y(1)==1)
      zl = [1 ; zl];
    end
    if (y(length(x))==1)
      zr = [zr ; length(zr)];
    end;
    z = [zl zr];
  end
end