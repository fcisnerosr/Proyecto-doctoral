% main_launcher.m
% Punto de entrada para el flujo de corridas del AG de detección de daño
% Realiza pre-cálculos estáticos una sola vez y luego lanza el launcher para las corridas variables

% --- PATH del proyecto ---
setupProjectPath(fileparts(mfilename('fullpath')));        % o:
% setupProjectPath(fileparts(mfilename('fullpath')), [], true);  % limpia path antes

% Apaga todos los warnings
oldState = warning;
warning('off', 'all');
clc; clear; close all;
% -------------------------------------------------------------------------
% 1) Carga configuración de parámetros generales
% -------------------------------------------------------------------------
config = config();  % Estructura con campos: tipo, rangoElem, porcentajes

% -------------------------------------------------------------------------
% 2) Obtención de rutas y archivos (una sola vez)
% -------------------------------------------------------------------------
config.pathfile     = obtenerRutaMarco3Ddam0();             % Ruta al Excel marco3Ddam0.xlsx
config.carpeta      = 'revision_6_jacket-subestructura_4NIVELES';
config.archivo      = 'datos_revision_5_jacket-subestructura_5NIVELES';
config.archivo_excel = construirRutaExcel(config.carpeta, config.archivo);  % Ruta al Excel de modelo ETABS

% -------------------------------------------------------------------------
% 3) Preparación de carpeta de resultados (con subcarpeta por tipo de daño)
% -------------------------------------------------------------------------
% 3.1) Cargar configuración para obtener tipo_dano
config_temp = config_deformacion_inicial();  % o config() según tu configuración activa

% 3.2) Crear subcarpeta con formato: tipo_dano_YYYY-MM-DD_HH-MM-SS
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
subfolder_name = sprintf('%s_%s', config_temp.tipo_dano, timestamp);

% 3.3) Ruta base de Resultados
outputFolder_base = obtenerOutputFolder();  % Proyecto-doctoral/Resultados
if ~exist(outputFolder_base,'dir')
    mkdir(outputFolder_base);
end

% 3.4) Crear subcarpeta específica para esta corrida
config.outputFolder = fullfile(outputFolder_base, subfolder_name);
if ~exist(config.outputFolder,'dir')
    mkdir(config.outputFolder);
end

fprintf('\n=== CARPETA DE RESULTADOS ===\n');
fprintf('Tipo de daño: %s\n', config_temp.tipo_dano);
fprintf('Carpeta: %s\n\n', config.outputFolder);

% 3.5) FUSIONAR configuraciones: rutas + parámetros del AG
% config      = rutas (pathfile, archivo_excel, outputFolder)
% config_temp = parámetros (tipo_dano, rangoElem, porcentajes, filtros, etc.)
% Se combinan para tener UNA config completa
fields_temp = fieldnames(config_temp);
for i = 1:length(fields_temp)
    config.(fields_temp{i}) = config_temp.(fields_temp{i});
end

fprintf('=== CONFIGURACIÓN CONSOLIDADA ===\n');
fprintf('Tipo de daño: %s\n', config.tipo_dano);
fprintf('Fuente de fuerzas axiales: %s\n', config.fuente_fuerzas_axiales);
fprintf('Filtrar por ρ: %s\n', mat2str(config.filtrar_elementos_por_rho));
if config.filtrar_elementos_por_rho
    fprintf('  Rango ρ: [%.3f, %.3f]\n', config.rho_min, config.rho_max);
end
fprintf('\n');

% -------------------------------------------------------------------------
% 4) PRE-CÁLCULOS ESTÁTICOS (solo una vez)
% -------------------------------------------------------------------------

% 4.1) Lectura de datos del modelo 3D sin daño desde ETABS
[coordenadas, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones, VXZ] = ...
    lectura_datos_modelo_ETABS(config.archivo_excel);

% 4.2) Lectura de nodos, elementos, propiedades e identificadores desde marco3Ddam0.xlsx
[NE, IDmax, NEn, elements, nodes, damele, eledent, ...
 A, Iy, Iz, J, E, G, vxz, ID, ~, ~] = lectura_hoja_excel(config.pathfile);

% 4.3) Modificación de la matriz de masas estática
[masas_en_cada_nodo, M_cond, M_completa] = ...
    modificacion_matriz_masas_estructura_sencilla(config.archivo_excel);

