function DivF = calcDivFjR(phi_AG, T_AG, phi_damaged, T_damaged)
% calcDivFjR Calcula el índice DivFjR (división de la flexibilidad) por nodo.
%
% Entradas:
%   phi_AG      : Matriz de formas modales del modelo generado por el AG (N x M).
%   T_AG        : Vector de períodos de vibración (en segundos) para el modelo generado.
%   phi_damaged : Matriz de formas modales del modelo dañado (N x M).
%   T_damaged   : Vector de períodos de vibración (en segundos) para el modelo dañado.
%
% Salida:
%   DivF        : Vector (n_nodes x 1) con el índice DivFjR para cada nodo, definido como:
%                 DivFjR(j) = Flex_gen(j) / Flex_damaged(j),
%                 donde Flex_gen y Flex_damaged son la flexibilidad nodal resultante.
%
% Se utiliza la función calcFlexibility para calcular la matriz de flexibilidad.
%
% Se intenta determinar automáticamente el número de DOF por nodo:
%   - Si N es divisible por 3 se asume 3 DOF por nodo.
%   - Si no, si es divisible por 2 se asume 2 DOF por nodo.
%   - En otro caso se asume 1 DOF por nodo.

    % Calcular las matrices de flexibilidad para ambos modelos
    F_AG = calcFlexibility(phi_AG, T_AG);
    F_damaged = calcFlexibility(phi_damaged, T_damaged);
    
    % Número total de DOF (N) y determinar DOF por nodo
    N = size(F_AG, 1);
    if mod(N,3) == 0
        dof_per_node = 3;
    elseif mod(N,2) == 0
        dof_per_node = 2;
    else
        dof_per_node = 1;
    end
    
    % Número de nodos
    n_nodes = N / dof_per_node;
    
    % Inicializar vectores para la flexibilidad nodal
    Flex_AG = zeros(n_nodes, 1);
    Flex_damaged = zeros(n_nodes, 1);
    
    % Para cada nodo, se extraen los DOF correspondientes y se calcula un
    % valor representativo de la flexibilidad. Aquí se usa la norma de la
    % diagonal del bloque asociado.
    for j = 1:n_nodes
        idx = (j-1)*dof_per_node + (1:dof_per_node);
        Flex_AG(j) = norm(diag(F_AG(idx, idx)));
        Flex_damaged(j) = norm(diag(F_damaged(idx, idx)));
    end
    
    % Índice DivFjR: razón de la flexibilidad generada sobre la dañada
    DivF = Flex_AG ./ Flex_damaged;
end
