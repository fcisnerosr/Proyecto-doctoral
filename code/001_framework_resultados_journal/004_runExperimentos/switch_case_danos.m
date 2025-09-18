function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos(no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G)
% SWITCH_CASE_DANOS  Genera matrices Ke locales con daño por elemento.
% Entradas: ver tu firma original.
% Salidas : ke_d_total (12x12xNE_danados), ke_d idem, prop_geom_mat (numérico)

        % Parámetros opcionales específicos de la ABOLLADURA (ab_opts)
    % -------------------------------------------------------------------------
    % Esta sección define un parámetro de entrada OPCIONAL llamado "ab_opts".
    % La idea es que, si NO envías ese argumento (o lo envías vacío []),
    % la función use valores por defecto sensatos para la discretización
    % geométrica y la tolerancia del algoritmo de ajuste del contorno abollado.
    %
    % Campos que controla "ab_opts":
    %   - Nseg  : Nº de segmentos para discretizar el perímetro de la sección
    %             transversal (a mayor Nseg, mayor precisión del perfil y de
    %             las inercias Iy/Iz que se integran sobre el contorno).
    %   - Slong : Nº de “estaciones” (puntos) a lo largo del elemento donde se
    %             evalúa la profundidad de abolladura y se calculan Iy(x), Iz(x).
    %   - lim   : Tolerancia numérica empleada en el ajuste del perímetro
    %             (búsqueda de la amplitud "delta" para que el contorno abollado
    %             conserve el perímetro original). Un valor más pequeño exige
    %             un ajuste más fino (más iteraciones).
    %
    % Ventaja: mantienes retrocompatibilidad. Si tus llamadas antiguas no
    % pasaban "ab_opts", TODO sigue funcionando con defaults; y cuando quieras
    % afinar precisión/tiempos, pasas tu propio struct ab_opts.
    %
    % Ejemplos de uso:
    %   % (1) Sin ab_opts -> usa defaults:
    %   [Ke, PF, P] = ab_build_element_ke(pct, D, t, L, E, nu, 1000, 5, 3e-3);
    %   % o indirectamente desde switch_case_danos(...), sin enviar ab_opts.
    %
    %   % (2) Con ab_opts -> usas tus valores:
    %   ab_opts = struct('Nseg', 2000, 'Slong', 7, 'lim', 1e-3);
    %   % Luego los pasas a tu ruta de abolladura (ver dónde se usa más abajo).
    %
    % NOTA: Estos parámetros impactan directamente a:
    %   - ab_build_dented_profile   (usa Nseg y lim)
    %   - ab_longitudinal_profile   (usa Slong)
    %   - ab_fit_inertia_polys      (barre estaciones longitudinales)
    %
    if nargin < 8 || isempty(ab_opts)
        % Si no se recibió "ab_opts" (o vino vacío), creamos un struct con
        % valores por defecto probados en tus demos:
        ab_opts = struct('Nseg', 1000, ...  % discretización de perímetro
                         'Slong', 5,    ...  % nº de estaciones longitudinales
                         'lim',   3e-3);     % tolerancia de ajuste de perímetro
    end

    % 1) Asegura matriz numérica de propiedades (una sola vez)
    prop_geom_mat = coerce_numeric_prop_geom(prop_geom);

    nElem = numel(no_elemento_a_danar);
    ke_d  = zeros(12,12,nElem);

    % (opcional) columnas donde están D y t en tu prop_geom_mat
    DIAM_COL  = 11;   % ajusta si cambias el layout
    THICK_COL = 12;

    for j = 1:nElem
        idxElemGlobal = no_elemento_a_danar(j);
        tipo = caso_dano{j};

        switch lower(tipo)
            case 'corrosion'
                ke_d(:,:,j) = ke_corrosion_uniform_from_prop( ...
                    idxElemGlobal, L_d(j), dano_porcentaje(j), procs ftp_geom_mat, ...
                    E(j), G(j), DIAM_COL, THICK_COL);

                case 'abolladura'
                % --- indices y entradas ---
                j    = idxElem;                % ya lo tienes en tu for
                idx  = idxElemGlobal;          % no_elemento_a_danar(j)
                L    = L_d(j);
                D    = prop_geom_mat(idx, 11); % diámetro exterior (col 11)
                t    = prop_geom_mat(idx, 12); % espesor (col 12)
                Eel  = E(j);
                Gel  = G(j);
                nu   = Eel/(2*Gel) - 1;        % Poisson por consistencia: G=E/2(1+nu)

                porcent = dano_porcentaje(j);
                assert(porcent < 50, 'La abolladura debe ser < 50%% del diámetro.');

                % --- controles numéricos (defaults o desde config, ver abajo) ---
                Nseg  = ab_opts.Nseg;
                Slong = ab_opts.Slong;
                lim   = ab_opts.lim;

                % --- construir Ke ---
                [ke_loc, ~, ~] = ab_build_element_ke(porcent, D, t, L, Eel, nu, Nseg, Slong, lim);
                ke_d(:,:,j) = ke_loc;

            otherwise
                error('Caso de daño "%s" no soportado.', tipo);
        end
    end

    ke_d_total = ke_d;
end
