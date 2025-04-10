function mask = createMask(firstNode, lastNode, modalMatrix)
% createMask Genera una máscara para excluir nodos, calculando internamente
%            el número total de nodos a partir de la matriz modal.
%
% Sintaxis:
%   mask = createMask(firstNode, lastNode, modalMatrix)
%
% Entradas:
%   firstNode  - ID del primer nodo a excluir (por ejemplo, 17)
%   lastNode   - ID del último nodo a excluir (por ejemplo, 20)
%   modalMatrix- Matriz de formas modales de tamaño (totalDOF x nModes),
%                donde totalDOF es el número total de DOF. Se asume que
%                cada nodo tiene 3 DOF.
%
% Salida:
%   mask       - Vector columna de tamaño (totalDOF x 1) con valores 1 para
%                los DOF que se incluyen y 0 para los DOF que se excluyen.
%
% Ejemplo:
%   % Si modalMatrix tiene 60 filas (20 nodos * 3 DOF):
%   mask = createMask(17, 20, modalMatrix);

    % Número de DOF totales
    totalDOF = size(modalMatrix, 1);
    dofPerNode = 3;  % Se asume que cada nodo tiene 3 DOF.
    
    % Calcular el número total de nodos a partir de la matriz modal.
    totalNodes = totalDOF / dofPerNode;
    
    % Inicializar la máscara con 1's para todos los DOF.
    mask = ones(totalDOF, 1);
    
    % Recorrer cada nodo a excluir (desde firstNode hasta lastNode)
    for node = firstNode:lastNode
        % Calcular la fila inicial para el nodo 'node'
        startRow = dofPerNode * (node - 1) + 1;
        % Calcular la fila final para el nodo 'node'
        endRow = dofPerNode * (node - 1) + dofPerNode;
        
        % Asignar 0 a los DOF correspondientes para excluir ese nodo.
        mask(startRow:endRow) = 0;
    end
end
