%% ================================================================
%  Beam-column tubular 3D (12 DOF): Ke + Kg(T) y f0 = Kg*v0  (SOLO LOCAL)
%
%  REWRITE para congruencia con Wilson:
%   (A) Wilson usa T (tensión +). Para compresión: T = -P  => softening.
%       Aquí: Ncomp > 0 significa COMPRESIÓN, internamente T = -Ncomp.
%   (B) Pcr se calcula consistente con BC del modal (factor K de longitud efectiva).
%   (C) Se incluye paso estático incremental: (Ke+Kg)u = Fext - f0,  f0=Kg*v0.
%
%  Sustento clave (Wilson, cap. 11):
%   FT = FE + FG = [kE + kG] v = kT v, y si el axial permanece constante,
%   basta kT para incluir stiffening/softening. En compresión T = -P, kT puede
%   volverse singular (cercanía a pandeo).
%  ================================================================

clear; clc; close all; format shortG

%% ----------------- INPUTS -----------------
% Material (MPa = N/mm^2), geometría (mm)
E   = 2.00e5;
nu  = 0.30;
G   = E/(2*(1+nu));
D   = 600;      % diámetro exterior (mm)
t   = 25.4;     % espesor (mm)
L   = 10000;    % longitud (mm)

% Axial (N): COMPRESIÓN POSITIVA (convención del script)
Ncomp = 2.0e7;

% Imperfección en % (respecto a L o D) -> e0y/e0z
use_pct_of_L = true;     % true: % respecto a L ; false: % respecto a D
eta_y = 0.05;            % [%] imperfección “pancita” en plano x–y (deflexión v)
eta_z = 0.00;            % [%] imperfección “pancita” en plano x–z (deflexión w)
e0y_direct = [];         % (mm) si quieres directo
e0z_direct = [];

% Modal: elige BC para el ELEMENTO PRUEBA
% Opciones: 'fixed-free' (cantilever), 'pinned-pinned', 'fixed-pinned', 'fixed-fixed'
bc_modal = 'fixed-free';

% Masa (consistente)
rho_kgmm3 = 7.85e-6;     % 7850 kg/m^3 = 7.85e-6 kg/mm^3
include_rx_torsion_mass = false;

% Cargas externas nodales (LOCAL 12x1), por defecto cero
Fext_loc = zeros(12,1);

%% ---------- Propiedades de sección del tubo ----------
[ A, Iy, Iz, J ] = section_tube(D, t);

%% ------------------- MATRICES LOCALES (12x12) -------------------
Ke_loc = Ke_beam3D(E, G, A, Iy, Iz, J, L);

% IMPORTANTE:
% Wilson define Kg con T (tensión +). Para compresión: T = -P.
% Aquí: Ncomp > 0 compresión => T = -Ncomp
Kg_loc = Kg_beam3D_fromCompression(Ncomp, L);

Kt_loc = Ke_loc + Kg_loc;    % kT = kE + kG

%% -------- Imperfección: % -> e0 (mm) y carga geométrica equivalente -------
% (2) Mapear % a amplitud e0 en media luz
if isempty(e0y_direct)
    base_y = L; if ~use_pct_of_L, base_y = D; end
    e0y = (eta_y/100)*base_y;
else
    e0y = e0y_direct;
end
if isempty(e0z_direct)
    base_z = L; if ~use_pct_of_L, base_z = D; end
    e0z = (eta_z/100)*base_z;
else
    e0z = e0z_direct;
end

% Vector de imperfección nodal (LOCAL)
% NOTA: esta "cúbica tipo Wilson" es una elección nodal (no seno exacto).
v0_loc = zeros(12,1);

% Plano x–y -> [v1 thz1 v2 thz2] = [2 6 8 12]
v_dof = [2, 6, 8, 12];
v0_loc(v_dof) = v0_loc(v_dof) + [0; 4*e0y/L; 0; -4*e0y/L];

% Plano x–z -> [w1 thy1 w2 thy2] = [3 5 9 11]
w_dof = [3, 5, 9, 11];
v0_loc(w_dof) = v0_loc(w_dof) + [0; 4*e0z/L; 0; -4*e0z/L];

% Carga geométrica equivalente: f0 = Kg*v0
f0_loc = Kg_loc * v0_loc;

%% ---------------------- BC: fijaciones para estático/modal ----------------
[fix, free] = bc_sets_12dof(bc_modal);

%% ---------------------- (C) ESTÁTICO incremental con f0 -------------------
% (Ke+Kg) u = Fext - f0   (incremental sobre la geometría inicial v0)
rhs = (Fext_loc - f0_loc);

u_loc = zeros(12,1);
Kred = Kt_loc(free, free);
rhs_red = rhs(free);

% Resolver (con chequeo básico)
if rcond(Kred) < 1e-14
    warning('Kt(free,free) muy mal condicionada (cerca de pandeo / singularidad).');
end
u_loc(free) = Kred \ rhs_red;

q_loc = v0_loc + u_loc;   % configuración total (v0 + incremento)

