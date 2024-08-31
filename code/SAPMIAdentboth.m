%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic
format shortG

%% Datos iniciales de entrada
archivo_excel = 'E:\Archivos_Jaret\Proyecto-doctoral\pruebas_excel\Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
% archivo_excel = '/home/francisco/Documents/Proyecto-doctoral/pruebas_excel/Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
tirante         = 87000;    % en mm
tiempo          = 03;       % en anos
d_agua          = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
densidad_crec   = 1.3506*10^-7;    % en N/mm^3
% Valor de la dessidad del crecimiento marino
% Valor de internet = 1325 kg/m^3
% Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3
pathfile        = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';
% pathfile = '/home/francisco/Documents/Proyecto-doctoral/pruebas_excel/marco3Ddam0.xlsx';

% Danos a elementos tubulares, caso de dano y su respectivo porcentaje
no_elemento_a_danar = [1, 2, 5, 18, 19];
caso_dano           = repmat({'corrosion'}, 1, 5);
dano_porcentaje     = [60 40 40 40 40 ];

%% Corregir de formato los números en la tabla importada de ETABS: En todo este bloque de código, se realizó el cambio de formato de los números, debido a que ETABS importa sus tablas en formato de texto en algunas columnas.
% % % % correccion_format_TablaETABS(archivo_excel);

%% CONDICIONES IMPRESINDIBLES: ESTE CÓDIGO ESTÁ REALIZADO PARA EXTRAER LOS DATOS DEL MODELO EN ETABS
%% 1.- LOS ELEMENTOS DEBEN CONSTRUIRSE Y CONECTARSE DEL LECHO MARINO HASTA LA SUPER ESTRUCTURA
%% 2.- LOS ELEMENTOS DEBEN TENER UN "Unique name" SECUENCIAL DE MENOR A MAYOR CONSTRUIDO DESDE ABAJO HASTA ARRIBA (NO IMPORTA EL ORDEN EN CADA STORY)
%%     EL Unique name ES UNA ETIQUETA QUE ETABS LE DA A CADA ELEMENTO Y SI SE USA EL "SPLIT" PARA DIVIDIR ELEMENTOS
%%     ES IMPORTANTE REESCRIBIRLOS A MANO PARA QUE VAYAN SECUENCIALMENTE SIN SALTARSE NINGÚN NÚMERO
%%     DESDE 1 HASTA LOS n ELEMENTOS QUE VAYA A TENER LA PLATAFORMA

% Lectura de datos del modelo de ETABS
[coordenadas, vxz, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones]    = lectura_datos_modelo_ETABS(archivo_excel);

% Modificación de la matriz de masas
[masas_en_cada_nodo]                                                                      = modificacion_matriz_masas(archivo_excel, tirante, d_agua, matriz_cell_secciones, tiempo, densidad_crec);

% Escritura de los datos hacia la hoja de excel del Dr. Rolando
escritura_datos_hoja_excel_del_dr_Rolando(coordenadas, vxz, conectividad, prop_geom, matriz_restriccion,masas_en_cada_nodo);

% Matriz de masas completa y condensada
[M_cond]                                                                                  = Matriz_M_completa_y_condensada(coordenadas, masas_en_cada_nodo);

% Lectura de datos de la hoja de EXCEL del dr. Rolando para la función "Ensamblaje de matrices globales"
[NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu] = lectura_hoja_excel(pathfile);
% clearvars -except archivo_excel tirante tiempo d_agua densidad_crec pathfile no_elemento_a_danar caso_dano dano_porcentaje coordenadas vxz conectividad prop_geom matriz_restriccion matriz_cell_secciones masas_en_cada_nodo M_cond NE IDmax NEn elements nodes damele eledent A Iy Iz J E G ID KG KGtu hoja_excel vigas_long brac_long col_long num_de_ele_long

