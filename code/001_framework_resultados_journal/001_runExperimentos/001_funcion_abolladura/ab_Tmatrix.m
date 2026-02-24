function T = ab_Tmatrix(L)
% AB_TMATRIX  Matriz T (12x6) para evitar invertir f_AA: Ke = T*(fAA\T').
T = [ -1  0   0   0   0   0;
       0 -1   0   0   0   0;
       0  0  -1   0   0   0;
       0  0   0  -1   0   0;
       0  0   L   0  -1   0;
       0 -L   0   0   0  -1;
       1  0   0   0   0   0;
       0  1   0   0   0   0;
       0  0   1   0   0   0;
       0  0   0   1   0   0;
       0  0   0   0   1   0;
       0  0   0   0   0   1 ];
end
