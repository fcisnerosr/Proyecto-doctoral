function [ke_d_total, ke_d] = switch_case_danos(no_elemento_a_danar, num_de_ele_long, L_d, caso_dano, dano_porcentaje, prop_geom, E, G)
    % %% SECCION: Asignacion de propiedades con dano segun el caso de dano
    % for i = 1:length(no_elemento_a_danar)
    %     if  strcmp(caso_dano{i}, 'corrosion')
    %         [ke_d_total, ke_d, elem_con_dano_long_NE] = corrosionlocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
    %     elseif strcmp(caso_dano{i}, 'abolladura')
    %         [ke_d_total, ke_d, elem_con_dano_long_NE] = abolladuralocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
    %     elseif strcmp(caso_dano{i}, 'efecto P-delta')
    % 
    %     elseif strcmp(caso_dano{i}, 'fatiga')
    % 
    %     else
    %         error('Error: The option "%s" in cell %d is incorrectly written or not recognized.', caso_dano{i}, i);
    %     end
    % end
    % Matrices de flexibilidades y de rigidez local llenas de ceros
    f_AA_d = zeros(6, 6, length(no_elemento_a_danar));
    ke_d = zeros(12, 12, length(no_elemento_a_danar));
    
    for i = 1:length(no_elemento_a_danar)
        if strcmp(caso_dano{i}, 'corrosion')
            % Código de la corrosión local
            % Bucle para cada elemento a dañar
            for i = 1:length(no_elemento_a_danar)
                % Reducción de espesor por corrosión
                index = find(num_de_ele_long(:,1) == i);
                long_elem_a_danar = num_de_ele_long(index,2);
                prop_geom_mat = cell2mat(prop_geom);
                t(i) = prop_geom_mat(no_elemento_a_danar(i),10); % Espesor extraido intacto
                t_corro(i) = dano_porcentaje(i) * t(i) / 100; % Espesor que va a restar al espesor sin dano
                t_d(i) = t(i) - t_corro(i); % Espesor ya reducido
                % Área con corrosión
                D(i) = prop_geom_mat(no_elemento_a_danar(i),9);
                D_d(i) = D(i) - (2*t_corro(i));
                R_d(i) = 0.5 * D_d(i);
                A1_d(i) = pi  * R_d(i)^2;
                R_interior_d(i) = 0.5 * (D_d(i) - (2*t_d(i)));
                A2_d(i) = pi  * R_interior_d(i)^2;
                A_d(i) = A1_d(i) - A2_d(i); % en mm^2
                % Momento de inercia con daño
                R_ext_d(i) = 0.5*D_d(i);
                I_ext_d(i) = 1/4 * pi * R_ext_d(i)^4;
                I_int_d(i) = 1/4 * pi *  R_interior_d(i)^4;
                I_d(i) = I_ext_d(i) - I_int_d(i);
                % Momento polar del elemento con daño
                j(i) = prop_geom_mat(no_elemento_a_danar(i),5);
                % Matriz de flexibilidades y uso de matriz de transformación T para convertirla a la matriz de rigidez local completa
                f_AA_d(:,:,i) = [
                    L_d(i)/(E(i)*A_d(i)) 0 0 0 0 0; ...
                    0 L_d(i)^3/(3*E(i)*I_d(i)) 0 0 0 L_d(i)^2/(2*E(i)*I_d(i)); ...
                    0 0 L_d(i)^3/(3*E(i)*I_d(i)) 0 -L_d(i)^2/(2*E(i)*I_d(i)) 0; ...
                    0 0 0 L_d(i)/(G(i)*j(i)) 0 0; ...
                    0 0 -L_d(i)^2/(2*E(i)*I_d(i)) 0 L_d(i)/(E(i)*I_d(i)) 0; ...
                    0 L_d(i)^2/(2*E(i)*I_d(i)) 0 0 0 L_d(i)/(E(i)*I_d(i))
                ];
                % Matriz de transformación
                T = [
                    -1 0 0 0 0 0; 0 -1 0 0 0 0; 0 0 -1 0 0 0; 0 0 0 -1 0 0; ...
                    0 0 L_d(i) 0 -1 0; 0 -L_d(i) 0 0 0 -1; 1 0 0 0 0 0; ...
                    0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1
                ];
                ke_d(:,:,i) = T * f_AA_d(:,:,i)^(-1) * T'; % Matriz de rigidez local del elemento tubular
            end % Fin del bucle for de corrosión
    
        elseif strcmp(caso_dano{i}, 'abolladura')
            % El código de la aboladura está en codigo_abolladura.txt en esta misma carpeta
        end
    end % Fin del ciclo for que itera sobre cada elemento a dañar
    ke_d_total = ke_d;
end
