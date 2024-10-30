function [T_gamma, T_beta] = TransfM3Dframe_sym(CX, CY, CZ, CXY)
% function [T_gamma, T_beta] = TransfM3Dframe(CX_sym, CY_sym, CZ_sym, CXY_sym)

    

    % Gamma para elementos inclinados
    % Gamma para elementos inclinados alrededor del eje global Y (eje horizontal)
   
    cosB = CX/CXY;
    sinB = CY/CXY;
    R_beta = [  cosB    0       sinB;
                0       1       0;
                -sinB   0       cosB];

    % Gamma para elementos inclinados alrededor del eje global Z (eje horizontal)
    cosG = CXY;
    sinG = CZ;
    R_gamma = [ cosG    sinG    0;
                -sinG   cosG    0;
                0       0       1];
    
    % Determinamos si el elemento es una columna (vertical)
    if abs(CX) <= 1e-3 && abs(CY) <= 1e-3 && abs(CZ) >= 0.99
        % Criterio para elementos tipo columna
        % Construimos la matriz gamma para columna
        gammaColumna = [0   CZ  0 ;
                        -CZ 0   0;
                        0   0   1];
        
        % Ensamblar la matriz LT para columna
        LT = [gammaColumna zeros(3,9);
              zeros(3,3) gammaColumna zeros(3,6);
              zeros(3,6) gammaColumna zeros(3,3);
              zeros(3,9) gammaColumna];
        
        % Asignar las matrices de transformación
        T_gamma = LT;
        T_beta  = LT;

    elseif CXY <= 1e-3
        % Criterio para elementos horizontales (vigas)
        gamma = [0   CZ  0 ;
                -CZ 0   0;
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


