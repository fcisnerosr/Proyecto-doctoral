%% Condensación dinámica
function [KG_cond_D,M_cond_D] = condensacion_dinamica(KG,frecuencias,KG_reordered,M)
    for i = 1:1
        n = size(KG);
        diagonal_matrix = -abs(frecuencias(1)^2*(2*pi)) * eye(n(1));
        KG_reordered = KG_reordered + diagonal_matrix;
        %% Eliminación mediante Gauss-Jordan
        % Elegir los índices de fila para los pivotes (por ejemplo, [1, 2])
        pivot_indices = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21];
        % Los elementos en el pivot_indices son los NGDL omitidos,
        % no tiene nada que ver con los NDGL de la matriz de rigidez origina
        KG_gauss = custom_gaussian_elimination_multiple_pivots(KG_reordered, pivot_indices);
                       
        KG_cond_D = KG_gauss(22:24,22:24);

        T = KG_gauss(1:21,22:24);
        I = eye(24-length(pivot_indices));
        T = vertcat(-T,I);
        % Comprobación
            % fprintf('Comprobación \n')
            % KG_cond_comprobacion = T'*KG_reordered*T;
        %% Condensación de matriz de masas
        M_cond_D = T'*M*T
    end
end
