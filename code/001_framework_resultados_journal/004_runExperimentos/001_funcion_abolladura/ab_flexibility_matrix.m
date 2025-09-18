function fAA = ab_flexibility_matrix(P, PF)
    % AB_FLEXIBILITY_MATRIX  Arma f_AA (6x6) con integrales de 1/(E*I(x)).
    E = P.E; G = P.G; A = P.A; J = P.J; L = P.L;
    
    % Helpers de evaluación (polinomio grado 4)
    py = PF.poly_y; pz = PF.poly_z;
    Iy_fun = @(x) py(1)*x.^4 + py(2)*x.^3 + py(3)*x.^2 + py(4)*x + py(5);
    Iz_fun = @(x) pz(1)*x.^4 + pz(2)*x.^3 + pz(3)*x.^2 + pz(4)*x + pz(5);
    
    ey = @(x) 1./(E*Iy_fun(x));
    ez = @(x) 1./(E*Iz_fun(x));
    
    % Definir integrandos (coinciden con tu notación)
    f_02_02 = integral(@(x) x.^2 .* ez(x), 0, L);
    f_03_03 = integral(@(x) x.^2 .* ey(x), 0, L);
    f_05_05 = integral(@(x)      ey(x),    0, L);
    f_06_06 = integral(@(x)      ez(x),    0, L);
    
    f_02_06 = integral(@(x)   x .* ez(x),  0, L);
    f_06_02 = f_02_06;
    f_03_05 = integral(@(x)  -x .* ey(x),  0, L);
    f_05_03 = f_03_05;
    
    f_02_08 = integral(@(x) (x - x.^2).*ez(x), 0, L);
    f_03_09 = integral(@(x) (x - x.^2).*ey(x), 0, L);
    f_05_11 = integral(@(x)      (-1).*ey(x),  0, L);
    f_06_12 = integral(@(x)      (-1).*ez(x),  0, L);
    f_06_08 = integral(@(x) (1 - x) .* ez(x),  0, L);
    f_05_09 = integral(@(x) (-1 + x).*ey(x),   0, L);
    f_03_11 = integral(@(x)       x  .*ey(x),  0, L);
    f_02_12 = integral(@(x)      (-x) .*ez(x), 0, L);
    
    fAA = [ L/(E*A)   0         0        0        0        0;
            0         f_02_02   0        0        0        f_06_02;
            0         0         f_03_03  0        f_05_03  0;
            0         0         0        L/(G*J)  0        0;
            0         0         f_03_05  0        f_05_05  0;
            0         f_02_06   0        0        0        f_06_06 ];
end
