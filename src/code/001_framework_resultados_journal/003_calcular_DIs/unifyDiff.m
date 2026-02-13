function Diff_perNode = unifyDiff(DI2_Diff)
% unifyDiff
%   Combina una matriz de diferencias de formas modales (o índices similares)
%   de tamaño (nCoords x nModes) en un único valor por nodo.
%
%   1) Suma la información de los modos con raíz de la suma de cuadrados (RSS),
%      produciendo un vector (nCoords x 1).
%   2) Agrupa cada bloque de gdlPerNode filas (coordenadas) para formar
%      un índice único por nodo (de tamaño nNodes x 1).
%
% Sintaxis:
%   Diff_perNode = unifyDiff(DI2_Diff, gdlPerNode)
%
% Entradas:
%   DI2_Diff   -> matriz de tamaño (nCoords x nModes), donde:
%                 - nCoords = número total de coordenadas (nodos*gdlPerNode)
%                 - nModes  = número de modos considerados
%   gdlPerNode -> grados de libertad por nodo (ej. 3 si x,y,z)
%
% Salida:
%   Diff_perNode -> vector columna (nNodes x 1), índice unificado por nodo.
%
% Ejemplo de uso:
%   % Supongamos que DI2_Diff es 60x12, con 20 nodos y 3 GDL por nodo
%   Diff_perNode = unifyDiff(DI2_Diff, 3);
%   % Diff_perNode será 20x1

    gdlPerNode = 3;

    [nCoords, nModes] = size(DI2_Diff);

    % 1) Combinar los nModes en un solo valor por coordenada (fila)
    %    usando la raíz de la suma de cuadrados
    Diff_perCoord = zeros(nCoords, 1);
    for i = 1:nCoords
        rowVals = DI2_Diff(i, :);   % los nModes valores para la coord i
        Diff_perCoord(i) = sqrt(sum(rowVals.^2));
    end

    % 2) Verificar que nCoords sea múltiplo de gdlPerNode
    if mod(nCoords, gdlPerNode) ~= 0
        error('El número de filas (%d) no es múltiplo de gdlPerNode (%d).', ...
               nCoords, gdlPerNode);
    end

    % Calcular número de nodos
    nNodes = nCoords / gdlPerNode;

    % 3) Agrupar cada bloque de gdlPerNode para formar un índice por nodo
    Diff_perNode = zeros(nNodes, 1);
    idx = 1;
    for nodo = 1:nNodes
        chunk = Diff_perCoord(idx : idx+gdlPerNode-1);
        % Raíz de la suma de cuadrados para unificar las gdl de ese nodo
        Diff_perNode(nodo) = sqrt(sum(chunk.^2));
        idx = idx + gdlPerNode;
    end

end
