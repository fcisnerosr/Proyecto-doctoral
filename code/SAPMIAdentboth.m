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
    % no_elemento_a_danar = [2];
    % caso_dano           = {'abolladura'};
    % dano_porcentaje     = [30];
    
    no_elemento_a_danar = [2, 74, 102];
    caso_dano           = {'abolladura', 'corrosion', 'abolladura'};
    dano_porcentaje     = [30 30 30];


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
    
%%
clc
clearvars -except archivo_excel tirante tiempo d_agua densidad_crec pathfile no_elemento_a_danar caso_dano dano_porcentaje coordenadas vxz conectividad prop_geom matriz_restriccion matriz_cell_secciones masas_en_cada_nodo M_cond NE IDmax NEn elements nodes damele eledent A Iy Iz J E G ID KG KGtu hoja_excel vigas_long brac_long col_long num_de_ele_long

f_AA_d  = zeros(6, 6, length(no_elemento_a_danar));        % Matrices de cero de flexibilidad
ke_d    = zeros(12, 12, length(no_elemento_a_danar));      % Matrices de cero de rigidez de cada elemento con abolladura

for i = 1:length(no_elemento_a_danar) % Inicio del primer for
    if strcmp(caso_dano{i}, 'corrosion') % Inicio del primer if
        [ke_d, elem_con_dano_long_NE, f_AA_d] = corrosionlocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J, f_AA_d)

    elseif strcmp(caso_dano{i}, 'abolladura') % Inicio del primer elseif
        
        index = find(num_de_ele_long(:,1) == i);
        long_elem_a_danar = num_de_ele_long(index,2);
        prop_geom_mat = cell2mat(prop_geom);
        espesor_elem_a_danar = prop_geom_mat(no_elemento_a_danar(i),10);

        D(i) = prop_geom_mat(no_elemento_a_danar(i),8);
        L_D(i) = long_elem_a_danar;
        Long(i) = long_elem_a_danar;
        z_s(i) = dano_porcentaje(i) * D(i) / 100;
        Nseg = 1000;
        lim = 0.003;

        t(i) = espesor_elem_a_danar;
        R(i) = 0.5 * D(i) - (0.5*t(i));
        A1(i) = pi * D(i)^2 * 0.25;
        D_interior(i) = D(i) - (t(i)*2);
        A2(i) = pi * D_interior(i)^2 * 0.25;
        Area(i) = A1(i) - A2(i);

        E = cell2mat(prop_geom(1,6));
        mu= 0.28;
        G = E/(2*(1+mu));
        J = pi/2 * ((0.5*D(i))^4 - (R(i))^4);

        if dano_porcentaje(i) > 50 % Inicio del segundo if
            fprintf('\n********************************************************** \n')
            fprintf('***La abolladura no puede ser más del 50%% del diámetro**** \n')
            fprintf('********************************************************** \n\n')
            error('La abolladura excede el 50%% del diámetro. La ejecución se detiene.')
        end % Fin del segundo if

        Slong = 5;
        x = 0;
        for j = 1:Slong % Inicio del segundo for
            x = x + L_D(i)/Slong;
            V(j) = x/L_D(i);
            Vz_s(j) = z_s(i) * sin(pi*V(j));
        end % Fin del segundo for
        Vz_s = Vz_s(1:end-1);

        % Ciclo para el cálculo de cada momento de inercia en cada sección de abolladura
        for p = 1:length(Vz_s) % Inicio del tercer for
            % Datos de abolladura
            P = 2*pi*R(i);
            z_i = R(i) - Vz_s(p);
            z_dent = z_i + R(i);
            theta = acosd(z_i/R(i));
            theta = 2*theta;
            cuerda = sqrt(R(i)^2 - z_i^2);
            cuerda = 2*cuerda;
            L1 = theta * pi/180 * R(i);
            L2 = L1;
            delta = L2 - cuerda;
            delta = 0.5 * delta;
            % Gráfica de sección abollada y sin daño
            Circ = zeros(Nseg, 2, 2); % Matriz de ceros donde ir incluyendo los valores del círculo
            Lseg = P / Nseg; % Longitud (perímetro) discretizado
            Alpha = 0 : 360 / Nseg : 360; % Diferentes valores de PI discretizados

            % Cálculo de curva Z del círculo dañado
            for j = 1 : Nseg + 1 % Inicio del cuarto for
                % Círculo sin daño
                Yi = R(i) * cosd(Alpha(j)); % Altura de circunferencia
                Zi = R(i) * sind(Alpha(j)); % Anchura de circunferencia
                Circ(j, 1, 1) = Yi; % Almacenamiento de valores de la altura de circunferencia
                Circ(j, 1, 2) = Zi; % Almacenamiento de valores de la anchura de circunferencia
                % Círculo con daño
                if Alpha(j) > 90 && Alpha(j) < 270 % Inicio del tercer if
                    Sig = -1;
                else
                    Sig = 1;
                end % Fin del tercer if
                if Zi > z_i % Inicio del cuarto if
                    Circ(j, 2, 1) = Circ(j-1, 2, 1) - Lseg; % Lseg = Longitud (perímetro) discretizado
                    Circ(j, 2, 2) = z_i;
                else
                    Yi = R(i) * cosd(Alpha(j)); % Altura de circunferencia sin daño (solo para traer el dato)
                    Zi = R(i) * sind(Alpha(j)); % Anchura de circunferencia sin daño (solo para traer el dato)
                    Circ(j, 2, 1) = Yi + delta * sin(((pi/2) / (z_dent)) * (Zi + R(i))) * Sig;
                    Circ(j, 2, 2) = Zi;
                end % Fin del cuarto if
            end % Fin del cuarto for
            % Cálculo de la longitud de la curva inferior
            % Mitad de curva izquierda, desde la cuerda hasta R
            % Tratamiento de vector en Y y Z
            for w = 1:Nseg % Inicio del quinto for
                if Circ(w,2,2) < z_i && Circ(w,2,1) < 0 % Inicio del quinto if
                    V_z(w) = Circ(w,2,2);
                    V_y(w) = Circ(w,2,1);
                end % Fin del quinto if
            end % Fin del quinto for
            % Longitud
            for w = 1:length(V_z)-1 % Inicio del sexto for
                if V_y(w) ~= 0 % Inicio del sexto if
                    Li = sqrt((V_y(w+1) - V_y(w))^2 + (V_z(w+1) - V_z(w))^2);
                    L_c(w) = Li;
                end % Fin del sexto if
            end % Fin del sexto for
            L_c = sum(L_c); % Suma de las longitudes

            % Longitud inferior completa
            L_c = 2 * L_c;

            % Cálculo correcto de delta
            % delta = ensachamiento de cada lado
            % fórmula a iterar:
            %%% ec = L_c + cuerda + 2*delta = P;
            ec = L_c + cuerda + 2*delta;
            error = abs(P-ec);
            kj = 1;
            kx = 5;

            while error > lim % Inicio del primer while
                delta = delta - lim;
                ec = L_c + cuerda + 2*delta;
                error = abs(P-ec);
                V_error(kj) = error;
                kj = kj+1;
                if kj > kx && V_error(2) > V_error(1) % Inicio del séptimo if
                    while error > lim % Inicio del segundo while
                        delta = delta + lim;
                        ec = L_c + cuerda + 2*delta;
                        error = abs(P-ec);
                        V_error(kj) = error;
                        kj = kj+1;
                    end % Fin del segundo while
                end % Fin del séptimo if
            end % Fin del primer while
            % fprintf('Ensanch_de_cada_lado = %5.2f cm\n',delta) 

            Circ = zeros(Nseg, 2, 2); % Matriz de ceros donde ir incluyendo los valores del círculo
            Lseg = P/Nseg; % Longitud (perímetro) discretizado
            Alpha = 0 : 360 / Nseg : 360; % Diferentes valores de PI discretizados
            % Gráficas finales
            for w = 1 : Nseg + 1 % Inicio del séptimo for
                % Círculo sin daño
                Yi = R(i) * cosd(Alpha(w)); % Altura de circunferencia
                Zi = R(i) * sind(Alpha(w)); % Anchura de circunferencia
                Circ(w, 1, 1) = Yi; % Almacenamiento de valores de la altura de circunferencia
                Circ(w, 1, 2) = Zi; % Almacenamiento de valores de la anchura de circunferencia

                % Círculo con daño
                if Alpha(w) > 90 && Alpha(w) < 270 % Inicio del octavo if
                    Sig = -1;
                else
                    Sig = 1;
                end % Fin del octavo if
                if Zi > z_i % Inicio del noveno if
                    Circ(w, 2, 1) = Circ(w, 2, 1) - Lseg; % Lseg = Longitud (perímetro) discretizado
                    Circ(w, 2, 2) = z_i;
                else
                    Yi = R(i) * cosd(Alpha(w)); % Altura de circunferencia sin daño (solo para traer el dato)
                    Zi = R(i) * sind(Alpha(w)); % Anchura de circunferencia sin daño (solo para traer el dato)
                    Circ(w, 2, 1) = Yi + delta * sin(((pi/2) / (z_dent)) * (Zi + R(i))) * Sig;
                    Circ(w, 2, 2) = Zi;
                end % Fin del noveno if
            end % Fin del séptimo for
            % Cálculo de centroide
            % Promedio de todas las alturas en ambas direcciones.
            c_y = 0;
            c_z = mean(Circ(:,2,2));

        % Cálculo de momentos de inercia
	    % Cálculo de ángulo de cada elemento diferencial
			    % Cuadrante I
			    j = 1;
			    for ii = 1 : Nseg + 1
				    Vy_I(j) = Circ(j,2,1);
				    Vz_I(j) = Circ(j,2,2);        
				    j = j+1;            
				    if Circ(j,2,2) == z_i
					    break
				    end
			    end
			    Vz_Ic = Vz_I;
			    Vy_Ic = Vy_I;
			    % Ciclo para: 
			    % realizar un vector con las longitudes de cada vector
			    % calcular ángulos y almacenarlos en en el vector V_ang_I y el vector de distancias al centroide global de la sección transversal
			    k = 1;
			    for ii = 1 : length(Vz_Ic)-1					
				    % Distancia de cada elemento diferencial
				    L_I(ii) = (((Vz_Ic(ii+1)) - Vz_Ic(ii))^2 + ((Vy_Ic(ii+1)) - Vy_Ic(ii))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    % Distancias necesarias para el cálculo del ángulo
				    V_longy_I(ii) = Vy_Ic(k) - Vy_Ic(k+1);
				    % Cálculo del ángulo de cada elemento diferencial
				    V_ang_I(ii) = acosd(V_longy_I(ii)/L_I(ii));
				    k = k+1;
				    % Cálculo de las distancias de los centroides de cada elemento diferencial al centroide global de la sección
				    % dy_I = distancia paralela a Y del centroide global al centroide local de cada elemento diferencial
				    % dz_I = distancia paralela a Z del centroide global al centroide local de cada elemento diferencial
				    if ii == 1
					    dy_I(ii) = (L_I(ii)*sind(V_ang_I(ii)) * 0.5) + (c_z*-1);
					    % L_I(ii)*sind(V_ang_I(ii)) es la proyección vertical de cada elemento diferencial, es la distancia vertical de cada elemento diferencial, ésta no es pequeña ni despreciable
					    dz_I(ii) = Circ(ii,2,1) - (L_I(ii)*cosd(V_ang_I(ii)) * 0.5);
					    % L_I(ii)*cosd(V_ang_I(ii)) es la proyección horizontal de cada elemento diferencia, ésta sí tiene valores muy pequeños
				    else
					    dy_I(ii) = Circ(ii,2,2) + (L_I(ii)*sind(V_ang_I(ii)) * 0.5 + (c_z*-1));
					    dz_I(ii) = Circ(ii,2,1) - (L_I(ii)*cosd(V_ang_I(ii)) * 0.5);
                    end
			    end

			    % Cálculo del momento de inercia local
			    for ii = 1:length(V_ang_I)
				    % Momento en y
				    Iy_I(ii) = 1/12 * L_I(ii) * t(i)^3;					
				    % Momento en Z
				    Iz_I(ii) = 1/12 * L_I(ii)^3 * t(i);					
				    % Momento inclinado
				    Iy_prima_I(ii) = ((Iy_I(ii) + Iz_I(ii)) * 0.5) + (((Iy_I(ii) - Iz_I(ii))* 0.5) * cosd(2*V_ang_I(ii)));
				    Iz_prima_I(ii) = ((Iy_I(ii) + Iz_I(ii)) * 0.5) - (((Iy_I(ii) - Iz_I(ii))* 0.5) * cosd(2*V_ang_I(ii)));
				    A_I(ii) = L_I(ii) * t(i);	% Área de cada elemento diferencial 
			    end


			    % Cuadrante II
			    Alpha = 0: 2*pi/Nseg : 2*pi;       % Diferentes valores de PI discretizados
			    j = 1;
			    for ii = 1 : Nseg
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante II mediante un
				    % círculo unitario
				    j = j+1;
				    % Condicional excluye a:
					    % 1.- Valores de coseno positivos
					    % 2.- Valores de seno vayores a 1
					    % 3.- Valores de seno Circ(:,2,2) mayores a z_i
				    if sign(y_uni(j)) == -1 && z_uni(j) < 1 && Circ(j,2,2) < z_i
					    Vy_II(j) = Circ(j,2,1);     % Vector que guarda los elementos del II cuadrante sin considerar la parte achatada
					    Vz_II(j) = Circ(j,2,2);     % Vector que guarda los elementos del II cuadrante sin considerar la parte achatada
				    end
				    if Circ(j,2,2) < 0
					    break
				    end
			    end
			    Vz_II(:,length(Vz_II)) = [];    % Retira el último elemento porque es menor a cero y pertenece al cuadrante III
			    j = 1;
			    r = 1;
			    for ii = 1:length(Vz_II)
				    if Vz_II(ii) ~= 0 & Vy_II(ii) ~= 0 % condicional que elimina todos los ceros de la matriz
					    Vz_IIc(j) = horzcat(Vz_II(ii)); %_c es de corregido, debido a que el anterior vector tenía valores de ceros inservibles
					    Vy_IIc(j) = horzcat(Vy_II(ii)); %_c es de corregido, debido a que el anterior vector tenía valores de ceros inservibles
					    j = j+1;					
				    else
					    r = r + 1;	% número para llegar al siguiente valor en el vector Circ, para el cálculo de la distancia d del teorema de ejes paralelos
				    end
			    end
			    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
			    k = 1;
			    for ii = 1 : (length(Vz_IIc)-1)
				    L_II(ii) = (((Vz_IIc(ii+1)) - Vz_IIc(ii))^2 + ((Vy_IIc(ii+1)) - Vy_IIc(ii))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    V_longy_II(ii) = Vy_IIc(k+1) - Vy_IIc(k); % V_longy_II vector con distancias de proyección horizontal de cada elemento diferencial
				    V_ang_II(ii) = acosd(-V_longy_II(ii)/L_II(ii));
				    k = k+1;
				    % Distancias de los centroides de cada elemento diferencial al centroide global en cada eje
				    dy_II(ii) = Circ(r,2,2) - L_II(ii)*sind(V_ang_II(ii)) * 0.5 + (c_z*-1);
				    dz_II(ii) = Circ(r,2,1) - L_II(ii)*cosd(V_ang_II(ii)) * 0.5;
				    r = r+1;
			    end

			    % Cálculo del momento de inercia local
			    for ii = 1:length(V_ang_II)
				    % Momento en y
				    Iy_II(ii) = 1/12 * L_II(ii) * t(i)^3;					
				    % Momento en Z
				    Iz_II(ii) = 1/12 * L_II(ii)^3 * t(i);					
				    % Momento inclinado
				    Iy_prima_II(ii) = ((Iy_II(ii) + Iz_II(ii)) * 0.5) + (((Iy_II(ii) - Iz_II(ii))* 0.5) * cosd(2*V_ang_II(ii)));
				    Iz_prima_II(ii) = ((Iy_II(ii) + Iz_II(ii)) * 0.5) - (((Iy_II(ii) - Iz_II(ii))* 0.5) * cosd(2*V_ang_II(ii)));
				    A_II(ii) = L_II(ii) * t(i);	% Área de cada elemento diferencial 
			    end

			    % Cuadrante III
			    j = 1;
			    for ii = 1 : Nseg
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante III mediante un círculo unitario
				    j = j+1;
				    if sign(y_uni(j)) == -1 && sign(z_uni(j)) == -1
					    Vy_III(j) = Circ(j,2,1);
					    Vz_III(j) = Circ(j,2,2);
				    end
				    if sign(y_uni(j)) == 0
					    break
				    end
			    end
			    j = 1;
			    for ii = 1:length(Vz_III)
				    if Vz_III(ii) ~= 0
					    Vy_IIIc(j) = horzcat(Vy_III(ii));
					    Vz_IIIc(j) = horzcat(Vz_III(ii));
					    j = j+1;
				    end
			    end
			    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
			    k = 1;
			    % Dist_emerg = (Circ(r,2,2)) - ((L_II(length(V_ang_II)) * sind(180 - V_ang_II(length(V_ang_II))))*-1);  % Esta distancia es el restante de la última pieza del cuadrante II que pasa a los números negativos. Solo se realiza una y su solución es general al no. de Nseg que se manejen.
			    r = r+1;
			    for ii = 1 : (length(Vz_IIIc)-1)
				    L_III(ii) = (((Vz_IIIc(ii+1)) - Vz_IIIc(ii))^2 + ((Vy_IIIc(ii+1)) - Vy_IIIc(ii))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    V_longy_III(ii) = Vy_IIIc(k+1) - Vy_IIIc(k);
				    V_ang_III(ii) = 180 - acosd(-V_longy_III(ii)/L_III(ii));
				    k = k+1;
				    % Cálculo de las distancias de los centroides de cada elemento diferencial al centroide global en cada eje
				    dy_III(ii) = Circ(r,2,2) - (L_III(ii)*sind(V_ang_III(ii)) * 0.5) - c_z;
				    dz_III(ii) = Circ(r,2,1) + (L_III(ii)*cosd(V_ang_III(ii)) * 0.5);
				    r = r+1;
			    end
			    % Cálculo del momento de inercia local
			    for ii = 1:length(V_ang_III)
				    % Momento en y
				    Iy_III(ii) = 1/12 * L_III(ii) * t(i)^3;					
				    % Momento en Z
				    Iz_III(ii) = 1/12 * L_III(ii)^3 * t(i);					
				    % Momento inclinado
				    Iy_prima_III(ii) = ((Iy_III(ii) + Iz_III(ii)) * 0.5) + ((Iy_III(ii) - (Iz_III(ii))* 0.5) * cosd(2*V_ang_III(ii)));
				    Iz_prima_III(ii) = ((Iy_III(ii) + Iz_III(ii)) * 0.5) - ((Iy_III(ii) - (Iz_III(ii))* 0.5) * cosd(2*V_ang_III(ii)));
				    A_III(ii) = L_III(ii) * t(i);	% Área de cada elemento diferencial 
			    end

			    % Cuadrante IV
			    for ii = 1 : Nseg+1
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante II mediante un círculo unitario
				    if sign(y_uni(ii)) == 1 && sign(z_uni(ii)) == -1
					    Vy_IV(ii) = Circ(ii,2,1);     % Vector que guarda los elementos del IV cuadrante sin considerar la parte achatada
					    Vz_IV(ii) = Circ(ii,2,2);     % Vector que guarda los elementos del IV cuadrante sin considerar la parte achatada
				    end
			    end
			    j = 1;
			    for ii = 1:length(Vz_IV)
				    if Vz_IV(ii) ~= 0
					    Vy_IVc(j) = horzcat(Vy_IV(ii));
					    Vz_IVc(j) = horzcat(Vz_IV(ii));
					    j = j+1;
				    end
			    end
			    Vy_IVc(:,length(Vy_IVc)+1) = [delta + R(i)];    % Añade un delta + R(i) al final.
			    Vz_IVc(:,length(Vz_IVc)+1) = [0];			    % Añade un cero al final.
			    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
			    k = 1;
			    r = r+1;
			    for ii = 1 : (length(Vz_IVc)-3)
				    L_IV(ii) = (((Vz_IVc(ii+1)) - Vz_IVc(ii))^2 + ((Vy_IVc(ii+1)) - Vy_IVc(ii))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    V_longy_IV(ii) = Vy_IVc(k+1) - Vy_IVc(k);
				    V_ang_IV(ii) = 180 - acosd(-V_longy_IV(ii)/L_IV(ii));
				    k = k+1;
				    dy_IV(ii) = Circ(r,2,2) + (L_IV(ii)*sind(V_ang_IV(ii)) * 0.5) - c_z;
				    dz_IV(ii) = Circ(r,2,1) + (L_IV(ii)*cosd(V_ang_IV(ii)) * 0.5);
				    r = r+1;
			    end

			    % Cálculo del momento de inercia local
			    for ii = 1:length(V_ang_IV)
				    % Momento en y
				    Iy_IV(ii) = 1/12 * L_IV(ii) * t(i)^3;					
				    % Momento en Z
				    Iz_IV(ii) = 1/12 * L_IV(ii)^3 * t(i);					
				    % Momento inclinado
				    Iy_prima_IV(ii) = ((Iy_IV(ii) + Iz_IV(ii)) * 0.5) + (((Iy_IV(ii) - Iz_IV(ii))* 0.5) * cosd(2*V_ang_IV(ii)));
				    Iz_prima_IV(ii) = ((Iy_IV(ii) + Iz_IV(ii)) * 0.5) - (((Iy_IV(ii) - Iz_IV(ii))* 0.5) * cosd(2*V_ang_IV(ii)));
				    A_IV(ii) = L_IV(ii) * t(i);	% Área de cada elemento diferencial 
			    end


		    % Cálculo del momento de inercia total
		    % Iy_t = Iy_prima + A*d^2; 
			    % Iy_t = Momento de inercia total,
			    % Iy_prima = Momento de inercia local inclinado
		    dy = horzcat(dy_I, dy_II, dy_III, dy_IV); 	% dy es la distancia paralela al eje y de cada elemento diferencial
		    dz = horzcat(dz_I, dz_II, dz_III, dz_IV);	% dz es la distancia paralela al eje z de cada elemento diferencial
		    Iy_prima = horzcat(Iy_prima_I, Iy_prima_II, Iy_prima_III, Iy_prima_IV); % Momento de inercia inclinado de cada elemento diferencial paralelo al eje y
		    Iz_prima = horzcat(Iz_prima_I, Iz_prima_II, Iz_prima_III, Iz_prima_IV);	% Momento de inercia inclinado de cada elemento diferencial paralelo al eje z
		    VA = horzcat(A_I, A_II, A_III, A_IV);		% Área de todos los elementos diferenciales
		    for ii = 1 : length(dy)-1
			    Iy_t = Iy_prima(ii) + (VA(ii) * dy.^2);
			    Iz_t = Iz_prima(ii) + (VA(ii) * dz.^2);
		    end

		    % Parte achatada
		    L_ach = cuerda + 2*delta;	% Longitud de parte achatada
		    Iy_ach= 1/12 * L_ach * t(i)^3;	% Momento de inercia paralelo al eje y
		    Iz_ach= 1/12 * L_ach^3 * t(i);	% Momento de inercia paralelo al eje z
		    A_ach = L_ach*t(i);			% Área parte achatada
		    d_acha = z_i + (c_z*-1);
		    Iy_achatada_centro = Iy_ach + (A_ach * d_acha^2);
		    Iz_achatada_centro = Iz_ach;

		    % Momento de inercia dañado
		    Iy_t_damaged = sum(Iy_t) + Iy_achatada_centro; 	% prefijo _t es de total
		    Iz_t_damaged = sum(Iz_t) + Iz_achatada_centro;

		    % Momento de inercia sin daño
		    R_ext(i) = 0.5*D(i);
		    I_ext = pi/4 * R_ext(i)^4;
		    R_int(i) = (0.5*D(i)) - t(i);
		    I_int = pi/4 * (R_int(i))^4;
		    I_undamaged = I_ext - I_int;
		    % I_undamaged es igual en el sentido Y y Z
		    % Diferencias y porcentajes de reducción en Y
		    Dif_y = (Iy_t_damaged - I_undamaged);
		    Porcentaje_reduccion_y = Dif_y*100 / I_undamaged;
		    % % Diferencias y porcentajes de reducción en Z
		    Dif_z = (Iz_t_damaged - I_undamaged);
		    Porcentaje_reduccion_z = Dif_z*100 / I_undamaged;

%     		% Propiedades del momento de inercia
%     		fprintf(' \n')
%     		fprintf('** Momentos de inercia ** \n')	
%     		fprintf('	** Paralelo al eje Y ** \n')	
%     		fprintf('	Iy_intacta = %1.2f cm^4 \n',I_undamaged)
%     		fprintf('	Iy_dañada  = %1.2f cm^4 \n',Iy_t_damaged)
%     		fprintf('	Reducción  = %1.2f%% \n\n',abs(Porcentaje_reduccion_y))
%     		fprintf('	** Paralelo al eje Z ** \n')
%     		fprintf('	Iz_intacta = %1.2f cm^4 \n',I_undamaged)
%     		fprintf('	Iz_dañada  = %1.2f cm^4 \n',Iz_t_damaged)
%     		if Iz_t_damaged > I_undamaged
%     			fprintf('	Aumento  = %1.2f%% \n',abs(Porcentaje_reduccion_z))
%     		else
%     			fprintf('	Reducción  = %1.2f%% \n',abs(Porcentaje_reduccion_z))
%     		end

        VIy(p) = Iy_t_damaged;
	    VIz(p) = Iz_t_damaged;

        %%%% R E C O R D A T O R I O %%%%
        % En SAP2000, 
            % El eje y es el 3, mientras que...
            % El eje z es el 2.


        % El código arrastra algunos valores en cada ciclo y tenía errores en los cálculos de los momentos de inercia,
        % fue necesario borrar todas las variables en cada ciclo con excepción de las siguientes variables:
            clearvars -except Long D t L_D R Area G J E z_s Lseg Nseg x V Vz_s i L P p pi z_i z_dent theta cuerda L1 L2 delta Circ Yi Zi Alpha Sig lim VIy VIz I_undamaged Slong prop_geom t_corro t_d D_d R_d A1_d R_interior_d A2_d A_d long_elem_con_dano hoja_excel datos_para_long elementos_y_long no_elemento_a_danar elem_con_dano_long_NE index ceros_agregar mat_zero ke_d R_ext_d I_ext_d I_int_d I_d archivo_excel tirante tiempo d_agua densidad_crec pathfile caso_dano dano_porcentaje coordenadas vxz conectividad matriz_restriccion matriz_cell_secciones masas_en_cada_nodo M_cond NE IDmax NEn elements nodes damele eledent Iy Iz ID KG KGtu vigas_long brac_long col_long num_de_ele_long f_AA_d

        end % Fin del ciclo for que va iterando sobre cada sección longitudinal del elemento i (elemento tubular con daño)

        % Polinomio del momento de inercia de la sección
        % VIyy = zeros(length(VIy),1)'
        VIy = horzcat(I_undamaged,VIy,I_undamaged); % en mm^4
        VIz = horzcat(I_undamaged,VIz,I_undamaged); % en mm^4
        x_f = 0 : L_D/Slong : L_D;          % Distancia longitudinal acumulada de L_D

        % Momento de inercia en Y    
        % Ajuste de curva para la sección abollada
        grado = 4;
        poly_y = polyfit(x_f, VIy, grado);      % Ajusta a la función sin a un conjunto de datos mediante mínimos cuadrados % poly = polyfit(x, y, grado) % polyfit arroja los polinomios

        % Interacción del cortante Vz,Vz en A y B, usado en f_33
        ec_y_03_03 = @(x) x.^2 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción del momento My,My en A y B, usado en f_22
        ec_y_05_05 = @(x) 1 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));

        % Momento de inercia en Z    
        % Ajuste de curva para la sección abollada
        poly_z = polyfit(x_f, VIz, grado);
         % Interacción del cortante Vy,Vy en A y B, usado en f_22            
        ec_z_02_02 = @(x) x.^2 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));            
        % Interacción del momento Mz,Mz en A y B, usado en f_66
        ec_z_06_06 = @(x) 1 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        
        % en A,A y B,B
        % Interacción del momento My,Vz en A, usado en f_05_03 y en f_03_05
        ec_y_03_05 = @(x) -x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        ec_y_05_03 = @(x) -x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción del momento My,Vz en A, usado en f_02_06 y en f_06_02
        ec_y_02_06 = @(x) x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        ec_y_06_02 = @(x) x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));

        % Efectos combinados
        % en A,B
        % Interación de Mz,Mz en A y B, usado en f_06_12 y f_12_06
        ec_z_06_12 = @(x) -1 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interación de Mz,Vy en A y B, usado en f_06_08 y f_08_06
        ec_z_06_08 = @(x) (1-x) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interación de Vz,Vz en A y B, usado en f_03_09 y f_09_03
        ec_y_03_09 = @(x) (x-x.^2) ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de My,My en A y B, usado en f_05_11 y en f_11_05
        ec_y_05_11 = @(x) -1 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de My,Vz en A y B, usado en f_05_09 y en f_09_05
        ec_y_05_09 = @(x) (-1+x) ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de Mz,Vy en A y B, usado en f_06_08 y en f_08_06
        ec_z_06_08 = @(x) (1-x) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interacción de Vz,My en A y B, usado en f_03_11 y en f_11_03
        ec_y_03_11 = @(x) x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de Vz,Mz en A y B, usado en f_02_12 y en f_12_02
        ec_z_02_12 = @(x) -x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interacción de Vy,Vy en A y B, usado en f_02_08 y en f_08_02
        ec_z_02_08 = @(x) (x-x.^2) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));

        % Matriz de flexibilidades general de un elemento de sección variable en 3D
    % % Cálculo de cada coeficiente que se ve afectado
        % Diagonal principal
        f_02_02 = integral(ec_z_02_02, 0, Long(i));
        f_03_03 = integral(ec_y_03_03, 0, Long(i));
        f_05_05 = integral(ec_y_05_05, 0, Long(i));
        f_06_06 = integral(ec_z_06_06, 0, Long(i));
        % Efectos combinados de V y M pero en A,A y en B,B
        f_02_06 = integral(ec_y_02_06, 0, Long(i));
        f_06_02 = integral(ec_y_06_02, 0, Long(i));
        f_03_05 = integral(ec_y_03_05, 0, Long(i));        
        f_05_03 = integral(ec_y_05_03, 0, Long(i));
        % Efectos combinados de A,B y B,A
          % Mz,Mz  en A,B
        f_02_08 = integral(ec_z_02_08, 0, Long(i));
        f_03_09 = integral(ec_y_03_09, 0, Long(i));
        f_05_11 = integral(ec_y_05_11, 0, Long(i));
        f_06_12 = integral(ec_z_06_12, 0, Long(i));
        f_06_08 = integral(ec_z_06_08, 0, Long(i));
        f_05_09 = integral(ec_y_05_09, 0, Long(i));
        f_03_11 = integral(ec_y_03_11, 0, Long(i));
        f_02_12 = integral(ec_z_02_12, 0, Long(i));

        % Matriz de flexibilidades
        f_AA_d(:,:,i) = [ Long(i)/(E*Area(i)) 0          0           0                0           0;...
                        0                   f_02_02    0           0                0           f_06_02;...
                        0                   0          f_03_03     0                f_05_03     0;...
                        0                   0          0           Long(i)/(G*J)    0           0;...
                        0                   0          f_03_05     0                f_05_05     0;...
                        0                   f_02_06    0           0                0           f_06_06]

        % Matriz de transformación para evitar invertir la matriz de flexibilidades
        T   = [-1    0          0           0   0   0
                0    -1         0           0   0   0 
                0    0         -1           0   0   0
                0    0          0          -1   0   0
                0    0          Long(i)     0  -1   0
                0   -Long(i)    0           0   0  -1
                1    0          0           0   0   0
                0    1          0           0   0   0
                0    0          1           0   0   0
                0    0          0           1   0   0
                0    0          0           0   1   0
                0    0          0           0   0   1];

        ke_d(:,:,i) = T * (f_AA_d(:,:,i))^(-1) * T';
        clearvars VIy VIz
    end % Fin de los condicionales de los tipos de dano a los elementos a danar
end % Fin del ciclo for que itera sobre cada elemento a danar

