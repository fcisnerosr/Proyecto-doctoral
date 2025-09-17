function S = pipe_props_corroded(D, t, pct)
% PIPE_PROPS_CORRODED  Propiedades de un tubo circular con corrosión uniforme (% sobre t).
% Usa geometría hueca exacta. Unidades: mm, mm^2, mm^4.
    pct = max(0, pct);
    t_loss = pct * t / 100;
    t_d = t - t_loss;                      % espesor residual
    D_d = D - 2*t_loss;                    % diámetro exterior residual
    assert(t_d>0 && D_d>0, 'Sección nula/negativa tras corrosión.');

    Do = D_d;
    Di = D_d - 2*t_d;
    assert(Di>=0 && Do>Di, 'Geometría interna inválida tras corrosión.');

    A  = (pi/4) * (Do^2 - Di^2);
    I  = (pi/64)* (Do^4 - Di^4);           % Iy = Iz para tubo
    J  = 2*I;                               % J=2Iy para sección circular

    assert(A>0 && I>0 && J>0, 'Propiedades negativas tras corrosión.');

    S = struct('A',A,'Iy',I,'Iz',I,'J',J,'D_d',D_d,'t_d',t_d);
end