%% ---------------------- (B) CHEQUEO DE CERCANÍA A Pcr ---------------------
% Euler con longitud efectiva: Pcr = pi^2*E*I / (Keff*L)^2
Keff = effective_length_factor(bc_modal);

Pcr_y = (pi^2 * E * Iy) / (Keff*L)^2;
Pcr_z = (pi^2 * E * Iz) / (Keff*L)^2;
Pcr_min = min(Pcr_y, Pcr_z);

rho = Ncomp / Pcr_min;     % utilización respecto al Pcr consistente con BC
near_buckling = rho >= 0.90;

%% ---------------------- MODAL (Ke vs Ke+Kg) -------------------------------
M_loc = M_beam3D_consistent(rho_kgmm3, A, L, Iy, Iz, include_rx_torsion_mass);

K0 = Ke_loc(free, free);
K1 = Kt_loc(free, free);
Mred = M_loc(free, free);

k_modes = min(6, size(K0,1));

% Para este tamaño, eig es robusto (evita sorpresas de eigs con matrices indefinidas)
[Phi0, Lam0] = eig(K0, Mred);
[Phi1, Lam1] = eig(K1, Mred);

lam0 = diag(Lam0); lam1 = diag(Lam1);

% Ordenar por lambda ascendente
[lam0s, i0] = sort(real(lam0), 'ascend'); Phi0 = Phi0(:, i0);
[lam1s, i1] = sort(real(lam1), 'ascend'); Phi1 = Phi1(:, i1);

lam0s = lam0s(1:k_modes);
lam1s = lam1s(1:k_modes);

% Frecuencias (si hay lambdas negativas => inestabilidad)
w0 = zeros(k_modes,1);
w1 = zeros(k_modes,1);

if any(lam1s <= 0)
    warning('Hay eigenvalores <= 0 con Kt: indica inestabilidad (cerca/mas allá de pandeo).');
end

w0(:) = sqrt(max(lam0s, 0));
w1(:) = sqrt(max(lam1s, 0));

red_pct = 100*(w1 - w0)./max(w0, eps);

%% ---------------------------- Reporte mínimo ------------------------------
disp('--- PROPIEDADES ---')
fprintf('BC modal = %s  |  Keff = %.3f\n', bc_modal, Keff);
fprintf('L = %.3f mm\n', L);
fprintf('Pcr_y=%.3e N, Pcr_z=%.3e N,  Pcr(min)=%.3e N\n', Pcr_y, Pcr_z, Pcr_min)
fprintf('Ncomp=%.3e N  -> rho=N/Pcr(min)=%.3f\n', Ncomp, rho)
if near_buckling
    warning('rho >= 0.90: muy cercano a inestabilidad Euler (K_t ~ singular).');
end

fprintf('Imperfecciones: e0y=%.3f mm  (eta_y=%.3f%% %s)\n', e0y, eta_y, tern(use_pct_of_L,'de L','de D'))
fprintf('                e0z=%.3f mm  (eta_z=%.3f%% %s)\n', e0z, eta_z, tern(use_pct_of_L,'de L','de D'))

