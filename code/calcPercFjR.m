function PercF = calcPercFjR(phi_AG, T_AG, phi_damaged, T_damaged)
% calcPercFjR Calcula el índice PercFjR (porcentaje de diferencia en la flexibilidad) por nodo.
%
% Entradas:
%   phi_AG      : Matriz de formas modales del modelo generado por el AG (N x M).
%   T_AG        : Vector de períodos de vibración (en segundos) para el modelo generado.
%   phi_damaged : Matriz de formas modales del modelo dañado (N x M).
%   T_damaged   : Vector de períodos de vibración (en segundos) para el modelo dañado.
%
% Salida:
%   PercF       : Vector (n_nodes x 1) con el índice PercFjR para cada nodo, definido como:
%                 PercFjR(j) = 100 * (Flex_gen(j) - Flex_damaged(j)) / Flex_damaged(j),
%                 expresado en porcentaje.
%
% Se utiliza la función calcFlexibility para obtener las matrices de flexibilidad.
%
% Se determina automáticamente el número de DOF por nodo (ver comentario en calcDivFjR).

    % Calcular las matrices de flexibilidad para ambos modelos
    F_AG = calcFlexibility(phi_AG, T_AG);
    F_damaged = calcFlexibility(phi_damaged, T_damaged);
    
    % Número total de DOF y determinación automática de dof_per_node
    N = size(F_AG, 1);
    if mod(N,3) == 0
        dof_per_node = 3;
    elseif mod(N,2) == 0
        dof_per_node = 2;
    else
        dof_per_node = 1;
    end
    n_nodes = N / dof_per_node;
    
    % Inicializar vectores para la flexibilidad nodal
    Flex_AG = zeros(n_nodes, 1);
    Flex_damaged = zeros(n_nodes, 1);
    
    for j = 1:n_nodes
        idx = (j-1)*dof_per_node + (1:dof_per_node);
        Flex_AG(j) = norm(diag(F_AG(idx, idx)));
        Flex_damaged(j) = norm(diag(F_damaged(idx, idx)));
    end
    
    % Índice PercFjR: cambio porcentual en la flexibilidad
    PercF = 100 * (Flex_AG - Flex_damaged) ./ Flex_damaged;
end
