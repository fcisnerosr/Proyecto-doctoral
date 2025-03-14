function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d, ...
    L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
    vxz, elem_con_dano_long_NE, ...
    modos_cond_d, prop_geom_mat)

       % --- Inicialización ---
    Objetivo = 0;  % Inicializa la variable objetivo
    
    % --- Recorte de propiedades a la subestructura ---
    L_sub  = L(1:num_element_sub);   % Longitud de los elementos de la subestructura
    A_sub  = A(1:num_element_sub);   % Área de los elementos de la subestructura
    Iy_sub = Iy(1:num_element_sub);  % Momento de inercia en y de los elementos de la subestructura
    Iz_sub = Iz(1:num_element_sub);  % Momento de inercia en z de los elementos de la subestructura
    E_sub  = E(1:num_element_sub);   % Módulo de elasticidad de los elementos de la subestructura
    G_sub  = G(1:num_element_sub);   % Módulo de corte de los elementos de la subestructura

    ke_AG_tensor = zeros(12, 12, num_element_sub);  % Inicializa el tensor de rigidez local

    % --- Recorre cada uno de los elementos para aplicar el daño (cálculo posterior) ---
       
    for i = 1:num_element_sub
        % Matriz de rigidez local
        ke_AG = zeros(12, 12);
        
        % --- Daño al espesor ---
        t = prop_geom_mat(i, 10);       % Espesor original
        t_corro = x(i) * t;           % Espesor de corrosión
        t_d = t - t_corro;            % Espesor reducido
        
        % --- Área con corrosión ---
        D = prop_geom_mat(i, 9);        % Diámetro original
        D_d = D - (2 * t_corro);       % Diámetro reducido
        R_d = 0.5 * D_d;               % Radio reducido (exterior)
        A1_d = pi * R_d^2;             % Área del círculo exterior (reducido)
        R_interior_d = 0.5 * (D_d - (2 * t_d));  % Radio interior reducido
        A2_d = pi * R_interior_d^2;    % Área del círculo interior (reducido)
        A_damaged = A1_d - A2_d;        % Área con daño (mm^2)
        
        % --- Momento de inercia con daño ---
        R_ext_d = 0.5 * D_d;            % Radio exterior reducido
        I_ext_d = (1/4) * pi * R_ext_d^4; % Momento de inercia exterior (reducido)
        I_int_d = (1/4) * pi * R_interior_d^4; % Momento de inercia interior (reducido)
        Iy_damaged = I_ext_d - I_int_d; % Momento de inercia con daño (eje y)
        Iz_damaged = Iy_damaged;        % Momento de inercia con daño (eje z)

        % --- Momento polar de inercia con daño ---
        J_sub = pi/32 * (D_d^4 - ((D_d - (2*t_d))^4));

        % --- Modificación de la matriz de rigidez local (ke_AG) ---        
        % Elementos de la diagonal principal
        ke_AG(1,  1) = E_sub(i)        * A_damaged  / L_sub(i);
        ke_AG(2,  2) = 12 * E_sub(i)   * Iz_damaged / L_sub(i)^3;
        ke_AG(3,  3) = 12 * E_sub(i)   * Iy_damaged / L_sub(i)^3;
        ke_AG(4,  4) = (G_sub(i)       * J_sub)     / L_sub(i);
        ke_AG(5,  5) = 4  * E_sub(i)   * Iy_damaged / L_sub(i);
        ke_AG(6,  6) = 4  * E_sub(i)   * Iz_damaged / L_sub(i);
        ke_AG(7,  7) = E_sub(i)        * A_damaged  / L_sub(i);
        ke_AG(8,  8) = 12 * E_sub(i)   * Iy_damaged / L_sub(i)^3;
        ke_AG(9,  9) = 12 * E_sub(i)   * Iz_damaged / L_sub(i)^3;
        ke_AG(10,10) = (G_sub(i)       * J_sub)     / L_sub(i);
        ke_AG(11,11) = 4  * E_sub(i)   * Iy_damaged / L_sub(i);
        ke_AG(12,12) = 4  * E_sub(i)   * Iz_damaged / L_sub(i);
        
        % Resto de los elementos de la matriz de rigidez local (elementos fuera de la diagonal)
        ke_AG(7, 1) = -ke_AG(1, 1);
        ke_AG(6, 2) = (6                * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(8, 2) = (-12              * E_sub(i) * Iz_damaged) / L_sub(i)^3;
        ke_AG(12,2) = (6                * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(5, 3) = -(6               * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(9, 3) = (-12              * E_sub(i) * Iy_damaged) / L_sub(i)^3;
        ke_AG(11,3) = (-6               * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(10,4) = (-G_sub(i)        * J_sub)      / L_sub(i);
        ke_AG(9, 5) = (6    * E_sub(i)  * Iy_damaged) / L_sub(i)^2;
        ke_AG(11,5) = 2     * E_sub(i)  * Iy_damaged  / L_sub(i);
        ke_AG(8, 6) = (-6   * E_sub(i)  * Iz_damaged) / L_sub(i)^2;
        ke_AG(12,6) = (2    * E_sub(i)  * Iz_damaged) / L_sub(i);
        ke_AG(12,8) = (-6   * E_sub(i)  * Iz_damaged) / L_sub(i)^2;
        ke_AG(11,9) = (6    * E_sub(i)  * Iy_damaged) / L_sub(i)^2;
        
        
        % --- Simetrización de la matriz ke_AG ---
        keT = ke_AG';                % Transpuesta de ke_AG
        kediag = diag(diag(ke_AG));  % Matriz diagonal de ke_AG
        ke_AG = ke_AG + keT - kediag; % Simetrización (asegurar la simetría)
        
        
        % Almacenamiento de la matriz de rigidez local
        ke_AG_tensor(:,:,i) = ke_AG;
        
    end

    % check_symmetry(ke_AG_tensor)

    % Reensamblar la matriz global de rigidez con daño del AG
    [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG_tensor,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
    
    % Condensación estática de matrices globales
    KG_AG_cond              = condensacion_estatica_AG(KG_AG);
    [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond);

    % --- Cálculo del RMSE (Root Mean Squared Error) ---
    SumRMSEVal = 0;                     % Inicializa la suma de errores al cuadrado
    for i = 1:length(frec_AG)           % Itera sobre las frecuencias
        SumRMSEVal = SumRMSEVal + (frec_AG(i) - frec_cond_d(i))^2; % Suma de los errores al cuadrado
    end
    RMSE = sqrt(SumRMSEVal / length(frec_AG));  % Calcula la raíz del error cuadrático medio
    
    % --- Cálculo del MACN (Modal Assurance Criterion Number) ---
    macn_value = 0;                     % Inicializa la suma de MACN
    for i = 1:size(modos_cond_d, 2)     % Itera sobre los modos
        num = (modos_cond_d(:, i)' * modos_AG_cond(:, i))^2; % Numerador del MAC
        den = (modos_cond_d(:, i)' * modos_cond_d(:, i)) * (modos_AG_cond(:, i)' * modos_AG_cond(:, i)); % Denominador del MAC
        MAC_value = num / den;           % Calcula el MAC
        macn_value = macn_value + ((1-sqrt(MAC_value))^2 / MAC_value); % Suma del valor del MACN
    end
    macn_value = macn_value / size(modos_cond_d, 2);  % Calcula el promedio del MACN
    
    % % --- Cálculo del Error basado en el Modal Curvature Method (MCM) ---
    % curv_modal_damaged  = mode_shape_curvature(modos_cond_d, L);
    % curv_modal_gen      = mode_shape_curvature(modos_AG_cond, L);
    % 
    % error_curvatura_total = 0; % Inicializa la suma del error de curvatura
    % 
    % % for i = 1:size(curv_modal_damaged, 2) % Itera sobre los modos
    % %     % Calcula el error cuadrático entre la curvatura modal del modelo generado y el modelo con daño
    % %     error_curvatura = sum((curv_modal_gen(:, i) - curv_modal_damaged(:, i)).^2) / length(curv_modal_damaged(:, i));
    % % 
    % %     % Convierte el error en un valor escalar tipo RMSE
    % %     error_curvatura_total = error_curvatura_total + sqrt(error_curvatura);
    % % end
    % 
    % for i = 1:size(curv_modal_damaged, 2) % Itera sobre los modos
    %     % Calcula el error usando la fórmula del artículo para la diferencia de curvatura modal
    %     error_curvatura = sum(abs(curv_modal_damaged(:, i) - curv_modal_gen(:, i))); 
    % 
    %     % Convierte el error en un valor escalar tipo RMSE
    %     error_curvatura_total = error_curvatura_total + sqrt(error_curvatura);
    % end
    % 
    % % Calcula el error promedio de la curvatura modal
    % error_curvatura_final = error_curvatura_total / size(curv_modal_damaged, 2);

    % --- Cálculo de índice de daño basado en las diferencias de la flexibilidad modal ---
    F_modal_damaged = calcFlexibility(modos_cond_d, frec_cond_d);
    F_modal_gen     = calcFlexibility(modos_AG_cond, frec_AG);
    diffMatrix      = F_modal_gen - F_modal_damaged;                % Diferencia entre ambas matrices    
    flexDiffIndex   = sum(diffMatrix(:).^2);                        % Suma de cuadrados de todas las entradas (equivale a la norma de Frobenius al cuadrado)

    % --- Cálculo de índice de daño basado en las relación de la flexibilidad modal ---
    DivF = calcDivFjR(modos_AG_cond, frec_AG, modos_cond_d, frec_cond_d);
    scalarDivF = norm(DivF, 2);     % Norma Euclidiana (o también se puede usar sum(DivF.^2))

    % --- Cálculo de índice de daño basado en las diferencia porcentual de la flexibilidad modal ---
    PercF = calcPercFjR(modos_AG_cond, frec_AG, modos_cond_d, frec_cond_d);
    scalarPercF = norm(PercF, 2);     % Norma Euclidiana

    % --- Cálculo de la función objetivo ---
    % Objetivo = w1 * RMSE + w2 * macn_value + w3 * error_curvatura_final;
    % Objetivo = w1 * RMSE + w2 * macn_value + w3 * flexDiffIndex;
    Objetivo = (w1 * RMSE) + (w2 * macn_value) + (w3 * flexDiffIndex) + (w4 * scalarDivF) + (w5 * scalarPercF);
end
