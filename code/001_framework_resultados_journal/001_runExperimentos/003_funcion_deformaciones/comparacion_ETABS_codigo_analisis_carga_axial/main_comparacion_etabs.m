%% MAIN_COMPARACION_ETABS - Script para comparar cargas axiales con ETABS
%
% DESCRIPCIÓN:
%   Script simplificado que ejecuta SOLO el análisis estático de fuerzas
%   axiales para comparar con los resultados de ETABS.
%
% SALIDA:
%   - N_axial_codigo.csv: Archivo CSV con cargas axiales [kN] de cada elemento
%
% USO:
%   1. Ejecutar en MATLAB: main_comparacion_etabs
%   2. Se generará: N_axial_codigo.csv en el directorio actual
%   3. Comparar con Python usando: python comparar_con_etabs.py
%
% AUTOR: Sistema de análisis estructural - Proyecto Doctoral
% FECHA: Enero 2026

clear; clc; close all;

% Forzar recarga de todas las funciones
clear functions;
rehash toolboxcache;

fprintf('========================================\n');
fprintf('  COMPARACIÓN CARGAS AXIALES: ETABS\n');
fprintf('========================================\n\n');

%% 1. CONFIGURACIÓN DEL ENTORNO
fprintf('Configurando entorno...\n');
setupProjectPath();

% Cargar configuración
config();

fprintf('  ✓ Configuración cargada\n\n');

%% 2. LECTURA DE DATOS DEL MODELO
fprintf('Leyendo modelo desde Excel...\n');

% Usar la misma función que main_launcher.m para obtener ruta
excel_path = obtenerRutaMarco3Ddam0();  % ../../pruebas_excel/marco3Ddam0.xlsx

% Leer datos del modelo (misma firma que main_launcher.m)
[NE, IDmax, NEn, elements, nodes, damele, eledent, ...
 A, Iy, Iz, J, E, G, vxz, ID, ~, ~] = lectura_hoja_excel(excel_path);

nElem = size(elements, 1);
nNodos = size(nodes, 1);

fprintf('  ✓ Modelo cargado:\n');
fprintf('    - Elementos: %d\n', nElem);
fprintf('    - Nodos: %d\n', nNodos);
fprintf('    - DOF totales: %d\n', IDmax);
fprintf('    - NE: %d\n\n', NE);

%% 3. ANÁLISIS ESTÁTICO DE FUERZAS AXIALES
fprintf('Ejecutando análisis estático...\n\n');

% Parámetros de carga
W_topside = 8337000;  % [N] = 8.337 MN
incluir_peso_propio = true;  % Incluir peso propio (DEAD)

% Ejecutar análisis
[N_axial, ~, ~, diagnostico] = analisis_estatico_fuerzas_axiales(...
    nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio);

%% 4. RESUMEN DE RESULTADOS
fprintf('\n========================================\n');
fprintf('  RESULTADOS\n');
fprintf('========================================\n\n');

fprintf('Archivo generado: N_axial_codigo.csv\n');
fprintf('Ubicación: %s\n', pwd);
fprintf('\nContenido:\n');
fprintf('  - Columna 1: Elemento (ID)\n');
fprintf('  - Columna 2: N_axial_kN (carga axial en kN)\n');
fprintf('\nTotal de elementos: %d\n', nElem);
fprintf('  - En tensión: %d\n', length(diagnostico.idx_tension));
fprintf('  - En compresión: %d\n', length(diagnostico.idx_compresion));

%% 5. INSTRUCCIONES PARA COMPARACIÓN
fprintf('\n========================================\n');
fprintf('  SIGUIENTE PASO\n');
fprintf('========================================\n\n');
fprintf('Ejecuta la comparación con Python:\n');
fprintf('  >> python comparar_con_etabs.py\n\n');
fprintf('Esto comparará automáticamente:\n');
fprintf('  - N_axial_codigo.csv (este resultado)\n');
fprintf('  - P_etabs_promedio.csv (datos de ETABS)\n\n');

fprintf('========================================\n');
fprintf('  ANÁLISIS COMPLETADO\n');
fprintf('========================================\n\n');
