function [ke_d_total, ke_d, prop_geom_mat] = switch_case_danos(no_elemento_a_danar, L_d, caso_dano, dano_porcentaje, prop_geom, E, G)
% SWITCH_CASE_DANOS  Genera matrices Ke locales con daño por elemento.
% Entradas: ver tu firma original.
% Salidas : ke_d_total (12x12xNE_danados), ke_d idem, prop_geom_mat (numérico)

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
