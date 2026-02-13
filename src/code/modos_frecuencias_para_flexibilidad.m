function [Phi, Omega] = modos_frecuencias_para_flexibilidad(K, M, nModes)
% modos_frecuencias  Extrae los primeros nModes modos y 
%                    sus frecuencias naturales en rad/s.
%
% Sintaxis:
%   [Phi, Omega] = modos_frecuencias(K, M, nModes)
%
% Entradas:
%   K      -> matriz de rigidez
%   M      -> matriz de masa
%   nModes -> número de modos que deseas (opcional)
%
% Salidas:
%   Phi    -> matriz de formas modales (nDOFs x nModes)
%   Omega  -> vector (1 x nModes) con frecuencias naturales en rad/s

    % Si no se especifica nModes, busca algunos modos (por ejemplo, 6)
    if nargin < 3
        nModes = 6;
    end

    % EIGS con la opción 'sm' busca los valores propios más pequeños
    % (los primeros modos)
    [PhiTemp, wn2] = eigs(K, M, nModes, 'sm');

    % wn2 son los valores propios asociados a omega^2
    wn = sqrt(diag(wn2));  % wn ahora es un vector de frecuencias en rad/s

    % Ordenar de menor a mayor
    [wn_sorted, idx] = sort(wn, 'ascend');
    PhiTemp = PhiTemp(:, idx);

    % Normalizar las formas modales si lo deseas (por ejemplo, 
    % con respecto a la matriz de masa o para que la suma de cuadrados sea 1)
    % Aquí, como ejemplo, se hace una normalización de masa:
    for i = 1:nModes
        % Escala para que PhiTemp(:,i)' * M * PhiTemp(:,i) = 1
        m_norm = sqrt(PhiTemp(:,i)' * M * PhiTemp(:,i));
        PhiTemp(:,i) = PhiTemp(:,i) / m_norm;
    end

    % Salidas
    Phi   = PhiTemp;       % nDOFs x nModes
    Omega = wn_sorted';    % 1 x nModes (frecuencias en rad/s)

end
