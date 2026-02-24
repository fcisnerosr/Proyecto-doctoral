function T = Tmatrix_from_length(L)
% TMATRIX_FROM_LENGTH  Matriz T (12x6) para Ke = T*(fAA\T')
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
