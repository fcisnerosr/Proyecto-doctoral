function [Objective] = RMSEfunction(x, k, M_global, frec_mod, modos_mod, ...
        L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
        vxz, elem_con_dano_long_NE, phi_intacta, phi_danada, M, Dd)

    % Pesos para la función objetivo combinada
    w1 = 0.6;  % Peso para RMSE
    w2 = 0.4;  % Peso para MACN

    % Recorre cada uno de los 116 elementos para aplicar el daño
    for i = 1:NE
        % Matriz de rigidez local para el elemento i
        ke_AG = zeros(12,12);

        % Aplicar daño por corrosión a las tres propiedades del elemento i
        A_damaged  = A(i)  * (1 - x(3*i - 2));  % El área se reduce debido a la corrosión
        Iy_damaged = Iy(i) * (1 - x(3*i - 1));  % Inercia en Y se reduce debido a la corrosión
        Iz_damaged = Iz(i) * (1 - x(3*i));      % Inercia en Z se reduce debido a la corrosión

        % Modifica los términos afectados en la matriz de rigidez local
        ke_AG(1, 1) =  E * A_damaged / L(i);  
        ke_AG(1, 7) = -E * A_damaged / L(i);
        ke_AG(7, 1) = -E * A_damaged / L(i);
        ke_AG(7, 7) =  E * A_damaged / L(i);
        
        ke_AG(2, 2) =  12 * E * Iy_damaged / L(i)^3;
        ke_AG(8, 8) =  12 * E * Iy_damaged / L(i)^3;
        ke_AG(2, 8) = -12 * E * Iy_damaged / L(i)^3;
        ke_AG(8, 2) = -12 * E * Iy_damaged / L(i)^3;
        
        ke_AG(5, 5)   = 4 * E * Iy_damaged / L(i);
        ke_AG(11, 11) = 4 * E * Iy_damaged / L(i);
        
        ke_AG(5, 3)  = -6 * E * Iy_damaged / L(i)^2;
        ke_AG(9, 3)  =  6 * E * Iy_damaged / L(i)^2;
        ke_AG(11, 3) = -6 * E * Iy_damaged / L(i)^2;
        ke_AG(5, 9)  =  6 * E * Iy_damaged / L(i)^2;
        
        ke_AG(3, 3) =  12 * E * Iz_damaged / L(i)^3;
        ke_AG(9, 9) =  12 * E * Iz_damaged / L(i)^3;
        ke_AG(3, 9) = -12 * E * Iz_damaged / L(i)^3;
        ke_AG(9, 3) = -12 * E * Iz_damaged / L(i)^3;
        
        ke_AG(6, 6)   = 4 * E * Iz_damaged / L(i);
        ke_AG(12, 12) = 4 * E * Iz_damaged / L(i);
        
        ke_AG(6, 2)  =  6 * E * Iz_damaged / L(i)^2;
        ke_AG(12, 2) = -6 * E * Iz_damaged / L(i)^2;
        ke_AG(6, 8)  =  6 * E * Iz_damaged / L(i)^2;
        ke_AG(12, 8) = -6 * E * Iz_damaged / L(i)^2;
                
        % Reensamblar la matriz global de rigidez
        [KG_AG] = ensamblaje_matriz_rigidez_global_AG(ID, NE, ke_AG,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);

        % Condensación estática de matrices globales
        [K_cond, M_cond] = condensacion_estatica(KG_AG, M_global);
        [frec_ga, modos_ga] = eig(K_cond, M_cond);
    end
    
    % Calcular RMSE para las frecuencias
    SumRMSEVal = 0;
    for i = 1:length(frec_mod)
        SumRMSEVal = SumRMSEVal + (1/frec_mod(i) - 1/frec_ga(i))^2;
    end
    RMSE = (SumRMSEVal / length(frec_mod))^0.5;

    % Calcular el MACN para formas modales
    macn_value = 0;
    for i = 1:size(phi_intacta, 2)
        num = (phi_intacta(:,i)' * M * phi_danada(:,i))^2;
        den = (phi_intacta(:,i)' * M * phi_intacta(:,i)) * (phi_danada(:,i)' * M * phi_danada(:,i));
        macn_value = macn_value + num / den;
    end
    macn_value = macn_value / size(phi_intacta, 2);  % Promedio de MACN
    
    % Combinar en una función objetivo ponderada
    Objective = w1 * RMSE + w2 * (1 - macn_value);

end


function [Objective] = RMSEfunction(x, k, M_global, frec_mod, modos_mod, ...
        L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
        vxz, elem_con_dano_long_NE, phi_intacta, phi_danada, M, Dd)

    % Pesos para la función objetivo combinada
    w1 = 0.6;  % Peso para RMSE
    w2 = 0.4;  % Peso para MACN

    % Recorre cada uno de los 116 elementos para aplicar el daño
    for i = 1:NE
        % Matriz de rigidez local para el elemento i
        ke_AG = zeros(12,12);

        % Aplicar daño por corrosión a las tres propiedades del elemento i
        A_damaged  = A(i)  * (1 - x(3*i - 2));  % El área se reduce debido a la corrosión
        Iy_damaged = Iy(i) * (1 - x(3*i - 1));  % Inercia en Y se reduce debido a la corrosión
        Iz_damaged = Iz(i) * (1 - x(3*i));      % Inercia en Z se reduce debido a la corrosión

        % Modifica los términos afectados en la matriz de rigidez local
        ke_AG(1, 1) =  E * A_damaged / L(i);  
        ke_AG(1, 7) = -E * A_damaged / L(i);
        ke_AG(7, 1) = -E * A_damaged / L(i);
        ke_AG(7, 7) =  E * A_damaged / L(i);
        
        ke_AG(2, 2) =  12 * E * Iy_damaged / L(i)^3;
        ke_AG(8, 8) =  12 * E * Iy_damaged / L(i)^3;
        ke_AG(2, 8) = -12 * E * Iy_damaged / L(i)^3;
        ke_AG(8, 2) = -12 * E * Iy_damaged / L(i)^3;
        
        ke_AG(5, 5)   = 4 * E * Iy_damaged / L(i);
        ke_AG(11, 11) = 4 * E * Iy_damaged / L(i);
        
        ke_AG(5, 3)  = -6 * E * Iy_damaged / L(i)^2;
        ke_AG(9, 3)  =  6 * E * Iy_damaged / L(i)^2;
        ke_AG(11, 3) = -6 * E * Iy_damaged / L(i)^2;
        ke_AG(5, 9)  =  6 * E * Iy_damaged / L(i)^2;
        
        ke_AG(3, 3) =  12 * E * Iz_damaged / L(i)^3;
        ke_AG(9, 9) =  12 * E * Iz_damaged / L(i)^3;
        ke_AG(3, 9) = -12 * E * Iz_damaged / L(i)^3;
        ke_AG(9, 3) = -12 * E * Iz_damaged / L(i)^3;
        
        ke_AG(6, 6)   = 4 * E * Iz_damaged / L(i);
        ke_AG(12, 12) = 4 * E * Iz_damaged / L(i);
        
        ke_AG(6, 2)  =  6 * E * Iz_damaged / L(i)^2;
        ke_AG(12, 2) = -6 * E * Iz_damaged / L(i)^2;
        ke_AG(6, 8)  =  6 * E * Iz_damaged / L(i)^2;
        ke_AG(12, 8) = -6 * E * Iz_damaged / L(i)^2;
                
        % Reensamblar la matriz global de rigidez
        [KG_AG] = ensamblaje_matriz_rigidez_global_AG(ID, NE, ke_AG,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);

        % Condensación estática de matrices globales
        [K_cond, M_cond] = condensacion_estatica(KG_AG, M_global);
        [frec_ga, modos_ga] = eig(K_cond, M_cond);
    end
    
    % Calcular RMSE para las frecuencias
    SumRMSEVal = 0;
    for i = 1:length(frec_mod)
        SumRMSEVal = SumRMSEVal + (1/frec_mod(i) - 1/frec_ga(i))^2;
    end
    RMSE = (SumRMSEVal / length(frec_mod))^0.5;

    % Calcular el MACN para formas modales
    macn_value = 0;
    for i = 1:size(phi_intacta, 2)
        num = (phi_intacta(:,i)' * M * phi_danada(:,i))^2;
        den = (phi_intacta(:,i)' * M * phi_intacta(:,i)) * (phi_danada(:,i)' * M * phi_danada(:,i));
        macn_value = macn_value + num / den;
    end
    macn_value = macn_value / size(phi_intacta, 2);  % Promedio de MACN
    
    % Combinar en una función objetivo ponderada
    Objective = w1 * RMSE + w2 * (1 - macn_value);

end
