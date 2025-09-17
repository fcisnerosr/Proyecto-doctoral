function [ke_d, PF, P] = ab_build_element_ke(porcent, D, t, L, E, nu, Nseg, Slong, lim)
    % AB_BUILD_ELEMENT_KE  Construye la Ke local 12x12 del elemento con abolladura.
    P  = ab_setup_params(porcent, D, t, L, E, nu, Nseg, Slong, lim);
    S  = ab_longitudinal_profile(P);
    PF = ab_fit_inertia_polys(P, S);
    fAA = ab_flexibility_matrix(P, PF);
    T   = ab_Tmatrix(P.L);
    
    % Ke = T*inv(fAA)*T'  ->  T*(fAA\T')
    ke_d = T * (fAA \ T.');
    % Simetriza por robustez numérica
    ke_d = 0.5*(ke_d + ke_d.');
end
