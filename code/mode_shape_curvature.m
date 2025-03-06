% function curvatura_modal = mode_shape_curvature(modos)
%     % Modo de entrada: modos (matriz NxM)
%     %   - Cada columna representa una forma modal.
%     %   - Cada fila corresponde a un nodo o punto de la estructura.
%     % Salida: curvatura_modal (matriz NxM)
%     %   - Representa la curvatura modal para cada modo.
% 
%     [n_puntos, n_modos] = size(modos);  % Tamaño de la matriz de modos
%     curvatura_modal = zeros(n_puntos, n_modos);  % Inicializar matriz de curvaturas
% 
%     for j = 1:n_modos  % Iterar sobre cada forma modal
%         for i = 2:n_puntos-1  % Diferencias finitas (sin incluir los extremos)
%             curvatura_modal(i, j) = modos(i+1, j) - 2 * modos(i, j) + modos(i-1, j);
%         end
%     end
% end

% function curvatura_modal = mode_shape_curvature(modos, L)
%     [n_puntos, n_modos] = size(modos)
%     curvatura_modal = zeros(n_puntos, n_modos);
% 
%     for j = 1:n_modos
%         for i = 2:n_puntos-1            
%             h = (L(i-1) + L(i)) / 2;  % <-- Asegúrate de que i e i-1 no excedan length(L)
%             curvatura_modal(i, j) = ...
%                 (modos(i+1, j) - 2 * modos(i, j) + modos(i-1, j)) / (h^2);
%             % if i == length(L)
%             %     break
%             % end
%         end
%     end
% end

function curvatura_modal = mode_shape_curvature(modos, L)
    % L: vector de longitudes de los elementos tubulares (56 elementos)
    % Se espera que el número de nodos físicos sea length(L) + 1 = 57.
    n_physical = length(L) + 1;  % 57 nodos físicos
    n_modos = size(modos, 2);
    
    % Extraemos solo los nodos físicos de "modos"
    modos_physical = modos(1:n_physical, :);
    
    curvatura_modal = zeros(n_physical, n_modos);

    % Calculamos la curvatura para los nodos intermedios
    for j = 1:n_modos
        for i = 2:n_physical-1
            h = (L(i-1) + L(i)) / 2;  % Promedio de las longitudes adyacentes
            curvatura_modal(i, j) = (modos_physical(i+1, j) - 2 * modos_physical(i, j) + modos_physical(i-1, j)) / (h^2);
        end
    end
end
