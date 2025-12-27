function resultados = funcion_deformaciones(opciones)
% FUNCION_DEFORMACIONES Análisis de elemento tubular 3D con deformación inicial
%
% Analiza un elemento tubular tipo viga-columna Euler-Bernoulli 3D (12 DOF)
% con deformación inicial geométrica en el centro del claro, bajo compresión axial.
%
% ENTRADA:
%   opciones - Estructura con campos:
%     .L          - Longitud del elemento [mm]
%     .D          - Diámetro exterior [mm]
%     .t          - Espesor de pared [mm]
%     .E          - Módulo de Young [MPa]
%     .nu         - Coeficiente de Poisson [-]
%     .rho_mat    - Densidad del material [kg/mm³]
%     .Ncomp      - Fuerza de compresión [N] (positiva)
%     .e0_sobre_L - Imperfección como fracción de L [-] (ej. 0.02 = 2%)
%     .nModos     - Número de modos a extraer (default: 6)
%     .verbose    - Imprimir diagnósticos (default: true)
%
% SALIDA:
%   resultados - Estructura con campos:
%     .q_equilibrio   - [12×1] Desplazamientos de equilibrio [mm, rad]
%     .Kt_equilibrio  - [12×12] Matriz tangente en equilibrio [N/mm, N/mm*rad]
%     .Ke             - [12×12] Rigidez elástica [N/mm, N/mm*rad]
%     .Kg             - [12×12] Rigidez geométrica [N/mm, N/mm*rad]
%     .M              - [12×12] Matriz de masa [kg, kg*mm², kg*mm⁴]
%     .omega_rad_s    - [nModos×1] Frecuencias angulares [rad/s]
%     .freq_Hz        - [nModos×1] Frecuencias [Hz]
%     .modos          - [12×nModos] Formas modales normalizadas por masa
%     .diagnosticos   - Estructura con:
%         .Pcr              - Carga crítica de Euler [N]
%         .rho              - Ratio N/Pcr [-]
%         .e0_mm            - Deformación inicial absoluta [mm]
%         .theta_max_rad    - Rotación máxima [rad]
%         .theta_max_deg    - Rotación máxima [deg]
%         .nIter_Newton     - Iteraciones de Newton-Raphson
%         .residuo_final    - Norma del residuo final [N, N*mm]
%         .cond_Kt          - Número de condición de Kt
%         .eig_min_Kt       - Eigenvalor mínimo de Kt (negativo → inestable)
%         .advertencias     - Cell array de strings con warnings
%
% CONVENCIONES:
%   - Orden de DOF: [u v w rx ry rz] en nodo 1, luego en nodo 2
%   - Eje X local: del nodo 1 al nodo 2 (longitudinal)
%   - Eje Y local: perpendicular a X (deflexión lateral v)
%   - Eje Z local: perpendicular a X e Y (deflexión w)
%   - Ncomp > 0 indica compresión
%   - Condiciones de borde: pinned-pinned (u,v,w fijos en ambos nodos)
%
% EJEMPLO:
%   opts.L = 10000;           % 10 m
%   opts.D = 400;             % 400 mm
%   opts.t = 20;              % 20 mm
%   opts.E = 200000;          % 200 GPa
%   opts.nu = 0.3;
%   opts.rho_mat = 7.85e-6;   % kg/mm³ (acero)
%   opts.Ncomp = 500000;      % 500 kN
%   opts.e0_sobre_L = 0.02;   % 2% de L
%   opts.nModos = 6;
%   opts.verbose = true;
%   
%   res = funcion_deformaciones(opts);
%   
%   % Visualizar resultados
%   fprintf('Frecuencia modo 1: %.3f Hz\n', res.freq_Hz(1));
%   fprintf('Iteraciones Newton: %d\n', res.diagnosticos.nIter_Newton);
%   fprintf('Ratio ρ = N/Pcr: %.3f\n', res.diagnosticos.rho);
%
% AUTOR: Framework proyecto doctoral - Detección de daños en jackets
% FECHA: Diciembre 2025
% VERSIÓN: 1.0

