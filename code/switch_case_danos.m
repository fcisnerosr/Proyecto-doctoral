function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos(no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G)
    %  % SECCION: Asignacion de propiedades con dano segun el caso de dano
    %     % for i = 1:length(no_elemento_a_danar)
    %     %     if  strcmp(caso_dano{i}, 'corrosion')
    %     %         [ke_d_total, ke_d, elem_con_dano_long_NE] = corrosionlocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
    %     %     elseif strcmp(caso_dano{i}, 'abolladura')
    %     %         [ke_d_total, ke_d, elem_con_dano_long_NE] = abolladuralocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
    %     %     elseif strcmp(caso_dano{i}, 'efecto P-delta')
    %     % 
    %     %     elseif strcmp(caso_dano{i}, 'fatiga')
    %     % 
    %     %     else
    %     %         error('Error: The option "%s" in cell %d is incorrectly written or not recognized.', caso_dano{i}, i);
    %     %     end
    %     % end
    % Matrices de flexibilidades y de rigidez local llenas de ceros
    f_AA_d = zeros(6, 6, length(no_elemento_a_danar));
    ke_d = zeros(12, 12, length(no_elemento_a_danar));

    for  idxElem = 1:length(no_elemento_a_danar)
    % for i = 1
        if strcmp(caso_dano{idxElem}, 'corrosion')
            % Código de la corrosión local
            % Bucle para cada elemento a dañar
            for j = 1:length(no_elemento_a_danar)
                % Reducción de espesor por corrosión
                % index = find(num_de_ele_long(:,1) == j);
                % long_elem_a_danar = num_de_ele_long(index,2);
                prop_geom_mat = cellfun(@(x) convert_to_number(x), prop_geom, 'UniformOutput', false);  % Recorre cada elemento de prop_geom y lo convierte a número si es string
                prop_geom_mat = cell2mat(prop_geom_mat);        % Convierte el cell array a matriz numérica
                t(j) = prop_geom_mat(no_elemento_a_danar(j),10); % Espesor extraido intacto
                t_corro(j) = dano_porcentaje(j) * t(j) / 100; % Espesor que va a restar al espesor sin dano
                t_d(j) = t(j) - t_corro(j); % Espesor ya reducido
                % Área con corrosión
                D(j) = prop_geom_mat(no_elemento_a_danar(j),9);
                D_d(j) = D(j) - (2*t_corro(j));
                R_d(j) = 0.5 * D_d(j);
                A1_d(j) = pi * R_d(j)^2;
                R_interior_d(j) = 0.5 * (D_d(j) - (2*t_d(j)));
                A2_d(j) = pi  * R_interior_d(j)^2;
                A_d(j) = A1_d(j) - A2_d(j); % en mm^2
                % Momento de inercia con daño
                R_ext_d(j) = 0.5*D_d(j);
                I_ext_d(j) = 1/4 * pi * R_ext_d(j)^4;
                I_int_d(j) = 1/4 * pi * R_interior_d(j)^4;
                I_d(j) = I_ext_d(j) - I_int_d(j);
                % Momento polar del elemento con daño
                J(j) = pi/32 * (D_d(j)^4 - ((D_d(j) - (2*t_d(j)))^4));
                % Matriz de flexibilidades y uso de matriz de transformación T para convertirla a la matriz de rigidez local completa
                % Matriz f_AA_d
                f_AA_d(:,:,j) = [
                    L_d(j)/(E(j)*A_d(j)),       0,                          0,                              0,                  0,                          0;
                    0,                          L_d(j)^3/(3*E(j)*I_d(j)),   0,                              0,                  0,                          L_d(j)^2/(2*E(j)*I_d(j));
                    0,                          0,                          L_d(j)^3/(3*E(j)*I_d(j)),       0,                  -L_d(j)^2/(2*E(j)*I_d(j)),  0;
                    0,                          0,                          0,                              L_d(j)/(G(j)*J(j)), 0,                          0;
                    0,                          0,                          -L_d(j)^2/(2*E(j)*I_d(j)),      0,                  L_d(j)/(E(j)*I_d(j)),       0;
                    0,                          L_d(j)^2/(2*E(j)*I_d(j)),   0,                              0,                  0,                          L_d(j)/(E(j)*I_d(j))
                ];

                % Matriz de transformación T
                T = [
                    -1,   0,    0,      0,  0,   0;
                     0,  -1,    0,      0,  0,   0;
                     0,   0,    -1,     0,  0,   0;
                     0,   0,    0,      -1, 0,   0;
                     0,   0,    L_d(j), 0,  -1,  0;
                     0, -L_d(j),0,      0,  0,  -1;
                     1,   0,    0,      0,  0,   0;
                     0,   1,    0,      0,  0,   0;
                     0,   0,    1,      0,  0,   0;
                     0,   0,    0,      1,  0,   0;
                     0,   0,    0,      0,  1,   0;
                     0,   0,    0,      0,  0,   1
                ];

                ke_d(:,:,j) = T * f_AA_d(:,:,j)^(-1) * T'; % Matriz de rigidez local del elemento tubular
            end % Fin del bucle for de corrosión

        elseif strcmp(caso_dano{idxElem}, 'abolladura')
            % código de abolladura...
        else
            error('Caso de daño "%s" no soportado', caso_dano{idxElem});
    end % Fin del ciclo for que itera sobre cada elemento a dañar
    ke_d_total = ke_d;

end
