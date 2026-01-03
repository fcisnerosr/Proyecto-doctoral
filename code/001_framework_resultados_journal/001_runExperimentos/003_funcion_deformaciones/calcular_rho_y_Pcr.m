function [rho, Pcr, diagnostico] = calcular_rho_y_Pcr(N_axial, elements, nodes, Iy, Iz, E)
% CALCULAR_RHO_Y_PCR - Calcula carga crítica de Euler y ratio de carga
%
% PROPÓSITO:
%   Función reutilizable para calcular Pcr (pandeo de Euler) y ρ (ratio
%   de carga crítica) dados las fuerzas axiales y geometría del modelo.
%   Permite usar N_axial de cualquier fuente (FEM interno, ETABS, etc.)
%
% SINTAXIS:
%   [rho, Pcr, diagnostico] = calcular_rho_y_Pcr(N_axial, elements, nodes, Iy, Iz, E)
%
% ENTRADAS:
%   N_axial  - [nElem×1] Fuerzas axiales [N]
%              Convención: Tensión (+), Compresión (-)
%   elements - [nElem×3] Conectividad: [ID, nodo_i, nodo_j]
%   nodes    - [nNodos×4] Coordenadas: [ID, x, y, z] [mm]
%   Iy, Iz   - [nElem×1] Momentos de inercia principales [mm⁴]
%   E        - [nElem×1] Módulo de elasticidad [MPa] = [N/mm²]
%
% SALIDAS:
%   rho        - [nElem×1] Ratio de carga crítica ρ = |N|/Pcr [-]
%                Rango típico: [0, 0.85] (límite de seguridad)
%                ρ > 1 indica INESTABILIDAD (carga excede pandeo)
%   Pcr        - [nElem×1] Carga crítica de pandeo [N]
%                Pcr = π²·E·Imin / L²  (Euler clásico)
%   diagnostico - Estructura con estadísticas:
%       .rho_max            - Máximo ratio (elemento más cargado)
%       .rho_promedio       - Promedio de ρ en todos los elementos
%       .elem_mas_cargado   - ID del elemento con mayor ρ
%       .n_compresion       - Elementos en compresión (N < 0)
%       .n_tension          - Elementos en tensión (N > 0)
%       .rho_distribucion   - Histograma de rangos de ρ
%       .elementos_criticos - IDs con ρ > 0.85 (alerta)
%
% FÓRMULA DE EULER (COLUMNA IDEAL):
%   Pcr = π² · E · Imin / L²
%   
%   Donde:
%     E    = Módulo de elasticidad [N/mm²]
%     Imin = min(Iy, Iz) [mm⁴] (pandea en eje más débil)
%     L    = Longitud del elemento [mm]
%
% RATIO DE CARGA CRÍTICA:
%   ρ = |N_axial| / Pcr
%   
%   Interpretación:
%     ρ < 0.3   → Subcargado (baja detectabilidad deformación inicial)
%     0.3 ≤ ρ < 0.7 → Rango óptimo (alta detectabilidad)
%     0.7 ≤ ρ < 0.85 → Altamente cargado (precaución)
%     ρ ≥ 0.85  → CRÍTICO (riesgo de pandeo, límite de seguridad)
%     ρ ≥ 1.0   → INESTABLE (carga excede capacidad teórica)
%
% EJEMPLO:
%   % Calcular ρ con fuerzas de ETABS
%   [N_etabs, ~] = leer_fuerzas_etabs('carga_axial_ETABS.csv', 120);
%   [rho, Pcr, diag] = calcular_rho_y_Pcr(N_etabs, elements, nodes, Iy, Iz, E);
%   fprintf('ρ máximo: %.4f (elemento %d)\n', diag.rho_max, diag.elem_mas_cargado);
%
% DECISIONES DE DISEÑO:
%   - Usa fórmula clásica de Euler (columna biarticulada)
%   - No considera: longitud efectiva (K), imperfecciones, pandeo local
%   - Imin = min(Iy, Iz): pandea en dirección de menor rigidez
%   - ρ calculado con |N| (valor absoluto): compresión y tensión
%   - Sistema N-mm consistente (no conversiones internas)
%
% SUPUESTOS Y LIMITACIONES:
%   1. Elementos prismáticos (sección constante)
%   2. Material elástico lineal (no plasticidad)
%   3. Sin cargas transversales (solo axial)
%   4. Conexiones ideales (biarticuladas)
%   5. Teoría de columnas esbeltas (L/r > 100 típicamente)
%
% NOTAS:
%   - Para estructuras offshore robustas: ρ típico 0.005-0.02 (muy bajo)
%   - Para edificios: ρ típico 0.2-0.6 (rango estándar)
%   - Para puentes: ρ típico 0.1-0.4 (moderado)
%
% REFERENCIAS:
%   - Euler, L. (1744): "De curvis elasticis"
%   - Timoshenko & Gere (1961): "Theory of Elastic Stability"
%   - AISC 360-16: "Specification for Structural Steel Buildings"
%   - API RP 2A-WSD: "Planning, Designing and Constructing Fixed Offshore Platforms"
%
% VER TAMBIÉN:
%   analisis_estatico_fuerzas_axiales, leer_fuerzas_etabs
%
% AUTOR: Sistema de análisis estructural - Proyecto Doctoral
% FECHA: Enero 2026
% VERSIÓN: 1.0