%% ========================================================================
%  1) VALIDACIÓN DE ENTRADAS Y VALORES POR DEFECTO
%  ========================================================================

if nargin < 1
    error('Debe proporcionar estructura de opciones');
end

% Campos obligatorios
campos_requeridos = {'L', 'D', 't', 'E', 'nu', 'rho_mat', 'Ncomp', 'e0_sobre_L'};
for i = 1:length(campos_requeridos)
    if ~isfield(opciones, campos_requeridos{i})
        error('Campo obligatorio faltante: %s', campos_requeridos{i});
    end
end

% Valores por defecto
if ~isfield(opciones, 'nModos'),   opciones.nModos = 6;      end
if ~isfield(opciones, 'verbose'),  opciones.verbose = true;  end

% Extraer parámetros
L = opciones.L;
D = opciones.D;
t = opciones.t;
E = opciones.E;
nu = opciones.nu;
rho_mat = opciones.rho_mat;
Ncomp = opciones.Ncomp;
e0_sobre_L = opciones.e0_sobre_L;
nModos = opciones.nModos;
verbose = opciones.verbose;

% Validaciones básicas
if L <= 0,        error('L debe ser positivo'); end
if D <= 0,        error('D debe ser positivo'); end
if t <= 0,        error('t debe ser positivo'); end
if t >= D/2,      error('t debe ser menor que D/2'); end
if E <= 0,        error('E debe ser positivo'); end
if nu <= -1 || nu >= 0.5, error('nu fuera de rango físico'); end
if rho_mat <= 0,  error('rho_mat debe ser positivo'); end
if Ncomp < 0,     error('Ncomp debe ser no negativo (usa valor positivo para compresión)'); end
if e0_sobre_L < 0 || e0_sobre_L > 0.15
    error('e0_sobre_L fuera de rango razonable [0, 0.15]');
end
if nModos < 1 || nModos > 6
    error('nModos debe estar entre 1 y 6 (elemento con 6 DOF libres)');
end

%% ========================================================================
%  2) CÁLCULO DE PROPIEDADES GEOMÉTRICAS Y MATERIALES
%  ========================================================================

% Área y momentos de inercia (tubular circular)
A = pi * (D^2 - (D - 2*t)^2) / 4;           % [mm²]
I = pi * (D^4 - (D - 2*t)^4) / 64;          % [mm⁴]
Iy = I;  % Momento de inercia alrededor de Z
Iz = I;  % Momento de inercia alrededor de Y
J = 2 * I;  % Momento polar (tubular circular)

% Módulo de cortante
G = E / (2 * (1 + nu));  % [MPa]

% Carga crítica de Euler
Pcr = (pi^2 * E * I) / (L^2);  % [N]

% Ratio de carga
rho = Ncomp / Pcr;

% Deformación inicial absoluta
e0_mm = e0_sobre_L * L;  % [mm]

% Rotación máxima en extremos (para perfil sin²)
theta_max_rad = 2 * pi * e0_mm / L;  % [rad]
theta_max_deg = rad2deg(theta_max_rad);

if verbose
    fprintf('\n========================================\n');
    fprintf('ANÁLISIS DE ELEMENTO CON DEFORMACIÓN INICIAL\n');
    fprintf('========================================\n\n');
    fprintf('GEOMETRÍA:\n');
    fprintf('  L = %.1f mm (%.2f m)\n', L, L/1000);
    fprintf('  D = %.1f mm, t = %.1f mm\n', D, t);
    fprintf('  A = %.1f mm², I = %.1e mm⁴\n', A, I);
    fprintf('\nMATERIAL:\n');
    fprintf('  E = %.0f MPa, G = %.0f MPa\n', E, G);
    fprintf('  ν = %.3f, ρ = %.2e kg/mm³\n', nu, rho_mat);
    fprintf('\nCOMPRESIÓN:\n');
    fprintf('  Ncomp = %.1f kN\n', Ncomp/1000);
    fprintf('  Pcr = %.1f kN\n', Pcr/1000);
    fprintf('  ρ = N/Pcr = %.4f\n', rho);
    fprintf('\nDEFORMACIÓN INICIAL:\n');
    fprintf('  e0/L = %.4f (%.2f%%)\n', e0_sobre_L, e0_sobre_L*100);
    fprintf('  e0 = %.2f mm\n', e0_mm);
    fprintf('  θmax = %.4f rad (%.2f°)\n', theta_max_rad, theta_max_deg);
    fprintf('\n');
