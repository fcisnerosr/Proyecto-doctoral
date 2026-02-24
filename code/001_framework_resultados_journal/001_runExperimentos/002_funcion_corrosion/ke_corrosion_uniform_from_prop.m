function Ke = ke_corrosion_uniform_from_prop(idxElem, L, pct_corrosion, prop_geom_mat, E, G, DIAM_COL, THICK_COL)
% KE_CORROSION_UNIFORM_FROM_PROP  Ke local 12x12 para tubo con corrosión uniforme.
%   Usa D,t del elemento 'idxElem' en prop_geom_mat(:,DIAM_COL/THICK_COL).

    % extrae dimensiones originales
    D = prop_geom_mat(idxElem, DIAM_COL); 
    t = prop_geom_mat(idxElem, THICK_COL);
    assert(isfinite(D)&&isfinite(t)&&D>0&&t>0, 'D/t inválidos para elemento %d', idxElem);

    % propiedades corroídas
    S = pipe_props_corroded(D, t, pct_corrosion);  % A_d, Iy_d=Iz_d, J_d, D_d, t_d

    % flexibilidades (Euler–Bernoulli, sección constante corroída)
    fAA = flexibility_const_section(L, E, G, S.A, S.Iy, S.Iz, S.J);

    % T (12x6) y rigidez
    T = Tmatrix_from_length(L);

    Ke = T * (fAA \ T.');          % sin inv()
    Ke = 0.5*(Ke + Ke.');          % simetriza numéricamente
    % (opcional) validación SPD:
    % [~,p]=chol(Ke); assert(p==0,'Ke no SPD; revisa entrada.');
end
