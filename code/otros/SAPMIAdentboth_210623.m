% Structural analysis program of structures in 3D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 30th October 2020
% 11 December 2020
% Modificated by FJCR
clc; clear all; close all

%% ============================================= %%
%%%%%%%%  I  N  T  E  G  R  A  C  I  Ó  N %%%%%%%%%
%% ============================================= %%

%% Datos del elemento a dañar
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ed = 5; % ed = elemento a dañar                                     %
    porcent = 44; % Porcen_de_prof_de_abolld_con_respecto_al_diam;      %
    % Unidades en milímetros                                            %
    % Longitud_total_del_elemento_en_mm;                                %
        switch ed                                                       %
            case {5,6,9,7}                                              %
                Long = 5000;                                            %
            case {1,3}                                                  %
                Long = 4000;                                            %
            case {2, 4}                                                 %
                Long = 3000;                                            %
        end                                                             %
    D       = 600;      % Diametro_de_elemento_tubular_en_mm;           %
    t       = 25.4;     % Espesor_en_mm;                                %
    L_D     = Long;     % longitud dañada_en_mm;                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function SAPMIAdentboth
    % reading data files
    pathfile = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0_120623.xlsx';

    % reading input data
    nodes       = xlsread(pathfile,'nudos');
    elements    = xlsread(pathfile,'conectividad');
    [propgeom,txtpg] = xlsread(pathfile,'prop geom');
    fixnodes    = xlsread(pathfile,'fix nodes');
    nodeforces  = xlsread(pathfile,'node forces');
    uniformload = xlsread(pathfile,'uniform load');
    pload       = xlsread(pathfile,'puntual load');
    vxz         = xlsread(pathfile,'vxz');
    masses      = xlsread(pathfile,'masses');
    modespar    = xlsread(pathfile,'modes');
    dynload     = xlsread(pathfile,'dynload');
    damage      = xlsread(pathfile,'damage');
    propdent    = xlsread(pathfile,'prop dent');

    % eliminating node numbers
    fixn = fixnodes(:,2:end)';

    % total number of nodes
    nnodes = length(nodes(:,1));

    fixt=zeros(nnodes,6);
    % adding non fix nodes
        % GDL a nudos libres
    for l = 1 : length(fixnodes(:,1))
        indxfix = find(fixnodes(l,1)==nodes(:,1));
        indxfixo = find(indxfix==fixnodes(:,1));
        fixt(indxfix,:)=fixn(:,indxfixo)';
    end

    fixn = fixt';
    % indexes of non fix and fix nodes
    indx0 = find(fixn==0);
    indx1 = find(fixn==1);

    k = 0;
    [m,n] = size(fixn);
    ID = zeros(m,n);

    %sorting element numbers
        % Ordena los no. de elementos
    [B,IN]=sort(elements(:,1));


    % creating ID matrix
        % Ciclos para definir los grados de libertad de cada elemento. 
        % Todos los grados de libertad de cada nodo que no están restringidos, 
        % los numera en orden consecutivo 1,2,3,…,n. 
        % Mientras los que sí lo están restringidos les da números negativos
    for i = 1:length(indx0)
        ID(indx0(i)) = k+1;
        k = k+1;   
    end    

    for i = 1:length(indx1)    
        ID(indx1(i)) = (k+1)*(-1);
        k = k+1;    
    end

    % geometrical properties
    NE = length(elements(:,1));
    A  = propgeom(:,2);
    %%%%%%%%%%%
    Iy = propgeom(:,3);
    Iz = propgeom(:,4);
    %%%%%%%%%%%
    J = propgeom(:,5);
    E = propgeom(:,6);
    G = propgeom(:,7);
    tipo = txtpg(3:end,8);
    radio = zeros(size(propgeom(:,10)));
    b = zeros(size(propgeom(:,10)));
    h = zeros(size(propgeom(:,10)));
    trec = zeros(size(propgeom(:,10)));
    for i = 1:length(propgeom(:,10))
        if strcmp(tipo(i),'circular')
            radio(i) = propgeom(i,9);
        elseif strcmp(tipo(i),'rectangular')
            b(i) = propgeom(i,9);
            h(i) = propgeom(i,10);
            trec(i) = propgeom(i,11);
        end
    end
        % **Puntos importantes**
        % 
        % - En las líneas del momento de inercia, es importante ver a detalle de que es un solo dato por elemento,
            % pero el dr. Rolando asegura que cada valor se concatena en una matriz.
        % - Él sugiere y asegura que hacer otra pestaña con las inercias calculadas del elemento abollado debe funcionar
        % - El comando “propgeom” no es más que una matriz. 
        %   En la línea 18 hay un comando donde lee todos los datos de la pestaña “prop geom”  de un Excel


    %% Dent properties
        % Condicional que asigna valores de daño existentes o nulos
    if isempty(propdent)==1
        eledent = [];
        Adent   = [];
        Iydent  = [];
        Izdent  = [];
        Jdent   = [];
        x1dentr = [];
        x2dentr = [];
    else
        eledent = propdent(:,1);
        Adent   = propdent(:,2);
        Iydent  = propdent(:,3);
        Izdent  = propdent(:,4);
        Jdent   = propdent(:,5);
            % Las dos variables siguientes le asigna las distancias de la abolladura, 
            % ya que se consideró una abolladura de forma trapezoidal
        x1dentr = propdent(:,6);
        x1dentr = propdent(:,7);
    end

    %% damage properties
        % En caso de que la condicional de dent properties no sea verdadero, 
        % las propiedades del daño son asignadas a continuación:
    if isempty(damage)==1
        damele = [];
        xdcr = [];
        depthr = [];
    else
        damele = damage(:,1);
        xdcr = damage(:,2);
        depthr = damage(:,3);
    end

    % ID es un índice que almacena y clasifica los valores máximos de GDL de cada elemento. 
    % Recordar que los ID negativos son los que están restringidos. 
    % NEn cuenta todos los nodos restringidos.
    IDmax  = max(max(ID));
    IDmin  = abs(min(min(ID)));
    indxdp = find(ID>0);
    indxdn = find(ID<0);

    NEn    = length(find(ID<0));
    
    %% Proceso de ensamblaje de KG (Matriz de rigidez global)        
        % Son inicialmente matrices de ceros, 
        % cuyas dimensiones son los GDL máximos, 
        % calculados en el paso anterior
    KG     = zeros(IDmax,IDmax);
    KGtu   = zeros(IDmax,NEn);  % KGtu = Matriz de rigidez global con reacciones
    % Ciclo de ensamblaje
    for i = 1:NE %  NE = length(elements(:,1)); -> representa el número de elementos totales
        KGf   = zeros(IDmax,IDmax);
        KGtuf = zeros(IDmax,NEn);
        % Length of the elements
            % L(i) es el cálculo de las longitudes de cada elemento
            % CZ(i), CY(i), CX(i) son vectores unitarios de cada nodo. 
            % La variable CXY(i) es la distancia de esos vectores unitarios, 
            % que tendría que equivaler a 1.
        L(i) = sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2+...
                (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2+...
                (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);

        CZ(i)  = (nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
        CY(i)  = (nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
        CX(i)  = (nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
        CXY(i) = sqrt(CX(i)^2+CY(i)^2);

        % Proceso de localización del daño.
        locdam  = find(damele==i,1);
        locdent = find(eledent==i, 1);
        if isempty(locdam) && isempty(locdent)
            % local stiffness matrix of the elements
            ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i)); % Matrices de rigideces locales de cada elemento.
        elseif isempty(locdent)
            xdc = xdcr(locdam)*L(i);    % Localiza el daño
            % condicional para elegir el tipo de sección circular o rectangular
            if strcmp(tipo(i),'circular')
                depthr1 = depthr(locdam)*radio(i);
                ke(:,:,i) = ZhengcircT(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i));
            elseif strcmp(tipo(i),'rectangular')
                depthr1 = depthr(locdam)*h(i);
                ke(:,:,i) = Zhengrectub(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),h(i),b(i),trec(i));  
            end     
        elseif isempty(locdam)
             ident = eledent(locdent);
             x1dent = x1dentr*L(ident);
             x2dent = x2dentr*L(ident);
             % Localiza la parte de la localización de la abolladura 
             % y además realiza una integración de elementos finitos de una sección variable.
             ke(:,:,i) = FEMdent(L(ident),Adent(locdent),Izdent(locdent),...
                        Iydent(locdent),Jdent(locdent),A(ident),Iz(ident),Iy(ident),...
                        J(ident),x1dent,x2dent,E(ident),G(ident))         
        end

        % Orientación de los ejes locales
        vxzl(:,i) = vxz(i,2:end);      % xvzl = Vecxzl. l es de local
        % Para más información revisar: 
        %       https://opensees.berkeley.edu/OpenSees/manuals/usermanual/237.htm
                % Dentro de la página, se refiere que a que la especificación de los componentes X, Y y Z del vector vecxz que se utiliza para definir el plano local x-z del sistema de coordenadas local. El eje y local se define mediante el producto cruz de este vector vecxz y el eje x local. 
                % Estos componentes se especifican en el sistema de coordenadas global X, Y, Z y definen un vector que está en un plano paralelo al plano x-z del sistema de coordenadas local.
                % Todo esto es importante en un problema tridimensional en el que se necesita especificar la matriz de transformación que permita la conversión de elementos de coordenadas locales a globales. En resumen, el texto describe los elementos necesarios para definir el sistema de coordenadas local y su relación con el sistema de coordenadas global.
                % También comenta que: El sistema de coordenadas del elemento se especifica de la siguiente manera: El eje x es el eje que conecta los dos nodos del elemento; los ejes y y z se definen utilizando un vector que se encuentra en un plano paralelo al plano local x-z, llamado vecxz. El eje y local se define tomando el producto cruz del vector vecxz y el eje x. La sección se adjunta al elemento de tal manera que el sistema de coordenadas y-z utilizado para especificar la sección corresponde a los ejes y-z del elemento.

        [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));

        %alpha=pi/4;

        % Transformation matrix 3D
            % Matriz de continuidad - transforma las coordenadas locales a globales.
        LT(:,:,i) = TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha); % LT = Linear transformation


        % global stiffnes matrix of the elements  
        kg(:,:,i) = LT(:,:,i)'*ke(:,:,i)*LT(:,:,i);

        LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];

        indxLV  = find(LV(:,i)>0);
        indxLVn = find(LV(:,i)<0);

        % assamblage general stiffness matrix
        KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i);
        KGtuf(LV(indxLV,i),LV(indxLVn,i)*(-1)-IDmax) = kg(indxLV,indxLVn,i);
        KG = KGf + KG;
        % stiffness matrix for reactions
        KGtu = KGtuf + KGtu;
        % Limpieza de variables para que, según el dr. Rolando, no se vicie:
        clear KGf;
        clear KGtuf;
    end
    KG
