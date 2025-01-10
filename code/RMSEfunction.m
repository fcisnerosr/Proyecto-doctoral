function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
    L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
    vxz, elem_con_dano_long_NE,...
    modos_cond_d, prop_geom_mat, no_elemento_a_danar)
    % Inicializa la variable objetivo
    Objetivo  = 0;
    % Pesos para las funciones objetivo
    % w1 = 0.6;  % Peso al RMSE
    % w2 = 0.4;  % Peso al MACN

    % w1 = 1;  % Peso al RMSE
    % w2 = 0;  % Peso al MACN

    % w1 = 5000;  % Peso al RMSE
    % w2 = 0;  % Peso al MACN
    
    % w1 = 1000;  % Peso al RMSE
    % w2 = 1000;  % Peso al MSD
    
    % Recorta las propiedades a la subestructura
    L_sub  = L(1:num_element_sub);   
    A_sub  = A(1:num_element_sub);   
    Iy_sub = Iy(1:num_element_sub);  
    Iz_sub = Iz(1:num_element_sub);
    E_sub  = E(1:num_element_sub);
    G_sub  = G(1:num_element_sub);
    J_sub  = J(1:num_element_sub);
    
    ke_AG_tensor = zeros(12,12,num_element_sub);
    % Recorre cada uno de los num_element_sub elementos para aplicar el daño
   
    for i = 1:num_element_sub
    % for i = 1:1
        % Matriz de rigidez local
        ke_AG = zeros(12,12);
        
        % % % Aplica daño por corrosión
        % A_damaged  = A_sub(i)  * (1 - x(3*i - 2));  
        % Iy_damaged = Iy_sub(i) * (1 - x(3*i - 1)); 
        % Iz_damaged = Iz_sub(i) * (1 - x(3*i));

        % % Aplica daño al espesor
        t = prop_geom_mat(i,10);
        t_corro = x(i) * t; % Espesor que va a restar al espesor sin dano
        t_d = t - t_corro; % Espesor ya reducido
        % Área con corrosión
        D = prop_geom_mat(i,9);
        D_d = D - (2*t_corro);
        R_d = 0.5 * D_d;
        A1_d = pi * R_d^2;
        R_interior_d = 0.5 * (D_d - (2*t_d));
        A2_d = pi  * R_interior_d^2;
        A_damaged = A1_d - A2_d; % en mm^2
        % Momento de inercia con daño
        R_ext_d = 0.5*D_d;
        I_ext_d = 1/4 * pi * R_ext_d^4;
        I_int_d = 1/4 * pi * R_interior_d^4;
        Iy_damaged = I_ext_d - I_int_d;
        Iz_damaged = Iy_damaged;        

        % Modifica los términos afectados en la matriz de rigidez local
        % Elementos de la diagonal principal
        ke_AG(1, 1)  =  E_sub(i)        * A_damaged  / L_sub(i);
        ke_AG(2, 2)  =  12 * E_sub(i)   * Iz_damaged / L_sub(i)^3;
        ke_AG(3, 3)  =  12 * E_sub(i)   * Iy_damaged / L_sub(i)^3;
        ke_AG(4, 4)  =  (G_sub(i)       * J_sub(i))  / L_sub(i);
        ke_AG(5, 5)  =  4 * E_sub(i)    * Iy_damaged / L_sub(i);
        ke_AG(6, 6)  =  4 * E_sub(i)    * Iz_damaged / L_sub(i);
        ke_AG(7, 7)  =  E_sub(i)        * A_damaged  / L_sub(i);
        ke_AG(8, 8)  =  12 * E_sub(i)   * Iy_damaged / L_sub(i)^3;
        ke_AG(9, 9)  =  12 * E_sub(i)   * Iz_damaged / L_sub(i)^3;
        ke_AG(10, 10) = (G_sub(i)       * J_sub(i))  / L_sub(i);
        ke_AG(11, 11) = 4 * E_sub(i)    * Iy_damaged / L_sub(i);
        ke_AG(12, 12) = 4 * E_sub(i)    * Iz_damaged / L_sub(i);
        
        % Resto de los elementos de la matriz de rigidez local
        ke_AG(7, 1) = -ke_AG(1, 1);
        ke_AG(6, 2) = (6                * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(8, 2) = (-12              * E_sub(i) * Iz_damaged) / L_sub(i)^3;
        ke_AG(12,2) = (6                * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(5, 3) = -(6               * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(9, 3) = (-12              * E_sub(i) * Iy_damaged) / L_sub(i)^3;
        ke_AG(11,3) = (-6               * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(10,4) = (-G_sub(i)        * J_sub(i))   / L_sub(i);
        ke_AG(9, 5) = (6    * E_sub(i)  * Iy_damaged) / L_sub(i)^2;
        ke_AG(11,5) = 2     * E_sub(i)  * Iy_damaged  / L_sub(i);
        ke_AG(8, 6) = (-6   * E_sub(i)  * Iz_damaged) / L_sub(i)^2;
        ke_AG(12,6) = (2    * E_sub(i)  * Iz_damaged) / L_sub(i);
        ke_AG(12,8) = (-6   * E_sub(i)  * Iz_damaged) / L_sub(i)^2;
        ke_AG(11,9) = (6    * E_sub(i)  * Iy_damaged) / L_sub(i)^2;
        
        % Las siguientes lineas acompleta el resto de la matriz de rigidez a fin de que quede simetrica
        
        keT = ke_AG';
        kediag = diag(diag(ke_AG));
        ke_AG = ke_AG + keT - kediag;
       
        ke_AG_tensor(:,:,i) = ke_AG;
        
   end

    % Reensamblar la matriz global de rigidez con daño del AG
    [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG_tensor,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
    
    % Condensación estática de matrices globales
    KG_AG_cond              = condensacion_estatica_AG(KG_AG);
    [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond);

    %%% Verificación de numeros reales en mis frecuencias y formas
    % Verificar si las matrices contienen solo números reales
    real_modos_cond_d = isreal(modos_AG_cond);
    real_frec_cond_d  = isreal(frec_AG);
    if real_frec_cond_d == 0
        frec_AG
        i
        x
    end

    % SumRMSEVal = 0;
    % for i = 1:length(frec_AG)
    %     SumRMSEVal = SumRMSEVal + ((2*pi/frec_AG(i)) - (2*pi/frec_cond_d(i)))^2;
    % end
    % RMSE = sqrt(SumRMSEVal / length(frec_AG));

    % % Calcular el MACN para formas modales
    % macn_value = 0;
    % for i = 1:size(modos_cond_d, 2)
    %     num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;
    %     den = (modos_cond_d(:,i)' * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * modos_AG_cond(:,i));
    %     MAC_value = num / den;
    %     macn_value = macn_value + sqrt((1 - MAC_value) / MAC_value);
    % end
    % macn_value = macn_value / size(modos_cond_d, 2);  % Promedio de MACN
    % Cálculo de COMAC nodo a nodo
    % for i = 1:3  % Iterar sobre cada modo
    %     for node = 1:216  % Iterar sobre cada nodo
    %         num = (modos_cond_d(node, i) * modos_AG_cond(node, i))^2;
    %         den = (modos_cond_d(node, i)^2) * (modos_AG_cond(node, i)^2);
    %         comac_values(node, i) = num / den  % Fórmula de COMAC
    %     end
    % end
    % comac_error = mean(abs(1 - comac_values(:)));

    % % Mode Shape Difference Method
    % % Normalizar formas modales
    % % Número de modos por dirección
    % num_modos = 216; 
    % % Número de direcciones
    % num_direcciones = 3; 
    % 
    % % Preasignar matrices normalizadas
    % modos_cond_d_norm = zeros(size(modos_cond_d));
    % modos_AG_cond_norm = zeros(size(modos_AG_cond));
    % 
    % % Bucle sobre cada dirección
    % 
    % for dir = 1:num_direcciones
    %     % Extraer la columna actual para la dirección
    %     modos_cond_dir = modos_cond_d(:, dir);
    %     modos_ag_dir = modos_AG_cond(:, dir);
    % 
    %     % Normalizar cada columna respecto al valor máximo en esa dirección
    %     max_val_cond = max(abs(modos_cond_dir));
    %     max_val_ag = max(abs(modos_ag_dir));
    % 
    %     % Si max_val_cond o max_val_ag es cero (para evitar la división por cero), se podría agregar un pequeño valor epsilon
    %     epsilon = 1e-8;
    %     max_val_cond = max(max_val_cond, epsilon);
    %     max_val_ag = max(max_val_ag, epsilon);
    % 
    %     modos_cond_d(:, dir) = modos_cond_dir / max_val_cond;
    %     modos_AG_cond(:, dir) = modos_ag_dir / max_val_ag;
    % end
    % 
    % % Asumiendo que 'modos_cond_d' y 'modos_AG_cond' están ya normalizados y tienen el mismo tamaño
    % [nodos, modos] = size(modos_cond_d);  % Obtener el número de nodos y modos
    % 
    % % Inicializar la matriz de diferencias modales absolutas
    % delta_phi = abs(modos_cond_d - modos_AG_cond);
    % 
    % % Inicializar el vector de MSD para cada modo
    % msd = zeros(1, modos);
    % 
    % % Calcular el MSD para cada modo
    % for j = 1:modos
    %     msd(j) = mean(delta_phi(:, j));  % Suma de diferencias modales absolutas para el modo j
    % end
    % 
    % MSD = mean(msd);
    % 
    % Objetivo = (MSD * w2) + (w1 * RMSE);
    % Combinar en una función objetivo ponderada
    % Objetivo = (comac_error*w2);
    % Objetivo = (w1 * RMSE)
    % Objetivo = (comac_error*w2) + (w1 * RMSE);
    
    % % calcularFlexibilidadObjetivo
    % % Calcular matrices de flexibilidad
    % F_danado = modos_cond_d * diag(frec_cond_d) * modos_cond_d';
    % F_danado_AG = modos_AG_cond * diag(frec_AG) * modos_AG_cond';
    % 
    % % Calcular diferencia de flexibilidad
    % DeltaF = F_danado_AG - F_danado;
    % 
    % % Calcular la métrica de cambio de flexibilidad
    % delta_max = max(abs(DeltaF), [], 1); % Máximos de cada columna
    % Objetivo = sum(delta_max); % Suma de máximos para obtener un escalar

    % Implementacion 2 (artítulo Liu2011)
    F1 = sum(((frec_AG - frec_cond_d) ./ frec_cond_d).^2);

    % MAC
    MAC_values = zeros(size(modos_cond_d, 2), 1); % Vector de MAC para cada modo
    % Calcular el MAC para cada par de modos
    for i = 1:size(modos_cond_d, 2)
        % Numerador: Producto interno cuadrado entre los modos
        num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;
        % Denominador: Producto de las normas cuadradas de ambos modos
        den = (modos_cond_d(:,i)' * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * modos_AG_cond(:,i));
        % Cálculo del MAC
        MAC_values(i) = num / den;
    end
    % Inicializar F_2
    F2 = 0;
    
    % Calcular el MAC para cada par de modos y acumular en F_2
    for i = 1:size(modos_cond_d, 2)
        % Numerador: Producto interno cuadrado entre los modos
        num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;
        % Denominador: Producto de las normas cuadradas de ambos modos
        den = (modos_cond_d(:,i)' * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * modos_AG_cond(:,i));
        % Calcular el MAC
        MAC_i = num / den;
        
        % Evitar división por cero o valores numéricamente inestables
        if MAC_i > 0
            % Cálculo del término para F_2
            F2 = F2 + ((1 - sqrt(MAC_i))^2) / MAC_i;
        else
            % Penalización en caso de MAC_i cero o muy pequeño
            F2 = F2 + 1e6; % Valor grande para penalizar
        end
    end
    % Calcular el porcentaje de daño notable (p)
    damaged_elements = length(no_elemento_a_danar);
    total_elements = num_element_sub;
    p = damaged_elements / total_elements;
    
    % Calcular los coeficientes C1 y C2
    dispersion = std(x); % Cálculo de dispersión de daño entre los elementos
    penalizacion = dispersion * 50; % Factor de penalización más alto
    % C1 = 0.8; 
    % C2 = 0.2;
    C1 = -0.75 * p + 0.75;
    C2 =  0.75 * p + 0.25;
    % C1 = -0.3 * p + 0.85; % Menos peso en F1
    % C2 = 1.0 * p + 0.1;   % Más peso en F2 para forzar la estructura modal
    % C1 = -0.2 * p + 0.9; % Menos peso en F1 (frecuencias)
    % C2 = 1.2 * p + 0.1;  % Más peso en F2 (formas modales)
    
    Objetivo = (C1*F1) + (C2*F2) + penalizacion;

end


