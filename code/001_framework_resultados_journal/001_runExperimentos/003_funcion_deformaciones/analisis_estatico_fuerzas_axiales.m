function [N_axial, rho, Pcr, diagnostico] = analisis_estatico_fuerzas_axiales(...
    nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio)
% ANALISIS_ESTATICO_FUERZAS_AXIALES - Calcula fuerzas axiales en elementos por bajada de cargas
%
% DESCRIPCIÓN:
%   Realiza análisis estático lineal de la estructura jacket bajo cargas
%   permanentes (peso propio + topside) para obtener las fuerzas axiales
%   necesarias para el análisis de deformación inicial.
%
% SINTAXIS:
%   [N_axial, rho, Pcr, diagnostico] = analisis_estatico_fuerzas_axiales(...
%       nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio)
%
% ENTRADAS:
%   nodes              - [nNodos×4] Matriz de nodos: [ID, x, y, z] en metros
%   elements           - [nElem×3] Matriz de elementos: [ID, nodo_i, nodo_j]
%   A                  - [nElem×1] Área de sección transversal [m²]
%   Iy, Iz             - [nElem×1] Momentos de inercia [m⁴]
%   J                  - [nElem×1] Momento polar de inercia [m⁴]
%   E                  - [nElem×1] Módulo de elasticidad [Pa]
%   G                  - [nElem×1] Módulo de cortante [Pa]
%   vxz                - [nElem×3] Vectores del plano xz local
%   ID                 - [6×nNodos] Matriz de identificadores de DOF
%                        Positivos: DOF libres, Negativos: DOF restringidos
%   W_topside          - [escalar] Peso total de la superestructura (deck) [N]
%                        Aplicado SOLO en nodos de superestructura
%                        (ejemplo: 12500000 N = 12.5 MN para ~1275 ton)
%                        Justificación: API RP2A-WSD (15-25 kPa), ISO 19902
%   incluir_peso_propio - [bool] true: incluye peso propio de elementos
%                                 false: solo cargas externas
%
% SALIDAS:
%   N_axial            - [nElem×1] Fuerza axial en cada elemento [N]
%                        Positivo: tensión, Negativo: compresión
%   rho                - [nElem×1] Ratio de carga crítica ρ = |N|/Pcr [-]
%                        Rango típico: [0, 0.85] (límite de seguridad)
%   Pcr                - [nElem×1] Carga crítica de pandeo de Euler [N]
%                        Pcr = π²·E·Imin / L²
%   diagnostico        - Estructura con información adicional:
%       .nodos_topside      - IDs de nodos donde se aplicó W_topside
%       .F_total            - Vector de cargas globales [6*nNodos×1]
%       .U_static           - Desplazamientos estáticos [6*nNodos×1]
%       .elementos_tension  - IDs de elementos en tensión (N>0)
%       .elementos_compresion - IDs de elementos en compresión (N<0)
%       .rho_max            - Máximo ratio de carga (el más crítico)
%       .elem_mas_cargado   - ID del elemento con mayor |ρ|
%
% ALGORITMO:
%   1. Ensambla matriz de rigidez global K usando elementos intactos
%   2. Construye vector de cargas F:
%      - Peso propio: distribuido a nodos extremos de cada elemento
%      - Topside: distribuido entre nodos superiores (z máxima)
%   3. Resuelve sistema lineal: K·U = F (solo DOF libres)
%   4. Extrae desplazamientos por elemento en coords locales
%   5. Calcula fuerza axial: N = E·A·(u_j - u_i)/L
%   6. Calcula carga crítica: Pcr = π²·E·min(Iy,Iz)/L²
%   7. Calcula ratio: ρ = |N|/Pcr
%
% EJEMPLO DE USO:
%   % Después de lectura_hoja_excel.m en main_launcher.m
%   [N_axial, rho, Pcr, diag] = analisis_estatico_fuerzas_axiales(...
%       nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, 8290953.54, true);
%   
%   % Elementos con compresión moderada-alta (buenos para deformación inicial)
%   idx_optimos = find(rho > 0.3 & rho < 0.7);
%   fprintf('Elementos óptimos para daño tipo 3: %d\n', length(idx_optimos));
%
% NOTAS:
%   - Usa la misma arquitectura que ensamblaje_matriz_rigidez_global_sin_dano.m
%   - Solo considera elementos intactos (sin daño previo)
%   - Análisis lineal: no considera efectos P-Δ de segundo orden
%   - Los nodos con ID<0 están restringidos (empotrados en mudline)
%
% REFERENCIAS:
%   - Vlajic et al. (2014): "Geometrically exact planar beams with initial 
%     pre-stress and large curvature"
%   - Euler buckling: Pcr = π²EI/L²
%
% VER TAMBIÉN:
%   ensamblaje_matriz_rigidez_global_sin_dano, funcion_deformaciones,
%   localkeframe3D, TransfM3Dframe
%
% AUTOR: Sistema de análisis estructural - Proyecto Doctoral
% FECHA: Diciembre 2025
% VERSIÓN: 1.0