% 4.4) ANÁLISIS ESTÁTICO: Cálculo de fuerzas axiales para daño tipo 3
fprintf('Calculando fuerzas axiales estáticas (bajada de cargas)...\n');

% Número de elementos del modelo
nElem = NE;

% -------------------------------------------------------------------------
% CARGAS DE TOPSIDE (DECK EQUIPMENT + STRUCTURE)
% -------------------------------------------------------------------------
% Basado en API RP 2A-WSD (22nd Ed.) Section 3.2.3 e ISO 19902:2007
%
% GEOMETRÍA:
%   - Área deck: 16.667m × 16.667m = 277.9 m²
%   - Nivel 1 (Z=100m): Production deck → 20 kN/m² × 277.9 m² = 5.558 MN
%   - Nivel 2 (Z=109m): Utility deck    → 10 kN/m² × 277.9 m² = 2.779 MN
%   - Nivel 3 (Z=118m): Roof structure  → 0 MN (peso propio en DEAD)
%
% TOTAL TOPSIDE: 8.337 MN (~850 ton)
%
% VALIDACIÓN:
%   - Reacción ETABS (DEAD): 33.16 MN
%   - Esperado (DEAD + Topside): 41.50 MN → 10.375 MN/pierna ✓
%
% NOTA: W_topside es solo un parámetro nominal. Las cargas reales se
%       aplican diferenciadas por nivel dentro de analisis_estatico_fuerzas_axiales.m
% -------------------------------------------------------------------------
W_topside = 8337000;  % [N] = 8.337 MN (~850 ton) TOTAL (2 niveles)
incluir_peso_propio = true;

% -------------------------------------------------------------------------
% 4.4) CÁLCULO DE FUERZAS AXIALES: CÓDIGO vs ETABS (según configuración)
% -------------------------------------------------------------------------
% DECISIÓN DE ARQUITECTURA:
%   Se permite elegir entre dos fuentes de fuerzas axiales:
%   1. 'codigo': Análisis FEM interno (autosuficiente)
%   2. 'etabs':  Lectura de CSV exportado (consistencia con diseño)
%
% La configuración está en config.fuente_fuerzas_axiales (línea 21-35)
%
% JUSTIFICACIÓN:
%   - Código FEM: ρ_max ≈ 0.008 (0.8% de carga crítica)
%   - ETABS:      ρ_max ≈ 0.012 (1.2%, +50% detectabilidad)
%   
%   Para deformación inicial, mayor ρ → mayor sensibilidad modal
%   Por tanto, se recomienda usar fuerzas ETABS para mejor detectabilidad
% -------------------------------------------------------------------------

switch config.fuente_fuerzas_axiales
    case 'codigo'
        fprintf('\n=== FUENTE DE FUERZAS AXIALES: CÓDIGO (FEM INTERNO) ===\n');
        [N_axial_global, rho_global, Pcr_global, diagnostico_estatico] = ...
            analisis_estatico_fuerzas_axiales(...
                nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio);
        
    case 'etabs'
        fprintf('\n=== FUENTE DE FUERZAS AXIALES: ETABS (CSV EXTERNO) ===\n');
        
        % Leer fuerzas axiales de ETABS (toma |N| máximo de combinaciones)
        [N_axial_global, diag_etabs] = leer_fuerzas_etabs(...
            config.csv_fuerzas_etabs, nElem);
        
        % Calcular Pcr y ρ con geometría del modelo
        [rho_global, Pcr_global, diag_rho] = calcular_rho_y_Pcr(...
            N_axial_global, elements, nodes, Iy, Iz, E);
        
        % Consolidar diagnóstico
        diagnostico_estatico.fuente = 'etabs';
        diagnostico_estatico.csv_path = diag_etabs.csv_path;
        diagnostico_estatico.rho_max = diag_rho.rho_max;
        diagnostico_estatico.elem_mas_cargado = diag_rho.elem_mas_cargado;
        diagnostico_estatico.n_compresion = diag_rho.n_compresion;
        diagnostico_estatico.n_tension = diag_rho.n_tension;
        
    otherwise
        error('main_launcher:FuenteInvalida', ...
            'config.fuente_fuerzas_axiales debe ser ''codigo'' o ''etabs'', recibido: %s', ...
            config.fuente_fuerzas_axiales);
