function [elem_con_dano_long_NE] = vector_asignacion_danos(no_elemento_a_danar, NE)
    % SECCION: Vector que posiciona en un indice del elemento a danar (elem_con_dano_long_NE)
    % Importante seccion que asigna los danos del vector de no_elemento_a_danar a los elementos a del modelo matematico
    elem_con_dano_long_NE = []; % vector de long NE con todos los elementos danados en las posiciones correspondientes
    index = find(no_elemento_a_danar == 1);
    
    if isempty(index)
        for i = 1:length(no_elemento_a_danar)
            if i < length(no_elemento_a_danar)
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
            else
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
            end
        end
        ceros_agregar = NE - length(elem_con_dano_long_NE);
        mat_zero = zeros(1,ceros_agregar);
        elem_con_dano_long_NE = horzcat(mat_zero,elem_con_dano_long_NE);
    else
        for i = 1:length(no_elemento_a_danar)
            if i < length(no_elemento_a_danar)
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
            else
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
            end
        end
    end
end
