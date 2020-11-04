% Basic Slope Finder
%   [startidx,endidx] = bsf( data , parameters )
%
% Takes one vector of data (ratio values only) and one vector of parameters.
% Detects events classified as having at least K out of N consecutive points
% with some minimum slope.  Then finds the limits of the event by extending
% the detected region to the left and right with a less restrictive value
% for slope.
%
% parameters = [direction slope window ngood rslope lslope extwin extngood]
%   direction = 1 for upslope, -1 for downslope
%   slope = minimum slope in units of rise per data point to count as event
%   window = number of consecutive data points to look for slope
%   ngood = number of data points in the window that must be as steep as slope
%   rslope = minimum slope needed to extend event to the right
%   lslope = minimum slope needed to extend event to the left
%   extwin = number of data points used for extension
%   extngood = number of points that must be as steep as rslope or lslope
%
% Returns two columns; first column is index of start of event, second is end.

% A Schafer lab script, originally bsf.m

function z = GetSpikes(x,param)

direction = sign(param(1));
steepness = (param(2));
window = ceil(param(3));
mingood = ceil(param(4));

ext_r_steepness = (param(5));
ext_l_steepness = (param(6));
extend_window = ceil(param(7));
extend_mingood = ceil(param(8));

dx = diff(x);
steeps = (dx*direction > steepness);

cs = cumsum(steeps);
lcs = length(cs);
dcs = cs((window+1):lcs) - cs(1:(lcs-window));
good = PatchFind(dcs >= mingood);

if (isempty(good))
  z = [];
else
  good = [good(:,1)+1 good(:,2)+window+1];
  
  rights = (dx*direction > ext_r_steepness);
  lefts = (dx*direction > ext_l_steepness);
  cr = cumsum(rights);
  cl = cumsum(lefts);
  dcr = cr((extend_window+1):lcs) - cr(1:(lcs-extend_window));
  dcl = cl((extend_window+1):lcs) - cl(1:(lcs-extend_window));
  rgood = PatchFind(dcr >= extend_mingood);
  lgood = PatchFind(dcl >= extend_mingood);
  if (isempty(rgood))
    rgood = [-extend_window -extend_window];
  end
  if (isempty(lgood))
    lgood = [-extend_window -extend_window];
  end
  
  rgood = [rgood(:,1)+1 rgood(:,2)+extend_window+1];
  lgood = [lgood(:,1)+1 lgood(:,2)+extend_window+1];

  sgood = size(good);
  y=zeros(sgood(1),2);
  for i = 1:sgood(1)
    loidx = find( lgood(:,2)>good(i,1) & lgood(:,1)<good(i,1) );
    if (isempty(loidx))
      y(i,1) = good(i,1);
    else
      y(i,1) = min( lgood(loidx,1) );
    end
    roidx = find( rgood(:,1)<good(i,2) & rgood(:,2)>good(i,2) );
    if (isempty(roidx))
      y(i,2) = good(i,2);
    else
      y(i,2) = max( rgood(roidx,2) );
    end
  end
  
  sy = size(y);
  j = 1;
  while (j <= sy(1) & sy(1)>1)
    oidx = find( (y(j,1)<y(:,2) & y(j,1)>y(:,1)) | (y(j,2)<y(:,2) & y(j,2)>y(:,1)) | (y(j,1)==y(:,1) & y(j,2)==y(:,2) & j~=(1:length(y))') );
    if (~isempty(oidx))
      k = oidx(1);
      temp = y(j,:);
      y(j,:) = [ min(y(j,1),y(k,1)) max(y(j,2),y(k,2)) ];
      sy = size(y);
      if (k < sy(1))
        y = y([1:(k-1) (k+1):sy(1)],:);
      else
        y = y( 1:(k-1) , : );
      end
      j = 1;
    elseif (y(j,1)>y(j,2))
      if (j < sy(1))
        y(j:(sy(1)-1),:) = y((j+1):sy(1),:);
      elseif (j > 1)
        y = y(1:(j-1),:);
      else
        y = [];
      end
    else
      j = j+1;
    end
    sy = size(y);
  end
  
  z = y;
end
