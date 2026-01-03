function [N_axial_etabs, diagnostico] = leer_fuerzas_etabs(csv_path, nElem)
% LEER_FUERZAS_ETABS - Extrae fuerzas axiales de archivo CSV exportado de ETABS
%
% PROPÓSITO:
%   Alternativa a análisis FEM interno. Permite usar fuerzas axiales 
%   calculadas por ETABS directamente, garantizando consistencia con 
%   el software de diseño comercial.
%
% SINTAXIS:
%   [N_axial_etabs, diagnostico] = leer_fuerzas_etabs(csv_path, nElem)
%
% ENTRADAS:
%   csv_path  - [string] Ruta al archivo CSV con formato ETABS:
%               Columnas: Element, P_kN (múltiples filas por elemento)
%               Ejemplo: "carga_axial_ETABS.csv"
%   nElem     - [escalar] Número esperado de elementos en el modelo
%
% SALIDAS:
%   N_axial_etabs - [nElem×1] Fuerza axial por elemento [N]
%                   Se toma el VALOR MÁXIMO en magnitud entre todas
%                   las combinaciones de carga del CSV
%                   Convención: Tensión (+), Compresión (-)
%   diagnostico   - Estructura con información del proceso:
%       .csv_path         - Ruta del archivo leído
%       .n_lineas_total   - Total de líneas en CSV
%       .n_combinaciones  - Número de combinaciones de carga por elemento
%       .elementos_leidos - IDs de elementos encontrados
%       .elementos_faltantes - IDs de elementos sin datos (si hay)
%       .N_min_kN         - Fuerza axial mínima leída [kN]
%       .N_max_kN         - Fuerza axial máxima leída [kN]
%       .criterio_seleccion - 'max_magnitud' (se usa |N| máximo)
%
% FORMATO CSV ESPERADO:
%   Element,P_kN,,,,
%   1,-8563.7385,,,,
%   1,-8365.9946,,,,   <- Múltiples valores por elemento
%   1,-8168.2508,,,,   <- (diferentes combinaciones de carga)
%   2,-1666.1707,,,,
%   2,-1560.9878,,,,
%   ...
%
% ALGORITMO:
%   1. Lee CSV con readtable (manejo robusto de formatos)
%   2. Agrupa por ID de elemento
%   3. Para cada elemento: selecciona |N| máximo (peor caso)
%   4. Valida que todos los elementos [1..nElem] tengan datos
%   5. Convierte kN → N
%
% EJEMPLO:
%   csv_file = fullfile('003_funcion_deformaciones', 'carga_axial_ETABS.csv');
%   [N_axial, diag] = leer_fuerzas_etabs(csv_file, 120);
%   fprintf('Leídos %d elementos, %d combinaciones c/u\n', ...
%       length(N_axial), diag.n_combinaciones);
%
% DECISIONES DE DISEÑO:
%   - Se usa |N| máximo (no promedio) para análisis conservador
%   - CSV puede tener múltiples combinaciones: DEAD, DEAD+LIVE, etc.
%   - Valores en kN (ETABS default) se convierten a N internamente
%   - Elementos sin datos generan warning (no error) para debugging
%
% NOTAS:
%   - CSV debe exportarse desde ETABS: Tables > Frame Forces
%   - Si elemento tiene solo 1 valor, ese se usa directamente
%   - Compatible con CSV de ETABS 2016+ (formato estándar)
%
% VER TAMBIÉN:
%   analisis_estatico_fuerzas_axiales, calcular_rho_y_Pcr
%
% AUTOR: Sistema de análisis estructural - Proyecto Doctoral
% FECHA: Enero 2026
% VERSIÓN: 1.0

%% ========================================================================
%  1. VALIDACIÓN DE ENTRADAS
%  ========================================================================
narginchk(2, 2);

if ~isfile(csv_path)
    error('leer_fuerzas_etabs:ArchivoNoExiste', ...
        'No se encontró el archivo CSV: %s', csv_path);
end

if ~isnumeric(nElem) || nElem < 1
    error('leer_fuerzas_etabs:nElemInvalido', ...
        'nElem debe ser un entero positivo, recibido: %s', num2str(nElem));
end

fprintf('\n--- LEYENDO FUERZAS AXIALES DE ETABS ---\n');
fprintf('Archivo: %s\n', csv_path);

