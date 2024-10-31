function [T_gamma, T_beta] = TransfM3Dframe_sym(CX, CY, CZ, CXY, i)
    %% Matriz local de rotacion beta y gamma para elementos inclinados
    % Gamma para elementos inclinados alrededor del eje global Y (eje horizontal)
    cosB = CX(i)/CXY(i);
    sinB = CY(i)/CXY(i);
    R_beta = [  cosB    0       sinB;
                0       1       0;
                -sinB   0       cosB];

    % Gamma para elementos inclinados alrededor del eje global Z (eje horizontal)
    cosG = CXY(i);
    sinG = CZ(i);
    R_gamma = [ cosG    sinG    0;
                -sinG   cosG    0;
                0       0       1];
    %% Rectos    
    % Determinamos si el elemento es una columna (vertical)
    if abs(CX(i)) <= 1e-3 && abs(CY(i)) <= 1e-3 && abs(CZ(i)) >= 0.99
        % Criterio para elementos tipo columna
        % Construimos la matriz gamma para columna
        gammaColumna = [0   CZ(i)  0 ;
                        -CZ(i) 0   0;
                        0   0   1];
        
        % Matriz de transformacion para elementos tipo columna
        % Ensamblar la matriz LT para columna
        LT = [gammaColumna zeros(3,9);
              zeros(3,3) gammaColumna zeros(3,6);
              zeros(3,6) gammaColumna zeros(3,3);
              zeros(3,9) gammaColumna];
        
        % Asignar las matrices de transformación
        T_gamma = LT;
        T_beta  = LT;

    elseif CXY(i) <= 1e-3
        % Criterio para elementos horizontales (vigas)
        gamma = [0   CZ(i)  0 ;
                -CZ(i) 0   0;
                0   0   1];
        LT = [gamma zeros(3,9);
              zeros(3,3) gamma zeros(3,6);
              zeros(3,6) gamma zeros(3,3);
              zeros(3,9) gamma];
        
        % Asignar las matrices de transformación
        T_gamma = LT;
        T_beta  = LT;
        
    else
        % Matrices de transformación para elementos inclinados
        T_gamma = [R_gamma zeros(3,9);
                   zeros(3,3) R_gamma zeros(3,6);
                   zeros(3,6) R_gamma zeros(3,3);
                   zeros(3,9) R_gamma];
                        
        T_beta = [R_beta zeros(3,9);
                  zeros(3,3) R_beta zeros(3,6);
                  zeros(3,6) R_beta zeros(3,3);
                  zeros(3,9) R_beta];
    end
end


