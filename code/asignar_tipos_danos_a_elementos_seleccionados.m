function [] = asignar_tipos_danos_a_elementos_seleccionados()
        %% SECCION: Asignacion de propiedades con dano segun el caso de dano
    for i = 1:length(no_elemento_a_danar)
        if  strcmp(caso_dano{i}, 'corrosion')
            [ke_d_total, ke_d, elem_con_dano_long_NE] = corrosionlocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
        elseif strcmp(caso_dano{i}, 'abolladura')
            [ke_d_total, ke_d, elem_con_dano_long_NE] = abolladuralocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
        elseif strcmp(caso_dano{i}, 'efecto P-delta')

        elseif strcmp(caso_dano{i}, 'fatiga')

        else
            error('Error: The option "%s" in cell %d is incorrectly written or not recognized.', caso_dano{i}, i);
        end
    end
end
