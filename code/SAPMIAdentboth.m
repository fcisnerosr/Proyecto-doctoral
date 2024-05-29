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
    %% SECCION: Elementos a danar y parametros de dano segun el dano inducido
    prop_geom(:,8:9)    = [];                           % eliminacion de 'circular' y 'wo', si no se eliminan la conversion a matriz numerica no es posible
    prop_geom           = cell2mat(prop_geom);          % Conversion de prop_geo que era un cell, en esta seccion se extraen los valores del espesor
    no_elemento_a_danar = [1, 6, 9];
    caso_dano           = {'corrosion', 'corrosion'};
    dano_porcentaje_corr= [50, 50];
    
    %% Parametros de dano
    %% SECCION: Corrosion
        % Reducción del espesor
        % vectores de ceros para almacenar valores
        t               = zeros(1, length(no_elemento_a_danar));
        t_corro         = t;
        t_d             = t;
        D_d             = t;
        R_d             = t;
        A1_d            = t;
        R_interior_d    = t;
        A2_d            = t;
        A_d             = t;
        long_elem_con_dano = t;
        
        %% Longitudes de elementos a danar (long_elem_con_dano)
        hoja_excel              = 'Frame Assigns - Summary';
        datos_para_long         = xlsread(archivo_excel, hoja_excel, 'C:E');
        datos_para_long(:,2)    = [];
        elementos_y_long        = sortrows(datos_para_long, 1);
        for i = 1:length(no_elemento_a_danar)
            long_elem_con_dano(i)  = elementos_y_long(no_elemento_a_danar(i),2);
        end
        
        %% SECCION (elem_con_dano_long_NE)
        % Vector de longitud NE con los elementos danados dentro que sirve como criterio en la siguiente seccion para saber que matriz de rigidez local intacta reemplazarla por
        % las que tienen dano
        % Inicializar elem_con_dano_long_NE como un vector vacío
        elem_con_dano_long_NE = [];
        
        % Construir el elem_con_dano_long_NE
        for i = 1:length(no_elemento_a_danar)
            if i < length(no_elemento_a_danar)
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
            else
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
            end
        end

        % SECCION: Matriz de rigidez local con corrosion (ke_d)
        % SUBLOQUE: Matrices con ceros, f_AA_d es la matriz de flexibilidad pero solo el primer cuadrante de un extremo por eso de 6 x 6, ke_d es la matriz de rigidez local completa
        %     en el siguiente subloque se convierte se la matriz de transformacion T para convertirla en matriz de rigidez local completa. Ya que al intentar
        %%     invertirla produce valores indeterminados
        f_AA_d  = zeros( 6,  6, length(no_elemento_a_danar));
        ke_d    = zeros(12, 12, length(no_elemento_a_danar)); 
        % % SUBLOQUE: Asignación de corrosión al area y a las inercias de la seccion 
        for i = 1:length(no_elemento_a_danar)
            % reduccion de espesor por corrosion
            t(i)        = prop_geom(i,10);                      % Estraccion de espesor sin dano
            t_corro(i)  = dano_porcentaje_corr(i) * t(i) / 100; % Espesor que va a restar al espesor sin dano
            t_d(i)      = t(i) - t_corro(i);                    % Espesor ya reducido. El subíndice "_d" es de "damaged"
            % Área con corrosion
            D(i)            = prop_geom(i,8);
            D_d(i)          = D(i) - (2*t_corro(i));
            R_d(i)          = 0.5 * D_d(i);
            A1_d(i)         = pi  * R_d(i)^2;  
            R_interior_d(i) = 0.5 * (D_d(i) - (2*t_d(i)));
            A2_d(i)         = pi  * R_interior_d(i)^2;
            A_d(i)          = A1_d(i) - A2_d(i);             % en mm^2. El subíndice "_u" es de "undamaged" 
            % Momento de inercia con dano
            R_ext_d(i)          = 0.5*D_d(i);
            I_ext_d(i)          = 1/4 * pi * R_ext_d(i)^4;
            I_int_d(i)          = 1/4 * pi *  R_interior_d(i)^4;
            I_d(i)              = I_ext_d(i) - I_int_d(i);
            L                   = long_elem_con_dano(i);
            % SUBLOQUE: Matriz de flexibilidades y usop de matriz de transformación T para convertirla a la matriz de rigidez local completa sin necesidad de
            % invertirla.
            % Elemento tubular dañado
            f_AA_d(:,:,i) = [L/(E(i)*A_d(i))    0                       0                       0                 0                     0;...
                            0                   L^3/(3*E(i)*I_d(i))     0                       0                 0                     L^2/(2*E(i)*I_d(i));...
                            0                   0                       L^3/(3*E(i)*I_d(i))     0                 -L^2/(2*E(i)*I_d(i))  0;...
                            0                   0                       0                       L/(G(i)*J(i))     0                     0;...
                            0                   0                       -L^2/(2*E(i)*I_d(i))    0                 L/(E(i)*I_d(i))       0;...
                            0                   L^2/(2*E(i)*I_d(i))     0                       0                 0                     L/(E(i)*I_d(i))];
            % Matriz de transformación para evitar invertir la matriz de flexibilidades
            T   = [-1    0      0       0   0   0
                    0    -1     0       0   0   0 
                    0    0      -1      0   0   0
                    0    0      0       -1  0   0
                    0    0      L       0   -1  0
                    0   -L      0       0   0  -1
                    1    0      0       0   0   0
                    0    1      0       0   0   0
                    0    0      1       0   0   0
                    0    0      0       1   0   0
                    0    0      0       0   1   0
                    0    0      0       0   0   1];
            ke_d(:,:,i) = T * f_AA_d(:,:,i)^(-1) * T';   % Matriz de rigidecez local del elemento tubular
            clear L                                      % Se borra la variable L ya que en el ensamblaje de matriz de rigidez se vuelve a usar esta variable
        end
        %%
        % ke_d_total  = zeros(12, 12, NE);
        % for j = 1:NE
        %     if j == elem_con_dano_long_NE(j)
        %         ke_d_total(:,:,j) = ke_d(:,:,j);
        %     end
        % end