end

%% ========================================================================
%  3) VERIFICACIONES DE SEGURIDAD (SALVAGUARDAS)
%  ========================================================================

advertencias = {};

% Verificar rotaciones grandes (límite ~0.15 rad = 8.6°)
if theta_max_rad > 0.15
    msg = sprintf('Rotaciones grandes (%.1f°). Modelo Euler-Bernoulli puede perder precisión.', ...
                  theta_max_deg);
    advertencias{end+1} = msg;
    if verbose, warning(msg); end
end

% Verificar proximidad a pandeo (límite seguro: ρ < 0.85)
if rho > 0.85
    error('Muy cerca de pandeo (ρ=%.3f > 0.85). Modelo no válido en esta zona.', rho);
elseif rho > 0.75
    msg = sprintf('Compresión alta (ρ=%.3f). Posible convergencia lenta.', rho);
    advertencias{end+1} = msg;
    if verbose, warning(msg); end
end

% Verificar esbeltez (L/D debe ser razonablemente alto)
esbeltez = L / D;
if esbeltez < 10
    msg = sprintf('Esbeltez baja (L/D=%.1f). Cortante puede ser significativo.', esbeltez);
    advertencias{end+1} = msg;
    if verbose, warning(msg); end
end

%% ========================================================================
%  4) CONSTRUCCIÓN DE MATRICES DE RIGIDEZ (Ke y Kg)
%  ========================================================================

% Inicializar matrices
Ke = zeros(12, 12);  % Rigidez elástica
Kg = zeros(12, 12);  % Rigidez geométrica (stress stiffening)

% ------------------------------------------------------------------------
% 4.1) Rigidez elástica (Ke) - Matriz estándar de Euler-Bernoulli 3D
% ------------------------------------------------------------------------

% Términos axiales (DOF u: 1, 7)
k_axial = E * A / L;
Ke([1 7], [1 7]) = k_axial * [1 -1; -1 1];

% Términos de flexión en plano X-Y (DOF v, ry: 2,6,8,12)
k_flex_y = E * Iz / L^3;
Ke_flex_y = k_flex_y * [ 12,     6*L,   -12,     6*L;
                          6*L,   4*L^2,  -6*L,   2*L^2;
                         -12,    -6*L,    12,    -6*L;
                          6*L,   2*L^2,  -6*L,   4*L^2 ];
dof_flex_y = [2, 6, 8, 12];
Ke(dof_flex_y, dof_flex_y) = Ke(dof_flex_y, dof_flex_y) + Ke_flex_y;

% Términos de flexión en plano X-Z (DOF w, rz: 3,5,9,11)
k_flex_z = E * Iy / L^3;
Ke_flex_z = k_flex_z * [ 12,    -6*L,   -12,    -6*L;
                        -6*L,    4*L^2,   6*L,    2*L^2;
                        -12,     6*L,    12,     6*L;
                        -6*L,    2*L^2,   6*L,    4*L^2 ];
dof_flex_z = [3, 5, 9, 11];
Ke(dof_flex_z, dof_flex_z) = Ke(dof_flex_z, dof_flex_z) + Ke_flex_z;

% Términos de torsión (DOF rx: 4, 10)
k_torsion = G * J / L;
Ke([4 10], [4 10]) = k_torsion * [1 -1; -1 1];

% ------------------------------------------------------------------------
% 4.2) Rigidez geométrica (Kg) - Efecto P-Delta / stress stiffening
% ------------------------------------------------------------------------

% Fuerza axial interna (convención: T > 0 tracción, T < 0 compresión)
T = -Ncomp;  % T negativo para compresión

% Matriz geométrica simplificada (aproximación lineal)
% Nota: Para deformaciones pequeñas, Kg es independiente de la configuración
coef = T / L;

