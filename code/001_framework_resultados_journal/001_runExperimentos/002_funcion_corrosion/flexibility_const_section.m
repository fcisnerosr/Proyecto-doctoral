function fAA = flexibility_const_section(L, E, G, A, Iy, Iz, J)
% FLEXIBILITY_CONST_SECTION  Matriz f_AA (6x6) para viga/marco EB 3D, sección constante.
    EA  = E*A;   EIy = E*Iy;   EIz = E*Iz;   GJ = G*J;

    fAA = [ L/EA,               0,                0,      0,              0,              0;
            0,       L^3/(3*EIz),                0,      0,              0,     L^2/(2*EIz);
            0,               0,        L^3/(3*EIy),      0,   -L^2/(2*EIy),              0;
            0,               0,                0,    L/GJ,              0,              0;
            0,               0,     -L^2/(2*EIy),      0,          L/(EIy),              0;
            0,      L^2/(2*EIz),                0,      0,              0,          L/(EIz) ];
end
