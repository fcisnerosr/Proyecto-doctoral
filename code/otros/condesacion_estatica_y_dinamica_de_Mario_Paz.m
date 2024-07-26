%% Condesación estática y dinámica de Mario Paz
function [M_cond,KG_cond] = condesacion_estatica_y_dinamica_de_Mario_Paz(KG,D,t)
    order = [3,4,5,9,10,11,15,16,17,21,22,23 1,2,6,7,8,12,13,14,18,19,20,24];
        % el vector order primero acomoda los grados por condensar y después los grados a conservar
    P = eye(length(order));
    P = P(order,:); 
    KG_reordered = P * KG * P';

    pivot_indices = [1,2,3,4,5,6,7,8,9,10,11,12];                                           % número de grados de libertad a condensar
    KG_gauss = custom_gaussian_elimination_multiple_pivots(KG_reordered, pivot_indices);    % Eliminación de Gauss Jordan

    KG_cond = KG_gauss(13:24,13:24);                                                        % Matriz de masa completa
    T       = KG_gauss(1:12,13:24);                                                         
    I       = eye(24-length(pivot_indices));
    T       = vertcat(-T,I);                                                                % Matriz de transformación
    M_cond  = matriz_de_masas_diagonal(D,t);                                               % Matriz de masa completa completamente diagonal 
    M_cond  = T' * M_cond * T;                                                              % Matriz de masa condensada

    %% Eigen datos
    %% Matriz condensada
        [modos_cond, wn2_cond] = eig(KG_cond,M_cond);
         wn2_cond = sort(diag(wn2_cond))
        frec_cond = diag(((wn2_cond).^0.5)/(2*pi))

%     % Condesación dinámica
%         for i = 1:2
%         n = size(KG);
%         diagonal_matrix = -wn2_cond(3)  * eye(n(1))
%         KG_reordered = KG_reordered + diagonal_matrix
%         %% Eliminación mediante Gauss-Jordan
%         % Elegir los índices de fila para los pivotes (por ejemplo, [1, 2])
%         pivot_indices = [1,2,3,4,5,6,7,8,9,10,11,12];
%         % Los elementos en el pivot_indices son los NGDL omitidos,
%         % no tiene nada que ver con los NDGL de la matriz de rigidez origina
%         KG_gauss = custom_gaussian_elimination_multiple_pivots(KG_reordered, pivot_indices);
%         
%         T = KG_gauss(1:12,13:24);
%         I = eye(24-length(pivot_indices));
%         T = vertcat(-T,I);      
% 
%         D_i = KG_gauss(13:24,13:24);
% 
%         M_cond  = matriz_de_masas_diagonal(D,t);
%         M_cond_D = T'*M_cond*T;
%         
%         KG_cond_D = D_i +  wn2_cond(3) * M_cond_D
%         
%         [modos_cond, wn2_cond] = eig(KG_cond_D,M_cond_D);
%          wn2_cond = sort(diag(wn2_cond))
%         frec_cond = diag(((wn2_cond).^0.5)/(2*pi))
%                 
%     end
end
