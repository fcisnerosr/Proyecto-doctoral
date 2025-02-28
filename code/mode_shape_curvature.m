function curvatura_modal = mode_shape_curvature(modos)
    % Modo de entrada: modos (matriz NxM)
    %   - Cada columna representa una forma modal.
    %   - Cada fila corresponde a un nodo o punto de la estructura.
    % Salida: curvatura_modal (matriz NxM)
    %   - Representa la curvatura modal para cada modo.

    [n_puntos, n_modos] = size(modos);  % Tamaño de la matriz de modos
    curvatura_modal = zeros(n_puntos, n_modos);  % Inicializar matriz de curvaturas

    for j = 1:n_modos  % Iterar sobre cada forma modal
        for i = 2:n_puntos-1  % Diferencias finitas (sin incluir los extremos)
            curvatura_modal(i, j) = modos(i+1, j) - 2 * modos(i, j) + modos(i-1, j);
        end
    end
end
