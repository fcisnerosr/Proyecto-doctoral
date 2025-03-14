function COMAC_sqrt = computeCOMACSqrt(COMAC)
% computeCOMACSqrt  Calcula el índice unificado para COMAC en grupos de 3.
%
% Sintaxis:
%   COMAC_sqrt = computeCOMACSqrt(COMAC)
%
% Descripción:
%   Esta función toma un vector COMAC cuya longitud debe ser un múltiplo de 3.
%   Divide el vector en grupos de 3 elementos y, para cada grupo, calcula:
%
%       DI = sqrt( (v1)^2 + (v2)^2 + (v3)^2 )
%
%   De esta forma se obtiene un único valor (escala) para cada grupo.
%   La salida es un vector columna de tamaño (nGrupos x 1), donde cada 
%   elemento corresponde a un nodo unificado.
%
% Ejemplo:
%   COMAC = [0.16167; 0.14099; 0.1632; 0.13848; 0.26948; 0.14315];
%   COMAC_sqrt = computeCOMACSqrt(COMAC);
%   % COMAC_sqrt tendrá tamaño 2x1.

    n = numel(COMAC);
    if mod(n, 3) ~= 0
        error('La longitud de COMAC debe ser un múltiplo de 3.');
    end

    numGrupos = n / 3;
    COMAC_sqrt = zeros(numGrupos, 1);  % Vector columna

    idx = 1;
    for k = 1:numGrupos
        chunk = COMAC(idx:idx+2);
        % Calcular la raíz de la suma de cuadrados
        chunk_RSS = sqrt(sum(chunk.^2));
        COMAC_sqrt(k) = chunk_RSS;
        idx = idx + 3;
    end
end