%% ========================================================================
%  1. VALIDACIÓN DE ENTRADAS
%  ========================================================================
narginchk(11, 11);

nNodos = size(nodes, 1);
nElem = size(elements, 1);
IDmax = max(max(ID));

% Densidad del acero (típica para estructuras offshore)
rho_acero = 7850;  % kg/m³

% Gravedad
g = 9.81;  % m/s²

fprintf('\n=== ANÁLISIS ESTÁTICO: BAJADA DE CARGAS ===\n');
fprintf('Estructura: %d nodos, %d elementos\n', nNodos, nElem);
fprintf('Peso topside: %.2f kN (%.1f ton)\n', W_topside/1e3, W_topside/(g*1e3));
fprintf('Peso propio: %s\n', mat2str(incluir_peso_propio));

%% ========================================================================
%  2. ENSAMBLAJE DE MATRIZ DE RIGIDEZ GLOBAL (solo elementos intactos)
%  ========================================================================
fprintf('Ensamblando matriz de rigidez global...\n');

KG = zeros(IDmax, IDmax);

for i = 1:nElem
    % Geometría del elemento
    nodo_i = elements(i, 2);
    nodo_j = elements(i, 3);
    
    xi = nodes(nodo_i, 2:4)';  % [x, y, z]
    xj = nodes(nodo_j, 2:4)';
    
    % Longitud
    L_elem = norm(xj - xi);
    
    % Cosenos directores
    CX = (xj(1) - xi(1)) / L_elem;
    CY = (xj(2) - xi(2)) / L_elem;
    CZ = (xj(3) - xi(3)) / L_elem;
    CXY = sqrt(CX^2 + CY^2);
    
    % Matriz de rigidez local (elemento intacto)
    ke = localkeframe3D(A(i), Iy(i), Iz(i), J(i), E(i), G(i), L_elem);
    
    % Vector del plano xz local
    vxzl = vxz(i, 2:end)';
    [cosalpha, sinalpha] = ejelocal(CX, CY, CZ, CXY, vxzl);
    
    % Matriz de transformación 3D
    [Gamma_gamma, Gamma_beta] = TransfM3Dframe_sym(CX, CY, CZ, CXY, i, cosalpha, sinalpha);
    
    % Rigidez global del elemento
    kg = Gamma_gamma' * Gamma_beta' * ke * Gamma_beta * Gamma_gamma;
    
    % Asegurar simetría
    kg = (kg + kg') / 2;
    
    % Vector de localización (DOF del elemento en numeración global)
    LV = [ID(:, nodo_i); ID(:, nodo_j)];  % 12×1
    indxLV = find(LV > 0);  % Solo DOF libres
    
    % Ensamblaje
    KG(LV(indxLV), LV(indxLV)) = KG(LV(indxLV), LV(indxLV)) + kg(indxLV, indxLV);
end

fprintf('  Matriz K ensamblada: %d×%d (DOF libres)\n', IDmax, IDmax);
fprintf('  Condicionamiento: κ(K) = %.2e\n', cond(KG));

%% ========================================================================
%  3. CONSTRUCCIÓN DEL VECTOR DE CARGAS GLOBALES
%  ========================================================================
fprintf('Construyendo vector de cargas...\n');

F_global = zeros(IDmax, 1);

% -------------------------------------------------------------------------
% 3.1) PESO PROPIO DE ELEMENTOS (distribuido a nodos extremos)
% -------------------------------------------------------------------------
if incluir_peso_propio
    fprintf('  Agregando peso propio de elementos...\n');
    
    for i = 1:nElem
        % Peso del elemento [N]
        nodo_i = elements(i, 2);
        nodo_j = elements(i, 3);
        xi = nodes(nodo_i, 2:4)';
        xj = nodes(nodo_j, 2:4)';
        L_elem = norm(xj - xi);
        
        W_elem = rho_acero * A(i) * L_elem * g;  % [N]
        
        % Distribuir mitad a cada nodo (en dirección Z negativa)
        % DOF Z es el tercero: [Ux, Uy, Uz, Rx, Ry, Rz]
        DOF_z_i = ID(3, nodo_i);  % DOF global de Uz en nodo i
        DOF_z_j = ID(3, nodo_j);  % DOF global de Uz en nodo j
        
        if DOF_z_i > 0  % Nodo i no restringido en Z
            F_global(DOF_z_i) = F_global(DOF_z_i) - W_elem / 2;
        end
        if DOF_z_j > 0  % Nodo j no restringido en Z
            F_global(DOF_z_j) = F_global(DOF_z_j) - W_elem / 2;
        end
    end
    
    peso_propio_total = sum(rho_acero * A .* arrayfun(@(i) ...
        norm(nodes(elements(i,3),2:4) - nodes(elements(i,2),2:4)), (1:nElem)')) * g;
    fprintf('    Peso propio total: %.2f kN\n', peso_propio_total/1e3);
end

% -------------------------------------------------------------------------
% 3.2) PESO DE SUPERESTRUCTURA (TOPSIDE)
% -------------------------------------------------------------------------
fprintf('  Agregando peso topside (deck)...\n');

% CRITERIO: Aplicar W_topside SOLO en nodos de superestructura
% Identificamos nodos por conectividad con elementos de superestructura
% Elementos 121-136 son superestructura, 1-120 son subestructura

% Extraer nodos únicos de elementos de superestructura (121-136)
elemento_inicio_super = 121;
elemento_fin_super = nElem;  % 136 según config

nodos_superestructura_set = [];
for i = elemento_inicio_super:elemento_fin_super
    nodo_i = elements(i, 2);
    nodo_j = elements(i, 3);
    nodos_superestructura_set = [nodos_superestructura_set; nodo_i; nodo_j];
end
nodos_topside = unique(nodos_superestructura_set);
n_topside = length(nodos_topside);

if n_topside == 0
    error('No se encontraron nodos en la superestructura (elementos 121-136)');
end

% Distribuir peso uniformemente entre nodos de superestructura
W_por_nodo = -W_topside / n_topside;  % Negativo: hacia abajo

fprintf('    Nodos superestructura identificados: %d nodos\n', n_topside);
fprintf('    Carga por nodo: %.2f kN\n', abs(W_por_nodo)/1e3);

for i = 1:n_topside
    nodo_id = nodos_topside(i);
    DOF_z = ID(3, nodo_id);
    
    if DOF_z > 0  % No restringido
        F_global(DOF_z) = F_global(DOF_z) + W_por_nodo;
    else
        warning('Nodo %d del topside está restringido en Z (ignorado)', nodo_id);
    end
end

fprintf('    Peso topside: %.2f kN distribuido en %d nodos\n', ...
    W_topside/1e3, n_topside);
fprintf('    Carga por nodo: %.2f kN\n', abs(W_por_nodo)/1e3);

% Verificación de carga total
carga_total = sum(abs(F_global));
fprintf('  Carga total aplicada: %.2f kN\n', carga_total/1e3);

%% ========================================================================
%  4. SOLUCIÓN DEL SISTEMA ESTÁTICO
%  ========================================================================
fprintf('Resolviendo sistema estático K·U = F...\n');

% Resolver solo para DOF libres
U_static = KG \ F_global;

fprintf('  Solución obtenida\n');
fprintf('  Desplazamiento vertical máximo: %.4f m\n', max(abs(U_static)));

%% ========================================================================
%  5. EXTRACCIÓN DE FUERZAS AXIALES POR ELEMENTO
%  ========================================================================
fprintf('Extrayendo fuerzas axiales por elemento...\n');

N_axial = zeros(nElem, 1);
Pcr = zeros(nElem, 1);
rho = zeros(nElem, 1);

for i = 1:nElem
    % Geometría del elemento
    nodo_i = elements(i, 2);
    nodo_j = elements(i, 3);
    
    xi = nodes(nodo_i, 2:4)';
    xj = nodes(nodo_j, 2:4)';
    L_elem = norm(xj - xi);
    
    % Cosenos directores
    CX = (xj(1) - xi(1)) / L_elem;
    CY = (xj(2) - xi(2)) / L_elem;
    CZ = (xj(3) - xi(3)) / L_elem;
    CXY = sqrt(CX^2 + CY^2);
    
    % Vector de DOF globales del elemento
    LV = [ID(:, nodo_i); ID(:, nodo_j)];  % 12×1
    
    % Desplazamientos globales del elemento (incluyendo DOF restringidos=0)
    u_global = zeros(12, 1);
    for k = 1:12
        if LV(k) > 0
            u_global(k) = U_static(LV(k));
        else
            u_global(k) = 0;  % DOF restringido
        end
    end
    
    % Transformación a coordenadas locales
    vxzl = vxz(i, 2:end)';
    [cosalpha, sinalpha] = ejelocal(CX, CY, CZ, CXY, vxzl);
    [Gamma_gamma, Gamma_beta] = TransfM3Dframe_sym(CX, CY, CZ, CXY, i, cosalpha, sinalpha);
    
    u_local = Gamma_beta * Gamma_gamma * u_global;
    
    % Fuerza axial: N = E·A·Δu/L
    % u_local(1) = desplazamiento axial en nodo i
    % u_local(7) = desplazamiento axial en nodo j
    delta_u = u_local(7) - u_local(1);
    N_axial(i) = E(i) * A(i) * delta_u / L_elem;
    
    % Carga crítica de Euler: Pcr = π²·E·Imin / L²
    Imin = min(Iy(i), Iz(i));
    Pcr(i) = (pi^2 * E(i) * Imin) / (L_elem^2);
    
    % Ratio de carga crítica
    rho(i) = abs(N_axial(i)) / Pcr(i);
end

%% ========================================================================
%  6. ANÁLISIS Y DIAGNÓSTICO
%  ========================================================================
fprintf('\n--- RESULTADOS DEL ANÁLISIS ---\n');

% Estadísticas de fuerzas axiales
idx_tension = find(N_axial > 0);
idx_compresion = find(N_axial < 0);

fprintf('Elementos en tensión: %d (%.1f%%)\n', ...
    length(idx_tension), 100*length(idx_tension)/nElem);
fprintf('Elementos en compresión: %d (%.1f%%)\n', ...
    length(idx_compresion), 100*length(idx_compresion)/nElem);

if ~isempty(idx_compresion)
    fprintf('\nCompresión:\n');
    fprintf('  Mínima: %.2f kN\n', min(N_axial(idx_compresion))/1e3);
    fprintf('  Máxima: %.2f kN\n', max(N_axial(idx_compresion))/1e3);
    fprintf('  Media: %.2f kN\n', mean(N_axial(idx_compresion))/1e3);
end

if ~isempty(idx_tension)
    fprintf('\nTensión:\n');
    fprintf('  Mínima: %.2f kN\n', min(N_axial(idx_tension))/1e3);
    fprintf('  Máxima: %.2f kN\n', max(N_axial(idx_tension))/1e3);
    fprintf('  Media: %.2f kN\n', mean(N_axial(idx_tension))/1e3);
end

% Estadísticas de ratio de carga
[rho_max, idx_max] = max(rho);
fprintf('\nRatio de carga crítica (ρ = |N|/Pcr):\n');
fprintf('  Mínimo: %.4f\n', min(rho));
fprintf('  Máximo: %.4f (elemento %d)\n', rho_max, idx_max);
fprintf('  Media: %.4f\n', mean(rho));

% Elementos en rangos de ρ
rho_bajo = sum(rho < 0.2);
rho_medio = sum(rho >= 0.2 & rho < 0.5);
rho_alto = sum(rho >= 0.5 & rho < 0.75);
rho_critico = sum(rho >= 0.75);

fprintf('\nDistribución de elementos por ρ:\n');
fprintf('  ρ < 0.2 (bajo):       %d elementos\n', rho_bajo);
fprintf('  0.2 ≤ ρ < 0.5 (medio): %d elementos\n', rho_medio);
fprintf('  0.5 ≤ ρ < 0.75 (alto): %d elementos\n', rho_alto);
fprintf('  ρ ≥ 0.75 (crítico):    %d elementos\n', rho_critico);

% Advertencias
if rho_max > 0.85
    warning('Elemento %d tiene ρ=%.3f > 0.85 (cerca de pandeo)', idx_max, rho_max);
end

if rho_critico > 0
    warning('%d elementos con ρ≥0.75 (verificar diseño)', rho_critico);
end

%% ========================================================================
%  7. ESTRUCTURA DE DIAGNÓSTICO
%  ========================================================================
diagnostico = struct();
diagnostico.nodos_topside = nodos_topside;
diagnostico.F_total = F_global;
diagnostico.U_static = U_static;
diagnostico.elementos_tension = idx_tension;
diagnostico.elementos_compresion = idx_compresion;
diagnostico.rho_max = rho_max;
diagnostico.elem_mas_cargado = idx_max;
diagnostico.peso_propio_total = peso_propio_total;
diagnostico.peso_topside = W_topside;
diagnostico.carga_total = carga_total;

fprintf('\n=== ANÁLISIS COMPLETADO ===\n\n');

end  % function
