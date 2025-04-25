%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic
format shortG

% Datos iniciales de entrada
carpeta = 'revision_6_jacket-subestructura_4NIVELES';
archivo = 'datos_revision_5_jacket-subestructura_5NIVELES';
archivo_excel = construirRutaExcel(carpeta, archivo);

tirante         = 87000;    % en mm
tiempo          = 03;       % en anos
d_agua          = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
% d_agua          = 0; % unidades de la densidad del agua en N/mm^3
densidad_crec   = 1.3506*10^-7;    % en N/mm^3
% Valor de la dessidad del crecimiento marino
% Valor de encontrado en internet = 1325 kg/m^3
% Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3

% Ruta relativa para la ubicación de marco3Ddam0
pathfile = obtenerRutaMarco3Ddam0();

% Danos en elementos tubulares
ID_Ejecucion = 5;
% no_elemento_a_danar = sort([102]);
% no_elemento_a_danar = sort([3 4 5 2]);
% no_elemento_a_danar = sort([29 27 26 28]);
% no_elemento_a_danar = sort([50 51 52 53]);
% no_elemento_a_danar = sort([76 74 72 75]);
no_elemento_a_danar = sort([104]);
% no_elemento_a_danar = sort([103 104 105 106]);
% no_elemento_a_danar = sort([1 18 24 43 25 26 21 5]);
% no_elemento_a_danar = sort([25 42 48 67 49 50 45 29]);
caso_dano           = repmat({'corrosion'}, 1, length(no_elemento_a_danar)); 
dano_porcentaje     = [30];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [40];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [10 10 10 10];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [40 40 40 40];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [30 30 30 30 30 30 30 30 30];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [40 40 40 40 40 40 40 40 40];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [50 50 50 50 50 50 50 50 50];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [80 80 80 80 80 80 80 80 80];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector

% Corregir de formato los números en la tabla importada de ETABS: En todo este bloque de código, se realizó el cambio de formato de los números, debido a que ETABS importa sus tablas en formato de texto en algunas columnas.
% % % % correccion_format_TablaETABS(archivo_excel);

% CONDICIONES IMPRESINDIBLES: ESTE CÓDIGO ESTÁ REALIZADO PARA EXTRAER LOS DATOS DEL MODELO EN ETABS
% 1.- LOS ELEMENTOS DEBEN CONSTRUIRSE Y CONECTARSE DEL LECHO MARINO HASTA LA SUPER ESTRUCTURA
% 2.- LOS ELEMENTOS DEBEN TENER UN "Unique name" SECUENCIAL DE MENOR A MAYOR CONSTRUIDO DESDE ABAJO HASTA ARRIBA (NO IMPORTA EL ORDEN EN CADA STORY)
%     EL Unique name ES UNA ETIQUETA QUE ETABS LE DA A CADA ELEMENTO Y SI SE USA EL "SPLIT" PARA DIVIDIR ELEMENTOS
%     ES IMPORTANTE REESCRIBIRLOS A MANO PARA QUE VAYAN SECUENCIALMENTE SIN SALTARSE NINGÚN NÚMERO
%     DESDE 1 HASTA LOS n ELEMENTOS QUE VAYA A TENER LA PLATAFORMA

% % Lectura de datos del modelo de ETABS
[coordenadas, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones, VXZ] = lectura_datos_modelo_ETABS(archivo_excel);

% Modificación de la matriz de masas
% [masas_en_cada_nodo] = modificacion_matriz_masas(archivo_excel, tirante, d_agua, matriz_cell_secciones, tiempo, densidad_crec);
[masas_en_cada_nodo, M_cond, M_completa] = modificacion_matriz_masas_estructura_sencilla(archivo_excel);

% Escritura de los datos hacia la hoja de excel del Dr. Rolando
escritura_datos_hoja_excel_del_dr_Rolando(coordenadas, conectividad, prop_geom, matriz_restriccion, masas_en_cada_nodo, VXZ);

% % Lectura de datos de la hoja de EXCEL del dr. Rolando para la función "Ensamblaje de matrices globales"
[NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu] = lectura_hoja_excel(pathfile);
% clearvars -except archivo_excel tirante tiempo d_agua densidad_crec pathfile no_elemento_a_danar caso_dano dano_porcentaje coordenadas vxz conectividad prop_geom matriz_restriccion matriz_cell_secciones masas_en_cada_nodo M_cond NE IDmax NEn elements nodes damele eledent A Iy Iz J E G ID KG KGtu hoja_excel vigas_long brac_long col_long num_de_ele_long