disp('--- ESTÁTICO incremental ---')
fprintf('||u_loc||_inf = %.3e  |  ||q_loc||_inf = %.3e\n', norm(u_loc,inf), norm(q_loc,inf))
disp('f0_loc^T (carga geométrica equivalente):'), disp(f0_loc.')
disp('u_loc^T (incremento estático):'), disp(u_loc.')

disp('--- MODAL (Ke vs Ke+Kg) con BC ---')
tbl = [ (1:k_modes).' , w0(:) , w1(:) , red_pct(:) ];
disp('modo   w0        w1        %Δw (w1-w0)/w0*100')
disp(tbl)

fprintf(['\nNota clave: aquí el modal depende de Ncomp vía Kg(Ncomp). ' ...
         'La imperfección v0 entra como f0=Kg*v0 en el estático incremental (u, q). ' ...
         'Si en tu estructura real N cambia por el preanálisis estático global, ' ...
         'entonces Kg se actualiza por elemento y eso sí afecta frecuencias/modos.\n']);

%% ========================== FUNCIONES AUXILIARES ==========================
function s = tern(cond, a, b), if cond, s=a; else, s=b; end, end

function [fix, free] = bc_sets_12dof(bc)
    % DOF por nodo: [u v w rx ry rz]  (nodo i = 1..6, nodo j = 7..12)
    switch lower(strtrim(bc))
        case 'fixed-free'   % cantilever: nodo i empotrado
            fix = 1:6;
        case 'pinned-pinned' % ambos apoyos: traslaciones fijas en ambos extremos
            fix = [1 2 3 7 8 9];
        case 'fixed-pinned'  % i fijo, j con traslaciones fijas
            fix = [1:6 7 8 9];
        case 'fixed-fixed'
            fix = 1:12;
        otherwise
            error('BC no reconocida: %s', bc);
    end
    free = setdiff(1:12, fix);
end

function Keff = effective_length_factor(bc)
    % Factores clásicos aproximados para Euler:
    % pinned-pinned: K=1.0
    % fixed-free (cantilever): K=2.0
    % fixed-pinned: K~0.699
    % fixed-fixed: K=0.5
    switch lower(strtrim(bc))
        case 'pinned-pinned', Keff = 1.0;
        case 'fixed-free',    Keff = 2.0;
        case 'fixed-pinned',  Keff = 0.699;
        case 'fixed-fixed',   Keff = 0.5;
        otherwise, error('BC no reconocida: %s', bc);
    end
end

function [A, Iy, Iz, J] = section_tube(D, t)
    Do = D; Di = D - 2*t;
    A  = pi/4 * (Do^2 - Di^2);
    I  = pi/64 * (Do^4 - Di^4);
    Iy = I; Iz = I;
    J  = pi/32 * (Do^4 - Di^4);
end

function Ke = Ke_beam3D(E,G,A,Iy,Iz,J,L)
    Ke = zeros(12);

    % Axial (u)
    k_ax = (E*A/L)*[ 1 -1; -1 1 ];
    Ke([1 7],[1 7]) = Ke([1 7],[1 7]) + k_ax;

    % Torsión (rx)
    k_tor = (G*J/L)*[ 1 -1; -1 1 ];
    Ke([4 10],[4 10]) = Ke([4 10],[4 10]) + k_tor;

    % Flexión x–z: [w1 ry1 w2 ry2] = [3 5 9 11]
    L2 = L*L;
    k_fz = (E*Iy/L^3) * [  12,   6*L,  -12,   6*L;
                           6*L,  4*L2, -6*L,  2*L2;
                          -12,  -6*L,   12,  -6*L;
                           6*L,  2*L2, -6*L,  4*L2 ];
    idx_z = [3 5 9 11];
    Ke(idx_z, idx_z) = Ke(idx_z, idx_z) + k_fz;

    % Flexión x–y: [v1 rz1 v2 rz2] = [2 6 8 12]
    k_fy = (E*Iz/L^3) * [  12,   6*L,  -12,   6*L;
                           6*L,  4*L2, -6*L,  2*L2;
                          -12,  -6*L,   12,  -6*L;
                           6*L,  2*L2, -6*L,  4*L2 ];
    idx_y = [2 6 8 12];
    Ke(idx_y, idx_y) = Ke(idx_y, idx_y) + k_fy;
end

function Kg = Kg_beam3D_fromCompression(Ncomp, L)
    % Wilson: Kg se expresa en función de T (tensión +).
    % Para compresión: T = -P.
    % Convención aquí: Ncomp > 0 significa COMPRESIÓN => T = -Ncomp.
    T = -Ncomp;

    Kg = zeros(12);
    kg4 = (T/(30*L)) * [  36,   3*L,  -36,   3*L;
                          3*L,  4*L^2, -3*L, -L^2;
                         -36,  -3*L,   36,  -3*L;
                          3*L, -L^2,  -3*L,  4*L^2 ];

    % Plano x–y: [v1 rz1 v2 rz2]
    Kg([2 6 8 12],[2 6 8 12]) = Kg([2 6 8 12],[2 6 8 12]) + kg4;

    % Plano x–z: [w1 ry1 w2 ry2]
    Kg([3 5 9 11],[3 5 9 11]) = Kg([3 5 9 11],[3 5 9 11]) + kg4;
end

function M = M_beam3D_consistent(rho, A, L, Iy, Iz, include_rx)
    M = zeros(12);
    mu = rho * A;
    L2 = L^2;

    % Axial u: [1 7]
    M_ax = (mu*L/6)*[2 1; 1 2];
    M([1 7],[1 7]) = M([1 7],[1 7]) + M_ax;

    % Flexión x–z: [w1 ry1 w2 ry2] = [3 5 9 11]
    M_fbz = (mu*L/420) * [ 156,   22*L,   54,  -13*L;
                           22*L,  4*L2,  13*L,  -3*L2;
                           54,    13*L, 156,  -22*L;
                          -13*L, -3*L2, -22*L,  4*L2 ];
    M([3 5 9 11],[3 5 9 11]) = M([3 5 9 11],[3 5 9 11]) + M_fbz;

    % Flexión x–y: [v1 rz1 v2 rz2] = [2 6 8 12]
    M_fby = (mu*L/420) * [ 156,   22*L,   54,  -13*L;
                           22*L,  4*L2,  13*L,  -3*L2;
                           54,    13*L, 156,  -22*L;
                          -13*L, -3*L2, -22*L,  4*L2 ];
    M([2 6 8 12],[2 6 8 12]) = M([2 6 8 12],[2 6 8 12]) + M_fby;

    if include_rx
        Jpol = 2*Iy;
        Irot = rho * Jpol * L / 2;  % heurística
        M([4 10],[4 10]) = M([4 10],[4 10]) + (Irot/6)*[2 1; 1 2];
    end
end

%% ------------------------ COMMIT (breve) ------------------------
% fix: kg sign in compression + Pcr by BC + static f0 step
