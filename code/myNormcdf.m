function p = myNormcdf(z)
% myNormcdf Devuelve la CDF de la Normal Estándar en z, usando erf.
%   z puede ser escalar, vector o matriz.
    p = 0.5 * (1 + erf(z ./ sqrt(2)));
end
