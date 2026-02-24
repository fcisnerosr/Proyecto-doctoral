% main_launcher.m
% Punto de entrada para el flujo de corridas del AG de detección de daño
% Realiza pre-cálculos estáticos una sola vez y luego lanza el launcher para las corridas variables

% --- PATH del proyecto ---
setupProjectPath(fileparts(mfilename('fullpath')));        % o:
% setupProjectPath(fileparts(mfilename('fullpath')), [], true);  % limpia path antes

% Refrescar caché de funciones (crítico para detectar nuevos archivos .m)
rehash toolboxcache;
rehash path;

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
config.archivo      = 'datos_revision_5_jacket-subestructura_5NIVELES.xlsx';
config.archivo_excel = construirRutaExcel(config.carpeta, config.archivo);  % Ruta al Excel de modelo ETABS

% -------------------------------------------------------------------------
% 3) Preparación de carpeta de resultados (con subcarpeta por tipo de daño)
% -------------------------------------------------------------------------
% 3.1) Crear subcarpeta con formato: tipo_dano_YYYY-MM-DD_HH-MM-SS
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
subfolder_name = sprintf('%s_%s', config.tipo_dano, timestamp);

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
fprintf('Tipo de daño: %s\n', config.tipo_dano);
fprintf('Elementos: %d\n', length(config.rangoElem));
fprintf('Niveles de daño: %d\n', length(config.porcentajes));
fprintf('Total corridas: %d\n', length(config.rangoElem) * length(config.porcentajes));
fprintf('Carpeta: %s\n\n', config.outputFolder);

% -------------------------------------------------------------------------
% 4) LECTURA DE DATOS Y PRE-CÁLCULOS MODALES
% -------------------------------------------------------------------------
fprintf('\n=== LECTURA DE DATOS DEL MODELO ===\n');

% 4.1) Lectura de datos del modelo 3D sin daño desde ETABS
[coordenadas, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones, VXZ] = ...
    lectura_datos_modelo_ETABS(config.archivo_excel);

% 4.2) Lectura de nodos, elementos, propiedades e identificadores desde marco3Ddam0.xlsx
[NE, IDmax, NEn, elements, nodes, damele, eledent, ...
 A, Iy, Iz, J, E, G, vxz, ID, ~, ~] = lectura_hoja_excel(config.pathfile);

% 4.3) Modificación de la matriz de masas
[masas_en_cada_nodo, M_cond, M_completa] = ...
    modificacion_matriz_masas_estructura_sencilla(config.archivo_excel);

fprintf('  ✓ Datos del modelo cargados\n');
fprintf('  ✓ %d elementos, %d nodos\n', NE, size(nodes,1));

% 4.4) Ensamble de matriz de rigidez global intacta y condensación
fprintf('\n=== CÁLCULOS MODALES ===\n');
KG_und = ensamblaje_matriz_rigidez_global_sin_dano( ...
    ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz);
KG_und_cond = condensacion_estatica(KG_und);

% 4.5) Cálculo de modos y frecuencias del modelo intacto
[modos_intactos, frec_intactos, Omega_intactos] = modos_frecuencias(KG_und_cond, M_cond);
fprintf('  ✓ Modos intactos calculados: %d modos\n', length(frec_intactos));
fprintf('  ✓ Frecuencias: %.3f - %.3f Hz\n', min(frec_intactos), max(frec_intactos));

% 4.6) Creación de máscara para nodos de interés en superestructura
numFixed = 4;  % Nodos empotrados condensados
mask = createMask(41, 52, modos_intactos, numFixed);  % Nodos 41-52 de superestructura

% 4.7) Cálculo de índices de daño base (DI_base)
[DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8] = ...
    calcular_DIs(modos_intactos, modos_intactos, Omega_intactos, Omega_intactos);
DI_base = struct('DI1', DI1, 'DI2', DI2, 'DI3', DI3, 'DI4', DI4, ...
                 'DI5', DI5, 'DI6', DI6, 'DI7', DI7, 'DI8', DI8);
fprintf('  ✓ DIs base calculados\n');

% -------------------------------------------------------------------------
% 5) LANZAMIENTO DE EXPERIMENTOS
% -------------------------------------------------------------------------
fprintf('\n=== INICIANDO EXPERIMENTOS ===\n');
fprintf('Daño: %s\n', config.tipo_dano);
fprintf('Corridas totales: %d\n\n', length(config.rangoElem) * length(config.porcentajes));

% Variables no usadas para abolladura/corrosión (solo para deformación inicial)
N_axial_global = [];
rho_global = [];

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
