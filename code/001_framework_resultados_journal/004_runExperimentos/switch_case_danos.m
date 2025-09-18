function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos( ...
    no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G, ab_opts)

    % defaults para abolladura (si no viene desde config.ab)
    if nargin < 8 || isempty(ab_opts)
        ab_opts = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);
    end

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

            otherwise
                error('switch_case_danos:TipoNoSoportado', ...
                      'Caso de daño "%s" no soportado.', tipoj);
        end
    end

    ke_d_total = ke_d;
end
