function PF = ab_fit_inertia_polys(P, S)
    % AB_FIT_INERTIA_POLYS  Barre estaciones, calcula Iy,Iz y ajusta polinomios.
    VIy = zeros(numel(S.zi),1);
    VIz = zeros(numel(S.zi),1);
    
    for k=1:numel(S.zi)
        G = ab_build_dented_profile(P, S.zi(k));
        [Iy_d, Iz_d] = ab_inertia_from_profile(P, G);
        VIy(k)=Iy_d; VIz(k)=Iz_d;
    end
    
    % añade extremos intactos
    VIy_full = [P.I_undamaged; VIy; P.I_undamaged];
    VIz_full = [P.I_undamaged; VIz; P.I_undamaged];
    x_full   = linspace(0, P.L, numel(VIy_full))';
    
    % Fit (grado 4)
    g = 4;
    poly_y = polyfit(x_full, VIy_full, g);
    poly_z = polyfit(x_full, VIz_full, g);
    
    PF.VIy = VIy_full; PF.VIz = VIz_full; PF.x = x_full;
    PF.poly_y = poly_y; PF.poly_z = poly_z;
end
