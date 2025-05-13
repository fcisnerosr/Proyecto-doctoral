% main_launcher.m
% Punto de entrada para el flujo de corridas del AG de detección de daño
% Realiza pre-cálculos estáticos una sola vez y luego lanza el launcher para las corridas variables
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
% 3) Preparación de carpeta de resultados
% -------------------------------------------------------------------------
config.outputFolder = obtenerOutputFolder();                 % Ruta absoluta a Proyecto-doctoral/Resultados
if ~exist(config.outputFolder,'dir')
    mkdir(config.outputFolder);  % Crea carpeta si no existe
end

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

% 4.4) Ensamble de matriz de rigidez global intacta y condensación
KG_und = ensamblaje_matriz_rigidez_global_sin_dano( ...
    ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz);
KG_und_cond = condensacion_estatica(KG_und);

% 4.5) Cálculo de modos y frecuencias del modelo intacto
[modos_intactos, frec_intactos, Omega_intactos] = modos_frecuencias(KG_und_cond, M_cond);

% 4.6) Creación de máscara para nodos de interés en superestructura
% Supongamos que has condensado los 4 nodos empotrados:
numFixed = 4;

% Nodos 41…52 de la superestructura
mask = createMask(41, 52, modos_intactos, numFixed);

% 4.7) Cálculo de índices de daño base (DI_base)
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
    NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, ID);