% Contribución traslacional (u, v, w)
Kg_trans_local = coef * [ 1,  0,  0, -1,  0,  0;
                          0,  1,  0,  0, -1,  0;
                          0,  0,  1,  0,  0, -1;
                         -1,  0,  0,  1,  0,  0;
                          0, -1,  0,  0,  1,  0;
                          0,  0, -1,  0,  0,  1 ];
dof_trans = [1, 2, 3, 7, 8, 9];
Kg(dof_trans, dof_trans) = Kg(dof_trans, dof_trans) + Kg_trans_local;

% Contribución rotacional (aproximación para flexión)
coef_rot = T / (10 * L);  % Factor empírico (orden de magnitud)
Kg_rot_y = coef_rot * [ 1, -1; -1, 1];  % ry: DOF 6, 12
Kg_rot_z = coef_rot * [ 1, -1; -1, 1];  % rz: DOF 5, 11
Kg([6 12], [6 12]) = Kg([6 12], [6 12]) + Kg_rot_y;
Kg([5 11], [5 11]) = Kg([5 11], [5 11]) + Kg_rot_z;

%% ========================================================================
%  5) CONSTRUCCIÓN DE MATRIZ DE MASA (M) - Consistente
%  ========================================================================

M = zeros(12, 12);
m = rho_mat * A * L;  % Masa total del elemento [kg]

% Masa traslacional (u, v, w)
% Matriz consistente para viga (coeficientes de Hermite)
m_trans = m / 420 * [ 140,    0,     0,    0,     0,     0,   70,    0,     0,    0,     0,     0;
                        0,  156,     0,    0,     0,   22*L,    0,   54,     0,    0,     0,  -13*L;
                        0,    0,   156,    0,  -22*L,     0,    0,    0,    54,    0,   13*L,     0;
                        0,    0,     0,  140,     0,     0,    0,    0,     0,   70,     0,     0;
                        0,    0, -22*L,    0,  4*L^2,     0,    0,    0, -13*L,    0, -3*L^2,     0;
                        0,  22*L,    0,    0,     0,  4*L^2,    0, 13*L,     0,    0,     0, -3*L^2;
                       70,    0,     0,    0,     0,     0,  140,    0,     0,    0,     0,     0;
                        0,   54,     0,    0,     0,  13*L,    0,  156,     0,    0,     0, -22*L;
                        0,    0,    54,    0, -13*L,     0,    0,    0,   156,    0,  22*L,     0;
                        0,    0,     0,   70,     0,     0,    0,    0,     0,  140,     0,     0;
                        0,    0,  13*L,    0, -3*L^2,     0,    0,    0,  22*L,    0,  4*L^2,     0;
                        0, -13*L,    0,    0,     0, -3*L^2,    0, -22*L,     0,    0,     0,  4*L^2 ];

M = M + m_trans;

% Masa rotacional (momentos de inercia)
Ip = rho_mat * J * L;  % Momento polar de inercia de masa [kg*mm²]
It = Ip / 12;  % Momento transversal aproximado

M(4,4) = Ip / 3;   % rx nodo 1
M(4,10) = Ip / 6;  % rx1-rx2
M(10,4) = Ip / 6;  % rx2-rx1
M(10,10) = Ip / 3; % rx nodo 2

%% ========================================================================
%  6) VECTOR DE DEFORMACIÓN INICIAL (v0)
%  ========================================================================

% Perfil de deformación inicial tipo sin² (máximo en centro)
% v(x) = e0 * sin²(π*x/L)
%      = e0 * (1 - cos(2π*x/L))/2

% Desplazamientos nodales equivalentes:
% v(0) = 0, v(L) = 0 (pinned-pinned)

% Rotaciones nodales equivalentes:
% dv/dx|_{x=0} = e0 * 2π/L * sin(2π*0/L) = 0 (pero aproximación cúbica)
% Para perfil cúbico Hermite que se ajusta mejor:
% Las rotaciones nodales se obtienen de la derivada del perfil

% Cálculo de rotaciones nodales para perfil sin²
% dv/dx = e0 * (2π/L) * sin(2πx/L)
% En x=0:  dv/dx = 0
% En x=L:  dv/dx = 0
% Pero para capturar la curvatura, usamos rotaciones equivalentes

