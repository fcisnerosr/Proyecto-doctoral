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

    % ────────────────────────────────────────────────────────────
    % ESTRUCTURA DE prop_geom (según lectura_datos_modelo_ETABS):
    % prop_geom = [prop_geom_cell,             cols 1-4: A, Iyy, Izz, J
    %              E_columna_cell,             col 5: E [MPa]
    %              G_columna_cell,             col 6: G [MPa]
    %              tipo,                       col 7: 'circular'
    %              wo_vector,                  col 8: 'wo'
    %              diam_diam_thick_tube_sub_cell,  cols 9-11: D, D, t [mm]
    %              gamma_beta_vector];         cols 12-13: gamma, beta
    % ────────────────────────────────────────────────────────────
    DIAM_COL  = 9;   % Diámetro exterior [mm] (duplicado en col 10)
    THICK_COL = 11;  % Espesor de pared [mm]

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
                
                % ─────────────────────────────────────────────────────────
                % VERIFICACIÓN DE DATOS NECESARIOS
                % ─────────────────────────────────────────────────────────
                if isempty(N_axial_global)
                    error('switch_case_danos:DatosInsuficientes', ...
                        'Daño "deformacion_inicial" requiere N_axial_global (fuerzas axiales precalculadas).');
                end
                
                % ─────────────────────────────────────────────────────────
                % EXTRACCIÓN DE GEOMETRÍA (D, t) DESDE prop_geom
                % ─────────────────────────────────────────────────────────
                % prop_geom_mat tiene D [mm] en col 11 y t [mm] en col 12
                D_mm = prop_geom_mat(idxElem, DIAM_COL);
                t_mm = prop_geom_mat(idxElem, THICK_COL);
                
                % Convertir a metros
                D = D_mm / 1000;  % mm → m
                t = t_mm / 1000;  % mm → m
                
                % Validaciones geométricas
                if ~isfinite(D) || D <= 0
                    error('Diámetro D=%.2f mm inválido en elemento %d', D_mm, idxElem);
                end
                if ~isfinite(t) || t <= 0
                    error('Espesor t=%.2f mm inválido en elemento %d', t_mm, idxElem);
                end
                if t >= D/2
                    error('Espesor t=%.2f >= D/2=%.2f en elemento %d', t_mm, D_mm/2, idxElem);
                end
                
                % ─────────────────────────────────────────────────────────
                % FUERZA AXIAL Y VERIFICACIONES
                % ─────────────────────────────────────────────────────────
                N_comp = N_axial_global(idxElem);  % [N]
                
                % Advertencia si está en tensión (no es crítico, pero inusual)
                if N_comp > 0
                    warning('Elemento %d en TENSIÓN (N=%.2f kN). Deformación inicial típicamente bajo COMPRESIÓN.', ...
                        idxElem, N_comp/1e3);
                end
                
                % Verificar ratio de carga si disponible
                if ~isempty(rho_global)
                    rho_elem = rho_global(idxElem);
                    if rho_elem > 0.85
                        warning('Elemento %d con ρ=%.4f > 0.85 (cercano a pandeo). Resultados pueden ser inestables.', ...
                            idxElem, rho_elem);
                    end
                end
                
                % ─────────────────────────────────────────────────────────
                % PARÁMETROS DE MATERIAL
                % ─────────────────────────────────────────────────────────
                % Poisson consistente con E y G: nu = E/(2*G) - 1
                nu = Ej / (2*Gj) - 1;
                
                % Densidad del acero [kg/m³]
                rho_mat = 7850;
                
                % ─────────────────────────────────────────────────────────
                % MAGNITUD DE DEFORMACIÓN INICIAL (e0/L)
                % ─────────────────────────────────────────────────────────
                % pctj viene como porcentaje: 2% → e0/L = 0.02
                e0_sobre_L = pctj / 100;
                
                % Validación de límite físico razonable
                if abs(e0_sobre_L) > 0.05  % Límite 5% de L
                    error('e0/L = %.2f%% excede límite razonable (5%%). Reducir porcentaje.', pctj);
                end
                
                % ─────────────────────────────────────────────────────────
                % LLAMADA A funcion_deformaciones
                % ─────────────────────────────────────────────────────────
                % FIRMA CORRECTA: resultados = funcion_deformaciones(opciones)
                % donde opciones es una estructura con campos:
                %   .L          - Longitud [mm]
                %   .D          - Diámetro [mm]  ← IMPORTANTE: debe estar en [mm]
                %   .t          - Espesor [mm]   ← IMPORTANTE: debe estar en [mm]
                %   .E          - Módulo Young [MPa]
                %   .nu         - Poisson [-]
                %   .rho_mat    - Densidad [kg/mm³] ← IMPORTANTE: conversión necesaria
                %   .Ncomp      - Fuerza compresión [N]
                %   .e0_sobre_L - Imperfección [-]
                %   .nModos     - Número de modos (5)
                %   .verbose    - false
                %
                % OUTPUT: estructura resultados con campo .Kt_equilibrio [N/mm]
                
                % Reconvertir D y t de [m] a [mm] (función espera [mm])
                D_mm_func = D * 1000;  % [m] → [mm]
                t_mm_func = t * 1000;  % [m] → [mm]
                
                % Convertir densidad de [kg/m³] a [kg/mm³]
                rho_mat_kg_mm3 = rho_mat / 1e9;  % 7850 → 7.85e-6
                
                % Armar estructura de opciones
                opciones = struct();
                opciones.L = Lj;                    % [mm]
                opciones.D = D_mm_func;             % [mm]
                opciones.t = t_mm_func;             % [mm]
                opciones.E = Ej;                    % [MPa]
                opciones.nu = nu;                   % [-]
                opciones.rho_mat = rho_mat_kg_mm3;  % [kg/mm³]
                opciones.Ncomp = N_comp;            % [N]
                opciones.e0_sobre_L = e0_sobre_L;   % [-]
                opciones.nModos = 5;
                opciones.verbose = false;
                
                try
                    resultados = funcion_deformaciones(opciones);
                    
                    % Extraer Kt_equilibrio (matriz tangente con P-δ)
                    ke_d(:,:,j) = resultados.Kt_equilibrio;
                    
                catch ME
                    error('switch_case_danos:ErrorDeformacion', ...
                        'Error en funcion_deformaciones (elem %d, e0/L=%.2f%%): %s', ...
                        idxElem, pctj, ME.message);
                end

            otherwise
                error('switch_case_danos:TipoNoSoportado', ...
                      'Caso de daño "%s" no soportado.', tipoj);
        end
    end

    ke_d_total = ke_d;
end