%     % Abolladura
%     % Efecto P-delta
%     % Fatiga
% 
%     %% SECCION: Asignacion de propiedades con dano segun el caso de dano
%     for i = 1:length(no_elemento_a_danar)
%        if  strcmp(caso_dano{i}, 'corrosion')
% 
%        elseif strcmp(caso_dano{i}, 'abolladura')
% 
%        elseif strcmp(caso_dano{i}, 'efecto P-delta')
% 
%        elseif strcmp(caso_dano{i}, 'fatiga')
% 
%        else
%            error('Error: The option "%s" in cell %d is incorrectly written or not recognized.', caso_dano{i}, i);
%        end
%     end




% %% función "Ensamblaje de matrices globales"
%     % [KG_undamage, ke] = ensamblaje_matriz_rigidez_global(NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu);
%     for i = 1:NE
%         KGf     = zeros(IDmax,IDmax);
%         KGtuf   = zeros(IDmax,NEn);
%         % Length of the elements
%         L(i) = sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2 + ...
%                (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2 + ...
%                (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);
% 
%         CZ(i) = (nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
%         CY(i) = (nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
%         CX(i) = (nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
%         CXY(i)= sqrt(CX(i)^2 + CY(i)^2);
% 
%         locdam  = find(damele == i,1);
%         locdent = find(eledent==i,1);
%         if isempty(locdam) && isempty(locdent)
%             % local stiffness matrix of the elements
%             if i == elem_con_dano_long_NE(i)
%                 ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
%             else
%                 ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
%             end
%         elseif isempty(locdent)
%             xdc = xdcr(locdam) * L(i);
%             if strcmp(tipo(i),'circular')
%                 depthr1 = depthr(locdam) * radio(i);
%                 ke(:,:,i) = ZhengcircT(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i));
%             elseif  strcmp(tipo(i),'rectangular')
%                 depthr1 = depthr(locdam) * h(i);
%                 ke(:,:,i) = Zhengrectub(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),h(i),b(i),trec(i));  
%             end             
%         elseif isempty(locdam)
%             ident = eledent(locdent);
%             x1dent = x1dentr * L(ident);
%             x2dent = x2dentr * L(ident);
%             ke(:,:,i) = FEMdent(L(ident),Adent(locdent),Izdent(locdent),...
%                         Iydent(locdent),Jdent(locdent),A(ident),Iz(ident),Iy(ident),...
%                         J(ident),x1dent,x2dent,E(ident),G(ident));                
%         end
%         vxzl(:,i) = vxz(i,2:end);
%         [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));
%         % Transformation matrix 3D
%         LT(:,:,i) = TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha);
%         % global stiffnes matrix of the elements  
%         kg(:,:,i) = LT(:,:,i)' * ke(:,:,i) * LT(:,:,i);
%         LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];
%         indxLV = find(LV(:,i)>0);
%         indxLVn = find(LV(:,i)<0);
%         % assamblage general stiffness matrix
%         KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i); 
%         KGtuf(LV(indxLV,i),LV(indxLVn,i) * (-1)-IDmax) = kg(indxLV,indxLVn,i);
%         KG = KGf + KG;
%         % stiffness matrix for reactions
%         KGtu = KGtuf + KGtu;
%         clear KGf;
%         clear KGtuf;
%     end
%     KG_damaged = KG;
%     clear KG

    %% KG intacta
    % for i = 1:NE
    %     KGf     = zeros(IDmax,IDmax);
    %     KGtuf   = zeros(IDmax,NEn);
    %     % Length of the elements
    %     L(i) = sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2 + ...
    %            (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2 + ...
    %            (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);
    % 
    %     CZ(i) = (nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
    %     CY(i) = (nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
    %     CX(i) = (nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
    %     CXY(i)= sqrt(CX(i)^2 + CY(i)^2);
    % 
    %     locdam  = find(damele == i,1);
    %     locdent = find(eledent==i,1);
    %     if isempty(locdam) && isempty(locdent)
    %         % local stiffness matrix of the elements
    %         ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
    %     elseif isempty(locdent)
    %         xdc = xdcr(locdam) * L(i);
    %         if strcmp(tipo(i),'circular')
    %             depthr1 = depthr(locdam) * radio(i);
    %             ke(:,:,i) = ZhengcircT(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i));
    %         elseif  strcmp(tipo(i),'rectangular')
    %             depthr1 = depthr(locdam) * h(i);
    %             ke(:,:,i) = Zhengrectub(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),h(i),b(i),trec(i));  
    %         end             
    %     elseif isempty(locdam)
    %         ident = eledent(locdent);
    %         x1dent = x1dentr * L(ident);
    %         x2dent = x2dentr * L(ident);
    %         ke(:,:,i) = FEMdent(L(ident),Adent(locdent),Izdent(locdent),...
    %                     Iydent(locdent),Jdent(locdent),A(ident),Iz(ident),Iy(ident),...
    %                     J(ident),x1dent,x2dent,E(ident),G(ident));                
    %     end
    %     vxzl(:,i) = vxz(i,2:end);
    %     [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));
    % 
    %     %alpha = pi/4;
    % 
    %     % Transformation matrix 3D
    %     LT(:,:,i) = TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha);
    % 
    % 
    %     % global stiffnes matrix of the elements  
    %     kg(:,:,i) = LT(:,:,i)' * ke(:,:,i) * LT(:,:,i);
    % 
    %     LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];
    % 
    %     indxLV = find(LV(:,i)>0);
    %     indxLVn = find(LV(:,i)<0);
    % 
    %     % assamblage general stiffness matrix
    %     KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i); 
    %     KGtuf(LV(indxLV,i),LV(indxLVn,i) * (-1)-IDmax) = kg(indxLV,indxLVn,i);
    %     KG = KGf + KG;
    %     % stiffness matrix for reactions
    %     KGtu = KGtuf + KGtu;
    %     clear KGf;
    %     clear KGtuf;
    % end
    % KG_undamage = KG;
    % clear KG

% %% Función Condensación estática    
%     KG_cond = condensacion_estatica(KG);
% 
% % Modos y frecuencias de estructura condensados y globales
%     [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond);

toc

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% keq = ke(:,:,ed); %%% eq = elemento a quitar
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % %% Proceso de integración del elemento danado a la matriz global
% % Expansión de la matriz local
%         % Tamano de la matriz expandida_g = global
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
%         KG_new = KG_undamage - K_dgq;    % Matriz global sin el elemento a danar   
%         % _new = nueva usada para para construir la matriz global danada

% ke_d = funcion_abulladura_longitudinal(ed, porcent, Long, D, t, L_D);
% %% Transformación de la matriz local a global
%     % Conversión de ejes locales a globales
%         ke_dT = LT(:,:,ed)'*ke_d*LT(:,:,ed); % _dT = danada y transformada
%     % Expanción de la matriz global
%         % Tamano de la matriz expandida_g = global
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
%             K_dg(coord_y, coord_x) = ke_dT(1, 1);    % K_dg = Matriz de rigidez global danada (del elemento danado nada más)
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
% % Adición del elemento danado a la matriz global de rigidez
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