%% ========================================================================
%  1. VALIDACIÓN DE ENTRADAS
%  ========================================================================
narginchk(6, 6);

nElem = length(N_axial);

% Validar dimensiones consistentes
if size(elements, 1) ~= nElem
    error('calcular_rho_y_Pcr:DimensionInconsistente', ...
        'elements debe tener %d filas, tiene %d', nElem, size(elements, 1));
end

if length(Iy) ~= nElem || length(Iz) ~= nElem || length(E) ~= nElem
    error('calcular_rho_y_Pcr:DimensionInconsistente', ...
        'Iy, Iz, E deben tener longitud %d', nElem);
end

fprintf('\n--- CALCULANDO CARGA CRÍTICA Y RATIO ρ ---\n');
fprintf('Número de elementos: %d\n', nElem);

%% ========================================================================
%  2. CÁLCULO DE Pcr Y ρ PARA CADA ELEMENTO
%  ========================================================================
Pcr = zeros(nElem, 1);
rho = zeros(nElem, 1);

for i = 1:nElem
    % Nodos del elemento
    node_i = elements(i, 2);
    node_j = elements(i, 3);
    
    % Coordenadas (ya en mm)
    idx_i = find(nodes(:, 1) == node_i, 1);
    idx_j = find(nodes(:, 1) == node_j, 1);
    
    if isempty(idx_i) || isempty(idx_j)
        warning('calcular_rho_y_Pcr:NodoNoEncontrado', ...
            'Elemento %d: nodo %d o %d no encontrado', i, node_i, node_j);
        continue;
    end
    
    xi = nodes(idx_i, 2:4);
    xj = nodes(idx_j, 2:4);
    
    % Longitud del elemento [mm]
    L_elem = norm(xj - xi);
    
    if L_elem == 0
        warning('calcular_rho_y_Pcr:LongitudCero', ...
            'Elemento %d tiene longitud cero', i);
        continue;
    end
    
    % Momento de inercia mínimo (pandeo en eje más débil)
    Imin = min(Iy(i), Iz(i));  % [mm⁴]
    
    if Imin <= 0
        warning('calcular_rho_y_Pcr:InerciaNegativa', ...
            'Elemento %d: Imin ≤ 0, se omite', i);
        continue;
    end
    
    % Carga crítica de Euler: Pcr = π²·E·Imin / L²
    % E [MPa] = [N/mm²], Imin [mm⁴], L [mm] → Pcr [N]
    Pcr(i) = (pi^2 * E(i) * Imin) / (L_elem^2);  % [N]
    
    % Ratio de carga crítica: ρ = |N| / Pcr
    if Pcr(i) > 0
        rho(i) = abs(N_axial(i)) / Pcr(i);
    else
        rho(i) = 0;
    end
end

%% ========================================================================
%  3. ESTADÍSTICAS Y DIAGNÓSTICO
%  ========================================================================
% Elementos válidos (con Pcr > 0)
validos = Pcr > 0;
n_validos = sum(validos);

if n_validos == 0
    error('calcular_rho_y_Pcr:SinElementosValidos', ...
        'No se pudo calcular Pcr para ningún elemento');
end

fprintf('  ✓ Elementos válidos: %d/%d\n', n_validos, nElem);

% Estadísticas de ρ
rho_validos = rho(validos);
[rho_max, idx_max] = max(rho_validos);
idx_global = find(validos);
elem_mas_cargado = idx_global(idx_max);