%% ========================================================================
%  2. LECTURA DEL CSV
%  ========================================================================
try
    % readtable maneja automáticamente headers, valores vacíos, etc.
    data = readtable(csv_path, 'VariableNamingRule', 'preserve');
    
    % Extraer columnas relevantes (Element y P_kN)
    % Nota: CSV de ETABS tiene columnas extra vacías, readtable las ignora
    if ~ismember('Element', data.Properties.VariableNames)
        error('leer_fuerzas_etabs:ColumnaFaltante', ...
            'CSV no contiene columna "Element"');
    end
    if ~ismember('P_kN', data.Properties.VariableNames)
        error('leer_fuerzas_etabs:ColumnaFaltante', ...
            'CSV no contiene columna "P_kN"');
    end
    
    elem_ids = data.Element;
    P_kN = data.P_kN;
    
    fprintf('  ✓ CSV leído: %d filas totales\n', length(elem_ids));
    
catch ME
    error('leer_fuerzas_etabs:ErrorLectura', ...
        'Error al leer CSV: %s', ME.message);
end

%% ========================================================================
%  3. PROCESAMIENTO: SELECCIÓN DE VALOR MÁXIMO POR ELEMENTO
%  ========================================================================
% Inicializar vector de salida
N_axial_etabs = zeros(nElem, 1);
elementos_encontrados = false(nElem, 1);

% IDs únicos de elementos en el CSV
elem_ids_unicos = unique(elem_ids);
n_combinaciones = zeros(nElem, 1);

fprintf('  Elementos únicos en CSV: %d\n', length(elem_ids_unicos));
fprintf('  Criterio de selección: Máxima magnitud |N|\n');

for i = 1:length(elem_ids_unicos)
    elem_id = elem_ids_unicos(i);
    
    % Validar que el ID esté en rango [1..nElem]
    if elem_id < 1 || elem_id > nElem
        warning('leer_fuerzas_etabs:ElementoFueraDeRango', ...
            'Elemento %d está fuera del rango [1, %d], se ignora', elem_id, nElem);
        continue;
    end
    
    % Extraer todos los valores P_kN para este elemento
    mask = (elem_ids == elem_id);
    P_values = P_kN(mask);
    n_combinaciones(elem_id) = length(P_values);
    
    % Seleccionar el valor con MÁXIMA MAGNITUD (conservador)
    % |P| máximo captura el peor escenario de compresión o tensión
    [~, idx_max] = max(abs(P_values));
    N_axial_etabs(elem_id) = P_values(idx_max) * 1000;  % kN → N
    
    elementos_encontrados(elem_id) = true;
end

%% ========================================================================
%  4. VALIDACIÓN Y DIAGNÓSTICO
%  ========================================================================
elementos_faltantes = find(~elementos_encontrados);
n_faltantes = length(elementos_faltantes);

if n_faltantes > 0
    warning('leer_fuerzas_etabs:ElementosFaltantes', ...
        'Faltan datos para %d elementos: [%s]', ...
        n_faltantes, num2str(elementos_faltantes', '%d '));
    fprintf('  ⚠ Elementos sin datos: %d (se asigna N=0)\n', n_faltantes);
end

fprintf('  ✓ Fuerzas extraídas: %d elementos\n', sum(elementos_encontrados));
fprintf('  ✓ Combinaciones promedio por elemento: %.1f\n', ...
    mean(n_combinaciones(elementos_encontrados)));

%% ========================================================================
%  5. ESTADÍSTICAS DE LAS FUERZAS LEÍDAS
%  ========================================================================
N_kN = N_axial_etabs / 1000;
N_compresion = N_kN(N_kN < 0);
N_tension = N_kN(N_kN > 0);

fprintf('\n  ESTADÍSTICAS DE FUERZAS ETABS:\n');
fprintf('    Rango: [%.2f, %.2f] kN\n', min(N_kN), max(N_kN));
fprintf('    Elementos en compresión: %d (N < 0)\n', sum(N_kN < 0));
fprintf('    Elementos en tensión:    %d (N > 0)\n', sum(N_kN > 0));
if ~isempty(N_compresion)
    fprintf('    Compresión máxima: %.2f kN (elemento %d)\n', ...
        min(N_compresion), find(N_kN == min(N_compresion), 1));
end
if ~isempty(N_tension)
    fprintf('    Tensión máxima:    %.2f kN (elemento %d)\n', ...
        max(N_tension), find(N_kN == max(N_tension), 1));
end

%% ========================================================================
%  6. ESTRUCTURA DE DIAGNÓSTICO
%  ========================================================================
diagnostico.csv_path = csv_path;
diagnostico.n_lineas_total = length(elem_ids);
diagnostico.n_combinaciones = mean(n_combinaciones(elementos_encontrados));
diagnostico.elementos_leidos = elem_ids_unicos;
diagnostico.elementos_faltantes = elementos_faltantes;
diagnostico.N_min_kN = min(N_kN);
diagnostico.N_max_kN = max(N_kN);
diagnostico.criterio_seleccion = 'max_magnitud';
diagnostico.n_elementos_ok = sum(elementos_encontrados);
diagnostico.n_elementos_faltantes = n_faltantes;

fprintf('\n');

end
