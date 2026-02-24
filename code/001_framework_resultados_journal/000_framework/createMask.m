function mask = createMask(firstNode, lastNode, modalMatrix, numFixedNodes)
% createMask  Genera máscara sabiendo que se han eliminado los 'numFixedNodes' 
%             primeros nodos de modalMatrix.
%
% Inputs:
%  firstNode     – Primer nodo a enmascarar (ID real, p.e. 41)
%  lastNode      – Último nodo a enmascarar  (ID real, p.e. 52)
%  modalMatrix   – Matriz de modos (totalDOF×nModes) tras la condensación
%  numFixedNodes – Cuántos nodos fijos (y sus DOF) ya no están en modalMatrix
%
% Output:
%  mask          – Vector (totalDOF×1) con 1 en DOF incluidos, 0 en excluidos

    if nargin<4, numFixedNodes = 0; end
    totalDOF   = size(modalMatrix,1);
    dofPerNode = 3;                  % tras la estática, quedaron sólo 3 DOF por nodo
    totalNodes = totalDOF / dofPerNode;
    
    mask = ones(totalDOF,1);
    
    % Convertir el ID real de nodo al índice “local” de modalMatrix
    for nod = firstNode:lastNode
        localNod = nod - numFixedNodes;
        if localNod<1 || localNod>totalNodes
            error('Nodo %d queda fuera de rango tras quitar %d nodos fijos', ...
                  nod, numFixedNodes);
        end
        startRow = (localNod-1)*dofPerNode + 1;
        endRow   = localNod*dofPerNode;
        mask(startRow:endRow) = 0;
    end
end
