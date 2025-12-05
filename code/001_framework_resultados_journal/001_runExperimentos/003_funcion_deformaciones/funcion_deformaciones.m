%% ================================================================
%  Beam-column tubular 3D (12 DOF): Ke + Kg(N) y f0 = Kg*v0  (SOLO LOCAL)
%  Objetivo de esta versión:
%   (1) Armar Kt (12x12) local con 6 GDL por nodo (u v w rx ry rz), sin ensamblaje global.
%   (2) Manejar imperfección en % (respecto a L o D) -> e0y/e0z.
%   (3) Reportar normalización N/Pcr y advertir cercanía a inestabilidad.
%   (4) Incluir valores propuestos de material, geometría y P.
%   (5) Empotrar nodo 1 (BC locales) y armar matrices reducidas para MODAL.
%   (6) Calcular modos “intacto” (Ke) vs “pre-esforzado” (Ke+Kg(N)) y comparar reducciones.
%   (7) Mantener estilo y estructura previos.
%
%  Sustento:
%   - (Wilson, Cap. 11)  k_G (4x4) para viga en flexión bajo axial, eqs. (11.4) y (11.6):
%         F_T = (k_E + k_G) v   ->  K_t = K_e + K_g
%     y formulación general K_g = ∫ G^T S G dV, eq. (11.23).
%   - (Han & Chen, 1983)  viga-columna: EI v'''' - N v'' = 0  -> ablandamiento por compresión.
%  Nota: N > 0 a compresión. Imperfección nodal en media luz (interpolación cúbica Hermite):
%        [0, 4e0/L, 0, -4e0/L] sobre [v1,thz1,v2,thz2] (plano y) y [w1,thy1,w2,thy2] (plano z).
%  ================================================================

clear; clc; close all; format shortG

%% ----------------- INPUTS (puedes dejarlos para probar) -----------------
% (4) Valores propuestos de material (MPa = N/mm^2) y geometría (mm)
E   = 2.00e5;           % Módulo de Young
nu  = 0.30;             % Poisson
G   = E/(2*(1+nu));     % Módulo cortante
D   = 600;              % Diámetro exterior (mm)
t   = 25.4;             % Espesor (mm)
L   = 10000;            % Longitud del miembro (mm)

% Carga axial (N) [Compresión positiva]  (se usa SOLO para Kg y f0)
N   = 2.0e7;

% (2) Imperfección ingresada como % -> define cómo convertir a e0 (elige UNO)
use_pct_of_L = true;     % true: % respecto a L ; false: % respecto a D

eta_y = 0.05;            % [%] imperfección “pancita” en plano x–y (deflexión v)
eta_z = 0.00;            % [%] imperfección “pancita” en plano x–z (deflexión w)

% Si prefieres dar e0 directo (mm), pon eta_y/eta_z en [] y pon e0y/e0z abajo.
e0y_direct = [];         % deja [] para usar %; o pon un número en mm
e0z_direct = [];

% (5) Condición de frontera local para MODAL: empotramiento en nodo 1
fix = [1 2 3 4 5 6];          % DOF fijos
free = setdiff(1:12, fix);    % DOF libres (nodo 2)

% (Dinámica) Densidad para matriz de masa consistente
rho_kgmm3 = 7.85e-6;     % acero ~7850 kg/m^3 = 7.85e-6 kg/mm^3
include_rx_torsion_mass = false;  % masa rotacional en rx (usual: false)

%% ---------- Propiedades de sección del tubo (si ya tienes A,I,J, usa esos) ----------
[ A, Iy, Iz, J ] = section_tube(D, t); % Iy=Iz para tubo circular; J≈2I

%% ------------------- MATRICES EN SISTEMA LOCAL (12x12) -------------------
Ke_loc = Ke_beam3D(E, G, A, Iy, Iz, J, L);   % Rigidez elástica clásica 3D
Kg_loc = Kg_beam3D(N, L);                    % Rigidez geométrica (Wilson 11.4, duplicada y/z)
Kt_loc = Ke_loc + Kg_loc;                    % Rigidez tangente local

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
v0_loc = zeros(12,1);
% Plano x–y -> [v1 thz1 v2 thz2] = [2 6 8 12]
v_dof = [2, 6, 8, 12];
v0_loc(v_dof) = v0_loc(v_dof) + [0; 4*e0y/L; 0; -4*e0y/L];
% Plano x–z -> [w1 thy1 w2 thy2] = [3 5 9 11]
w_dof = [3, 5, 9, 11];
v0_loc(w_dof) = v0_loc(w_dof) + [0; 4*e0z/L; 0; -4*e0z/L];

% Carga geométrica equivalente (Wilson 11.6): f0 = Kg * v0  (NO entra al modal)
f0_loc = Kg_loc * v0_loc;

%% ---------------------- (3) Chequeo de cercanía a Pcr ---------------------
Pcr_y = (pi^2 * E * Iy) / L^2;
Pcr_z = (pi^2 * E * Iz) / L^2;
Pcr_min = min(Pcr_y, Pcr_z);
rho = N / Pcr_min;                      % Utilización de pandeo (ideal Euler)
alpha = 1 / max(1 - rho, eps);          % Amplificador conceptual (no usado en modal)

% Reglas prácticas (informativas, NO normativas):
near_buckling = rho >= 0.90;
service_limit_ratio = (max(abs([e0y,e0z])))/(L);  % e0/L (adimensional)
% Por defecto, mantener e0/L <= ~1% como “imperfección pequeña” (solo guía).

%% ---------------------- MATRICES REDUCIDAS PARA MODAL ---------------------
% Masa consistente local 12x12 (traducciones y flexiones; rot rx opcional)
M_loc = M_beam3D_consistent(rho_kgmm3, A, L, Iy, Iz, include_rx_torsion_mass);

% Intacto: K = Ke ; Pre-esforzado: Kt = Ke + Kg(N)
K_intact = Ke_loc;
K_damaged = Kt_loc;

% Reducidas (empotramiento nodo 1)
K0 = K_intact(free, free);
K1 = K_damaged(free, free);
Mred = M_loc(free, free);

% Autovibraciones (libre) — NO necesito unidades absolutas, comparo razones
[numVecs,~] = size(K0);  % solo para pedir pocas
k_modes = min(6, size(K0,1));  % hasta 6 modos como máximo razonable

[Phi0, Lam0] = eigs(K0, Mred, k_modes, 'SM');  % intacto
[Phi1, Lam1] = eigs(K1, Mred, k_modes, 'SM');  % con preesfuerzo

w0 = sqrt(diag(Lam0));               % rad/s (escala relativa)
w1 = sqrt(diag(Lam1));

% (6) Comparación en porcentaje de reducción por “daño geométrico” (N)
red_pct = 100*(w1 - w0)./w0;         % < 0 => reducción

%% ---------------------------- Reporte mínimo ------------------------------
disp('--- PROPIEDADES ---')
fprintf('L = %.3f mm\n', L);
fprintf('Pcr_y=%.3e N, Pcr_z=%.3e N,  Pcr(min)=%.3e N\n', Pcr_y, Pcr_z, Pcr_min)
fprintf('N=%.3e N  -> rho=N/Pcr(min)=%.3f  (alpha=1/(1-rho)=%.3f)\n', N, rho, alpha)
if near_buckling
    warning('rho >= 0.90: muy cercano a inestabilidad de Euler (K_t ~ singular).')
end
fprintf('Imperfecciones: e0y=%.3f mm  (eta_y=%.3f%% %s)\n', e0y, eta_y, tern(use_pct_of_L,'de L','de D'))
fprintf('                e0z=%.3f mm  (eta_z=%.3f%% %s)\n', e0z, eta_z, tern(use_pct_of_L,'de L','de D'))
fprintf('e0_max/L = %.4f (guía: mantener <= ~0.01 para imperfección pequeña)\n', service_limit_ratio)
disp('Subbloque Kg_y LOCAL [v1 thz1 v2 thz2]:'), disp(Kg_loc(v_dof, v_dof))
disp('Subbloque Kg_z LOCAL [w1 thy1 w2 thy2]:'), disp(Kg_loc(w_dof, w_dof))
disp('f0_loc^T (NO entra al eigen, solo estática):'), disp(f0_loc.')

disp('--- MODAL (empotramiento en nodo 1) ---')
tbl = [ (1:k_modes).' , w0(:) , w1(:) , red_pct(:) ];
disp('modo   w0        w1        %Δw (w1-w0)/w0*100')
disp(tbl)

% Nota importante sobre e0:
fprintf(['\nNota: En la formulación de Wilson (modos con preesfuerzo), las frecuencias ' ...
         'dependen de N vía Kg(N), NO de e0. La imperfección influye en MODAL solo si antes ' ...
         'se hace un estático con f0=Kg*v0 para actualizar el estado axial N*. Aquí se reporta e0 ' ...
         'y se construye f0, pero el eigen usa únicamente K=Ke y K=Ke+Kg(N).\n'])

%% ========================== FUNCIONES AUXILIARES ==========================
function s = tern(cond, a, b), if cond, s=a; else, s=b; end, end

function [A, Iy, Iz, J] = section_tube(D, t)
    % Tubo circular hueco: A, Iy=Iz, J ~ 2I (N-mm coherentes afuera)
    Do = D; Di = D - 2*t;
    A  = pi/4 * (Do^2 - Di^2);
    I  = pi/64 * (Do^4 - Di^4);   % eje y o z
    Iy = I; Iz = I;
    J  = pi/32 * (Do^4 - Di^4);   % polar (~2*I)
end

function Ke = Ke_beam3D(E,G,A,Iy,Iz,J,L)
    % Ke local 12x12, orden DOF por nodo: [u v w rx ry rz] (Euler-Bernoulli)
    Ke = zeros(12);

    % Axial (u)
    k_ax = (E*A/L)*[ 1 -1; -1 1 ];
    Ke([1 7],[1 7]) = Ke([1 7],[1 7]) + k_ax;

    % Torsión (rx)
    k_tor = (G*J/L)*[ 1 -1; -1 1 ];
    Ke([4 10],[4 10]) = Ke([4 10],[4 10]) + k_tor;

    % Flexión en plano x–z (curvatura en y): DOF [w1 thy1 w2 thy2] = [3 5 9 11]
    L2 = L*L;
    k_fz = (E*Iy/L^3) * [  12,   6*L,  -12,   6*L;
                           6*L,  4*L2, -6*L,  2*L2;
                          -12,  -6*L,   12,  -6*L;
                           6*L,  2*L2, -6*L,  4*L2 ];
    idx_z = [3 5 9 11];
    Ke(idx_z, idx_z) = Ke(idx_z, idx_z) + k_fz;

    % Flexión en plano x–y (curvatura en z): DOF [v1 thz1 v2 thz2] = [2 6 8 12]
    k_fy = (E*Iz/L^3) * [  12,   6*L,  -12,   6*L;
                           6*L,  4*L2, -6*L,  2*L2;
                          -12,  -6*L,   12,  -6*L;
                           6*L,  2*L2, -6*L,  4*L2 ];
    idx_y = [2 6 8 12];
    Ke(idx_y, idx_y) = Ke(idx_y, idx_y) + k_fy;
end

function Kg = Kg_beam3D(N,L)
    % Kg local 12x12 por esfuerzo axial N (compresión > 0).
    % (Wilson, cap. 11, eq. 11.4): bloque 4x4 aplicado a ambos planos de flexión.
    Kg = zeros(12);
    kg4 = (N/(30*L)) * [  36,   3*L,  -36,   3*L;
                          3*L,  4*L^2, -3*L, -L^2;
                         -36,  -3*L,   36,  -3*L;
                          3*L, -L^2,  -3*L,  4*L^2 ];
    % Plano x–y: [v1 thz1 v2 thz2]
    Kg([2 6 8 12],[2 6 8 12]) = Kg([2 6 8 12],[2 6 8 12]) + kg4;
    % Plano x–z: [w1 thy1 w2 thy2]
    Kg([3 5 9 11],[3 5 9 11]) = Kg([3 5 9 11],[3 5 9 11]) + kg4;
end

function M = M_beam3D_consistent(rho, A, L, Iy, Iz, include_rx)
    % Masa consistente local 12x12 (traducciones y flexiones Euler-Bernoulli)
    % rho = kg/mm^3 ; M en kg. Para comparar reducciones modales la escala absoluta no importa.
    M = zeros(12);
    mu = rho * A;     % masa lineal (kg/mm)
    L2 = L^2;

    % Axial u: [1 7]
    M_ax = (mu*L/6)*[2 1; 1 2];
    M([1 7],[1 7]) = M([1 7],[1 7]) + M_ax;

    % Flexión x–z: [w1 thy1 w2 thy2] = [3 5 9 11]
    M_fbz = (mu*L/420) * [ 156,   22*L,   54,  -13*L;
                           22*L,  4*L2,  13*L,  -3*L2;
                           54,    13*L, 156,  -22*L;
                          -13*L, -3*L2, -22*L,  4*L2 ];
    M([3 5 9 11],[3 5 9 11]) = M([3 5 9 11],[3 5 9 11]) + M_fbz;

    % Flexión x–y: [v1 thz1 v2 thz2] = [2 6 8 12]
    M_fby = (mu*L/420) * [ 156,   22*L,   54,  -13*L;
                           22*L,  4*L2,  13*L,  -3*L2;
                           54,    13*L, 156,  -22*L;
                          -13*L, -3*L2, -22*L,  4*L2 ];
    M([2 6 8 12],[2 6 8 12]) = M([2 6 8 12],[2 6 8 12]) + M_fby;

    % (opcional) Torsión rotacional en rx: [4 10] como inercia de St. Venant -> suele omitirse.
    if include_rx
        % aproximación simple (no crítica para comparación relativa)
        Jpol = 2*Iy;  % para tubo circular J ~ 2I
        Irot = rho * Jpol * L / 2;  % masa/inercia rotacional equivalente (heurística)
        M([4 10],[4 10]) = M([4 10],[4 10]) + (Irot/6)*[2 1; 1 2];
    end
end
