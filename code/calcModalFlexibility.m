function [F] = calcModalFlexibility(Phi, Omega)
% calcModalFlexibility
%   Dada la matriz de formas modales Phi (nDOFs x nModes) y el
%   vector de frecuencias naturales Omega (1 x nModes) en rad/s,
%   calcula la matriz de flexibilidad modal:
%
%       F = Phi * diag(1./(Omega.^2)) * Phi'
%
%   Asegúrate de que las unidades sean coherentes (Omega en rad/s).
%   F tendrá dimensión (nDOFs x nDOFs).
%
% Entradas:
%   Phi   -> matriz con nModes columnas (cada columna es una forma modal)
%   Omega -> vector (1 x nModes) con las frecuencias naturales (rad/s)
%
% Salida:
%   F     -> matriz (nDOFs x nDOFs) de flexibilidad modal

    % Verificar dimensiones
    [nDOFs, nModes] = size(Phi);
    if length(Omega) ~= nModes
        error('El número de modos en Phi debe coincidir con la longitud de Omega');
    end

    % Calcular la matriz de flexibilidad
    F = Phi * diag(1./(Omega.^2)) * Phi';

end

