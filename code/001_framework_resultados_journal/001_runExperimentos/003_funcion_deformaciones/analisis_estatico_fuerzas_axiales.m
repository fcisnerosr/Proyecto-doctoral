function [N_axial, rho, Pcr, diagnostico] = analisis_estatico_fuerzas_axiales(...
    nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio)
% ANALISIS_ESTATICO_FUERZAS_AXIALES - Calcula fuerzas axiales en elementos por bajada de cargas
%
% IMPORTANTE: Asegurar que localkeframe3D.m local se usa (no otras versiones)
current_dir = fileparts(mfilename('fullpath'));
addpath(current_dir, '-begin');

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
%   W_topside          - [escalar] Peso TOTAL de topside para referencia [N]
%                        NOTA: Este parámetro es informativo. Las cargas
%                        reales se calculan INTERNAMENTE diferenciadas por
%                        nivel según API RP 2A-WSD Section 3.2.3:
%                          • Production deck (Z=100m): 20 kN/m² × 277.9 m²
%                          • Utility deck (Z=109m): 10 kN/m² × 277.9 m²
%                          • Roof (Z=118m): 0 kN (peso propio en DEAD)
%                        (ejemplo: 8337000 N = 8.337 MN para ~850 ton)
%   incluir_peso_propio - [bool] true: incluye peso propio de elementos
%                                 false: solo cargas externas (topside únicamente)
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
%   W_topside = 8337000;  % [N] 8.337 MN (cargas diferenciadas internamente)
%   [N_axial, rho, Pcr, diag] = analisis_estatico_fuerzas_axiales(...
%       nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, true);
%   
%   % Elementos con compresión moderada-alta (buenos para deformación inicial)
%   idx_optimos = find(rho > 0.3 & rho < 0.7);
%   fprintf('Elementos óptimos para daño tipo 3: %d\n', length(idx_optimos));
%
%   % Verificar distribución de cargas topside
%   fprintf('Topside aplicado: %.2f MN\n', diag.topside.W_topside_total/1e6);
%   fprintf('Production deck: %.2f MN en %d nodos\n', ...
%       diag.topside.W_production_total/1e6, length(diag.topside.nodos_production));
%   fprintf('Utility deck: %.2f MN en %d nodos\n', ...
%       diag.topside.W_utility_total/1e6, length(diag.topside.nodos_utility));
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
%  1. VALIDACIÓN DE ENTRADAS Y CONVERSIÓN DE UNIDADES
%  ========================================================================
narginchk(12, 12);

nNodos = size(nodes, 1);
nElem = size(elements, 1);
IDmax = max(max(ID));

% CONVERSIÓN DE UNIDADES: Sistema N-mm
% El archivo Excel tiene:
%   - Coordenadas (nodes): metros [m]
%   - Áreas (A): milímetros cuadrados [mm²]
%   - Inercias (Iy, Iz, J): [mm⁴]
%   - E, G: Mega-Pascales [MPa] = [N/mm²]
%
% El código trabaja en sistema N-mm consistente:
%   - Longitudes: mm
%   - Fuerzas: N
%   - Áreas: mm²
%   - Inercias: mm⁴
%   - Tensiones: MPa = N/mm²
%
% SISTEMA N-mm: Sistema consistente de unidades
% El archivo Excel tiene todo en sistema N-mm:
%   - Coordenadas (nodes): milímetros [mm]
%   - Áreas (A): milímetros cuadrados [mm²]
%   - Inercias (Iy, Iz, J): [mm⁴]
%   - E, G: Mega-Pascales [MPa] = [N/mm²]
%
% El código trabaja en sistema N-mm consistente:
%   - Longitudes: mm
%   - Fuerzas: N
%   - Áreas: mm²
%   - Inercias: mm⁴
%   - Tensiones: MPa = N/mm²
%
% NO SE REQUIERE CONVERSIÓN DE UNIDADES
% Todos los datos ya están en el sistema correcto