% Aproximación: para sin²(πx/L), las rotaciones equivalentes son:
% ry1 ≈ 4*e0/L  (nodo 1)
% ry2 ≈ -4*e0/L (nodo 2)

v0 = zeros(12, 1);
v0(2) = 0;           % v1 = 0 (traslación)
v0(6) = 4*e0_mm/L;   % ry1 (rotación positiva)
v0(8) = 0;           % v2 = 0 (traslación)
v0(12) = -4*e0_mm/L; % ry2 (rotación negativa)

% Nota: Solo imperfección en plano X-Y (eje Y), w = 0 (decisión 7)

%% ========================================================================
%  7) FUERZAS NODALES EQUIVALENTES POR DEFORMACIÓN INICIAL (f0)
%  ========================================================================

% f0 = Kg * v0
% Estas son las fuerzas que el preesfuerzo N genera debido a la curvatura inicial
f0 = Kg * v0;

%% ========================================================================
%  8) CONDICIONES DE BORDE: PINNED-PINNED
%  ========================================================================

% DOF fijos: traslaciones en ambos nodos (u,v,w) + una rotación de referencia
% Decisión 14: NO fijar rx en ensamble global, pero para elemento AISLADO
% necesitamos evitar modo rígido torsional
% 
% Para elemento aislado en pruebas: fijar traslaciones + rx1
% Para ensamble global (integración futura): no fijar rx

% Determinar si es caso de prueba aislado o integración
esElementoAislado = true;  % Flag para distinguir casos

if esElementoAislado
    % Elemento aislado: fijar traslaciones + rx1 (evitar modo rígido)
    fix = [1, 2, 3, 4, 7, 8, 9];  % u1, v1, w1, rx1, u2, v2, w2
else
    % Ensamble global: solo traslaciones (rx libre para conectividad)
    fix = [1, 2, 3, 7, 8, 9];  % u1, v1, w1, u2, v2, w2
end

free = setdiff(1:12, fix);  % DOF libres

%% ========================================================================
%  9) RESOLVER EQUILIBRIO ESTÁTICO CON NEWTON-RAPHSON
%  ========================================================================

% Fuerzas externas (en este caso, cero)
Fext = zeros(12, 1);

% Caso especial: sin compresión y sin deformación inicial → equilibrio trivial
if Ncomp < 1e-6 && e0_mm < 1e-6
    if verbose
        fprintf('CASO TRIVIAL (N=0, e0=0):\n');
        fprintf('  Equilibrio: q = 0 (sin iteración necesaria)\n');
    end
    q = zeros(12, 1);
    converged = true;
    nIter_Newton = 0;
    residuo_final = 0;
else
    % Configuración de Newton-Raphson
    max_iter = 50;
    tol_res = 1e-6 * max([norm(f0), 1e-3]);  % Tolerancia residuo (relativa)
    tol_dq = 1e-8 * L;                       % Tolerancia incremento (absoluta)
    
    % Inicializar: q = v0 (geometría inicial como punto de partida)
    q = v0;
    
    if verbose
        fprintf('NEWTON-RAPHSON:\n');
        fprintf('  Tolerancias: ||R|| < %.2e N, ||dq|| < %.2e mm\n', tol_res, tol_dq);
    end
    
    converged = false;
    for iter = 1:max_iter
        % Calcular residuo: R = Fint - Fext
        % Fint = (Ke + Kg) * q - f0  (fuerzas internas)
        % R = (Ke + Kg) * q - f0 - Fext
        
        Kt = Ke + Kg;  % Tangente (aquí aproximado como constante)
        R = Kt * q - f0 - Fext;
        
        % Extraer sistema reducido (solo DOF libres)
        R_red = R(free);
        Kt_red = Kt(free, free);
        
        % Verificar singularidad
        rcond_Kt = rcond(Kt_red);
        if rcond_Kt < 1e-14
            error('Matriz tangente singular (iter=%d). rcond=%.1e. Verificar condiciones de borde.', ...
                  iter, rcond_Kt);
        end
        
        % Resolver: Kt * dq = -R
        dq_red = -Kt_red \ R_red;
        dq = zeros(12, 1);
        dq(free) = dq_red;
        
        % Actualizar configuración
        q = q + dq;
        
        % Verificar convergencia
        norm_R = norm(R_red);
        norm_dq = norm(dq_red);
        
        if verbose && (iter <= 3 || mod(iter, 10) == 0 || norm_R < tol_res)
            fprintf('  Iter %2d: ||R|| = %.3e, ||dq|| = %.3e\n', iter, norm_R, norm_dq);
        end
        
        if norm_R < tol_res && norm_dq < tol_dq
            converged = true;
            if verbose
                fprintf('  ✓ Convergencia alcanzada en %d iteraciones\n', iter);
            end
            break;
        end
    end
    
    if ~converged
        msg = sprintf('Newton-Raphson NO convergió en %d iteraciones (||R||=%.2e)', ...
                      max_iter, norm_R);
        advertencias{end+1} = msg;
        warning(msg);
    end
    
    nIter_Newton = iter;
    residuo_final = norm_R;
