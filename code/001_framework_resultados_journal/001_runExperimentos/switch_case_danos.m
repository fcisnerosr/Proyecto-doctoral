function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos( ...
    no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G, ab_opts, ...
    N_axial_global, rho_global, matriz_cell_secciones)

    % defaults para abolladura (si no viene desde config.ab)
    if nargin < 8 || isempty(ab_opts)
        ab_opts = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);
    end
    
    % NUEVOS PARÁMETROS OPCIONALES (para deformación inicial)
    if nargin < 9, N_axial_global = []; end
    if nargin < 10, rho_global = []; end
    if nargin < 11, matriz_cell_secciones = {}; end

    % prop_geom -> matriz numérica
    prop_geom_mat = coerce_numeric_prop_geom(prop_geom);

    % columnas de D y t (ajusta si cambia tu layout)
    DIAM_COL  = 11;
    THICK_COL = 12;

    nElem = numel(no_elemento_a_danar);
    ke_d  = zeros(12,12,nElem);

    for j = 1:nElem
        idxElem = no_elemento_a_danar(j);              % ID global del elemento
        tipoj   = char(lower(string(caso_dano{j})));
        Lj      = L_d(j);
        pctj    = dano_porcentaje(j);

        % E y G como escalar global o por elemento GLOBAL
        if isscalar(E), Ej = E; else, Ej = E(idxElem); end
        if isscalar(G), Gj = G; else, Gj = G(idxElem); end

        switch tipoj
            case 'corrosion'
                % Rigidez local con corrosión uniforme (tubular)
                ke_d(:,:,j) = ke_corrosion_uniform_from_prop( ...
                    idxElem, Lj, pctj, prop_geom_mat, Ej, Gj, DIAM_COL, THICK_COL);

            case 'abolladura'
                % Geometría intacta
                D = prop_geom_mat(idxElem, DIAM_COL);
                t = prop_geom_mat(idxElem, THICK_COL);

                % Validaciones básicas
                assert(isfinite(D) && D>0 && isfinite(t) && t>0, ...
                    'D/t inválidos en elemento %d.', idxElem);
                assert(t < D/2, 't debe ser < D/2 en elemento %d.', idxElem);

                % Poisson consistente con E y G: G = E/(2*(1+nu))
                nu = Ej/(2*Gj) - 1;

                % % de abolladura < 50
                assert(pctj < 50, 'La abolladura debe ser < 50%% del diámetro.');

                % Ke local con abolladura
                ke_d(:,:,j) = ab_build_element_ke( ...
                    pctj, D, t, Lj, Ej, nu, ab_opts.Nseg, ab_opts.Slong, ab_opts.lim );

            case 'deformacion_inicial'
                % NUEVO CASO: Daño por deformación inicial (bow imperfection)
                
                % Verificar que tenemos los datos necesarios
                if isempty(N_axial_global) || isempty(matriz_cell_secciones)
                    error('switch_case_danos:DatosInsuficientes', ...
                        'Daño tipo "deformacion_inicial" requiere N_axial_global y matriz_cell_secciones.');
                end
                
                % Fuerza axial en este elemento (precalculada)
                N_comp = N_axial_global(idxElem);
                
                % Verificar que está en compresión (signo negativo esperado)
                if N_comp > 0
                    warning('Elemento %d en tensión (N=%.2f kN). Deformación inicial aplica típicamente en compresión.', ...
                        idxElem, N_comp/1e3);
                end
                
                % Extraer D y t desde matriz_cell_secciones
                % Formato esperado: cell array con etiqueta, OD_mm, t_mm
                seccion_elem = prop_geom(idxElem, :);  % Fila del elemento
                etiqueta_seccion = seccion_elem{1};    % Primera columna: etiqueta
                
                % Buscar en matriz_cell_secciones
                idx_seccion = find(strcmp({matriz_cell_secciones.Etiqueta}, etiqueta_seccion), 1);
                if isempty(idx_seccion)
                    error('No se encontró sección "%s" en matriz_cell_secciones', etiqueta_seccion);
                end
                
                D = matriz_cell_secciones(idx_seccion).OD_mm / 1000;  % mm → m
                t = matriz_cell_secciones(idx_seccion).t_mm / 1000;   % mm → m
                
                % Poisson y densidad (típicos para acero)
                nu = 0.3;
                rho_mat = 7850;  % kg/m³
                
                % Magnitud de deformación inicial (pctj es e0/L en %)
                e0_sobre_L = pctj / 100;  % 2% → 0.02
                
                % Validación de parámetros
                if abs(e0_sobre_L) > 0.05  % Límite 5%
                    error('e0/L = %.2f%% excede límite razonable (5%%)', pctj);
                end
                
                % Calcular ratio de carga
                if ~isempty(rho_global)
                    rho_elem = rho_global(idxElem);
                    if rho_elem > 0.85
                        warning('Elemento %d con ρ=%.4f > 0.85 (cerca de pandeo)', idxElem, rho_elem);
                    end
                end
                
                % Llamar a funcion_deformaciones para obtener Kt
                nModos_temp = 5;  % Modos para análisis modal interno
                verbose = false;
                
                try
                    [~, Kt, ~, ~, ~, ~, ~, ~, ~] = funcion_deformaciones(...
                        Lj, D, t, Ej, nu, rho_mat, ...
                        N_comp, e0_sobre_L, nModos_temp, verbose);
                    
                    ke_d(:,:,j) = Kt;  % Usar Kt (incluye Ke + Kg)
                    
                catch ME
                    error('switch_case_danos:ErrorDeformacion', ...
                        'Error en funcion_deformaciones para elem %d: %s', idxElem, ME.message);
                end

            otherwise
                error('switch_case_danos:TipoNoSoportado', ...
                      'Caso de daño "%s" no soportado.', tipoj);
        end
    end

    ke_d_total = ke_d;
end
