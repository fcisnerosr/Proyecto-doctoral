% function [ke_d] = funcion_corrosion(ed, porcent, Long, D, t, L_D);

format short G
    %% COMENTAR desde AQUí %%%%
    clc; clear all; close all %%% Cuidado con correr el código principal y que esta línea esté descomentada
    

%% Datos del elemento a dañar
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ed = 5; % ed = elemento a dañar                                     %
        porcent_long = 025; % Porcen de longitudinal de la corrosión;       %
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
    L_d = porcent_long * L / 100; % longitud de corrosión en función al porcentaje ingresado

    fprintf('Propiedades del elemento tubular \n\n')
    fprintf('Longitud del elemento                  = %7.0f  mm \n',Long)
    fprintf('Diámetro                               = %7.0f  mm \n',D)
    fprintf('Espesor                                = %7.0f  mm \n',t)
    fprintf('Ubicación central de corrosión         = %7.0f  mm \n',Ubicacion_de_corrosion_en_m)
    fprintf('Porcentaje longitudinal de corrosión   = %7.0f  %% \n',porcent_long)
    fprintf('Longitud de corrosión                  = %7.0f  mm \n',L_d)
    L_u = 0.5*(L - L_d);    % Longitd del primer tramo no corroido
    fprintf('Longitud intacta                       = %7.0f  mm \n\n',L_u)

    
    %% Sección intacta
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

    %% Sección corroida
    % Reducción del espesor
    t_porcent = 050;                % Porcentaje de reducción del espesor
    t_corro = t_porcent * t / 100;  % Espesor que va a restar al espesor sin daño
    t_d = t - t_corro;              % Espesor ya dañado. El subíndice "_d" es de "damaged"

    fprintf('\nPropiedades de la reducción del espesor y su área \n\n')
    fprintf('Porcentaje de reducción del espesor    = %7.0f  %% \n',t_porcent)
    fprintf('Espesor ya dañado                      = %7.1f  mm \n',t_d)
    
    % Área dañada
    D_d          = D - (2*t_corro);
    R_d          = 0.5 * D_d;
    A1_d         = pi * R_d^2;  
    R_interior_d = 0.5 * (D_d - (2*t_d));
    A2_d         = pi * R_interior_d^2;
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
        % 1er tramo sin daño 
            % Área
                f_11_u = L_u / (E*A_u);
            % Inercia
                % Ecuaciones a integrar
                    ec_u_02_02 = @(x) x.^2 / (E*I_u);
                    ec_u_03_03 = @(x) x.^2 / (E*I_u);
                    ec_u_05_05 = L_u/(E*I_u);
                    ec_u_06_06 = L_u/(E*I_u);
                    ec_u_02_06 = @(x)  x / (E*I_u);
                    ec_u_03_05 = @(x) -x / (E*I_u);
                    ec_u_05_03 = ec_u_03_05;
                    ec_u_06_02 = ec_u_02_06;
                % Integraciones
                    fu_02_02   = integral(ec_u_02_02, 0 , L_u);
                    fu_03_03   = integral(ec_u_03_03, 0 , L_u);
                    fu_05_05   = ec_u_05_05;
                    fu_06_06   = ec_u_06_06;
                    fu_02_06   = integral(ec_u_02_06, 0 , L_u);
                    fu_03_05   = integral(ec_u_03_05, 0 , L_u);
                    fu_05_03   = integral(ec_u_05_03, 0 , L_u);
                    fu_06_02   = integral(ec_u_06_02, 0 , L_u); 
            % Matriz de flexibidad 1
                    f_AA_u1 = [f_11_u    0                  0               0           0               0;...
                              0         fu_02_02            0               0           0               fu_06_02;...
                              0         0                   fu_03_03        0           fu_05_03        0;...
                              0         0                   0               L_u/(G*J)   0               0;...
                              0         0                   fu_03_05        0           fu_05_05        0;...
                              0         fu_02_06            0               0           0               fu_06_06];

        % 2do tramo con daño
            % Longitud dañada
                L_d = (L_d + L_u ) - L_u;
            % Área 
                f_11_d = L_d / (E*A_d);
            % Inercia
                % Ecuaciones a integrar
                    ec_d_02_02 = @(x) x.^2 / (E*I_d);
                    ec_d_03_03 = @(x) x.^2 / (E*I_d);
                    ec_d_05_05 = ((L_d + L_u ) /(E*I_d))- (L_u/(E*I_d));
                    ec_d_06_06 = ((L_d + L_u ) /(E*I_d))- (L_u/(E*I_d));
                    ec_d_02_06 = @(x)  x / (E*I_d);
                    ec_d_03_05 = @(x) -x / (E*I_d);
                    ec_d_05_03 = ec_d_03_05;
                    ec_d_06_02 = ec_d_02_06;
                % Integraciones
                    fd_02_02 = integral(ec_d_02_02, L_u , L_u + L_d);
                    fd_03_03 = integral(ec_d_03_03, L_u , L_u + L_d);
                    fd_05_05 = ec_d_05_05;
                    fd_06_06 = ec_d_06_06;
                    fd_02_06 = integral(ec_d_02_06, L_u , L_u + L_d);
                    fd_03_05 = integral(ec_d_03_05, L_u , L_u + L_d);
                    fd_05_03 = integral(ec_d_05_03, L_u , L_u + L_d);
                    fd_06_02 = integral(ec_d_06_02, L_u , L_u + L_d);
            % Matriz de flexibidad 2
                    f_AA_d2 = [f_11_d        0                   0               0           0               0;...
                                  0         fd_02_02            0               0           0               fd_06_02;...
                                  0         0                   fd_03_03        0           fd_05_03        0;...
                                  0         0                   0               L_u/(G*J)   0               0;...
                                  0         0                   fd_03_05        0           fd_05_05        0;...
                                  0         fd_02_06            0               0           0               fd_06_06]
        
        % 3er tramo sin daño 
        % Área
            f_11_u = L_u / (E*A_u);
        % Inercia
            % Ecuaciones a integrar
                ec_u_02_02 = @(x) x.^2 / (E*I_u);
                ec_u_03_03 = @(x) x.^2 / (E*I_u);
                ec_u_05_05 = ((L_u + L_d + L_u)/(E*I_u)) - ((L_u + L_d)/(E*I_u));
                ec_u_06_06 = ((L_u + L_d + L_u)/(E*I_u)) - ((L_u + L_d)/(E*I_u));
                ec_u_02_06 = @(x)  x / (E*I_u);
                ec_u_03_05 = @(x) -x / (E*I_u);
                ec_u_05_03 = ec_u_03_05;
                ec_u_06_02 = ec_u_02_06;
            % Integraciones
                fu_02_02   = integral(ec_u_02_02, L_u + L_d, L_u + L_d + L_u);
                fu_03_03   = integral(ec_u_03_03, L_u + L_d, L_u + L_d + L_u);
                fu_05_05   = ec_u_05_05;
                fu_06_06   = ec_u_06_06;
                fu_02_06   = integral(ec_u_02_06, L_u + L_d, L_u + L_d + L_u);
                fu_03_05   = integral(ec_u_03_05, L_u + L_d, L_u + L_d + L_u);
                fu_05_03   = integral(ec_u_05_03, L_u + L_d, L_u + L_d + L_u);
                fu_06_02   = integral(ec_u_06_02, L_u + L_d, L_u + L_d + L_u);
        % Matriz de flexibidad 3
                f_AA_u3 = [f_11_u       0                   0               0           0               0;...
                              0         fu_02_02            0               0           0               fu_06_02;...
                              0         0                   fu_03_03        0           fu_05_03        0;...
                              0         0                   0               L_u/(G*J)   0               0;...
                              0         0                   fu_03_05        0           fu_05_05        0;...
                              0         fu_02_06            0               0           0               fu_06_06];
        
        % Matriz de flexibilidad total
        f_AA_t = f_AA_u1 + f_AA_d2 + f_AA_u3;

        % Matriz de transformación para evitar invertir la matriz de flexibilidades
            T   = [-1    0                      0                   0   0   0
                    0    -1                     0                   0   0   0 
                    0    0                      -1                  0   0   0
                    0    0                      0                   -1  0   0
                    0    0                      (L_u + L_d + L_u)   0   -1  0    
                    0   -(L_u + L_d + L_u)      0                   0   0  -1
                    1    0                      0                   0   0   0
                    0    1                      0                   0   0   0
                    0    0                      1                   0   0   0
                    0    0                      0                   1   0   0
                    0    0                      0                   0   1   0
                    0    0                      0                   0   0   1];
        
            ke_tu = T * f_AA_t^(-1) * T'    % Matriz de rigidecez del elemento tubular completa (dañada)

%     % Comparación de modelos en SAP2000
%     % Viga 3D
%     % Aplicación de fuerzas
        P = [0; 0; 0; 0; 0; 0;...
            -7000;  1000;  3000; 0;  0;  0];
        % Modelo con corrosion    
            % Matriz de rigidez
            f_AA = ke_tu(1:6,1:6);
            f_AB = zeros(6,6);
            k_d1 = horzcat(f_AA,f_AB);
            k_d2 = horzcat(f_AB,f_AA);
            k_d = vertcat(k_d1,k_d2)

            % Desplazamientos
            d_d = k_d^-1 * P
% % end
