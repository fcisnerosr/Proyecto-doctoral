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

% Vector de nodos dañados
respuesta = [5, 7];  % Escribe aquí los nodos con daño

% Danos en elementos tubulares
ID_Ejecucion = 18;
no_elemento_a_danar = sort([98]);
dano_porcentaje     = [30];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
caso_dano           = repmat({'corrosion'}, 1, length(no_elemento_a_danar)); 

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

% proceso de filtrado de nodos de la superestructura
mask = createMask(41-4, 52-4, modos_cond_u);
modos_cond_d = modos_cond_d .* mask; % Aplica la máscara a cada fila
modos_cond_u = modos_cond_u .* mask; % Se "anulan" los DOF excluidos en ambos modelos

[DI1_COMAC, DI2_Diff, DI3_Div, DI4_Diff_Flex, DI5_Div_Flex, DI6_Perc_Flex, DI7_Zscore_Flex, DI8_Prob_Flex] = calcular_DIs(modos_cond_u, modos_cond_d, Omega_cond_u, Omega_cond_d)

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

% Genera el vector T con nodos marcados como dañados y define un umbral para la evaluación.
[T, threshold] = generarT(no_elemento_a_danar, conectividad, DI1_COMAC);

% Ejecuta el Algoritmo Genético (AG) para encontrar los pesos óptimos (alpha) que minimizan la diferencia entre los DIs combinados y el patrón de daño real.
[optimal_alpha, fval] = GA(DI, T, threshold);

% Asigna cada valor del vector optimal_alpha a una variable individual w1 a w8, que representa el peso de cada índice de daño (DI).
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

[Resultado_final, P_scaled] = createNodeTable(P, DI1_COMAC);


toc
%%

tiempo_total = toc;


% Datos estadisticos de valores dispersos
valid_vals = P_scaled(~isnan(P_scaled) & P_scaled < 50);  % Filtra los valores válidos excluyendo NaNs y posibles verdaderos positivos (valores ≥ 50)

prom_dispersion     = mean(valid_vals);
std_dispersion      = std(valid_vals);
mean_abs_dispersion = mean(abs(valid_vals));
n_falsos_positivos  = sum(valid_vals > 50);

fprintf('Promedio de dispersión: %.2f\n', prom_dispersion);
fprintf('Desviación estándar: %.2f\n', std_dispersion);
fprintf('Promedio absoluto: %.2f\n', mean_abs_dispersion);
fprintf('Falsos positivos fuertes (>50): %d\n', n_falsos_positivos);

guardar_resultados_AG(Resultado_final, no_elemento_a_danar, dano_porcentaje, tiempo_total, ID_Ejecucion, P);

