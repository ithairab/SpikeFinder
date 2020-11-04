% smoothed_data = qsmooth(data , width_of_gaussian)
% Smooths your data by convolving with a Gaussian of a specified
% width (measured in data points).  Operation is performed in chunks
% for speed.  Endpoints may be slightly distorted.
% From Schafer Lab scripts, originally called qsmooth

function z = GaussianSmooth(x,N)

lx = length(x);
Ni = max( 1 , ceil(N) );
sx = size(x);
if (sx(1) == lx)
  x = [ x(1)*ones(2*Ni,1) ; x ; x(lx)*ones(2*Ni,1) ];
else
  x = [ x(1)*ones(2*Ni,1) ; x' ; x(lx)*ones(2*Ni,1) ];
end
lx = lx + 4*Ni;
if (lx < 8192)
  ahat = fft(gaussian(N,lx));
  z = real( ifft( fft(x) .* ahat ) );
else
  z = zeros(lx,1);
  chunksize = 2048;
  while (chunksize < Ni*32)
    chunksize = chunksize*2;
  end
  if (chunksize >= lx/2)
    z = smooth(x,N);
  else
    a = gaussian(N,chunksize);
    ahat = fft(a);
    nchunks = ceil(lx / (chunksize-Ni*16));
    for i=1:nchunks
      left = (i-1)*(chunksize-Ni*16)+1;
      right = left+chunksize-1;
      if (right > lx)               % Fell off end!  Fix it.
        left = left - (right-lx);
        right = lx;
      end
      chunk = real( ifft( fft(x(left:right)) .* ahat ) );  % Convolve
% The central part of the convolution isn't affected by the endpoints;
% place that in the output data.  The very beginning & very end of the
% data will be a bit messed up.
      if (left == 1)
        z(1:right) = chunk;
      elseif (right == lx)
        z((left+Ni*8):right) = chunk((Ni*8+1):chunksize);
      else
        z((left+Ni*8):(right-Ni*8)) = chunk((Ni*8+1):(chunksize-Ni*8));
      end
    end
  end
end
z = z((2*Ni+1):(lx-2*Ni));