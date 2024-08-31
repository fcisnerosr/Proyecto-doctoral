%% Condensación estática
function [KG_AG_cond] = condensacion_estatica_AG(KG_AG,M_cond)
    n = length(KG_AG);
    vector = 1:n;
    [order1, order2] = reorganizar_vector(vector);
    order2 = setdiff(order2, order1);
    order  = horzcat(order1,order2);
    % en el vector order se elige cómo irán organizados 
    % las columnas para la reorganización de la matriz de rigidez
    % el espacio en el vector "order" separa los grados que se van
    % a condensar primero y después los GDL a considerar
    % NOTA: Se conservan los grados traslacionales en X, Y y Z local y se condensan las rotaciones al rededor de cada eje local
          % El resto de los GDL se van a condensar en la aplicación de la fórmula

    % Formula:
    %     K_tt = K_tt - K_tr' * K_rr^-1 * K_rt
    %                 t = traslación
    %                 r = rotación

    % Matriz de permutación 
    P = eye(length(order));
    P = P(order,:);

    % Reorganizar la matriz de rigidez
    KG_reordered = P * KG_AG * P';
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

    KG_AG_cond = K_tt - (K_tr' * (K_rr^-1) * K_tr); % Matriz condensada
end
