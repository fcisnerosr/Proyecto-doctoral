function x_norm = normalizeTo01(x)
% normalizeTo01  Escala un vector x al rango [0, 1] usando min-max.
%
% Sintaxis:
%   x_norm = normalizeTo01(x)
%
% Descripción:
%   Calcula x_norm = (x - xmin) / (xmax - xmin), donde xmin = min(x) y
%   xmax = max(x). Si xmin = xmax, x_norm se devuelve como un vector de ceros.
%
% Entradas:
%   x - vector numérico (por ejemplo, 20x1) a normalizar.
%
% Salida:
%   x_norm - vector del mismo tamaño que x, con valores en [0, 1].
%
% Ejemplo:
%   x = [5; 7; 10; 8];
%   x_norm = normalizeTo01(x);
%   % x_norm estará entre 0 y 1.

    % Verificar que x sea vector
    if ~isvector(x)
        error('La entrada debe ser un vector.');
    end

    % Convertir a vector columna si fuera necesario
    x = x(:);

    xmin = min(x);
    xmax = max(x);

    % Manejo del caso donde todos los valores son iguales
    if abs(xmax - xmin) < 1e-14
        % Si el vector es constante, todos los valores se asignan a 0
        x_norm = zeros(size(x));
    else
        x_norm = (x - xmin) / (xmax - xmin);
    end
end
