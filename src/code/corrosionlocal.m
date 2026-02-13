function [ke_d, elem_con_dano_long_NE, f_AA_d] = corrosionlocal(no_elemento_a_danar, num_de_ele_long, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J, f_AA_d)
    
    % %% SECCION: Matriz de rigidez total con corrosion cuya 3ra dimension equivale a NE, los elementos con dano estan ubicados en su lugar correspondientes (ke_d_total)
    % % Generar una matriz de longitud NE con los ke_d en los indices correspondientes de no_elemento_a_danar para posterior
    % ke_d_total  = zeros(12, 12, NE);                            % Matriz de ceros con NE longitud en su tercera dimension. NE es el num. de elementos
    % for i = 1:length(no_elemento_a_danar)
    %     ke_d_total(:,:,no_elemento_a_danar(i)) = ke_d(:,:,i);   % matriz vacia de 12 por 12 por NE, pero con las matrices locales de ke_d posicionadas en su lugar para correspondientes
    % end
    % %% IMPORTANTE: LA MATRIZ ke_d_total CONTIENE EN SU MAYORIA CEROS PERO LOS ELEMENTOS DIFERENTES A CEROS CONTIENE LA MATRICES LOCALES CON DANO
    %             %% QUE SERA USADA EN EL ENSAMBLAJE GLOBAL PARA REEMPLAZAR LAS MATRICES LOCALES INTACTAS POR LAS QUE TIENEN DANO
end