end

%% ========================================================================
%  10) CALCULAR TANGENTE EN EQUILIBRIO
%  ========================================================================

% Kt en el equilibrio (para este modelo simplificado, Kt = Ke + Kg constante)
Kt_equilibrio = Ke + Kg;
Kt_red_final = Kt_equilibrio(free, free);

% Diagnósticos de la matriz tangente
cond_Kt = cond(Kt_red_final);
eigs_Kt = eig(Kt_red_final);
eig_min_Kt = min(eigs_Kt);
n_eigs_negativos = sum(eigs_Kt < -1e-8);

if verbose
    fprintf('\nDIAGNÓSTICOS DE RIGIDEZ:\n');
    fprintf('  cond(Kt) = %.2e\n', cond_Kt);
    fprintf('  λmin(Kt) = %.3e N/mm\n', eig_min_Kt);
    fprintf('  Eigenvalores negativos: %d\n', n_eigs_negativos);
end

% Verificar mal condicionamiento
if cond_Kt > 1e10
    msg = sprintf('Matriz mal condicionada (κ=%.1e). Precisión reducida.', cond_Kt);
    advertencias{end+1} = msg;
    if verbose, warning(msg); end
end

% Verificar eigenvalores negativos (indica inestabilidad)
if eig_min_Kt < -1e-6
    msg = sprintf('Rigidez indefinida (λmin=%.2e). Sistema inestable.', eig_min_Kt);
    advertencias{end+1} = msg;
    if verbose, warning(msg); end
end

%% ========================================================================
%  11) ANÁLISIS MODAL (VIBRACIONES LIBRES ALREDEDOR DEL EQUILIBRIO)
%  ========================================================================

if verbose
    fprintf('\nANÁLISIS MODAL:\n');
end

% Matrices reducidas
M_red = M(free, free);

% Ajustar número de modos al número de DOF libres disponibles
nDOF_libres = length(free);
nModos_solicitados = nModos;
nModos = min(nModos, nDOF_libres);

if nModos < nModos_solicitados && verbose
    fprintf('  Nota: Se extraerán %d modos (máximo para %d DOF libres)\n', ...
            nModos, nDOF_libres);
end

% Verificar definición positiva de M
eigs_M = eig(M_red);
if min(eigs_M) < 1e-12
    error('Matriz de masa singular. Verificar masa rotacional.');
end

