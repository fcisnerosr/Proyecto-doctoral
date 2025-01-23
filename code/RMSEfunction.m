function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
    L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
    vxz, elem_con_dano_long_NE,...
    modos_cond_d, prop_geom_mat, no_elemento_a_danar) % Línea de AG_experimentos_001

    % Inicializa la variable objetivo
    Objetivo  = 0;
    
    % Pesos para las funciones objetivo
    % w1 = 500;  % Peso al RMSE  % Línea de HEAD comentada
    % w2 = 1e19;  % Peso al COMAC % Línea de HEAD comentada
    
    % w1 = 5000;  % Peso al RMSE % Línea de AG_experimentos_001
    % w2 = 0;  % Peso al MACN % Línea de AG_experimentos_001
    
    % w1 = 1000;  % Peso al RMSE % Línea de AG_experimentos_001
    % w2 = 1000;  % Peso al MSD % Línea de AG_experimentos_001

    % Verificación de números reales en frecuencias y formas
    % %%% Verificación de numeros reales en mis frecuencias y formas % Línea de HEAD comentada
    % % Verificar si las matrices contienen solo números reales % Línea de HEAD comentada
    % real_modos_cond_d = isreal(modos_AG_cond); % Línea de HEAD comentada
    % real_frec_cond_d  = isreal(frec_AG); % Línea de HEAD comentada
    % if real_frec_cond_d == 0 % Línea de HEAD comentada
    %     print('Frecuencias con numeros imaginarios\n') % Línea de HEAD comentada
    % end % Línea de HEAD comentada
    % 
    SumRMSEVal = 0; % Línea de HEAD comentada
    for i = 1:length(frec_AG) % Línea de HEAD comentada
        % SumRMSEVal = SumRMSEVal + (frec_AG(i) - frec_cond_d(i))^2; % Línea de HEAD comentada
        SumRMSEVal = SumRMSEVal + ((2*pi/frec_AG(i)) - (2*pi/frec_cond_d(i)))^2; % Línea de HEAD comentada
    end % Línea de HEAD comentada
    RMSE = sqrt(SumRMSEVal / length(frec_AG)); % Línea de HEAD comentada

    
    % % Cálculo del CoMAC para cada nodo en cada modo
    % for i = 1:3  % Iterar sobre cada modo  % Línea de HEAD comentada
    %     for node = 1:216  % Iterar sobre cada nodo % Línea de HEAD comentada
    %         num = (modos_cond_d(node, i) * modos_AG_cond(node, i))^2; % Línea de HEAD comentada
    %         den = (modos_cond_d(node, i)^2) * (modos_AG_cond(node, i)^2); % Línea de HEAD comentada
    %         comac_values(node, i) = num / den;  % Fórmula de COMAC % Línea de HEAD comentada
    %     end % Línea de HEAD comentada
    % end % Línea de HEAD comentada
    % Calcular el error cuadrático medio de las desviaciones del COMAC de la unidad % Línea de HEAD comentada
    % comac_error = mean(abs(1 - comac_values(:))); % Línea de HEAD comentada
    % Objetivo = (comac_error*w2); % Línea de HEAD comentada
    % x % Línea de HEAD comentada
    % Objetivo = (comac_error*w2) + (w1 * RMSE) % Línea de HEAD comentada

    % Código de AG_experimentos_001 (implementación MAC)
    F1 = sum(((frec_AG - frec_cond_d) ./ frec_cond_d).^2);

    % MAC
    MAC_values = zeros(size(modos_cond_d, 2), 1); % Vector de MAC para cada modo
    % Calcular el MAC para cada par de modos
    for i = 1:size(modos_cond_d, 2)
        % Numerador: Producto interno cuadrado entre los modos
        num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;masas_con_nodos
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
    C1 = -0.75 * p + 0.75;
    C2 =  0.75 * p + 0.25;
    
    Objetivo = (C1*F1) + (C2*F2) + penalizacion;

end