% Danos locales
[num_de_ele_long, prop_geom] = extraer_longitudes_elementos(prop_geom, archivo_excel);
L_d = extraer_longitudes_danadas(archivo_excel, no_elemento_a_danar);

% Vector que posiciona en un indice del elemento a danar
[elem_con_dano_long_NE] = vector_asignacion_danos(no_elemento_a_danar, NE);

% Matriz de rigidez local con dano aplicado
[ke_d_total, ke_d, prop_geom_mat] = switch_case_danos(no_elemento_a_danar, num_de_ele_long, L_d, caso_dano, dano_porcentaje, prop_geom, E, G);
% [KG_damaged, KG_undamaged,L, kg] = ensamblaje_matriz_rigidez_global_con_dano(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G,  vxz, elem_con_dano_long_NE);
[KG_damaged, L, kg] = ensamblaje_matriz_rigidez_global_con_dano(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G,  vxz, elem_con_dano_long_NE);

% Matriz de rigidez global sin dano (para el método de los DIs)
[KG_undamaged] = ensamblaje_matriz_rigidez_global_sin_dano(ID, NE, ke_d_total, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);

% Función Condensación estática
KG_damaged_cond     = condensacion_estatica(KG_damaged);
KG_undamaged_cond   = condensacion_estatica(KG_undamaged);

% Modos y frecuencias de estructura condensados y globales
[modos_cond_d,frec_cond_d, Omega_cond_d] = modos_frecuencias(KG_damaged_cond,M_cond);
[modos_cond_u,frec_cond_u, Omega_cond_u] = modos_frecuencias(KG_undamaged_cond,M_cond);
% [modos_completos,frec_completos] = modos_frecuencias(KG_damaged,M_completa);

% % proceso de filtrado de nodos de la superestructura
% mask = createMask(25, 32, modos_cond_u);
% modos_cond_d = modos_cond_d .* mask; % Aplica la máscara a cada fila
% modos_cond_u = modos_cond_u .* mask; % Se "anulan" los DOF excluidos en ambos modelos


% DIs (Damage Index)
% Formas modales
% 1. COMAC
COMAC       = calcCOMAC(modos_cond_u, modos_cond_d);
COMAC_sqrt  = computeCOMACSqrt(COMAC);
DI1_COMAC   = 1 - COMAC_sqrt;
DI1_COMAC   = normalizeTo01(DI1_COMAC);

% 2. Diff
DI2_Diff        = abs(modos_cond_u - modos_cond_d);
Diff_perNode    = unifyDiff(DI2_Diff);
DI2_Diff        = normalizeTo01(Diff_perNode);

% 3. Div
ratio       = modos_cond_d ./ modos_cond_u;
Div_perNode = unifyDiff(ratio);
DI3_Div     = abs(ratio - 1);
DI3_Div     = unifyDiff(DI3_Div);
DI3_Div     = normalizeTo01(DI3_Div);