% Resolver eigenproblema: (Kt - ω² M) φ = 0
try
    [phi_red, wn2_diag] = eig(Kt_red_final, M_red);
    wn2_vec = diag(wn2_diag);
    
    % Filtrar eigenvalores negativos o complejos
    idx_validos = (real(wn2_vec) > 0) & (abs(imag(wn2_vec)) < 1e-10);
    wn2_vec = real(wn2_vec(idx_validos));
    phi_red = real(phi_red(:, idx_validos));
    
    % Ordenar por frecuencia ascendente
    [wn2_vec, idx_sort] = sort(wn2_vec, 'ascend');
    phi_red = phi_red(:, idx_sort);
    
    % Verificar que tengamos suficientes modos válidos
    nModos_disponibles = length(wn2_vec);
    if nModos_disponibles < nModos
        msg = sprintf('Solo %d modos válidos (se esperaban %d). Verificar Kt y M.', ...
                      nModos_disponibles, nModos);
        advertencias{end+1} = msg;
        if verbose, warning(msg); end
        nModos = nModos_disponibles;  % Ajustar
    end
    
    wn2_vec = wn2_vec(1:nModos);
    phi_red = phi_red(:, 1:nModos);
    
    % Calcular frecuencias
    omega_rad_s = sqrt(wn2_vec);  % [rad/s]
    freq_Hz = omega_rad_s / (2 * pi);  % [Hz]
    
    % Normalizar modos por masa: φᵀ M φ = 1
    phi_red_norm = zeros(size(phi_red));
    for i = 1:nModos
        masa_modal = phi_red(:, i)' * M_red * phi_red(:, i);
        phi_red_norm(:, i) = phi_red(:, i) / sqrt(masa_modal);
    end
    
    % Expandir modos a 12×1 (Decisión 17: Opción B)
    modos_full = zeros(12, nModos);
    modos_full(free, :) = phi_red_norm;
    
    if verbose
        fprintf('  Modos extraídos: %d\n', nModos);
        fprintf('\n  Frecuencias naturales:\n');
        for i = 1:nModos
            fprintf('    Modo %d: ω = %.3f rad/s, f = %.3f Hz\n', ...
                    i, omega_rad_s(i), freq_Hz(i));
        end
    end
    
catch ME
    error('Fallo en análisis modal: %s', ME.message);
end

%% ========================================================================
%  12) RESUMEN FINAL Y ADVERTENCIAS
%  ========================================================================

if verbose
    fprintf('\n========================================\n');
    fprintf('RESUMEN FINAL\n');
    fprintf('========================================\n');
    fprintf('Equilibrio alcanzado: %s\n', ternary(converged, 'SÍ', 'NO'));
    fprintf('Iteraciones Newton: %d\n', nIter_Newton);
    fprintf('Modos válidos: %d\n', nModos_disponibles);
    fprintf('Advertencias: %d\n', length(advertencias));
    if ~isempty(advertencias)
        fprintf('\n⚠️  ADVERTENCIAS:\n');
        for i = 1:length(advertencias)
            fprintf('  %d. %s\n', i, advertencias{i});
        end
    end
    fprintf('========================================\n\n');
end

%% ========================================================================
%  13) EMPAQUETAR RESULTADOS
%  ========================================================================

resultados = struct();

% Resultados principales
resultados.q_equilibrio = q;
resultados.Kt_equilibrio = Kt_equilibrio;
resultados.Ke = Ke;
resultados.Kg = Kg;
resultados.M = M;
resultados.omega_rad_s = omega_rad_s;
resultados.freq_Hz = freq_Hz;
resultados.modos = modos_full;

% Diagnósticos
resultados.diagnosticos = struct();
resultados.diagnosticos.Pcr = Pcr;
resultados.diagnosticos.rho = rho;
resultados.diagnosticos.e0_mm = e0_mm;
resultados.diagnosticos.theta_max_rad = theta_max_rad;
resultados.diagnosticos.theta_max_deg = theta_max_deg;
resultados.diagnosticos.nIter_Newton = nIter_Newton;
resultados.diagnosticos.residuo_final = residuo_final;
resultados.diagnosticos.cond_Kt = cond_Kt;
resultados.diagnosticos.eig_min_Kt = eig_min_Kt;
resultados.diagnosticos.n_eigs_negativos = n_eigs_negativos;
resultados.diagnosticos.converged = converged;
resultados.diagnosticos.advertencias = advertencias;

end

%% ========================================================================
%  FUNCIONES AUXILIARES
%  ========================================================================

function resultado = ternary(condicion, valor_si, valor_no)
    % Operador ternario simple
    if condicion
        resultado = valor_si;
    else
        resultado = valor_no;
    end
end
