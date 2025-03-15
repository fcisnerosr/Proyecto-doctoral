%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic
format shortG

% Datos iniciales de entrada
carpeta = 'revision_4_jacket-subestructura_2NIVELES';
archivo = 'datos_revision_4_jacket-subestructura_2NIVELES.xlsx';
archivo_excel = construirRutaExcel(carpeta, archivo);

tirante         = 87000;    % en mm
tiempo          = 03;       % en anos
d_agua          = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
% d_agua          = 0; % unidades de la densidad del agua en N/mm^3
densidad_crec   = 1.3506*10^-7;    % en N/mm^3
% densidad_crec   = 0;    % en N/mm^3
% Valor de la dessidad del crecimiento marino
% Valor de encontrado en internet = 1325 kg/m^3
% Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3

% Ruta relativa para la ubicación de marco3Ddam0
pathfile = obtenerRutaMarco3Ddam0();

% % Danos a elementos tubulares, caso de dano y su respectivo porcentaje
% no_elemento_a_danar = sort([1 5 21 26 25 43 24 18]);
% caso_dano           = repmat({'corrosion'}, 1, length(no_elemento_a_danar)); 
% % dano_porcentaje     = [10 10 10 10];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% % dano_porcentaje     = [60 60 60 60 60 60 60 60];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [80 80 80 80 80 80 80 80];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector

no_elemento_a_danar = sort([26 27 29 28]);
caso_dano           = repmat({'corrosion'}, 1, length(no_elemento_a_danar)); 
% dano_porcentaje     = [10 10 10 10];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
% dano_porcentaje     = [60 60 60 60 60 60 60 60];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector
dano_porcentaje     = [80 80 80 80];  % El dano va en decimal y se debe incluir el numero de elementos con dano dentro de un vector


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
[KG_damaged, KG_undamaged,L, kg] = ensamblaje_matriz_rigidez_global_con_dano(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G,  vxz, elem_con_dano_long_NE);

% Matriz de rigidez global sin dano (para el método de los DIs)
[KG_undamaged] = ensamblaje_matriz_rigidez_global_sin_dano(ID, NE, ke_d_total, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);

% Función Condensación estática
KG_damaged_cond     = condensacion_estatica(KG_damaged);
KG_undamaged_cond   = condensacion_estatica(KG_undamaged);

% Cargas aplicadas con matriz condensada
% P = buildLoadVector();
% P = [    0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          500000
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          0
%          -500000
%          0]
% Deform = (KG_ubdamaged_cond^-1) * P

% Modos y frecuencias de estructura condensados y globales
[modos_cond_d,frec_cond_d, Omega_cond_d] = modos_frecuencias(KG_damaged_cond,M_cond);
[modos_cond_u,frec_cond_u, Omega_cond_u] = modos_frecuencias(KG_undamaged_cond,M_cond);
% [modos_completos,frec_completos] = modos_frecuencias(KG_damaged,M_completa);
%%
% DIs
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

%%
% Flexibilidad
F_u = modos_cond_u * diag(1./(Omega_cond_u.^2)) * modos_cond_u';
F_d = modos_cond_d * diag(1./(Omega_cond_d.^2)) * modos_cond_d';
% 4. Diff
DI4_Diff_Flex       = abs(F_d - F_u);
diff_diag           = diag(DI4_Diff_Flex);
DI4_Diff_Flex_node  = unifyDiffVector(diff_diag, 3);
DI4_Diff_Flex       = normalizeTo01(DI4_Diff_Flex_node);
% 5. Div
flex_diag_u     = diag(F_u);
flex_diag_d     = diag(F_d);
ratio_flex      = flex_diag_d ./ flex_diag_u;    % Calcular el ratio (elemento a elemento) para cada DOF
DI_F_Div_raw    = abs(ratio_flex - 1);         % Calcular el DI de división para la flexibilidad (elemento a elemento)
DI_F_Div_node   = unifyDiffVector(DI_F_Div_raw, 3);   % Unificar los valores por nodo. Suponiendo que tienes 3 DOF por nodo, usa la función 'unifyDiffVector' para agrupar el vector en índices por nodo.
DI_F_Div        = normalizeTo01(DI_F_Div_node);            % Normalizar el vector resultante a [0,1]
DI5_Div_Flex    = DI_F_Div;


%%
clc
% --- Nueva Implementación del Algoritmo Genético de detección de dano en los nodos del modelo (AG) ---

