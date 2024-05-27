%% Condensación estática
function [KG_cond] = condensacion_estatica(KG)
    
    % Prueba con matriz aleatorea de 24 x 24
    % % Generar una matriz aleatoria de 24x24 con valores enteros entre 1 y 5
    % KG = randi([1, 5], 24, 24)
    % 
    % % Hacer que la matriz sea simétrica
    % KG = triu(KG, 1) + triu(KG, 1).' + diag(diag(KG))

    n = length(KG);
    vector = 1:n;
    [order1, order2] = reorganizar_vector(vector);
    order2 = setdiff(order2, order1);
    order  = horzcat(order1,order2);
    % en el vector order se elige cómo irán organizados 
    % las columnas para la reorganización de la matriz de rigidez
    % el espacio en el vector "order" separa los grados que se van
    % a condensar primero y después los GDL a considerar
    % NOTA: Se conservan los grados traslacionales en X y y GLOBAL y la rotación al rededor del Z GLOBAL.
          % El resto de los GDL se van a condensar en la aplicación de la fórmula

    % Formula:
    %     K_tt = K_tt - K_tr' * K_rr^-1 * K_rt
    %                 t = traslación
    %                 r = rotación

    % PRUEBA DE MATRIZ DE MARCO3D
    % order = [1,2,6,7,8,12,13,14,18,19,20,24, 3,4,5,9,10,11,15,16,17,21,22,23];

    
    % PRUEBA CON OTRA MATRIZ MÁS PEQUEÑA
    % KG = [8.8   0.4     0       2       0   0   0       2   -0.24;...
    %       0.4   5.8     0.5     0       2   0   -2      2   0.135;...
    %       0     0.5     9       0       0   2   0       2   0.375;...
    %       2     0       0       4.8     0.4 0   -2      2   -0.24;...
    %       0     2       0       0.4     5.8 0.5 -2      2   0.135;...
    %       0     0       2       0       0.5 5   -2      2   0.375;...
    %       0     -2      0       -2      -2 -2    6.667  -4  0;...
    %       2     2       2       2       2   2   -4      4   0;...
    %       -0.24 0.134   0.375   -0.24   0.135 0.375 0 0 0.567]
    % 
    %     order1 = [7 8];
    %     order2 = [1 2 3 4 5 6 9];
    %     order  = horzcat(order1, order2);
    % 
    % Matriz de permutación
    
    % Matriz de permutación 
    P = eye(length(order));
    P = P(order,:);

    % Reorganizar la matriz de rigidez
    KG_reordered = P * KG * P';
        % Esta matriz tiene los grados traslacionales (X y Y) de cada nodo del marco 
        % y los grados rotacionales alrededor de Z, también de cada nodo en los primeros 12 filas y 12 columnas de la matriz.


    % Discretización de la matriz global con los grados a conservar al inicio de los primeros 12 filas y columnas de la matriz
    lim1 = 'length(order1)';
    lim1 = eval(lim1);
    lim2 = 'length(order2)';
    lim2 = eval(lim2);
    K_tt = KG_reordered(1:lim1,1:lim1);
    K_rr = KG_reordered(lim1+1:lim2*2,lim1+1:lim2*2);
    K_tr = KG_reordered(lim1+1:lim2*2,1:lim1);
    K_tt = KG_reordered(1:lim1,1:lim1);

    % Prueba con matriz más pequeña
    % K_rr = KG_reordered(lim1+1:lim2+ lim1,lim1+1:lim2+ lim1);
    % K_tr = KG_reordered(lim1+1:lim2+ lim1,1:lim1);
    % K_tt = KG_reordered(1:2,1:2);     % Grados traslacionales X y Y y rotacional Z de cada nodo 
    % K_rr = KG_reordered(3:9,3:9);   % Grados restantes a condensar
    % K_tr = KG_reordered(3:9,1:2);    % Grados acoplados restantes también por condesar

    % Prueba con matriz de marco 3d
    %     KG_cond = K_tt - (K_tr' * (K_rr^-1) * K_tr) % Matriz condensada
    % % % Aplicación de la fórmula de condensación estática:    
    % % % Discretización de la matriz global con los grados a conservar al inicio de los primeros 12 filas y columnas de la matriz
    %     K_tt = KG_reordered(1:12,1:12);     % Grados traslacionales X y Y y rotacional Z de cada nodo 
    %     K_rr = KG_reordered(13:24,13:24);   % Grados restantes a condensar
    %     K_tr = KG_reordered(13:24,1:12);    % Grados acoplados restantes también por condesar
    % 
    KG_cond = K_tt - (K_tr' * (K_rr^-1) * K_tr); % Matriz condensada
end
