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

% MEF
    NumEle = 3;
    E = [E E E];
    Ar = [A_u A_d A_u];
    Uni = [1 2; 2 3; 3 4];
    Des = [0 1 1 0];
    Ncord= [0 ; 1875; 3125; 5000];
    F   = [0 3000 0 0];
    L   = [1875; 3125; 5000];
    
    for i = 1:NumEle
        A(:,:,i) = (E(i) .* Ar (i) ./ L(i)) * [1 -1; -1 1];
    end
    A;
    
    S = size(Ncord,1);
    K = zeros(S,S);
    
    for i = 1:size(Uni,1)
        m = Uni(i,1);
        n = Uni(i,2);
        MG([m n],[m n],i) = A(:,:,i);
    end
    
    KG = sum(MG,3)
