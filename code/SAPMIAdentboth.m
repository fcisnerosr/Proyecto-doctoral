%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic

%% ===================== %%
%%%%%%%%  m a i n %%%%%%%%%
%% ===================== %%
format shortG
% format long
%% Datos del elemento a dañar
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     ed = 5; % ed = elemento a dañar                                     %
%     porcent = 44; % Porcen_de_prof_de_abolld_con_respecto_al_diam;      %
%     % Unidades en milímetros                                            %
%     % Longitud_total_del_elemento_en_mm;                                %
%         switch ed                                                       %
%             case {5,6,9,7}                                              %
%                 Long = 5000;                                            %
%             case {1,3}                                                  %
%                 Long = 4000;                                            %
%             case {2, 4}                                                 %
%                 Long = 3000;                                            %
%         end                                                             %
%     D       = 600;      % Diametro_de_elemento_tubular_en_mm;           %
%     t       = 25.4;     % Espesor_en_mm;                                %
%     L_D     = Long;     % longitud dañada_en_mm;                        %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Datos iniciales de entrada
    archivo_excel = 'E:\Archivos_Jaret\Proyecto-doctoral\pruebas_excel\Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
    tirante = 87000;    % en mm
    tiempo  = 03;       % en años
    d_agua = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
    densidad_crec = 1.3506*10^-7;    % en N/mm^3
    % Valor de la dessidad del crecimiento marino
            % Valor de internet = 1325 kg/m^3
            % Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3
    pathfile = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';
    % pathfile = 'E:\Archivos_Jaret\todos\Jaret3erPlataforma_wo.xlsx';

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

%% Lectura de datos de la hoja de EXCEL del dr. Rolando para la función "Ensamblaje de matrices globales"
    [NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu] = lectura_hoja_excel(pathfile);

% función "Ensamblaje de matrices globales"
    [KG_undamage, ke] = ensamblaje_matriz_rigidez_global(NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu);

%% Función Condensación estática    
    KG_cond = condensacion_estatica(KG_undamage);

% Modos y frecuencias de estructura condensados y globales
    [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond);

toc

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keq = ke(:,:,ed); %%% eq = elemento a quitar
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % %% Proceso de integración del elemento dañado a la matriz global
% % Expansión de la matriz local
%         % Tamaño de la matriz expandida_g = global
%         GDL = 24;
% 
%         % Crear matriz expandida con ceros
%         K_dgq = zeros(GDL);
% 
%         % Coordenadas del primer elemento de la matriz original en la matriz expandida
%             % coord_x = coordenada x en la matriz expandida
%             % coord_y = coordenada y en la matriz expandida
% 
%         switch ed
%             case {1,5}
%                 coord_x = 1;
%                 coord_y = 1;
%             case {2,6}
%                 coord_x = 7;
%                 coord_y = 7;
%             case {3,7,8}
%                 coord_x = 13;
%                 coord_y = 13;                    
%             otherwise
%                 keq = [keq(1:6, 1:6)        zeros(6,6)  zeros(6,6)  keq(end-5:end, end-5:end);...
%                        zeros(6,6)           zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                        zeros(6,6)           zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                        keq(end-5:end, 1:6)  zeros(6,6)  zeros(6,6)  keq(end-5:end, end-5:end)];
%         end
% 
%         if ed ~= 4
%             % Copiar el primer elemento de la matriz original en la matriz expandida
%             K_dgq(coord_y, coord_x) = keq(1, 1);
% 
%             % Expandir los elementos restantes
%             for i = 1:size(keq, 1)
%                 for j = 1:size(keq, 2)
%                     K_dgq(coord_y + i - 1, coord_x + j - 1) = keq(i, j);
%                 end
%             end
%             K_dgq;
%         else
%             K_dgq = keq;
%         end
%         KG_new = KG_undamage - K_dgq;    % Matriz global sin el elemento a dañar   
%         % _new = nueva usada para para construir la matriz global dañada

% ke_d = funcion_abulladura_longitudinal(ed, porcent, Long, D, t, L_D);
% %% Transformación de la matriz local a global
%     % Conversión de ejes locales a globales
%         ke_dT = LT(:,:,ed)'*ke_d*LT(:,:,ed); % _dT = dañada y transformada
%     % Expanción de la matriz global
%         % Tamaño de la matriz expandida_g = global
%         GDL = 24;
% 
%         % Crear matriz expandida con ceros
%         K_dg = zeros(GDL);
% 
%         % Coordenadas del primer elemento de la matriz original en la matriz expandida
%             % coord_x = coordenada x en la matriz expandida
%             % coord_y = coordenada y en la matriz expandida
%         % Criterio de expanción (Exclusivo de marco3D)
%         switch ed
%             case {1,5}
%                 coord_x = 1;
%                 coord_y = 1;
%             case {2,6}
%                 coord_x = 7;
%                 coord_y = 7;
%             case {3,7,8}
%                 coord_x = 13;
%                 coord_y = 13;                    
%             otherwise
%                 ke_dT = [ke_d(1:6, 1:6)          zeros(6,6)  zeros(6,6)  ke_d(end-5:end, end-5:end);...
%                         zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                         zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                         ke_d(end-5:end, 1:6)    zeros(6,6)  zeros(6,6)  ke_d(end-5:end, end-5:end)];
%         end
% 
%         if ed ~= 4
%             % Copiar el primer elemento de la matriz original en la matriz expandida
%             K_dg(coord_y, coord_x) = ke_dT(1, 1);    % K_dg = Matriz de rigidez global dañada (del elemento dañado nada más)
% 
%             % Expandir los elementos restantes
%             for i = 1:size(ke_dT, 1)
%                 for j = 1:size(ke_dT, 2)
%                     K_dg(coord_y + i - 1, coord_x + j - 1) = ke_dT(i, j);
%                 end
%             end
%             K_dg;
%         else
%             K_dg = ke_dT;
%         end
% 
% fprintf('\n\n')
% % Adición del elemento dañado a la matriz global de rigidez
% KG_damage = KG_new + K_dg;
% 
% % % %% Ejercicio de Marco 3D para comprobar matrices de rigidez
% % % P = [9000;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
% % % d_d = (KG_damage^(-1)) * P
% % % d_u = (KG_undamage^(-1)) * P
% 

% %% Algoritmo genético
% Samples     = 1000; % Población de soluciones, esta se mantiene constante, desde que inicia hasta que termina el proceso del GA. Y solo cambian variables entre sí, hasta que cuando termine todo el proceso, los n valores de la población se parezcan entre sí y todos convergan a la solución buscada.
% Generations = 2000; % No. de generaciones por el cual el GA va a trabajar
% Nvar        = 12;   % CAMBIAR AL NGDL QUE ESTOY MANEJANDO (MODELO CONDENSADO)
% 
% options                 = gaoptimset(@ga);  % conjunto de opciones para el algoritmo genético. Esta línea se utiliza para crear un conjunto de opciones (options) específicamente diseñado para el algoritmo genético (ga) en MATLAB. Después de esta línea, puedes personalizar las opciones según tus necesidades específicas.
% options.PopulationSize  = 1000;             % Establecer el tamaño de la población
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