% Densidad del acero y gravedad para cálculo de peso
rho_acero = 7850;  % kg/m³
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
    
    % DEBUG: Verificar unidades del primer elemento
    if i == 1
        fprintf('DEBUG Elemento 1:\n');
        fprintf('  Nodos: %d - %d\n', nodo_i, nodo_j);
        fprintf('  xi = [%.2f, %.2f, %.2f] mm\n', xi(1), xi(2), xi(3));
        fprintf('  xj = [%.2f, %.2f, %.2f] mm\n', xj(1), xj(2), xj(3));
        fprintf('  L = %.2f mm\n', L_elem);
        fprintf('  A = %.2f mm²\n', A(i));
        fprintf('  E = %.2f MPa\n', E(i));
        fprintf('  ke(1,1) = E*A/L = %.2f*%.2f/%.2f = %.6e N/mm\n', ...
            E(i), A(i), L_elem, E(i)*A(i)/L_elem);
    end
    
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
    % TransfM3Dframe_sym espera vectores, creamos temporales con índice 1
    CX_vec = CX; CY_vec = CY; CZ_vec = CZ; CXY_vec = CXY;
    [Gamma_gamma, Gamma_beta] = TransfM3Dframe_sym(CX_vec, CY_vec, CZ_vec, CXY_vec, 1);
    
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
        L_elem = norm(xj - xi);  % mm (tras conversión de coordenadas)
        
        % Sistema N-mm: A[mm²] × L[mm] × rho[kg/m³] × g[m/s²]
        % Volumen = A × L = mm³, convertir a m³: ÷1e9
        W_elem = rho_acero * (A(i) * L_elem / 1e9) * g;  % [N]
        
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
    
    peso_propio_total = sum(rho_acero * (A .* arrayfun(@(i) ...
        norm(nodes(elements(i,3),2:4) - nodes(elements(i,2),2:4)), (1:nElem)') / 1e9)) * g;
    fprintf('    Peso propio total: %.2f kN\n', peso_propio_total/1e3);
    fprintf('    DEBUG: F_global(1) = %.2e N (debe estar en N, no kN)\n', F_global(1));
else
    % Si no se incluye peso propio, calcularlo para referencia
    peso_propio_total = sum(rho_acero * (A .* arrayfun(@(i) ...
        norm(nodes(elements(i,3),2:4) - nodes(elements(i,2),2:4)), (1:nElem)') / 1e9)) * g;
end

% =========================================================================
% 3.2) PESO DE SUPERESTRUCTURA (TOPSIDE) - CARGAS DIFERENCIADAS POR NIVEL
% =========================================================================
fprintf('  Agregando cargas de topside (deck equipment + structure)...\n');

% -------------------------------------------------------------------------
% JUSTIFICACIÓN TÉCNICA Y NORMATIVA
% -------------------------------------------------------------------------
% Las cargas aplicadas están basadas en normativa internacional para
% plataformas offshore de producción sin datos específicos de equipos.
%
% REFERENCIAS:
% [1] API RP 2A-WSD (22nd Edition, 2014)
%     Section 3.2.3 - Deck Loads for Fixed Offshore Platforms
%     Tabla 3.2.3-1: Cargas típicas para áreas de proceso y utilidades
%
% [2] ISO 19902:2007 - Petroleum and natural gas industries
%     Section 8.2.2 - Permanent Actions (Dead Loads)
%     Para plataformas sin datos específicos: 15-25 kN/m² (producción)
%                                             8-12 kN/m² (utilidades)
%
% CRITERIO DE DISEÑO:
% Se adopta un enfoque conservador utilizando los valores medios de las
% recomendaciones API/ISO, diferenciando cargas según función del deck:
%   - Production Deck (equipos de proceso): 20 kN/m²
%   - Utility Deck (servicios/control): 10 kN/m²
%   - Roof Structure: Solo peso propio (ya considerado en DEAD)
%
% -------------------------------------------------------------------------
% GEOMETRÍA DE LA SUPERESTRUCTURA (SEGÚN ETABS)
% -------------------------------------------------------------------------
% Configuración: 2 niveles de deck + 1 techo estructural
%   Nivel 1 (Z = 100 m): Production deck - Nodos 41-44
%   Nivel 2 (Z = 109 m): Utility deck    - Nodos 45-48
%   Nivel 3 (Z = 118 m): Roof structure  - Nodos 49-52 (sin carga adicional)
%
% Dimensiones en planta: 16.667 m × 16.667 m (según Joint Coordinates ETABS)
% Área efectiva: A_deck = 16.667² = 277.9 m²
% Altura entre niveles: 9 m
%
% -------------------------------------------------------------------------
% CÁLCULO DE CARGAS POR NIVEL
% -------------------------------------------------------------------------

% Parámetros geométricos
L_deck = 16.667;  % [m] Longitud lado del deck (cuadrado)
A_deck = L_deck^2;  % [m²] Área efectiva del deck

% Cargas por área según API RP 2A-WSD (Section 3.2.3)
q_production = 20e3;  % [N/m²] Production deck (20 kN/m²)
q_utility = 10e3;     % [N/m²] Utility deck (10 kN/m²)

% Carga total por nivel
W_production = q_production * A_deck;  % [N] = 5,558,000 N = 5.558 MN
W_utility = q_utility * A_deck;        % [N] = 2,779,000 N = 2.779 MN

% Distribución nodal (4 nodos por nivel, distribución uniforme)
n_nodos_por_nivel = 4;
W_production_por_nodo = -W_production / n_nodos_por_nivel;  % [N] -1389.5 kN/nodo
W_utility_por_nodo = -W_utility / n_nodos_por_nivel;        % [N] -694.75 kN/nodo

% Signo negativo: cargas hacia abajo (dirección -Z)

% -------------------------------------------------------------------------
% IDENTIFICACIÓN DE NODOS POR NIVEL (SEGÚN COORDENADAS Z)
% -------------------------------------------------------------------------

% Tolerancia para comparación de coordenadas Z [mm]
tol_z = 100;  % 100 mm = 0.1 m

% Extraer coordenadas Z de todos los nodos [mm]
z_coords = nodes(:, 4);

% Nivel 1: Production Deck (Z ≈ 100,000 mm = 100 m)
z_production = 100000;  % [mm]
nodos_production = find(abs(z_coords - z_production) < tol_z);

% Nivel 2: Utility Deck (Z ≈ 109,000 mm = 109 m)
z_utility = 109000;  % [mm]
nodos_utility = find(abs(z_coords - z_utility) < tol_z);

% Nivel 3: Roof (Z ≈ 118,000 mm = 118 m) - SIN CARGA ADICIONAL
z_roof = 118000;  % [mm]
nodos_roof = find(abs(z_coords - z_roof) < tol_z);

% Validación de nodos identificados
if isempty(nodos_production)
    error('No se encontraron nodos en nivel production (Z=100m)');
end
if isempty(nodos_utility)
    error('No se encontraron nodos en nivel utility (Z=109m)');
end

fprintf('\n  ┌─ DISTRIBUCIÓN DE CARGAS TOPSIDE ─────────────────────────┐\n');
fprintf('  │                                                          │\n');
fprintf('  │ NIVEL 1 - PRODUCTION DECK (Z = 100 m):                  │\n');
fprintf('  │   Carga área: %.1f kN/m² (API RP 2A Table 3.2.3-1)      │\n', q_production/1e3);
fprintf('  │   Área: %.1f m²                                          │\n', A_deck);
fprintf('  │   Carga total: %.2f MN                                  │\n', W_production/1e6);
fprintf('  │   Nodos: %d (IDs: %s)                                   │\n', ...
    length(nodos_production), mat2str(nodos_production'));
fprintf('  │   Carga/nodo: %.2f kN                                   │\n', abs(W_production_por_nodo)/1e3);
fprintf('  │                                                          │\n');
fprintf('  │ NIVEL 2 - UTILITY DECK (Z = 109 m):                     │\n');
fprintf('  │   Carga área: %.1f kN/m² (API RP 2A Utility areas)      │\n', q_utility/1e3);
fprintf('  │   Área: %.1f m²                                          │\n', A_deck);
fprintf('  │   Carga total: %.2f MN                                  │\n', W_utility/1e6);
fprintf('  │   Nodos: %d (IDs: %s)                                   │\n', ...
    length(nodos_utility), mat2str(nodos_utility'));
fprintf('  │   Carga/nodo: %.2f kN                                   │\n', abs(W_utility_por_nodo)/1e3);
fprintf('  │                                                          │\n');
fprintf('  │ NIVEL 3 - ROOF STRUCTURE (Z = 118 m):                   │\n');
fprintf('  │   Carga: 0.00 kN (peso propio en DEAD)                  │\n');
fprintf('  │   Nodos: %d (IDs: %s)                                   │\n', ...
    length(nodos_roof), mat2str(nodos_roof'));
fprintf('  │                                                          │\n');
fprintf('  │ TOTAL TOPSIDE: %.2f MN                                  │\n', (W_production + W_utility)/1e6);
fprintf('  │ VALIDACIÓN: Reacción ETABS = 33.16 MN (DEAD)            │\n');
fprintf('  │             Esperado = %.2f MN (DEAD+Topside)           │\n', ...
    (peso_propio_total + W_production + W_utility)/1e6);
fprintf('  └──────────────────────────────────────────────────────────┘\n\n');

% -------------------------------------------------------------------------
% APLICACIÓN DE CARGAS EN VECTOR GLOBAL F
% -------------------------------------------------------------------------

% Nivel 1: Production Deck
for i = 1:length(nodos_production)
    nodo_id = nodos_production(i);
    DOF_z = ID(3, nodo_id);  % DOF vertical (Uz)
    
    if DOF_z > 0  % Nodo no restringido en Z
        F_global(DOF_z) = F_global(DOF_z) + W_production_por_nodo;
    else
        warning('Nodo %d (production deck) restringido en Z - carga ignorada', nodo_id);
    end
end

% Nivel 2: Utility Deck
for i = 1:length(nodos_utility)
    nodo_id = nodos_utility(i);
    DOF_z = ID(3, nodo_id);  % DOF vertical (Uz)
    
    if DOF_z > 0  % Nodo no restringido en Z
        F_global(DOF_z) = F_global(DOF_z) + W_utility_por_nodo;
    else
        warning('Nodo %d (utility deck) restringido en Z - carga ignorada', nodo_id);
    end
end

% Nivel 3: Roof - NO SE APLICA CARGA ADICIONAL
% El peso propio de la estructura del techo ya está incluido en el análisis
% de peso propio (Section 3.1)

% Número total de nodos topside y lista completa
n_topside = length(nodos_production) + length(nodos_utility);
nodos_topside = [nodos_production; nodos_utility];

% Guardar información de topside para diagnóstico
diagnostico.topside = struct(...
    'W_production_total', W_production, ...
    'W_utility_total', W_utility, ...
    'W_topside_total', W_production + W_utility, ...
    'nodos_production', nodos_production, ...
    'nodos_utility', nodos_utility, ...
    'nodos_roof', nodos_roof, ...
    'q_production_kPa', q_production/1e3, ...
    'q_utility_kPa', q_utility/1e3, ...
    'area_deck_m2', A_deck, ...
    'referencia_normativa', 'API RP 2A-WSD (22nd Ed.) Section 3.2.3, ISO 19902:2007 Section 8.2.2');

% Carga promedio por nodo (topside)
W_topside_aplicado = W_production + W_utility;
W_por_nodo_promedio = W_topside_aplicado / n_topside;

fprintf('    Peso topside: %.2f kN distribuido en %d nodos\n', ...
    W_topside_aplicado/1e3, n_topside);
fprintf('    Carga promedio/nodo: %.2f kN\n', abs(W_por_nodo_promedio)/1e3);

% Verificación de carga total
carga_total = sum(abs(F_global));
fprintf('  Carga total aplicada: %.2f kN\n', carga_total/1e3);

% DEBUG: Verificar magnitudes
DOF_nodo41_z = ID(3, 41);  % DOF vertical del nodo 41 (production deck)
if DOF_nodo41_z > 0
    fprintf('  DEBUG: F_global(%d) [nodo 41, Uz] = %.2e N (esperado ~-1.39e6 N)\n', ...
        DOF_nodo41_z, F_global(DOF_nodo41_z));
end

%% ========================================================================
%  4. SOLUCIÓN DEL SISTEMA ESTÁTICO
%  ========================================================================
fprintf('Resolviendo sistema estático K·U = F...\n');

% Resolver solo para DOF libres
U_static = KG \ F_global;

fprintf('  Solución obtenida\n');
fprintf('  Desplazamiento vertical máximo: %.4f mm (%.2f cm)\n', ...
    max(abs(U_static)), max(abs(U_static))/10);
fprintf('  DEBUG: Sistema N-mm → U en mm ✓\n');

%% ========================================================================
%  5. EXTRACCIÓN DE FUERZAS AXIALES POR ELEMENTO
%  ========================================================================
fprintf('Extrayendo fuerzas axiales por elemento...\n');

N_axial = zeros(nElem, 1);
% SOLO PARA COMPARACIÓN CON ETABS: Se comentan Pcr y rho
% Pcr = zeros(nElem, 1);
% rho = zeros(nElem, 1);

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
    
    % TransfM3Dframe_sym espera vectores, creamos temporales con índice 1
    CX_vec = CX; CY_vec = CY; CZ_vec = CZ; CXY_vec = CXY;
    [Gamma_gamma, Gamma_beta] = TransfM3Dframe_sym(CX_vec, CY_vec, CZ_vec, CXY_vec, 1);
    
    u_local = Gamma_beta * Gamma_gamma * u_global;
    
    % Fuerza axial: N = E·A·Δu/L
    % u_local(1) = desplazamiento axial en nodo i
    % u_local(7) = desplazamiento axial en nodo j
    % CONVENCIÓN: Tensión (+), Compresión (-)
    % Acortamiento: u(j) < u(i) → delta_u < 0 → N < 0 (compresión)
    delta_u = u_local(7) - u_local(1);
    N_axial(i) = E(i) * A(i) * delta_u / L_elem;
    
    % DEBUG: Verificar signo y magnitud
    if i == 1
        fprintf('DEBUG N_axial: Elem 1 = %.2f kN, delta_u = %.4e mm\n', ...
            N_axial(i)/1000, delta_u);
    end
    
    % Carga crítica de Euler: Pcr = π²·E·Imin / L²
    % Sistema N-mm: E[MPa], Imin[mm⁴], L[mm]
    Imin = min(Iy(i), Iz(i));  % [mm⁴]
    Pcr(i) = (pi^2 * E(i) * Imin) / (L_elem^2);  % [N]
    
    % Ratio de carga crítica (adimensional)
    if Pcr(i) > 0
        rho(i) = abs(N_axial(i)) / Pcr(i);
    else
        rho(i) = 0;
    end
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

% Estadísticas de ratio de carga crítica
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
%  7. ESTRUCTURA DE DIAGNÓSTICO Y GUARDADO
%  ========================================================================
diagnostico = struct();
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
