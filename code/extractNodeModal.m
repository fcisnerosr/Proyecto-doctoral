function phi_node = extractNodeModal(modalMatrix, nodeID)
% extractNodeModal Extrae las 3 filas correspondientes al nodo dado
%
% Sintaxis:
%   phi_node = extractNodeModal(modalMatrix, nodeID)
%
% Entradas:
%   modalMatrix - Matriz de formas modales de tamaño ((N x 3) x nModes)
%                 donde se asume que las filas se agrupan de a 3 por cada nodo.
%   nodeID      - ID (índice) del nodo del cual se desean extraer los datos modales.
%
% Salida:
%   phi_node    - Matriz de tamaño (3 x nModes) que contiene los valores modales
%                 del nodo identificado (las 3 filas correspondientes).
%
% Ejemplo:
%   % Supongamos que modalMatrix tiene 60 filas (20 nodos x 3 DOF) y 12 modos.
%   phi_node1 = extractNodeModal(modalMatrix, 1);
%   % Esto extrae las filas 1:3 para el nodo 1.

    % Calcular el índice inicial y final para el nodo (3 DOF por nodo)
    startRow = 3 * (nodeID - 1) + 1;
    endRow = 3 * nodeID;
    
    % Extraer las filas correspondientes
    phi_node = modalMatrix(startRow:endRow, :);
end
