t = 13;
x = 0.31921;
D = 300
% --- Daño al espesor ---
        t_corro = x * t;           % Espesor de corrosión
        t_d = t - t_corro            % Espesor reducido
        
        % --- Área con corrosión ---
        D_d = D - (2 * t_corro)       % Diámetro reducido
        R_d = 0.5 * D_d;               % Radio reducido (exterior)
        A1_d = pi * R_d^2;             % Área del círculo exterior (reducido)
        R_interior_d = 0.5 * (D_d - (2 * t_d));  % Radio interior reducido
        A2_d = pi * R_interior_d^2;    % Área del círculo interior (reducido)
        A_damaged = A1_d - A2_d        % Área con daño (mm^2)
        
        % --- Momento de inercia con daño ---
        R_ext_d = 0.5 * D_d;            % Radio exterior reducido
        I_ext_d = (1/4) * pi * R_ext_d^4; % Momento de inercia exterior (reducido)
        I_int_d = (1/4) * pi * R_interior_d^4; % Momento de inercia interior (reducido)
        Iy_damaged = I_ext_d - I_int_d % Momento de inercia con daño (eje y)
        Iz_damaged = Iy_damaged;        % Momento de inercia con daño (eje z)