% Definir DI como estructura con los 5 índices ya calculados (escalares)
DI.DI1_COMAC     = DI1_COMAC;
DI.DI2_Diff      = DI2_Diff;
DI.DI3_Div       = DI3_Div;
DI.DI4_Diff_Flex = DI4_Diff_Flex;
DI.DI5_Div_Flex  = DI5_Div_Flex;        % valor escalar para Div en flexibilidad

T = zeros(20,1);  % Vector columna de 20 elementos, todos 0
T(9) = 1;         % Nodo 13 se marca como dañado
threshold = 0.05*2;   % umbral definido, por ejemplo, 0.05 (ajusta según tu caso)

nVars = 5;
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


[w1, w2, w3, w4, w5] = assignWeights(optimal_alpha);

nNodes = length(DI1_COMAC);
P = zeros(nNodes,1);  % Inicializamos el vector resultado

% Iterar por cada nodo para combinar los índices
for j = 1:nNodes
    P(j) = w1 * DI1_COMAC(j) + w2 * DI2_Diff(j) + w3 * DI3_Div(j) + w4 * DI4_Diff_Flex(j) + w5 * DI5_Div_Flex(j);
end

% Mostrar el vector combinado P
% disp('Valor combinado P para cada nodo:');
% disp(P);
%%
Resultado_final = createNodeTable(P, DI1_COMAC);

