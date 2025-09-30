function S = ab_longitudinal_profile(P)
    % AB_LONGITUDINAL_PROFILE  Estaciones x y profundidades zi(x) con ley seno.
    x = linspace(0, P.L, P.Slong+1);  % S0..S_Slong
    v = x/P.L;                        % 0..1
    Vz_s = P.z_s * sin(pi*v);
    Vz_s = Vz_s(2:end-1);            % quitar extremos (intactos)
    S.x_stations = x;
    S.zi = P.R - Vz_s(:);            % cota de flatten (z_i)
    S.VIy = []; S.VIz = [];          % se llenan luego
end
