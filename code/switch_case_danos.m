function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos(no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G)
% switch_case_danos   Genera matrices de rigidez local con daño
%   no_elemento_a_danar: vector de índices de elementos dañados
%   L_d: longitudes de elementos dañados
%   caso_dano: cell de strings con tipo de daño por elemento
%   dano_porcentaje: vector de porcentajes de daño
%   prop_geom: cell array con propiedades geométricas (strings o numéricos)
%   E, G: módulos de elasticidad y cortante
    
    % Convertir prop_geom a matriz numérica (solo una vez)
    numeric_cells = cellfun(@(x) convert_to_number(x), prop_geom, 'UniformOutput', false);
    prop_geom_mat = cell2mat(numeric_cells);

    nElem = numel(no_elemento_a_danar);
    ke_d  = zeros(12, 12, nElem);

    % Iterar por cada elemento dañado
    for idxElem = 1:nElem
        tipo = caso_dano{idxElem};
        switch tipo
            case 'corrosion'
                %%
                % % Diagnóstico de valores clave antes de armar f_AA
                % j = idxElem;
                % idx = no_elemento_a_danar(j);
                % 
                % % 1) Longitud del elemento
                % fprintf('DEBUG: j=%d, elemento=%d, L_d=%g\n', j, idx, L_d(j));
                % 
                % % 2) Propiedades geométricas (diámetro y espesor original)
                % fprintf('DEBUG: prop_geom_mat(%d,9:10) = [%g, %g]\n', idx, ...
                %         prop_geom_mat(idx,9), prop_geom_mat(idx,10));
                % 
                % % 3) Espesor y diámetro extraídos
                % t  = prop_geom_mat(idx,10);
                % D  = prop_geom_mat(idx,9);
                % fprintf('DEBUG: t=%g, D=%g\n', t, D);
                % 
                % % 4) Área residual y momento polar calculados
                % t_corro = dano_porcentaje(j) * t / 100;
                % t_d     = t - t_corro;
                % D_d     = D - 2*t_corro;
                % R_d     = D_d/2;
                % A1_d    = pi * R_d^2;
                % R_in    = (D_d - 2*t_d)/2;
                % A2_d    = pi * R_in^2;
                % A_d     = A1_d - A2_d;
                % J_d     = pi/32 * (D_d^4 - (D_d - 2*t_d)^4);
                % fprintf('DEBUG: A_d=%g, J_d=%g\n', A_d, J_d);
                % 
                % % 5) Módulos de material
                % fprintf('DEBUG: E(%d)=%g, G(%d)=%g\n', j, E(j), j, G(j));
                % 
                % % 6) Condición de la matriz de flexibilidades antes de invertir
                % f_AA = zeros(6);
                % condF = nan;
                % try
                %     condF = condest(f_AA);
                % catch
                % end
                % fprintf('DEBUG: condición inicial f_AA = %g (antes de rellenar)\n', condF);
                %%
                % Solo necesitamos procesar el idxElem puntual en modo simple
                j = idxElem;
                idx = no_elemento_a_danar(j);

                % Valores geométricos originales
                t = prop_geom_mat(idx,12);  % espesor
                D = prop_geom_mat(idx,11);  % diámetro exterior

                % Cálculos de corrosión
                t_corro = dano_porcentaje(j) * t / 100;
                t_d = t - t_corro;

                D_d = D - 2*t_corro;
                R_d = D_d/2;
                A1_d   = pi * R_d^2;
                R_in   = (D_d - 2*t_d)/2;
                A2_d   = pi * R_in^2;
                A_d    = A1_d - A2_d;
                if A_d <= 0, error('Área A_d inválida en elemento %d', idx); end

                % Momento polar con daño
                J_d = pi/32 * (D_d^4 - (D_d - 2*t_d)^4);
                if J_d <= 0, error('Momento polar J_d inválido en elemento %d', idx); end

                % Matriz de flexibilidades local (6×6)
                f_AA = [
                    L_d(j)/(E(j)*A_d), 0, 0, 0, 0, 0;
                    0, L_d(j)^3/(3*E(j)*J_d), 0, 0, 0, L_d(j)^2/(2*E(j)*J_d);
                    0, 0, L_d(j)^3/(3*E(j)*J_d), 0, -L_d(j)^2/(2*E(j)*J_d),0;
                    0, 0, 0, L_d(j)/(G(j)*J_d), 0, 0;
                    0, 0, -L_d(j)^2/(2*E(j)*J_d), 0, L_d(j)/(E(j)*J_d),0;
                    0, L_d(j)^2/(2*E(j)*J_d), 0, 0, 0, L_d(j)/(E(j)*J_d)
                ];

                % Operación de rigidez local (12×12)
                T = [
                    -1,0,0,0,0,0;
                     0,-1,0,0,0,0;
                     0,0,-1,0,0,0;
                     0,0,0,-1,0,0;
                     0,0,L_d(j),0,-1,0;
                     0,-L_d(j),0,0,0,-1;
                     1,0,0,0,0,0;
                     0,1,0,0,0,0;
                     0,0,1,0,0,0;
                     0,0,0,1,0,0;
                     0,0,0,0,1,0;
                     0,0,0,0,0,1
                ];

                ke_d(:,:,j) = T * (f_AA \ eye(6)) * T';

            case 'abolladura'
                error('Abolladura no implementada');

            otherwise
                error('Caso de daño "%s" no soportado', tipo);
        end
    end

    ke_d_total = ke_d;
end