end

fprintf('  ✓ Fuerzas axiales obtenidas para %d elementos\n', length(N_axial_global));
fprintf('  ✓ Elementos con ρ∈[0.3,0.7]: %d (óptimos para deformación inicial)\n', ...
    sum(rho_global >= 0.3 & rho_global <= 0.7));
fprintf('  ✓ Elemento más cargado: %d (ρ=%.4f)\n', ...
    diagnostico_estatico.elem_mas_cargado, diagnostico_estatico.rho_max);

% 4.4.1) DIAGNÓSTICO DETALLADO DE DISTRIBUCIÓN DE ρ
fprintf('\n--- DIAGNÓSTICO DE DISTRIBUCIÓN DE ρ ---\n');
fprintf('ρ mínimo:  %.4f (elemento %d)\n', min(rho_global), find(rho_global == min(rho_global), 1));
fprintf('ρ máximo:  %.4f (elemento %d)\n', max(rho_global), find(rho_global == max(rho_global), 1));
fprintf('ρ promedio: %.4f\n', mean(rho_global));
fprintf('ρ mediana:  %.4f\n', median(rho_global));
fprintf('\nDistribución por rangos:\n');
fprintf('  ρ < 0.10:      %3d elementos (%.1f%%)\n', sum(rho_global < 0.10), 100*sum(rho_global < 0.10)/length(rho_global));
fprintf('  0.10 ≤ ρ < 0.20: %3d elementos (%.1f%%)\n', sum(rho_global >= 0.10 & rho_global < 0.20), 100*sum(rho_global >= 0.10 & rho_global < 0.20)/length(rho_global));
fprintf('  0.20 ≤ ρ < 0.30: %3d elementos (%.1f%%)\n', sum(rho_global >= 0.20 & rho_global < 0.30), 100*sum(rho_global >= 0.20 & rho_global < 0.30)/length(rho_global));
fprintf('  0.30 ≤ ρ < 0.50: %3d elementos (%.1f%%)\n', sum(rho_global >= 0.30 & rho_global < 0.50), 100*sum(rho_global >= 0.30 & rho_global < 0.50)/length(rho_global));
fprintf('  0.50 ≤ ρ < 0.75: %3d elementos (%.1f%%)\n', sum(rho_global >= 0.50 & rho_global < 0.75), 100*sum(rho_global >= 0.50 & rho_global < 0.75)/length(rho_global));
fprintf('  ρ ≥ 0.75:      %3d elementos (%.1f%%)\n', sum(rho_global >= 0.75), 100*sum(rho_global >= 0.75)/length(rho_global));
fprintf('\n');

% 4.5) Ensamble de matriz de rigidez global intacta y condensación
KG_und = ensamblaje_matriz_rigidez_global_sin_dano( ...
    ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz);
KG_und_cond = condensacion_estatica(KG_und);

% 4.6) Cálculo de modos y frecuencias del modelo intacto
[modos_intactos, frec_intactos, Omega_intactos] = modos_frecuencias(KG_und_cond, M_cond);

% 4.7) Creación de máscara para nodos de interés en superestructura
% Supongamos que has condensado los 4 nodos empotrados:
numFixed = 4;

% Nodos 41…52 de la superestructura
mask = createMask(41, 52, modos_intactos, numFixed);

% 4.8) Cálculo de índices de daño base (DI_base)
[DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8] = ...
    calcular_DIs(modos_intactos, modos_intactos, Omega_intactos, Omega_intactos);
DI_base = struct('DI1', DI1, 'DI2', DI2, 'DI3', DI3, 'DI4', DI4, ...
                 'DI5', DI5, 'DI6', DI6, 'DI7', DI7, 'DI8', DI8);

% -------------------------------------------------------------------------
% 5) Lanzamiento de corridas variables
% -------------------------------------------------------------------------
tablaResultados = runExperimentos( ...
    config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    config.tipo_dano, prop_geom, E, G, ...
    NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, ID, ...
    N_axial_global, rho_global, matriz_cell_secciones);

% un “ping” al terminar
fs = 8192;                % frecuencia de muestreo-
t  = 0:1/fs:0.5;          % medio segundo de duración
tone = sin(2*pi*440*t);   % tono A4 a 440 Hz
sound(tone,fs)     
