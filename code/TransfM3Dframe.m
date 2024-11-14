function [Gamma_gamma, Gamma_beta] = TransfM3Dframe(CX, CY, CZ , CXY, i, cosalpha, sinalpha)
    % Ejes globales
    % X = eje acostado 1
    % Y = eje acostado 2, ortogonal a X
    % Z = eje vertical

    % No borrar lo siguiente para revisión:
    % sinalpha_v = sinalpha
    % cosalpha_v = cosalpha
    % CX_v        = CX(i)
    % CY_v        = CY(i)
    % CZ_v        = CZ(i)
    % CXY_v       = CXY(i)

    if CXY(i) <= 1e-3 || CXY(i) == 1 && sinalpha ~= 0
        %% Elementos ortogonales
        % disp('Columna')
        % Columnas
        beta_M =[    0                  0           CZ(i); 
                     CZ(i)*sinalpha     cosalpha    0;
                    -CZ(i)*cosalpha     sinalpha    0];
        Gamma_beta = blkdiag(beta_M, beta_M, beta_M, beta_M); % Crea bloques diagonales de R_beta
        Gamma_gamma = eye(12,12);
    elseif sinalpha == 0 && cosalpha == 1 && CY(i) == 1
        % Vigas
        % disp('Viga paralela a Y')
        beta_M =[    0      1   0; 
                     1      0   0;
                     0      0   1];
        Gamma_beta = blkdiag(beta_M, beta_M, beta_M, beta_M); % Crea bloques diagonales de R_beta
        Gamma_gamma = eye(12,12);
    elseif sinalpha == 0 && cosalpha == 1 && CY(i) == 0
        % disp('Viga paralela a X')
        Gamma_beta  = eye(12,12);
        Gamma_gamma = eye(12,12);
    % elseif sinalpha ~= 0 && cosalpha ~= 1
    else
        % disp('Elemento diagonal')
        %% Elementos diagonales
        %% Angulo Beta, angulo que gira alrededor de Y global
        % Nota: No eliminar las siguientes líneas de código; son necesarias para verificar los ángulos correspondientes.
        % nodes(2,4)
        % beta = asin(nodes(2,4)/L)
        % beta_grados = rad2deg(beta)
        % beta_M = [ cos(beta)  0       sin(beta);
        %            0          1       0;
        %           -sin(beta)  0       cos(beta)];
        % Recordatorio: 
        % cos(beta) = CXY
        % sin(beta) = CZ
        beta_M = [ CXY(i)   0   CZ(i);
                   0        1   0;
                  -CZ(i)    0   CXY(i)];
        Gamma_beta = blkdiag(beta_M, beta_M, beta_M, beta_M); % Crea bloques diagonales de R_beta

        %% Angulo Gamma, angulo que gira alrededor de Z global
        % Nota: No eliminar las siguientes líneas de código; son necesarias para verificar los ángulos correspondientes.
        % Referencia: https://marcelopardo.com/coordenadas-globales-y-locales-portico-3d/
        % cos(beta)=proy/L
        % proy = L*cos(beta)
        % gamma = acos(nodes(2,2)/proy);
        % gamma_grados = rad2deg(gamma)
        % gamma_M = [ cos(gamma)    sin(gamma)  0;
        %            -sin(gamma)    cos(gamma)  0;
        %             0             0           1];
        % Recordatorio: 
        % cos(gamma) = CX/CXY
        % sin(gamma) = CY/CXY
        gamma_M = [ CX(i)/CXY(i)    CY(i)/CXY(i)    0;
                   -CY(i)/CXY(i)    CX(i)/CXY(i)    0;
                    0               0               1];
        Gamma_gamma = blkdiag(gamma_M, gamma_M, gamma_M, gamma_M); % Crea bloques diagonales de R_beta
    end
end 