% KG_undamage = KG
% 
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
%                 keq = [keq(1:6, 1:6)          zeros(6,6)  zeros(6,6)  keq(end-5:end, end-5:end);...
%                         zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                         zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                         keq(end-5:end, 1:6)    zeros(6,6)  zeros(6,6)  keq(end-5:end, end-5:end)];
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
        % _new = nueva usada para para construir la matriz global dañada

% ke_d = funcion_abulladura_longitudinal_120623(ed, porcent, Long, D, t, L_D);
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
% %% Ejercicio de Marco 3D para comprobar matrices de rigidez
% P = [9000;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
% % Fx Fy Fz Mx My Mz
% d_d = (KG_damage^(-1)) * P
% d_u = (KG_undamage^(-1)) * P
% 
% %% Fuerzas sobre la estructura y la matriz de masas
%     % En esta sección se realiza el ensamble global de las fuerzas en cada nudo de toda la estructura. 
%     % Generalmente se manejan pocas cargas fuerzas y 
%     % por tanto la matriz contiene ceros en la mayoría de sus elementos, 
%     % excepto donde haya fuerzas externas aplicadas.
%     Pnodes = zeros(IDmax,1);    % Vector de fuerzas externas que inicia siendo una matriz identidad con ceros
%     % assamblage of node forces
%     if isempty(nodeforces)==0
%         for j = 1:length(nodeforces(:,1))
%             LVnodes(:,j) = [ID(:,nodeforces(j,1))];
% 
%             Pnodes(LVnodes(:,j)) = nodeforces(j,2:end);
%         end
%     end
%     %  mass matrix
%         % La matriz de masas. En las siguientes líneas, la convierte de un vector a una matriz
%         % Matriz cuadrada y simétrica. Las masas están concentradas en los nudos
%         % y tienen sus GDL en x,y,z
%     Mass = zeros(IDmax,IDmax);
%     for j = 1:length(masses(:,1))
%         indxLV = find(ID(:,j)>0);
%         LVnodes = [ID(indxLV,masses(j,1))];
%         if isempty(LVnodes)==0
%           Mass(LVnodes,LVnodes) = diag(masses(j,indxLV+1)); 
%         end
%     end
%     % Fuerzas de empotramiento perfecto
%         % Lo transfiere a los nudos cuando se trata de cargas distribuidas
%     % uniform distributed load
%     FEMG = zeros(1,IDmax);
%     FEMGu = zeros(1,NEn);
%     FEMGup = zeros(1,NEn);
%     if isempty(uniformload)==0
%         for i = 1:length(uniformload(:,1))
%             FEMGf = zeros(1,IDmax);
%             FEMGuf = zeros(1,NEn);
%             Li = L(IN(uniformload(i,1)));
%             Fex = uniformload(i,2)*Li/2;
%             Fey = uniformload(i,3)*Li/2;
%             Fez = uniformload(i,4)*Li/2;
%             Mez = uniformload(i,3)*Li^2/12;
%             Mey = uniformload(i,4)*Li^2/12;
% 
%             % Ensamble del vector local de fuerzas
%             FEMew(:,i) = [-Fex,-Fey,-Fez,0,Mey,-Mez,-Fex,-Fey,-Fez,0,-Mey,Mez];
% 
%             % Transformación de ejes locales a globales
%             FEMgw(:,i) = LT(:,:,IN(uniformload(i,1)))'*FEMew(:,i);
% 
%             % Suma de todos los elementos
%             LVF = LV(:,IN(uniformload(i,1)));
%             indxLVF = find(LVF>0);
%             indxLVn = find(LVF<0);
%             FEMGf(LVF(indxLVF)) = FEMgw(indxLVF,i); 
%             FEMGuf(LVF(indxLVn)*(-1)-IDmax) = FEMgw(indxLVn,i);
%             % Nudos libres y nudos restringidos
%             FEMG  = FEMGf+FEMG;
%             FEMGu = FEMGuf+FEMGu;
%             clear FEMGf;
%             clear FEMGuf;
% 
%         end
%     end
%     % Concentrated load between nodes
%         % Calcula las fuerzas de empotramiento perfecto 
%     if isempty(pload)==0
%         for i = 1:length(pload(:,1))
%             FEMGp = zeros(1,IDmax);
%             Li = L(IN(pload(i,1)));
%             ay = pload(i,4)*Li;
%             az = pload(i,5)*Li;
%             by = Li-ay;
%             bz = Li-az;
% 
%             Peiy = pload(i,2)*by^2/Li^2*(3-2*by/Li);
%             Pejy = pload(i,2)*ay^2/Li^2*(3-2*ay/Li);
%             Meiz = pload(i,2)*ay*by^2/Li^2;
%             Mejz = pload(i,2)*by*ay^2/Li^2;
% 
%             Peiz = pload(i,3)*bz^2/Li^2*(3-2*bz/Li);
%             Pejz = pload(i,3)*az^2/Li^2*(3-2*az/Li);
%             Meiy = pload(i,3)*az*bz^2/Li^2;
%             Mejy = pload(i,3)*bz*az^2/Li^2;
% 
%             % Ensable de fuerzas en cordenadas locales y globales
%             % para cada elemento y hace un solo vector grande
%             % local FEM element
%             FEMep(:,i) = [0,-Peiy,-Peiz,0,Meiy,-Meiz,0,-Pejy,-Pejz,0,-Mejy,Mejz];
%             % global FEM element    
%             FEMgp(:,i) = LT(:,:,IN(pload(i,1)))'*FEMep(:,i);
%             % global FEM structure
%             LVF = LV(:,IN(pload(i,1)));
%             indxLVF = find(LVF>0);
%             indxLVn = find(LVF<0);
%             FEMGp(LVF(indxLVF)) = FEMgp(indxLVF,i); 
%             if isempty(indxLVn)==1
%                 FEMGup = zeros(1,NEn);
%             else
%                 FEMGup(LVF(indxLVn)*(-1)-IDmax) = FEMgp(indxLVn,i);
%             end
%             FEMG = FEMGp + FEMG;
%             FEMGu = FEMGup + FEMGu;
%             clear FEMGp;
%             clear FEMGup;
%         end
%     end    
%     % net global external force
%         % Este apartado tiene que ver con el cálculo de las fuerzas de estado I y II
%     NForce = Pnodes-FEMG';
%     % global displacements structure
%     DeltaG = (KG^(-1))*NForce;
%     % global reactions
%     React = KGtu'*DeltaG+FEMGu';
%     % Element internal forces
%     Deltag = zeros(6,NE);
%     for i=1:NE
%     indxLV=find(LV(:,i)>0);
%     Deltag(indxLV,i)=DeltaG(LV(indxLV,i));
%     Fi(:,i)=ke(:,:,elements(i,1))*LT(:,:,i)*Deltag(:,i);
% end
% 
% %% Locate global displacements
% DeltaGo = zeros(IDmin,1);
% DeltaGo(indxdp,1) = DeltaG;
% 
% %% Determination of mode shapes and circular frecuencies
% % Undameged
%     [phi,omega] = modes(KG,Mass,modespar,ID);   % Función donde está la:
%                                                 % CONDENSACIÓN ESTÁTICA y los eigendatos
%     Tn = 2*pi./omega;
%     fn = 1./Tn;
%     numodes = modespar(1,1);
%     phio = zeros(IDmin,numodes);
%     phio(indxdp,:) = phi; % phi es la forma modal.
%         % Coloca ceros donde está restringido 
%         % los restantes (los nodos libres) calcula la forma modal
%         % Cuenta con un comando para "dibujar" las formas modales si es necesario.
%         % MPF considera los factores de participación modal.
% 
%     % modal participation factor
% 
%     [MPx,MPy,MPz]=MPf(phi,Mass,ID);
% 
%     %% Función para dibujar los modos de vibrar de la estructura
%     drawmodes(nodes,elements,phio,Tn)
%     % Resultados
%     % Especificar el nombre del archivo de Excel
%     archivo_excel = 'E:\Archivos_Jaret\Mis_modificaciones\Resultados\Resultados_undamage.xlsx';
% 
%     % Escribir la matriz en la primera hoja de Excel
%     hoja_matriz = 'phi';
%     xlswrite(archivo_excel, phi, hoja_matriz);
    
%     % Escribir el vector en la segunda hoja de Excel
%     hoja_vector = 'omega';
%     xlswrite(archivo_excel, omega, hoja_vector);

% % Damaged
%     [phi,omega] = modes(KG_damage,Mass,modespar,ID);   % Función donde está la:
%                                                 % CONDENSACIÓN ESTÁTICA y los eigendatos
%     Tn = 2*pi./omega;
%     fn = 1./Tn;
%     numodes = modespar(1,1);
%     phio = zeros(IDmin,numodes);
%     phio(indxdp,:) = phi; % phi es la forma modal.
%         % Coloca ceros donde está restringido 
%         % los restantes (los nodos libres) calcula la forma modal
%         % Cuenta con un comando para "dibujar" las formas modales si es necesario.
%         % MPF considera los factores de participación modal.
%     
%     % modal participation factor
%     
%     [MPx,MPy,MPz] = MPf(phi,Mass,ID);
%     
%     %% Función para dibujar los modos de vibrar de la estructura
%     drawmodes(nodes,elements,phio,Tn)
%     % Resultados
%     % Especificar el nombre del archivo de Excel
%     archivo_excel = 'E:\Archivos_Jaret\Mis_modificaciones\Resultados\Resultados_damage.xlsx';
%     
%     % Escribir la matriz en la primera hoja de Excel
%     hoja_matriz = 'phi';
%     xlswrite(archivo_excel, phi, hoja_matriz);
%     
%     % Escribir el vector en la segunda hoja de Excel
%     hoja_vector = 'omega';
%     xlswrite(archivo_excel, omega, hoja_vector);

% %% Dynamic response
% fi = dynload(1,1);
% dt = dynload(2,1);
% TDuration = dynload(end,1);
% forcet = dynload(5:end,2:end);
% fdir = dynload(1,2:end);
% fnodes = dynload(2,2:end);
% u0i = dynload(3,2:end);
% v0i = dynload(4,2:end);
% [Ntime,Ntr] = size(forcet);
% force = zeros(Ntime,IDmax);
% force(:,diag(ID(fdir,fnodes))) = forcet;
% u0 = zeros(1,IDmax);
% v0 = zeros(1,IDmax);
% u0(1,diag(ID(fdir,fnodes))) = u0i;
% v0(1,diag(ID(fdir,fnodes))) = v0i;
% 
% [u,v,ac] = Wilson1(dt,TDuration,Mass,phi,fi,force,omega,u0,v0);
    
    
% %% Eliminating file extension
% dotLocations = find(file == '.');
% if isempty(dotLocations)
%     % No dots at all found so just take entire name.
%     outfile = file;
% else
%     % Take up to , but not including, the first dot.
%     outfile = file(1:dotLocations(1)-1);
% end
% 
% % creating output file
% outfile = strcat(outfile,'damresults');
% 
% % variables to be saved
% results = 'DeltaG DeltaGo Fi React KG ke kg Pnodes Mass fn LT ID L CX CY CZ FEMG NForce phi phio Tn u v ac ;';
% 
% %saving main results to output file
% eval(['save ' outfile '  ' results ]);