fprintf('\n  ESTADÍSTICAS DE ρ:\n');
fprintf('    ρ mínimo:   %.6f\n', min(rho_validos));
fprintf('    ρ máximo:   %.6f (elemento %d)\n', rho_max, elem_mas_cargado);
fprintf('    ρ promedio: %.6f\n', mean(rho_validos));
fprintf('    ρ mediana:  %.6f\n', median(rho_validos));

% Distribución por rangos
fprintf('\n  DISTRIBUCIÓN POR RANGOS:\n');
fprintf('    ρ < 0.01:        %3d elementos (%.1f%%) - Muy subcargados\n', ...
    sum(rho < 0.01), 100*sum(rho < 0.01)/n_validos);
fprintf('    0.01 ≤ ρ < 0.10: %3d elementos (%.1f%%) - Subcargados\n', ...
    sum(rho >= 0.01 & rho < 0.10), 100*sum(rho >= 0.01 & rho < 0.10)/n_validos);
fprintf('    0.10 ≤ ρ < 0.30: %3d elementos (%.1f%%) - Carga baja\n', ...
    sum(rho >= 0.10 & rho < 0.30), 100*sum(rho >= 0.10 & rho < 0.30)/n_validos);
fprintf('    0.30 ≤ ρ < 0.70: %3d elementos (%.1f%%) - Rango óptimo\n', ...
    sum(rho >= 0.30 & rho < 0.70), 100*sum(rho >= 0.30 & rho < 0.70)/n_validos);
fprintf('    0.70 ≤ ρ < 0.85: %3d elementos (%.1f%%) - Alta carga\n', ...
    sum(rho >= 0.70 & rho < 0.85), 100*sum(rho >= 0.70 & rho < 0.85)/n_validos);
fprintf('    ρ ≥ 0.85:        %3d elementos (%.1f%%) - ⚠ CRÍTICO\n', ...
    sum(rho >= 0.85), 100*sum(rho >= 0.85)/n_validos);

% Elementos críticos (ρ > 0.85)
elementos_criticos = find(rho >= 0.85);
if ~isempty(elementos_criticos)
    fprintf('\n  ⚠ ALERTA: %d elementos con ρ ≥ 0.85:\n', length(elementos_criticos));
    for k = 1:min(10, length(elementos_criticos))  % Mostrar máximo 10
        elem_id = elementos_criticos(k);
        fprintf('    Elem %d: ρ = %.4f, N = %.2f kN, Pcr = %.2f kN\n', ...
            elem_id, rho(elem_id), N_axial(elem_id)/1000, Pcr(elem_id)/1000);
    end
    if length(elementos_criticos) > 10
        fprintf('    ... y %d más\n', length(elementos_criticos) - 10);
    end
end

% Separar compresión y tensión
n_compresion = sum(N_axial < 0);
n_tension = sum(N_axial > 0);
fprintf('\n  DISTRIBUCIÓN POR TIPO DE CARGA:\n');
fprintf('    Compresión: %3d elementos (%.1f%%)\n', ...
    n_compresion, 100*n_compresion/nElem);
fprintf('    Tensión:    %3d elementos (%.1f%%)\n', ...
    n_tension, 100*n_tension/nElem);

%% ========================================================================
%  4. ESTRUCTURA DE DIAGNÓSTICO
%  ========================================================================
diagnostico.rho_max = rho_max;
diagnostico.rho_promedio = mean(rho_validos);
diagnostico.rho_mediana = median(rho_validos);
diagnostico.elem_mas_cargado = elem_mas_cargado;
diagnostico.n_compresion = n_compresion;
diagnostico.n_tension = n_tension;
diagnostico.n_elementos_validos = n_validos;

% Distribución detallada
diagnostico.rho_distribucion.muy_bajo = sum(rho < 0.01);
diagnostico.rho_distribucion.bajo = sum(rho >= 0.01 & rho < 0.10);
diagnostico.rho_distribucion.moderado_bajo = sum(rho >= 0.10 & rho < 0.30);
diagnostico.rho_distribucion.optimo = sum(rho >= 0.30 & rho < 0.70);
diagnostico.rho_distribucion.alto = sum(rho >= 0.70 & rho < 0.85);
diagnostico.rho_distribucion.critico = sum(rho >= 0.85);

diagnostico.elementos_criticos = elementos_criticos;

fprintf('\n');

end
