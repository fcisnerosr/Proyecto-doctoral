function check_symmetry(ke_AG_tensor)
    % Obtener el tamaño de la matriz
    [rows, cols, num_matrices] = size(ke_AG_tensor);
    
    % Verificar si la matriz es cuadrada
    if rows ~= cols
        error('Las matrices deben ser cuadradas para verificar simetría.');
    end

    % Iterar sobre cada capa (página) de la matriz 3D
    for i = 1:num_matrices
        % Extraer la matriz actual
        ke_matrix = ke_AG_tensor(:,:,i);
        
        % Verificar simetría: debe ser igual a su transpuesta
        if isequal(ke_matrix, ke_matrix')
            fprintf('La matriz %d es simétrica.\n', i);
        else
            fprintf('La matriz %d NO es simétrica.\n', i);
            
            % Opcional: Mostrar la diferencia
            diff_matrix = ke_matrix - ke_matrix';
            disp('Diferencias entre la matriz y su transpuesta:')
            disp(diff_matrix)
        end
    end
end
