function Diff_perNode = unifyDiffVector(DI_vector, gdlPerNode)
% unifyDiffVector Agrupa un vector de diferencias en un índice unificado por nodo.
%
%   Diff_perNode = unifyDiffVector(DI_vector, gdlPerNode)
%
% Entradas:
%   DI_vector  - Vector de diferencia (por ejemplo, la diagonal de DI4_Diff_Flex)
%                con tamaño (nCoords x 1), donde nCoords = nNodes * gdlPerNode.
%   gdlPerNode - Número de grados de libertad por nodo (por ejemplo, 3).
%
% Salida:
%   Diff_perNode - Vector columna (nNodes x 1) con el índice unificado por nodo.
%
% Ejemplo:
%   diff_diag = diag(DI4_Diff_Flex); % DI4_Diff_Flex es 60x60, diff_diag es 60x1.
%   Diff_perNode = unifyDiffVector(diff_diag, 3); % Devuelve un vector 20x1.
    
    nCoords = numel(DI_vector);
    if mod(nCoords, gdlPerNode) ~= 0
        error('La longitud del vector (%d) no es múltiplo de gdlPerNode (%d).', nCoords, gdlPerNode);
    end

    nNodes = nCoords / gdlPerNode;
    Diff_perNode = zeros(nNodes, 1);
    for nodo = 1:nNodes
        idx_start = (nodo - 1) * gdlPerNode + 1;
        chunk = DI_vector(idx_start : idx_start + gdlPerNode - 1);
        Diff_perNode(nodo) = sqrt(sum(chunk .^ 2));
    end
end
