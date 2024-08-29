function [SumRMSE] = RMSEfunction(x, k, M_global, frec_mod, modos_mod,...
        L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
        vxz, elem_con_dano_long_NE)
    % x: Vector de daños (longitud 348 = 3 propiedades * 116 elementos)
    % k: Matrices de rigidez originales
    % M_global: Matriz de masa global
    % frec_mod, modos_mod: Frecuencias y modos modales del modelo intacto

    % Recorre cada uno de los 116 elementos para aplicar el daño
    for i = 1:num_elements
        % Matriz de rigidez local donde se alojarán los resultados de los danos de los genes de cada individuo
        ke_AG = zeros(12,12);

        % Aplicar daño por corrosión a las tres propiedades del elemento i
        A_damaged  = A(i)  * (1 - x(3*i - 2));  % El área se reduce debido a la corrosión
        Iy_damaged = Iy(i) * (1 - x(3*i - 1));  % Inercia en Y se reduce debido a la corrosión
        Iz_damaged = Iz(i) * (1 - x(3*i));  % Inercia en Z se reduce debido a la corrosión

        % Modifica los términos afectados en la matriz de rigidez local
        ke_AG(1, 1) =  E * A_damaged / L;  % Modifica el término afectado por el área
        ke_AG(1, 7) = -E * A_damaged / L;  % Modifica el término afectado por el área (simetría)
        ke_AG(7, 1) = -E * A_damaged / L;  % Modifica el término afectado por el área (simetría)
        ke_AG(7, 7) =  E * A_damaged / L;  % Modifica el término afectado por el área
        
        % Modificar los términos relacionados con la inercia Iy
        ke_AG(2, 2) =  12 * E * Iy_damaged / L^3;  % Modifica el término relacionado con Iy
        ke_AG(8, 8) =  12 * E * Iy_damaged / L^3;  % Modifica el término relacionado con Iy (extremo B)
        ke_AG(2, 8) = -12 * E * Iy_damaged / L^3; % Modifica el término relacionado con Iy (simetría)
        ke_AG(8, 2) = -12 * E * Iy_damaged / L^3; % Modifica el término relacionado con Iy (simetría)
        
        ke_AG(5, 5)   = 4 * E * Iy_damaged / L;   % Modifica el término relacionado con Iy (término diagonal)
        ke_AG(11, 11) = 4 * E * Iy_damaged / L; % Modifica el término relacionado con Iy (término diagonal extremo B)
        
        ke_AG(5, 3)  = -6 * E * Iy_damaged / L^2;  % Modifica el término relacionado con Iy (acoplamiento Mz-Vy)
        ke_AG(9, 3)  =  6 * E * Iy_damaged / L^2;   % Modifica el término relacionado con Iy (acoplamiento Mz-Vy extremo B)
        ke_AG(11, 3) = -6 * E * Iy_damaged / L^2; % Modifica el término relacionado con Iy (acoplamiento Mz-Vy simetría)
        ke_AG(5, 9)  =  6 * E * Iy_damaged / L^2;   % Modifica el término relacionado con Iy (acoplamiento Mz-Vy simetría extremo B)
        
        % Modificar los términos relacionados con la inercia Iz
        ke_AG(3, 3) =  12 * E * Iz_damaged / L^3;  % Modifica el término relacionado con Iz
        ke_AG(9, 9) =  12 * E * Iz_damaged / L^3;  % Modifica el término relacionado con Iz (extremo B)
        ke_AG(3, 9) = -12 * E * Iz_damaged / L^3; % Modifica el término relacionado con Iz (simetría)
        ke_AG(9, 3) = -12 * E * Iz_damaged / L^3; % Modifica el término relacionado con Iz (simetría)
        
        ke_AG(6, 6)   = 4 * E * Iz_damaged / L;   % Modifica el término relacionado con Iz (término diagonal)
        ke_AG(12, 12) = 4 * E * Iz_damaged / L; % Modifica el término relacionado con Iz (término diagonal extremo B)
        
        ke_AG(6, 2)  =  6 * E * Iz_damaged / L^2;   % Modifica el término relacionado con Iz (acoplamiento My-Vz)
        ke_AG(12, 2) = -6 * E * Iz_damaged / L^2; % Modifica el término relacionado con Iz (acoplamiento My-Vz extremo B)
        ke_AG(6, 8)  =  6 * E * Iz_damaged / L^2;   % Modifica el término relacionado con Iz (acoplamiento My-Vz simetría)
        ke_AG(12, 8) = -6 * E * Iz_damaged / L^2; % Modifica el término relacionado con Iz (acoplamiento My-Vz simetría extremo B)
                
        % Reensamblar la matriz global de rigidez
        [KG_AG] = ensamblaje_matriz_rigidez_global_AG(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE)

        % Condensación estática de matrices globales
        [K_cond, M_cond] = condensacion_estatica(K_global, M_global);
        [frec_ga, modos_ga] = eig(K_cond, M_cond);
    end

    % Calcular RMSE para comparar con los modos originales
    SumRMSEVec = 0;
    SumRMSEVal = 0;

    for i = 1:num_elements
        SumRMSEVal = SumRMSEVal + (1/frec_mod(i,i) - 1/frec_ga(i,i))^2;
        for j = 1:num_elements
            SumRMSEVec = SumRMSEVec + (modos_mod(i,j) - modos_ga(i,j))^2;
        end
    end    

    % Combina los errores de frecuencia y modos
    SumRMSE = 1e8 * (SumRMSEVal / num_elements)^0.5;
end