% Flexibilidad
F_u = modos_cond_u * diag(1./(Omega_cond_u.^2)) * modos_cond_u';
F_d = modos_cond_d * diag(1./(Omega_cond_d.^2)) * modos_cond_d';
% 4. Diff
DI4_Diff_Flex       = abs(F_d - F_u);
diff_diag           = diag(DI4_Diff_Flex);
DI4_Diff_Flex_node  = unifyDiffVector(diff_diag, 3);
DI4_Diff_Flex       = normalizeTo01(DI4_Diff_Flex_node);
% 5. Div
flex_diag_u     = diag(F_u);                        % Extrae un vector donde cada entrada es la flexibilidad (autovalor) del estado sano para cada DOF.
flex_diag_d     = diag(F_d);                        % Extrae de forma similar los valores locales de flexibilidad en el estado dañado.
ratio_flex      = flex_diag_d ./ flex_diag_u;       % Calcular el ratio (elemento a elemento) para cada DOF
DI_F_Div_raw    = abs(ratio_flex - 1);              % Calcular el DI de división para la flexibilidad (elemento a elemento)
DI_F_Div_node   = unifyDiffVector(DI_F_Div_raw, 3); % Unificar los valores por nodo. Suponiendo que tienes 3 DOF por nodo, usa la función 'unifyDiffVector' para agrupar el vector en índices por nodo.
DI_F_Div        = normalizeTo01(DI_F_Div_node);     % Normalizar el vector resultante a [0,1]
DI5_Div_Flex    = DI_F_Div;
% 6. Perc
Perc_flex_raw = 100 * abs(flex_diag_d - flex_diag_u) ./ max(flex_diag_u, eps);  % Calcular la variación porcentual para cada DOF evita dividir por cero si algún elemento de flex_diag_u es 0
Perc_flex_node = unifyDiffVector(Perc_flex_raw, 3);     % Unificar los valores por nodo. Si cada nodo tiene 3 DOF (x, y, z), agrupa cada 3 elementos usando, por ejemplo, 'unifyDiffVector'. (Suponiendo que unifyDiffVector está definida para hacer RSS o alguna combinación de esos 3 DOF). 
Perc_flex_node_norm = normalizeTo01(Perc_flex_node);    % Normalizar a [0,1] para integrarlo con otros DIs
DI6_Perc_Flex = Perc_flex_node_norm;
% 7. Z-score
diff_flex   = abs(F_d - F_u);         % Diferencia global de flexibilidad (matriz)
diff_diag   = diag(diff_flex);          % Vector de diferencias por DOF
flex_unify  = unifyDiffVector(diff_diag, 3);  % Unifica cada 3 DOF en 1 valor por nodo
% (Opcional: normalizar los valores unificados si se desea)
% flex_normalize = normalizeTo01(flex_unify);
mu_flex     = mean(flex_unify);
sigma_flex  = std(flex_unify);
Z_flex      = (flex_unify - mu_flex) / sigma_flex;
DI7_Zscore_Flex = Z_flex;
% 8. Probabilidad
absZ = abs(Z_flex);
p_flex = 2 * (1 - myNormcdf(absZ));  % Prueba bilateral
p_flex_norm = normalizeTo01(Perc_flex_node);    % Normalizar a [0,1] para integrarlo con otros DIs
DI8_Prob_Flex = p_flex_norm;



%%
clc
% --- Nueva Implementación del Algoritmo Genético de detección de dano en los nodos del modelo (AG) ---

% Definir DI como estructura con los 5 índices ya calculados (escalares)
DI.DI1_COMAC        = DI1_COMAC;
DI.DI2_Diff         = DI2_Diff;
DI.DI3_Div          = DI3_Div;
DI.DI4_Diff_Flex    = DI4_Diff_Flex;
DI.DI5_Div_Flex     = DI5_Div_Flex;
DI.DI6_Perc_Flex    = DI6_Perc_Flex; 
DI.DI7_Zscore_Flex  = DI7_Zscore_Flex; 
DI.DI8_Prob_Flex    = DI8_Prob_Flex; 

T = zeros(length(DI1_COMAC),1);     
T(33) = 1;                       % Nodo 13 se marca como dañado
threshold = 0.05;               % umbral definido, por ejemplo, 0.05 (ajusta según tu caso)

nVars = 8;
lb = zeros(1, nVars);
ub = ones(1, nVars);

options.PopulationSize  = 300;
options.Generations     = 500;
options.StallGenLimit   = 200;          % límite de generaciones en donde los individuos no cumplen con la función objetivo

objFun = @(alpha) objective_function(alpha, DI, T, threshold);
options = optimoptions('ga', 'Display', 'iter', 'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping});

[optimal_alpha, fval] = ga(objFun, nVars, [], [], [], [], lb, ub, [], options);

disp('Pesos óptimos (alpha):');
disp(optimal_alpha);
disp('Valor de la función objetivo:');
disp(fval);


[w1, w2, w3, w4, w5, w6, w7, w8] = assignWeights(optimal_alpha);

nNodes = length(DI1_COMAC);
P = zeros(nNodes,1);  % Inicializamos el vector resultado
%%
% Iterar por cada nodo para combinar los índices
for j = 1:nNodes
    P(j) =      w1 * DI1_COMAC(j)       + w2 * DI2_Diff(j) +...
            +   w3 * DI3_Div(j)         + w4 * DI4_Diff_Flex(j) + ...
            +   w5 * DI5_Div_Flex(j)    + w6 * DI6_Perc_Flex(j) + ...
            +   w7 * DI7_Zscore_Flex(j) + w8 + DI8_Prob_Flex(j); 
end

Resultado_final = createNodeTable(P, DI1_COMAC);


toc
%%

tiempo_total = toc;
guardar_resultados_AG(Resultado_final, no_elemento_a_danar, dano_porcentaje, tiempo_total, ID_Ejecucion, P);

