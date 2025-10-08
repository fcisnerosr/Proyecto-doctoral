function P = ab_setup_params(porcent, D, t, L, E, nu, Nseg, Slong, lim)
    % AB_SETUP_PARAMS  Parámetros y chequeos para tubo abollado (unidades N-mm-MPa).
    %  P = ab_setup_params(porcent, D, t, L, E, nu, Nseg, Slong, lim)
    
    % --- Validaciones locales (no cruzadas) ---
    arguments
        porcent (1,1) double {mustBeGreaterThanOrEqual(porcent,0), mustBeLessThan(porcent,50)}
        D       (1,1) double {mustBePositive}
        t       (1,1) double {mustBePositive}
        L       (1,1) double {mustBePositive}
        E       (1,1) double {mustBePositive} = 1.9995e5    % MPa = N/mm^2
        nu      (1,1) double {mustBeGreaterThanOrEqual(nu,0), mustBeLessThan(nu,0.5)} = 0.28
        Nseg    (1,1) double {mustBePositive} = 1000
        Slong   (1,1) double {mustBePositive} = 5
        lim     (1,1) double {mustBePositive} = 3e-3
    end
    
    % --- Checks cruzados robustos (fuera del 'arguments') ---
    assert(t < D/2, 'ab_setup_params:ThicknessTooLarge', 't debe ser < D/2.');
    assert(abs(Nseg - round(Nseg)) < eps,  'ab_setup_params:NsegNotInteger',  'Nseg debe ser entero.');
    assert(abs(Slong - round(Slong)) < eps, 'ab_setup_params:SlongNotInteger', 'Slong debe ser entero.');
    
    % --- Cálculos base ---
    P.porcent = porcent;  P.D = D;   P.t = t;  P.L = L;
    P.Nseg = round(Nseg); P.Slong = round(Slong); P.lim = lim;
    P.E = E; P.nu = nu;   P.G = E/(2*(1+nu));
    
    P.Ro = D/2;           % radio exterior
    P.Rm = P.Ro - t/2;    % radio a fibra media (coherente con tu contorno)
    P.R  = P.Rm;
    
    % Área hueca (exacta)
    P.A = pi * ((P.Ro)^2 - (P.Ro - t)^2);
    
    % Polar (pared gruesa)
    P.J = (pi/2) * ((P.Ro)^4 - (P.Ro - t)^4);
    
    % Inercia intacta (Iy = Iz)
    Iext = (pi/4) * (P.Ro)^4;
    Iint = (pi/4) * (P.Ro - t)^4;
    P.I_undamaged = Iext - Iint;
    
    % Profundidad máxima de abolladura
    P.z_s = porcent * D / 100;
    
    % Límite 50 % del diámetro (como en tu script)
    if (P.z_s*100)/(P.R*2) > 50
        error('ab_setup_params:DentTooLarge', ...
              'La abolladura supera 50%% del diámetro (%.1f%%).', (P.z_s*100)/(P.R*2));
    end
end
