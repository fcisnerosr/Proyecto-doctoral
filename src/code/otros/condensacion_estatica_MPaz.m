%% Condensación estática
function [KG_cond,M_cond,KG_reordered] = condensacion_estatica_MPaz(KG,M)
    %% Estructura condensada
        %% Reorganización de los modos a condensar
            % Grados de libertad de la estructura en el orden deseado
                % order = [1, 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];
%             order = [3,4,5,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,  1,2,6];
            order = [3,4,5,9,10,11,15,16,17,21,22,23,  1,2,6, 7,8,12, 13,14,18, 19,20,24];
            % en el vector order se elige cómo irán organizados 
            % las columnas para la reorganización de la matriz de rigidez
            % el espacio en el vector "order" separa los grados que se van
            % a condensar primero y después los GDL a considerar

            % Crear la matriz de permutación
            P = eye(length(order));
            P = P(order,:);
            

            % Reorganizar la matriz de rigidez
            KG_reordered = P * KG * P';
         
            %% Eliminación mediante Gauss-Jordan
            % Elegir los índices de fila para los pivotes (por ejemplo, [1, 2])
%             pivot_indices = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21];
            pivot_indices = [1,2,3,4,5,6,7,8,9,10,11,12];
            % Los elementos en el pivot_indices son los NGDL omitidos,
            % no tiene nada que ver con los NDGL de la matriz de rigidez original
    
            % Aplicar eliminación gaussiana personalizada con múltiples pivotes
            KG_gauss = custom_gaussian_elimination_multiple_pivots(KG_reordered, pivot_indices)
               
%             KG_cond = KG_gauss(22:24,22:24)
%             KG_cond = KG_gauss(23:24,23:24)

%             T = -1*KG_gauss(1:21,22:24)
%             T = -1*KG_gauss(1:22,23:24)
%             KG_cond = KG_gauss(22:24,22:24)
%             KG_cond = KG_gauss(23:24,23:24)
%             I = eye(24-length(pivot_indices));
%             T = vertcat(T,I);
            % Comprobación
%                 fprintf('Comprobación \n')
%                 KG_cond_comprobacion = T'*KG_reordered*T
%             %% Condensación de matriz de masas
%             M_cond = T'*M*T
end