% Danos locales
% [ke_d_total, ke_d, elem_con_dano_long_NE] = switch_case_danos(no_elemento_a_danar, caso_dano, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
prop_geom(:,8:9)    = [];                          % eliminacion de 'circular' y 'wo', si no se eliminan la conversion a matriz numerica no es posible
% Tabla con no. de elemento y longitud de orden descendente
hoja_excel = 'Beam Object Connectivity';
vigas_long = xlsread (archivo_excel, hoja_excel, '');
vigas_long(:,2:5) = [];
% Extracción de datos de las columas (tanto en la subestructura como en al superestructura)
hoja_excel = 'Brace Object Connectivity'; % pestaña con elementos diagonales (ubicados en la subestructura)
brac_long = xlsread (archivo_excel, hoja_excel, '');
brac_long(:,2:5) = [];
hoja_excel = 'Column Object Connectivity'; % pestaña con columnas rectas (generalmente ubicados en la superestructura)
col_long = xlsread (archivo_excel, hoja_excel, '');
col_long(:,2:5) = [];
% no_ele_long = sort(vertcat(vigas_long,brac_long,col_long),1)
num_de_ele_long = sortrows(vertcat(vigas_long,brac_long,col_long),1);
% SECCION: Longitudes de elementos a danar (long_elem_con_dano)
hoja_excel              = 'Frame Assigns - Summary';
datos_para_long         = xlsread(archivo_excel, hoja_excel, 'C:E');
datos_para_long(:,2)    = [];
elementos_y_long        = sortrows(datos_para_long, 1);
for i = 1:length(no_elemento_a_danar)
    long_elem_con_dano(i)  = elementos_y_long(no_elemento_a_danar(i),2);
end
L_d = long_elem_con_dano;
%%
clc
% SECCION: Vector que posiciona en un indice del elemento a danar (elem_con_dano_long_NE)
% Importante seccion que asigna los danos del vector de no_elemento_a_danar a los elementos a del modelo matematico
elem_con_dano_long_NE = []; % vector de long NE con todos los elementos danados en las posiciones correspondientes
index = find(no_elemento_a_danar == 1);

if isempty(index)
    for i = 1:length(no_elemento_a_danar)
        if i < length(no_elemento_a_danar)
            elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
        else
            elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
        end
    end
    ceros_agregar = NE - length(elem_con_dano_long_NE);
    mat_zero = zeros(1,ceros_agregar);
    elem_con_dano_long_NE = horzcat(mat_zero,elem_con_dano_long_NE);
else
    for i = 1:length(no_elemento_a_danar)
        if i < length(no_elemento_a_danar)
            elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
        else
            elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
        end
    end
end

% Matrices de flexibilidades y de rigidez local llenas de ceros
f_AA_d = zeros(6, 6, length(no_elemento_a_danar));
ke_d = zeros(12, 12, length(no_elemento_a_danar));

for i = 1:length(no_elemento_a_danar)
    if strcmp(caso_dano{i}, 'corrosion')
        % Código de la corrosión local
        % Inicialización de matrices
        f_AA_d = zeros(6, 6, length(no_elemento_a_danar));
        ke_d = zeros(12, 12, length(no_elemento_a_danar));
        % Bucle para cada elemento a dañar
        for i = 1:length(no_elemento_a_danar)
            % Reducción de espesor por corrosión
            index = find(num_de_ele_long(:,1) == i);
            long_elem_a_danar = num_de_ele_long(index,2);
            prop_geom_mat = cell2mat(prop_geom);
            t(i) = prop_geom_mat(no_elemento_a_danar(i),10); % Espesor extraido intacto
            t_corro(i) = dano_porcentaje(i) * t(i) / 100; % Espesor que va a restar al espesor sin dano
            t_d(i) = t(i) - t_corro(i); % Espesor ya reducido
            % Área con corrosión
            D(i) = prop_geom_mat(no_elemento_a_danar(i),9);
            D_d(i) = D(i) - (2*t_corro(i));
            R_d(i) = 0.5 * D_d(i);
            A1_d(i) = pi  * R_d(i)^2;
            R_interior_d(i) = 0.5 * (D_d(i) - (2*t_d(i)));
            A2_d(i) = pi  * R_interior_d(i)^2;
            A_d(i) = A1_d(i) - A2_d(i); % en mm^2
            % Momento de inercia con daño
            R_ext_d(i) = 0.5*D_d(i);
            I_ext_d(i) = 1/4 * pi * R_ext_d(i)^4;
            I_int_d(i) = 1/4 * pi *  R_interior_d(i)^4;
            I_d(i) = I_ext_d(i) - I_int_d(i);
            % Momento polar del elemento con daño
            j(i) = prop_geom_mat(no_elemento_a_danar(i),5);
            % Matriz de flexibilidades y uso de matriz de transformación T para convertirla a la matriz de rigidez local completa
            f_AA_d(:,:,i) = [
                L_d(i)/(E(i)*A_d(i)) 0 0 0 0 0; ...
                0 L_d(i)^3/(3*E(i)*I_d(i)) 0 0 0 L_d(i)^2/(2*E(i)*I_d(i)); ...
                0 0 L_d(i)^3/(3*E(i)*I_d(i)) 0 -L_d(i)^2/(2*E(i)*I_d(i)) 0; ...
                0 0 0 L_d(i)/(G(i)*j(i)) 0 0; ...
                0 0 -L_d(i)^2/(2*E(i)*I_d(i)) 0 L_d(i)/(E(i)*I_d(i)) 0; ...
                0 L_d(i)^2/(2*E(i)*I_d(i)) 0 0 0 L_d(i)/(E(i)*I_d(i))
            ];
            % Matriz de transformación
            T = [
                -1 0 0 0 0 0; 0 -1 0 0 0 0; 0 0 -1 0 0 0; 0 0 0 -1 0 0; ...
                0 0 L_d(i) 0 -1 0; 0 -L_d(i) 0 0 0 -1; 1 0 0 0 0 0; ...
                0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1
            ];
            ke_d(:,:,i) = T * f_AA_d(:,:,i)^(-1) * T'; % Matriz de rigidez local del elemento tubular
        end % Fin del bucle for de corrosión

    elseif strcmp(caso_dano{i}, 'abolladura')
        % El código de la aboladura está en codigo_abolladura.txt en esta misma carpeta
    end
end % Fin del ciclo for que itera sobre cada elemento a dañar
ke_d_total = real(ke_d);

[KG_damaged, KG_undamaged,L] = ensamblaje_matriz_rigidez_global_ambos_modelos(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);

%%
clc
% Función Condensación estática
KG_damaged_cond   = condensacion_estatica(KG_damaged);

% % Modos y frecuencias de estructura condensados y globales
[modos_cond_d,frec_cond_d] = modos_frecuencias(KG_damaged_cond,M_cond);

% Implementación del Algoritmo Genetico (AG)
% Inicializar los vectores LB y UB con el tamaño adecuado para long_x daños
% Por ahora solo se está considerando la corrosión
num_elements = 116;
long_x = 3 * num_elements; % = 348
% 3 porque solamente se aplica dano al área y ambas inercias en x y en y
% 116 porque se le aplica dano a los primeros 116 elementos de la subestructura % Configuraciones básicas del AG
Samples     = 1000;
Generations = 500;
Nvar        = long_x;        % numero de variables que va a tener la variable de dano x. Son 116 elementos de la subestructura * 3 variables de dano de la corrosion = long_x
options                 = gaoptimset(@ga);          % gaoptimset es para crear las configuraciones específicas para el AG
options.PopulationSize  = Samples;
options.Generations     = Generations;
options.StallGenLimit   = 50;          % límite de generaciones en donde los individuos no cumplen con la función objetivo
options.Display         = 'iter';                         % Muestra la información en cada iteración
% Configuraciones específicas del AG
% Este bloque de código configura funciones específicas que controlan el comportamiento de varios procesos dentro del Algoritmo Genético (GA) en MATLAB. Cada opción define una función que el GA utilizará para diferentes aspectos del proceso de evolución, como la creación de la población inicial, la selección de individuos, la mutación, y si se debe usar o no procesamiento paralelo.
% el @ le dice al campo de options que haga uso de la función después de @
options.CreationFcn         = @gacreationlinearfeasible;  % esta línea del dice al AG cómo debe crear la primera generación de los individuos. @gacreationlinearfeasible hace que la primera generación de individuos cumplan con cualquier restricción lineal que defina en el problema. Esto asegura que el AG comience desde un inicio con soluciones válidas y así poder aumentar las probabilidades de que devuelva una respuesta correcta cuando el AG finalice
options.FitnessScalingFcn   = @fitscalingprop;      % fitscalingprop: Esta técnica de escalamiento ajusta los valores de aptitud para que las diferencias entre ellos no sean tan extremas. Esto significa que incluso los individuos con una aptitud no tan alta todavía tienen una oportunidad razonable de ser seleccionados para la reproducción. Uno de los riesgos en los Algoritmos Genéticos (GA) es que si un individuo (o un pequeno grupo de individuos) tiene un valor de aptitud significativamente superior al de los demás en una población, el GA podría converger rápidamente hacia las características de esos individuos. Esto puede llevar a que el algoritmo se quede atrapado en un óptimo local en lugar de encontrar el óptimo global, que es la mejor solución posible en todo el espacio de búsqueda.
options.SelectionFcn        = @selectionroulette;        % En este método, la probabilidad de que un individuo sea seleccionado es proporcional a su aptitud. Los individuos con mejores valores de aptitud tienen más probabilidades de ser seleccionados, pero también hay una oportunidad para aquellos con menor aptitud, lo que ayuda a mantener la diversidad genética en la población.
options.MutationFcn         = @mutationadaptfeasible;     % Configura cómo se llevará a cabo la mutación. Función de Mutación Adaptativa Factible: mutationadaptfeasible es una función específica de MATLAB que realiza mutaciones de manera adaptativa. Aquí está lo que hace: Adaptativa: La mutación es adaptativa porque ajusta el grado de mutación dependiendo del progreso del GA. Si el algoritmo está haciendo buenos progresos, la mutación puede ser menos agresiva. Si no está haciendo mucho progreso, la mutación puede volverse más agresiva para explorar nuevas áreas del espacio de soluciones. Factibilidad: La mutación se realiza de tal manera que los individuos mutados aún cumplen con cualquier restricción del problema. Esto es crucial para asegurarse de que las soluciones mutadas sigan siendo válidas dentro del espacio de búsqueda permitido.
% Propósito de la Mutación: La mutación es una operación que introduce variación en los individuos de una población. Es esencial para mantener la diversidad genética, permitiendo que el algoritmo explore nuevas soluciones que no estaban presentes en la población original.
% Cómo Funciona: Durante la mutación, una pequena parte del código genético (representado por el vector x en tu caso) de un individuo se altera al azar. Esta alteración puede ser un cambio pequeno en el valor de una variable o un ajuste más significativo, dependiendo de cómo esté definida la función de mutación.
options.UseParallel = 'always';
% Graficas de monitoreo para ver el estado del AG durante todo su proceso
options = gaoptimset('PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping});
% @gaplotbestf: Mejores valores de función
% @gaplotbestindiv: Valores del mejor individuo por generación
% @gaplotdistance: Distancia entre individuos en las soluciones de busqueda
% @gaplotrange: Rango de valores de la población
% @gaplotstopping: Criterios de parada del algoritmo

% Definir los límites de daño
LowerLim = 0.0;       % Daño mínimo permitido: 0%
UpperLim = 0.50;      % Daño máximo permitido: 50%

LB = zeros(long_x, 1);   % Todos los valores se inicializan con 0 (sin daño mínimo)
UB = UpperLim * ones(long_x, 1);   % Todos los valores se inicializan con 0.50 (daño máximo permitido)

% Escritura de registros del AG
CWFile='CWFOutput1.txt';    % Nombre del archivo donde irán registrándose los resultados del AG
diary (CWFile);             % Abre el archivo de salida para que todas las salidas en la consola de MATLAB se registren en este archivo

% Proceso en paralelo
parpool('Processes', 6)     %  configura MATLAB para ejecutar la optimización del Algoritmo Genético utilizando 6 núcleos de CPU en paralelo, lo que puede acelerar significativamente el proceso al permitir la evaluación simultánea de múltiples individuos en cada generación
% En mi CPU se pueden 6 como máximo, para saber cuántos puede cada usaurio ejecutar en el command window lo siguiente:
% numCores = feature('numcores');
% disp(['Número de núcleos: ', num2str(numCores)]);
% La siguiente linea se a cabo el proceso del ga
[x,fval,exitflag,output,population,scores] = ga(@(x)RMSEfunction(x, num_elements, M_cond, frec_cond_d,...
        L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
        vxz, elem_con_dano_long_NE,...
        modos_cond_d),Nvar,[],[],[],[],LB,UB,[],options);

% Datos de salida de la funcion ga (Algoritmo Genético de MATLAB):
% fval: Valor mínimo de la función objetivo (RMSE) alcanzado durante la optimización.
% exitflag: Razón por la que el AG terminó (convergencia, límite Ade generaciones, error, etc.).
% output: Estructura que contiene detalles del proceso de optimización, como el número de generaciones, evaluaciones de la función objetivo, y tiempo de ejecución.
% population: Población de individuos en la última generación del AG.
% scores: Valores de la función objetivo (RMSE) para cada individuo en la última generación.
% Datos de entrada de la función ga:
%     Función Objetivo: RMSEfunction es la función objetivo que el AG intenta minimizar.
%     Variables de Optimización: Nvar define el número de variables que se optimizan.
%     Límites: LB y UB+ son los límites inferiores y superiores para las variables de optimización, definidos previamente.
    % Opciones: options incluye todas las configuraciones del AG como el tamaño de la población, número de generaciones, funciones de selección, etc.
delete(gcp('nocreate'));    % Cierra el procesamiento paralelo
%
% % Función Condensación estática
    % KG_damaged_cond   = condensacion_estatica(KG_damaged);
%     KG_undamaged_cond = condensacion_estatica(KG_undamaged);
%
% % Modos y frecuencias de estructura condensados y globales
%     [modos_cond_u,frec_cond_u] = modos_frecuencias(KG_undamaged_cond,M_cond);
%     [modos_cond_d,frec_cond_d] = modos_frecuencias(KG_damaged_cond,M_cond);
%
% % Cálculo del Root Mean Square Error (RMSE)
%     rmse_frec = sqrt(mean((frec_cond_u - frec_cond_d).^2));
%
%
