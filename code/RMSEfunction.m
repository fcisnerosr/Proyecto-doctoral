function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
    L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
    vxz, elem_con_dano_long_NE,...
    modos_cond_d)
    x
    % Inicializa la variable objetivo
    Objetivo  = 0;
    
    % Pesos para las funciones objetivo
    w1 = 0.6;  % Peso al RMSE
    w2 = 0.4;  % Peso al MACN
    
    % Recorta las propiedades a la subestructura
    L_sub  = L(1:num_element_sub);   
    A_sub  = A(1:num_element_sub);   
    Iy_sub = Iy(1:num_element_sub);  
    Iz_sub = Iz(1:num_element_sub);
    E_sub  = E(1:num_element_sub);
    G_sub  = G(1:num_element_sub);
    J_sub  = J(1:num_element_sub);
    
    % Recorre cada uno de los num_element_sub elementos para aplicar el daño
    for i = 1:num_element_sub
        % Matriz de rigidez local
        ke_AG = zeros(12,12);
        
        % Aplica daño por corrosión
        A_damaged  = A_sub(i)  * (1 - x(3*i - 2));  
        Iy_damaged = Iy_sub(i) * (1 - x(3*i - 1));  
        Iz_damaged = Iz_sub(i) * (1 - x(3*i)); 
        
        % Modifica los términos afectados en la matriz de rigidez local
        ke_AG(1, 1) =  E_sub(i) * A_damaged / L_sub(i);  
        ke_AG(1, 7) = -E_sub(i) * A_damaged / L_sub(i);  
        ke_AG(7, 1) = -E_sub(i) * A_damaged / L_sub(i);  
        ke_AG(7, 7) =  E_sub(i) * A_damaged / L_sub(i);  
        
        % Modificar los términos relacionados con la inercia Iy
        ke_AG(2, 2) =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;  
        ke_AG(8, 8) =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;  
        ke_AG(2, 8) = -12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
        ke_AG(8, 2) = -12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
        
        ke_AG(5, 5)   = 4 * E_sub(i) * Iy_damaged / L_sub(i);   
        ke_AG(11, 11) = 4 * E_sub(i) * Iy_damaged / L_sub(i);
        
        ke_AG(5, 3)  = -6 * E_sub(i) * Iy_damaged / L_sub(i)^2;  
        ke_AG(9, 3)  =  6 * E_sub(i) * Iy_damaged / L_sub(i)^2;   
        ke_AG(11, 3) = -6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
        ke_AG(5, 9)  =  6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
        
        % Modificar los términos relacionados con la inercia Iz
        ke_AG(3, 3) =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;  
        ke_AG(9, 9) =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;  
        ke_AG(3, 9) = -12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
        ke_AG(9, 3) = -12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
        
        ke_AG(6, 6)   = 4 * E_sub(i) * Iz_damaged / L_sub(i);   
        ke_AG(12, 12) = 4 * E_sub(i) * Iz_damaged / L_sub(i);
        
        ke_AG(6, 2)  =  6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
        ke_AG(12, 2) = -6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
        ke_AG(6, 8)  =  6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
        ke_AG(12, 8) = -6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
        
        % Valores de torsion que no se alteran
        ke_AG(4,4)     = (G_sub(i)*J_sub(i))/L_sub(i);
        ke_AG(10,10)   = (G_sub(i)*J_sub(i))/L_sub(i);
        ke_AG(10,4)    = (-G_sub(i)*J_sub(i))/L_sub(i);
        ke_AG(4,10)    = (-G_sub(i)*J_sub(i))/L_sub(i);
        
        % Reensamblar la matriz global de rigidez
        [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
    end
    
    % Condensación estática de matrices globales
    KG_AG_cond              = condensacion_estatica_AG(KG_AG);
    [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond);
    
    % RMSE y MACN (MAC Normalizado)
    SumRMSEVal = 0;
    for i = 1:length(frec_AG)
        SumRMSEVal = SumRMSEVal + (frec_AG(i) - frec_cond_d(i))^2;
    end
    RMSE = sqrt(SumRMSEVal / length(frec_AG));

    % Calcular el MACN para formas modales
    macn_value = 0;
    for i = 1:size(modos_cond_d, 2)
        num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;
        den = (modos_cond_d(:,i)' * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * modos_AG_cond(:,i));
        MAC_value = num / den;
        macn_value = macn_value + sqrt((1 - MAC_value) / MAC_value);
    end
    macn_value = macn_value / size(modos_cond_d, 2);  % Promedio de MACN

    % Combinar en una función objetivo ponderada
    Objetivo = w1 * RMSE + w2 * (1 - macn_value);
end


%
% function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
%     L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
%     vxz, elem_con_dano_long_NE,...
%     modos_cond_d)
%     % Inicializa la variable objetivo
%     Objetivo  = 0;
%
%     % Pesos para las funciones objetivo
%     w1 = 0.6;  % Peso al RMSE
%     w2 = 0.4;  % Peso al MACN
%
%     % Recorta las propiedades a la subestructura
%     L_sub  = L(1:num_element_sub);
%     A_sub  = A(1:num_element_sub);
%     Iy_sub = Iy(1:num_element_sub);
%     Iz_sub = Iz(1:num_element_sub);
%     E_sub  = E(1:num_element_sub);
%     G_sub  = G(1:num_element_sub);
%     J_sub  = J(1:num_element_sub);
%
%     % Recorre cada uno de los num_element_sub elementos para aplicar el daño
%     for i = 1:num_element_sub
%         % Matriz de rigidez local
%         ke_AG = zeros(12,12);
%
%         % Aplica daño por corrosión
%         A_damaged  = A_sub(i)  * (1 - x(3*i - 2));
%         Iy_damaged = Iy_sub(i) * (1 - x(3*i - 1));
%         Iz_damaged = Iz_sub(i) * (1 - x(3*i));
%
%         % Modifica los términos afectados en la matriz de rigidez local
%         ke_AG(1, 1) =  E_sub(i) * A_damaged / L_sub(i);
%         ke_AG(1, 7) = -E_sub(i) * A_damaged / L_sub(i);
%         ke_AG(7, 1) = -E_sub(i) * A_damaged / L_sub(i);
%         ke_AG(7, 7) =  E_sub(i) * A_damaged / L_sub(i);
%
%         % Modificar los términos relacionados con la inercia Iy
%         ke_AG(2, 2) =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
%         ke_AG(8, 8) =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
%         ke_AG(2, 8) = -12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
%         ke_AG(8, 2) = -12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
%
%         ke_AG(5, 5)   = 4 * E_sub(i) * Iy_damaged / L_sub(i);
%         ke_AG(11, 11) = 4 * E_sub(i) * Iy_damaged / L_sub(i);
%
%         ke_AG(5, 3)  = -6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
%         ke_AG(9, 3)  =  6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
%         ke_AG(11, 3) = -6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
%         ke_AG(5, 9)  =  6 * E_sub(i) * Iy_damaged / L_sub(i)^2;
%
%         % Modificar los términos relacionados con la inercia Iz
%         ke_AG(3, 3) =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
%         ke_AG(9, 9) =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
%         ke_AG(3, 9) = -12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
%         ke_AG(9, 3) = -12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
%
%         ke_AG(6, 6)   = 4 * E_sub(i) * Iz_damaged / L_sub(i);
%         ke_AG(12, 12) = 4 * E_sub(i) * Iz_damaged / L_sub(i);
%
%         ke_AG(6, 2)  =  6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
%         ke_AG(12, 2) = -6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
%         ke_AG(6, 8)  =  6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
%         ke_AG(12, 8) = -6 * E_sub(i) * Iz_damaged / L_sub(i)^2;
%
%         % Valores de torsion que no se alteran
%         ke_AG(4,4)     = (G_sub(i)*J_sub(i))/L_sub(i);
%         ke_AG(10,10)   = (G_sub(i)*J_sub(i))/L_sub(i);
%         ke_AG(10,4)    = (-G_sub(i)*J_sub(i))/L_sub(i);
%         ke_AG(4,10)    = (-G_sub(i)*J_sub(i))/L_sub(i);
%
%         % Reensamblar la matriz global de rigidez
%         [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
%     end
%
%     % Condensación estática de matrices globales
%     [KG_AG_cond]            = condensacion_estatica_AG(KG_AG);
%     [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond);
%
%     % Funcion objetivo
%     SumRMSEVal = 0;
%     for i = 1:length(frec_AG)
%         SumRMSEVal = SumRMSEVal + (frec_AG(i) - frec_cond_d(i))^2;
%     end
%     RMSE = sqrt(SumRMSEVal / length(frec_AG));
%
%     % Calcular el MACN para formas modales
%     macn_value = 0;
%     for i = 1:size(modos_cond_d, 2)
%         num = (modos_cond_d(:,i)' * M_cond * modos_AG_cond(:,i))^2;
%         den = (modos_cond_d(:,i)' * M_cond * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * M_cond * modos_AG_cond(:,i));
%         MAC_value = num / den;
%         macn_value = macn_value + sqrt((1 - MAC_value) / MAC_value);
%     end
%     macn_value = macn_value / size(modos_cond_d, 2);  % Promedio de MACN
%
%     % Combinar en una función objetivo ponderada
%     Objetivo = w1 * RMSE + w2 * (1 - macn_value);
% end
%



