% function [ke_d] = funcion_corrosion(ed, porcent, Long, D, t, L_D);

format short G
    %% COMENTAR desde AQUí %%%%
    clc; clear all; close all %%% Cuidado con correr el código principal y que esta línea esté descomentada
    

%% Datos del elemento a dañar
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ed = 5; % ed = elemento a dañar                                     %
        % Unidades en milímetros                                            %
        % Longitud_total_del_elemento_en_mm;                                %
            switch ed                                                       %
                case {5,6,9,7}                                              %
                    Long = 5000;                                            %
                case {1,3}                                                  %
                    Long = 4000;                                            %
                case {2, 4}                                                 %
                    Long = 3000;                                            %
            end                                                             %                  
        D       = 600;      % Diametro_de_elemento_tubular_en_mm;           %
        t       = 25.4;     % Espesor_en_mm;                                %
%         L_D     = Long;     % longitud dañada_en_mm;                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% COMENTAR hasta ACÁ %%%%
    L = Long;
    Ubicacion_de_corrosion_en_m  = Long*0.5;

    fprintf('Propiedades del elemento tubular \n\n')
    fprintf('Longitud del elemento                  = %7.0f  mm \n',Long)
    fprintf('Diámetro                               = %7.0f  mm \n',D)
    fprintf('Espesor                                = %7.1f  mm \n',t)
    fprintf('Ubicación central de corrosión         = %7.0f  mm \n',Ubicacion_de_corrosion_en_m)
    
    %% Elemento tubular no corroido
    % Área 
    R = 0.5 * D;
    A1 = pi * R^2;
    R_interior = 0.5 *(D - (2*t));
    A2 = pi * R_interior^2;
    A_u = A1 - A2;             % en mm^2. El subíndice "_u" es de "undamaged" 

    % Módulos
    E = 1.999477869*1E+05;          % Elasticidad (MPa)
    mu = 0.28;                      % relación de Poisson (promedio para el acero)
    G = E/(2*(1+mu));               % Cortante (MPa)
    R = R-0.5*t;                    % Radio sin la mitad del espesor
    J = pi/4 * ((0.5*D)^4 - (R)^4); % Polar de inercia en mm^4
    
    % Momento de inercia
    R_ext = 0.5*D;
    I_ext = pi/4 * R_ext^4;
    R_int = (0.5*D) - t;
    I_int = pi/4 * R_int^4;
    I_u   = I_ext - I_int;

    %% Elemento tubular corroido
    % Reducción del espesor
    t_porcent = 50;                 % Porcentaje de reducción del espesor
    t_corro = t_porcent * t / 100;  % Espesor que va a restar al espesor sin daño
    t_d = t - t_corro;              % Espesor ya dañado. El subíndice "_d" es de "damaged"

    fprintf('\nPropiedades de la reducción del espesor y su área \n\n')
    fprintf('Porcentaje de reducción del espesor    = %7.0f  %% \n',t_porcent)
    fprintf('Espesor ya dañado                      = %7.1f  mm \n',t_d)
    
    % Área dañada
    D_d          = D - (2*t_corro);
    R_d          = 0.5 * D_d;
    A1_d         = pi  * R_d^2;  
    R_interior_d = 0.5 * (D_d - (2*t_d));
    A2_d         = pi  * R_interior_d^2;
    A_d          = A1_d - A2_d;             % en mm^2. El subíndice "_u" es de "undamaged" 

    fprintf('Área dañada                            = %7.0f  mm^2 \n',A_d)
    fprintf('Área intacta                           = %7.0f  mm^2 \n',A_u)
    fprintf('Porcentaje de reducción del área       = %7.1f  %% \n\n',100 - (A_d/A_u*100))

    % Momento de inercia dañado
    R_ext_d = 0.5*D_d;
    I_ext_d = 1/4 * pi * R_ext_d^4;
    I_int_d = 1/4 * pi *  R_interior_d^4;
    I_d     = I_ext_d - I_int_d;

    %% Matriz de flexibilidades y rigidecez
    % Elemento tubular dañado
        f_AA_d = [L/(E*A_d)     0               0               0           0               0;...
                  0             L^3/(3*E*I_d)   0               0           0               L^2/(2*E*I_d);...
                  0             0               L^3/(3*E*I_d)   0           -L^2/(2*E*I_d)  0;...
                  0             0               0               L/(G*J)     0               0;...
                  0             0               -L^2/(2*E*I_d)  0           L/(E*I_d)       0;...
                  0             L^2/(2*E*I_d)   0               0           0               L/(E*I_d)];
    
       % Matriz de transformación para evitar invertir la matriz de flexibilidades
        T   = [-1    0      0       0   0   0
                0    -1     0       0   0   0 
                0    0      -1      0   0   0
                0    0      0       -1  0   0
                0    0      L       0   -1  0
                0   -L      0       0   0  -1
                1    0      0       0   0   0
                0    1      0       0   0   0
                0    0      1       0   0   0
                0    0      0       1   0   0
                0    0      0       0   1   0
                0    0      0       0   0   1];
    
        ke_d = T * f_AA_d^(-1) * T'   % Matriz de rigidecez del elemento
    
%% Ejemplo de comprobación de resultados
     % Elemento tubular inacto
        f_AA_u = [L / (E*A_u)   0               0               0           0               0;...
                  0             L^3/(3*E*I_u)   0               0           0               L^2/(2*E*I_u);...
                  0             0               L^3/(3*E*I_u)   0           -L^2/(2*E*I_u)  0;...
                  0             0               0               L/(G*J)     0               0;...
                  0             0               -L^2/(2*E*I_u)  0           L/(E*I_u)       0;...
                  0             L^2/(E*I_u)     0               0           0               L/(E*I_u)];
            
        % Matriz de transformación para evitar invertir la matriz de flexibilidades
        T   = [-1    0      0       0   0   0
                0    -1     0       0   0   0 
                0    0      -1      0   0   0
                0    0      0       -1  0   0
                0    0      L       0   -1  0
                0   -L      0       0   0  -1
                1    0      0       0   0   0
                0    1      0       0   0   0
                0    0      1       0   0   0
                0    0      0       1   0   0
                0    0      0       0   1   0
                0    0      0       0   0   1];
    
        ke_u = T * f_AA_u^(-1) * T'    % Matriz de rigidecez del elemento tubular inacto

    % Comparación de modelos en SAP2000
    % Viga 3D
    % Aplicación de fuerzas
        P = [0; 0; 0; 0; 0; 0; 7000;  -1000;   -3000;   +0;  +0;  +0];
        % Modelo sin corrosion
            % Matriz de rigidez de elemento viga
            k_AA = ke_u(7:12,7:12);
            k_AB = zeros(6,6);
            k_u1 = horzcat(k_AA,k_AB);
            k_u2 = horzcat(k_AB,k_AA);
            k_u = vertcat(k_u1,k_u2)
            % Desplazamientos del extremo libre
            d_u = k_u^-1 * P
        % Modelo con corrosion    
            % Matriz de rigidez
            k_AA = ke_d(7:12,7:12);
            k_AB = zeros(6,6);
            k_d1 = horzcat(k_AA,k_AB);
            k_d2 = horzcat(k_AB,k_AA);
            k_d  = vertcat(k_d1,k_d2)

            % Desplazamientos
            d_d = k_d^-1 * P
% end