toc
% % 
% % %%
% % 
% % 
% % % % --- Implementación del Algoritmo Genético (AG) ---
% % % %
% % % % Este script implementa un Algoritmo Genético (AG) para la optimización de la
% % % % identificación de daños, enfocándose por ahora en la corrosión.
% % % % Se considera una subestructura de 'num_element_sub' elementos y se 
% % % % crea un vector de daño 'long_x' para representar el nivel de corrosión
% % % % en cada elemento.
% % % 
% % % % Cierra cualquier 'parallel pool' existente para evitar conflictos
% % % delete(gcp('nocreate'));
% % % 
% % % % --- Parámetros de la subestructura y del AG ---
% % % num_element_sub = length(elements);       % Número de elementos en la subestructura
% % % long_x = num_element_sub(end, 1);   % Longitud del vector de daños (corrosión)
% % % 
% % % Samples     = 300;
% % % Generations = 5000;
% % % Nvar        = long_x;        % numero de variables que va a tener la variable de dano x. Son 116 elementos de la subestructura * 3 variables de dano de la corrosion = long_x
% % % options                 = gaoptimset(@ga);          % gaoptimset es para crear las configuraciones específicas para el AG
% % % options.PopulationSize  = Samples;
% % % options.Generations     = Generations;
% % % options.StallGenLimit   = 2000;          % límite de generaciones en donde los individuos no cumplen con la función objetivo
% % % options.Display         = 'iter';                         % Muestra la información en cada iteración
% % % options.OutputFcn       = @gaoutfun;  % Añade la función de salida para mostrar el tiempo transcurrido
% % % 
% % % % Configuraciones específicas del AG
% % % % Este bloque de código configura funciones específicas que controlan el comportamiento de varios procesos dentro del Algoritmo Genético (GA) en MATLAB. Cada opción define una función que el GA utilizará para diferentes aspectos del proceso de evolución, como la creación de la población inicial, la selección de individuos, la mutación, y si se debe usar o no procesamiento paralelo.
% % % % el @ le dice al campo de options que haga uso de la función después de @
% % % options.CreationFcn         = @gacreationlinearfeasible;    % Genera la población inicial asegurando que cumpla con restricciones lineales
% % % options.EliteCount          = 2;                            % Preserva los 2 mejores individuos en cada generación para evitar perder buenas soluciones
% % % options.FitnessScalingFcn = @fitscalingrank;         % Asigna rangos a los individuos según su aptitud en lugar de escalar los valores directamente, reduciendo el impacto de las grandes diferencias de aptitud y evitando convergencia prematura.
% % % % options.FitnessScalingFcn   = @fitscalingprop;      % fitscalingprop: Esta técnica de escalamiento ajusta los valores de aptitud para que las diferencias entre ellos no sean tan extremas. Esto significa que incluso los individuos con una aptitud no tan alta todavía tienen una oportunidad razonable de ser seleccionados para la reproducción. Uno de los riesgos en los Algoritmos Genéticos (GA) es que si un individuo (o un pequeno grupo de individuos) tiene un valor de aptitud significativamente superior al de los demás en una población, el GA podría converger rápidamente hacia las características de esos individuos. Esto puede llevar a que el algoritmo se quede atrapado en un óptimo local en lugar de encontrar el óptimo global, que es la mejor solución posible en todo el espacio de búsqueda.
% % % 
% % % options.SelectionFcn        = @selectionroulette;        % En este método, la probabilidad de que un individuo sea seleccionado es proporcional a su aptitud. Los individuos con mejores valores de aptitud tienen más probabilidades de ser seleccionados, pero también hay una oportunidad para aquellos con menor aptitud, lo que ayuda a mantener la diversidad genética en la población.
% % % % options.SelectionFcn = {@selectiontournament, 3}; % Torneo con 3 individuos para favorecer convergencia
% % % % options.SelectionFcn = {@selectiontournament, 2}; % Torneo con 2 individuos
% % % % options.SelectionFcn        = @selectiontournament;        % Este método selecciona grupos al azar (torneos), y dentro de cada torneo, se elige el mejor individuo, favoreciendo la diversidad y mejores aptitudes.
% % % % options.SelectionFcn = {@selectiontournament, 1}; % Solo se selecciona el mejor individuo
% % % % options.SelectionFcn = @selectionstochunif; % Selección estocástica uniforme
% % % 
% % % options.MutationFcn                               = @mutationadaptfeasible;     % Configura cómo se llevará a cabo la mutación. Función de Mutación Adaptativa Factible: mutationadaptfeasible es una función específica de MATLAB que realiza mutaciones de manera adaptativa. Aquí está lo que hace: Adaptativa: La mutación es adaptativa porque ajusta el grado de mutación dependiendo del progreso del GA. Si el algoritmo está haciendo buenos progresos, la mutación puede ser menos agresiva. Si no está haciendo mucho progreso, la mutación puede volverse más agresiva para explorar nuevas áreas del espacio de soluciones. Factibilidad: La mutación se realiza de tal manera que los individuos mutados aún cumplen con cualquier restricción del problema. Esto es crucial para asegurarse de que las soluciones mutadas sigan siendo válidas dentro del espacio de búsqueda permitido.
% % % % options.MutationFcn = @(parents,options,nvars,FitnessFcn,state,thisScore,thisPopulation) ...
% % % %     round(mutationadaptfeasible(parents,options,nvars,FitnessFcn,state,thisScore,thisPopulation) / 0.005) * 0.005;
% % % % options.MutationFcn    = {@mutationuniform, 0.02}; % Solo el 2% de las variables mutará en cada generación
% % % % options.MutationFcn = {@mutationuniform, 0.01}; % Solo el 1% de las variables mutará en cada generación
% % % % options.MutationFcn = {@mutationuniform, 0.005}; % Solo el 0.5% de las variables mutará en cada generación
% % % % options.MutationFcn = {@mutationuniform, 0.002}; % Solo el 0.2% de las variables mutará
% % % % options.MutationFcn = {@mutationuniform, 0.001}; % Solo el 0.1% de las variables mutará
% % % % options.MutationFcn = {@mutationuniform, 0.0005}; % Solo 0.05% de las variables mutarán
% % % % options.MutationFcn = {@mutationuniform, 0.0001}; % Solo el 0.01% de las variables mutará
% % % 
% % % 
% % % % Propósito de la Mutación: La mutación es una operación que introduce variación en los individuos de una población. Es esencial para mantener la diversidad genética, permitiendo que el algoritmo explore nuevas soluciones que no estaban presentes en la población original.
% % % % Cómo Funciona: Durante la mutación, una pequena parte del código genético (representado por el vector x en tu caso) de un individuo se altera al azar. Esta alteración puede ser un cambio pequeno en el valor de una variable o un ajuste más significativo, dependiendo de cómo esté definida la función de mutación.
% % % options.UseParallel = 'always';
% % % % Graficas de monitoreo para ver el estado del AG durante todo su proceso
% % % options = gaoptimset('PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping});
% % % % @gaplotbestf: Mejores valores de función
% % % % @gaplotbestindiv: Valores del mejor individuo por generación
% % % % @gaplotdistance: Distancia entre individuos en las soluciones de busqueda
% % % % @gaplotrange: Rango de valores de la población
% % % % @gaplotstopping: Criterios de parada del algoritmo
% % % 
% % % % Definir los límites de daño
% % % LowerLim = 0.0;       % Daño mínimo permitido
% % % UpperLim = 0.80;      % Daño máximo permitido
% % % % UpperLim = dano_porcentaje/100;      % Daño máximo permitido
% % % 
% % % LB = LowerLim * ones(long_x, 1);  % Límite inferior
% % % UB = UpperLim * ones(long_x, 1);  % Límite superior
% % % 
% % % % % % % % % Escritura de registros del AG
% % % % % % % % CWFile='CWFOutput1.txt';    % Nombre del archivo donde irán registrándose los resultados del AG
% % % % % % % % diary (CWFile);             % Abre el archivo de salida para que todas las salidas en la consola de MATLAB se registren en este archivo
% % % % 
% % % % Proceso en paralelo
% % % % parpool('Processes', 6, 'IdleTimeout', 6000);  % Configura n minutos de inactividad antes de apagarse
% % % parpool('Processes', 2, 'IdleTimeout', 6000);
% % % % En mi CPU se pueden 6 como máximo, para saber cuántos puede cada usaurio ejecutar en el command window lo siguiente:
% % % % numCores = feature('numcores');
% % % % disp(['Número de núcleos: ', num2str(numCores)]);
% % % % La siguiente linea se a cabo el proceso del ga
% % % tic;
% % % 
% % % clc
% % % % % Inicialización de las matrices COMAC
% % % % nodos = ((nodes(end,1))-4)*3;
% % % % modos = 3;
% % % % comac_values = zeros(nodos, modos);
% % % % comac_ref = ones(nodos, modos);  % COMAC de referencia, asumimos valores ideales (1)
% % % 
% % % % Obtener la ruta del directorio de SAPMIAdentboth.m
% % % ruta_directorio_actual = fileparts(mfilename('fullpath'));
% % % 
% % % % Construir la ruta a RMSEfunction.m
% % % ruta_rmse = fullfile(ruta_directorio_actual, 'RMSEfunction.m');
% % % 
% % % %%
% % % % Verificar si RMSEfunction.m existe
% % % if exist(ruta_rmse, 'file') == 2
% % %     % Agregar la ruta al path de manera temporal
% % %     addpath(ruta_directorio_actual);
% % %     % [x,fval,exitflag,output,population,scores] = ga(@(x)RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
% % %     %     L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
% % %     %     vxz, elem_con_dano_long_NE,...
% % %     %     modos_cond_d, prop_geom_mat),Nvar,[],[],[],[],LB,UB,[],options);
% % %     [x,fval,exitflag,output,population,scores] = ga(@(x)RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
% % %         L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
% % %         vxz, elem_con_dano_long_NE,...
% % %         modos_cond_d, prop_geom_mat),Nvar,[],[],[],[],LB,UB,[],options);
% % % 
% % %     % Remover la ruta del path de manera temporal
% % %     rmpath(ruta_directorio_actual);
% % % else
% % %     error('No se encontró RMSEfunction.m');
% % % end
% % % 
% % % 
% % % 
% % % % Crear la gráfica de barras
% % % figure;        % Abre una nueva ventana de figura
% % % bar(x*100);   % Genera la gráfica de barras
% % % title('Mejor individuo');  % Título de la gráfica
% % % xlabel('Elemento con daño');                % Etiqueta del eje X
% % % ylabel('Porcentaje con daño');                        % Etiqueta del eje Y
% % % toc;
% % % % % % % % 
% % % % % % % % % % Datos de salida de la funcion ga (Algoritmo Genético de MATLAB):
% % % % % % % % % % fval: Valor mínimo de la función objetivo (RMSE) alcanzado durante la optimización.
% % % % % % % % % % exitflag: Razón por la que el AG terminó (convergencia, límite Ade generaciones, error, etc.).
% % % % % % % % % % output: Estructura que contiene detalles del proceso de optimización, como el número de generaciones, evaluaciones de la función objetivo, y tiempo de ejecución.
% % % % % % % % % % population: Población de individuos en la última generación del AG.
% % % % % % % % % % scores: Valores de la función objetivo (RMSE) para cada individuo en la última generación.
% % % % % % % % % % Datos de entrada de la función ga:
% % % % % % % % % %     Función Objetivo: RMSEfunction es la función objetivo que el AG intenta minimizar.
% % % % % % % % % %     Variables de Optimización: Nvar define el número de variables que se optimizan.
% % % % % % % % % %     Límites: LB y UB+ son los límites inferiores y superiores para las variables de optimización, definidos previamente.
% % % % % % % % %     % Opciones: options incluye todas las configuraciones del AG como el tamaño de la población, número de generaciones, funciones de selección, etc.
% % % % % % % % % % delete(gcp('nocreate'));    % Cierra el procesamiento paralelo
