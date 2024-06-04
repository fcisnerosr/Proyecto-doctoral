%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic
format shortG

%% Datos iniciales de entrada
    archivo_excel = 'E:\Archivos_Jaret\Proyecto-doctoral\pruebas_excel\Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
    % archivo_excel = '/home/francisco/Documents/Proyecto-doctoral/pruebas_excel/Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
    tirante = 87000;    % en mm
    tiempo  = 03;       % en anos
    d_agua = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
    densidad_crec = 1.3506*10^-7;    % en N/mm^3
    % Valor de la dessidad del crecimiento marino
            % Valor de internet = 1325 kg/m^3
            % Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3
    pathfile = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';
    % pathfile = '/home/francisco/Documents/Proyecto-doctoral/pruebas_excel/marco3Ddam0.xlsx';
    
    % Danos a elementos tubulares, caso de dano y su respectivo porcentaje
    no_elemento_a_danar = [6, 9];
    caso_dano           = {'corrosion', 'corrosion'};
    dano_porcentaje     = [50, 50];

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

% Danos locales
    [ke_d_total, ke_d, elem_con_dano_long_NE] = switch_case_danos(no_elemento_a_danar, caso_dano, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);

%% función "Ensamblaje de matrices globales" con dano e intacto
    [KG_damaged, ke]    = ensamblaje_matriz_rigidez_global_con_dano(NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu, ke_d_total, elem_con_dano_long_NE);
    [KG_undamage]       = ensamblaje_matriz_rigidez_global_intacta (NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu);

    

% %% Función Condensación estática    
%     KG_cond = condensacion_estatica(KG);
% 
% % Modos y frecuencias de estructura condensados y globales
%     [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond);

toc

% ke_d = funcion_abulladura_longitudinal(ed, porcent, Long, D, t, L_D);


% %% Algoritmo genético
% Samples     = 1000; % Población de soluciones, esta se mantiene constante, desde que inicia hasta que termina el proceso del GA. Y solo cambian variables entre sí, hasta que cuando termine todo el proceso, los n valores de la población se parezcan entre sí y todos convergan a la solución buscada.
% Generations = 2000; % No. de generaciones por el cual el GA va a trabajar
% Nvar        = 12;   % CAMBIAR AL NGDL QUE ESTOY MANEJANDO (MODELO CONDENSADO)
% 
% options                 = gaoptimset(@ga);  % conjunto de opciones para el algoritmo genético. Esta línea se utiliza para crear un conjunto de opciones (options) específicamente disenado para el algoritmo genético (ga) en MATLAB. Después de esta línea, puedes personalizar las opciones según tus necesidades específicas.
% options.PopulationSize  = 1000;             % Establecer el tamano de la población
% options.Generations     = 2000;             % número máximo de generaciones
% options.StallGenLimit   = 50;               % límite de generaciones sin mejora
% options.Display         = 'iter';           % visualización para mostrar información en cada iteración
% 
% options.CreationFcn         = @gacreationlinearfeasible;    % Crea la población inicial
% options.FitnessScalingFcn   = @fitscalingprop;              % Aquí se establece la función de escalado de aptitud. El escalado de aptitud se utiliza para ajustar las puntuaciones de aptitud de las soluciones en la población.
% options.SelectionFcn        = @selectionroulette;           % Función de selección que se utilizará para seleccionar soluciones para reproducción. En este caso, se está utilizando la función de selección de ruleta, que asigna probabilidades de selección a las soluciones proporcionalmente a sus puntuaciones de aptitud
% options.MutationFcn         = @mutationadaptfeasible;       % Establece la función de mutación que se utilizará para realizar cambios en las soluciones de la población
% options.UseParallel         = 'always';                     % Indica que se debe utilizar el procesamiento en paralelo
% 
% LB = zeros(12,1);
% UB = zeros(12,1);
% 
% LowerLim = 0.0;
% UpperLim = 0.30;
% 
% for i=1:1:12
%    LB(i) = LowerLim; 
%    UB(i) = UpperLim;  
% end    
% CWFile = 'CWFOutput1.txt';
% diary (CWFile);
% %matlabpool open local 8
% [x,fval,exitflag,output,population,scores] = ga(@(x)RMSEfunction(x,KG_cond,M_cond,modos_cond,Dd),Nvar,[],[],[],[],LB,UB,[],options);
% %matlabpool close
% diary off;
% 
% LB = zeros(12,1);
% UB = zeros(12,1);
% 
% LowerLim = 0.0;
% UpperLim = 0.30;
% 
% for i = 1:1:12
%    LB(i) = LowerLim; 
%    UB(i) = UpperLim;  
% end    
% CWFile='CWFOutput1.txt';
% diary (CWFile);
% %matlabpool open local 8
% [x,fval,exitflag,output,population,scores] =ga(@(x)RMSEfunction(x,k1,m1,Vd,Dd),Nvar,[],[],[],[],LB,UB,[],options);
% %matlabpool close
% diary off;
% 
% x
% fval
% exitflag
% output
% population
% scores

% M1 = zeros(12,12);
% K1 = zeros(12,12);
% 
% for i=1:1:12
%    M1(i,i)=m1(i); 
%    if i<12
%       K1(i,i)=k1(i)*(1-x(i))+k1(i+1)*(1-x(i+1)); 
%       if i==1
%           K1(i,i+1)=-k1(i+1)*(1-x(i+1)); 
%       else
%           K1(i,i+1)=-k1(i+1)*(1-x(i+1));
%           K1(i,i-1)=-k1(i)*(1-x(i));
%       end
%    else
%       K1(i,i)=k1(i)*(1-x(i));
%       K1(i,i-1)=-k1(i)*(1-x(i)); 
%    end
% end    
% M1
% K1
% [Vr,Dr]=eig(K1,M1)
