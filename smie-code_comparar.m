%% SAPMIAdenthboth.m

% Main
clc; clear all; close all, warning off
tic
format shortG

% Danos a elementos tubulares, caso de dano y su respectivo porcentaje   
% CORROSIÓN ->                          % PIERNAS Y ELEMENTOS DIAGNOALES                                                % V I G A S                                                     ELEMENTOS DIAGONALES INFERIORES                                             ELEMENTOS DIAGONALES SUPERIORES
no_elemento_a_danar_todos_modelos   = [ 1,2,5,18,19, 25,26,29,42,43, 49,50,53,66,67, 73,74,77,90,91, 97,98,101,114,115, 21,26,28,5,3, 45,27,29,52,50, 69,51,53,76,74, 93,100,98,77,75,  2,1,5,4,21, 26,29,25,21,5, 50,53,49,45,52, 74,57,76,77,73, 98,101,97,100,93, 3,6,10,4,21, 27,45,34,28,30, 51,52,54,58,69, 75,82,93,76,78, 99,100,117,106,102,...
                                        97,115,96,110,112, 73,77,84,76,79, 98,87,85,77,86,  99,112,113,110,98,  117,119,118,120,116, 93,77,82,81,84, 69,71,72,68,63, 45,47,46,48, 21,23,22,24,13];
% ABOLLADURAS ->                        % ELEM.DIAG                                                             VIGAS

% Casos de dano
caso_dano_corr                      = {'corrosion'};
caso_dano_corr_total                = repmat({'corrosion'}, 1, 95);     % 19 modelos por 5 elementos con corrosion por modelo = 95 elementos tubulares corroios en el estudio
caso_dano_abo                       = {'abolladura'};
caso_dano_abo_total                 = repmat({'abolladura'}, 1, 45);    % 9 modelos por 5 elementos con abolladura por modelo = 45 elementos tubulares con abolladura en el estudio
caso_dano                           = horzcat(caso_dano_corr_total,caso_dano_abo_total);

% Porcentajes de dano
dano_porcentaje_corr                = [60 40 40 40 40];
dano_porcentaje_corr_total          = repmat(dano_porcentaje_corr, 1, 19);
dano_porcentaje_abo                 = [40 1 1 1 1];
dano_porcentaje_abo_total           = repmat(dano_porcentaje_abo, 1, 9);
dano_porcentaje                     = horzcat(dano_porcentaje_corr_total,dano_porcentaje_abo_total);

% Formas modales
no_formas_por_modo = 72; 
matriz_rmse_formas_modales = zeros(no_formas_por_modo, 3, 28);
% 3 por tres modos de vibrar
% 28 modelos con dano a analizar

% Frecuencias naturales
no_frec_nat = 28;
vector_rmse_frec = zeros(1,no_frec_nat);

for iteraciones_modelo = 1:28       % 28 modelos con dano a analizar
    %% Datos iniciales de entrada
        % indices para ir recorriendo 5 porcentajes de daño en cada iteracion de modelo a analizar 
        inicio  = 5 * (iteraciones_modelo-1)+1;
        fin     = min(inicio + 4, length(no_elemento_a_danar_todos_modelos));
        no_elemento_a_danar = no_elemento_a_danar_todos_modelos(inicio:fin);
    
        archivo_excel = 'E:\Archivos_Jaret\Proyecto-doctoral\pruebas_excel\Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
        % archivo_excel = '/home/francisco/Documents/Proyecto-doctoral/pruebas_excel/Datos_nudos_elementos_secciones_masas_nuevo_pend1a8_vigasI.xlsx';
        tirante         = 87000;    % en mm
        tiempo          = 03;       % en anos
        d_agua          = 1.07487 * 10^-8; % unidades de la densidad del agua en N/mm^3
        densidad_crec   = 1.3506*10^-7;    % en N/mm^3
        % Valor de la dessidad del crecimiento marino
                % Valor de internet = 1325 kg/m^3
                % Conversión: 1325 kg/m^3 * (1 N / 9.81 kg) * (1 m^3/1000^3 m^3) = 1.3506*10^-7 en N/mm^3
        pathfile        = 'E:\Archivos_Jaret\Proyecto-doctoral\pruebas_excel\marco3Ddam0.xlsx';
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
    % SECCION: Vector que posiciona en un indice el elemento a danar (elem_con_dano_long_NE)
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
                fprintf('Elemento: %d, Daño: %s\n', no_elemento_a_danar(i), caso_dano{i});
                ke_d(:,:,i) = T * f_AA_d(:,:,i)^(-1) * T'; % Matriz de rigidez local del elemento tubular
            end % Fin del bucle for de corrosión

        elseif strcmp(caso_dano{i}, 'abolladura')
            % Código de abolladura
            index = find(num_de_ele_long(:,1) == i);
            long_elem_a_danar = num_de_ele_long(index,2);
            prop_geom_mat = cell2mat(prop_geom); espesor_elem_a_danar = prop_geom_mat(no_elemento_a_danar(i),10);
            D(i) = prop_geom_mat(no_elemento_a_danar(i),8);
            L_D(i) = long_elem_a_danar;
            z_s(i) = dano_porcentaje(i) * D(i) / 100;
            Nseg = 1000;
            lim = 0.003;
            t(i) = espesor_elem_a_danar;
            R(i) = 0.5 * D(i) - (0.5*t(i));
            A1(i) = pi * D(i)^2 * 0.25;
            D_interior(i) = D(i) - (t(i)*2);
            A2(i) = pi * D_interior(i)^2 * 0.25;
            A_d(i) = A1(i) - A2(i); % Área con daño
            j(i) = prop_geom_mat(no_elemento_a_danar(i),5);

            if dano_porcentaje(i) > 50
                fprintf('\n********************************************************** \n')
                fprintf('***La abolladura no puede ser más del 50%% del diámetro**** \n')
                fprintf('********************************************************** \n\n')
                error('La abolladura excede el 50%% del diámetro. La ejecución se detiene.')
            end 

	    % [] = momento_inercia_abolladura(caso_dano, index, num_de_ele_long, long_elem_a_danar, prop_geom_mat, prop_geom, espesor_elem_a_danar, no_elemento_a_danar, D, L_D, z_s, dano_porcentaje, Nseg, lim, t, R, A1, D_interior, A2, A_d, j);

            Slong = 5;
            x = 0;
            for j = 1:Slong % Inicio del segundo for
                x = x + L_d(i)/Slong;
                V(j) = x/L_d(i);
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
                for w = 1:Nseg % Inicio del quinto for
                    if Circ(w,2,2) < z_i && Circ(w,2,1) < 0 % Inicio del quinto if
                        V_z(w) = Circ(w,2,2);
                        V_y(w) = Circ(w,2,1);
                    end % Fin del quinto if
                end % Fin del quinto for
                for w = 1:length(V_z)-1 % Inicio del sexto for
                    if V_y(w) ~= 0 % Inicio del sexto if
                        Li = sqrt((V_y(w+1) - V_y(w))^2 + (V_z(w+1) - V_z(w))^2);
                        L_c(w) = Li;
                    end % Fin del sexto if
                end % Fin del sexto for
                L_c = sum(L_c); % Suma de las longitudes
                L_c = 2 * L_c;

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

                Circ = zeros(Nseg, 2, 2); % Matriz de ceros donde ir incluyendo los valores del círculo
                Lseg = P/Nseg; % Longitud (perímetro) discretizado
                Alpha = 0 : 360 / Nseg : 360; % Diferentes valores de PI discretizados

                for w = 1 : Nseg + 1 % Inicio del séptimo for
                    Yi = R(i) * cosd(Alpha(w)); % Altura de circunferencia
                    Zi = R(i) * sind(Alpha(w)); % Anchura de circunferencia
                    Circ(w, 1, 1) = Yi; % Almacenamiento de valores de la altura de circunferencia
                    Circ(w, 1, 2) = Zi; % Almacenamiento de valores de la anchura de circunferencia
                    if Alpha(w) > 90 && Alpha(w) < 270 % Inicio del octavo if
                        Sig = -1;
                    else
                        Sig = 1;
                    end % Fin del octavo if
                    if Zi > z_i % Inicio del noveno if
                        Circ(w, 2, 1) = Circ(w, 2, 1) - Lseg; % Lseg = Longitud (perímetro) discretizado
                        Circ(w, 2, 2) = z_i;
                    else
                        Yi = R(i) * cosd(Alpha(w)); % Altura de circunferencia sin daño
                        Zi = R(i) * sind(Alpha(w)); % Anchura de circunferencia sin daño
                        Circ(w, 2, 1) = Yi + delta * sin(((pi/2) / (z_dent)) * (Zi + R(i))) * Sig;
                        Circ(w, 2, 2) = Zi;
                    end % Fin del noveno if
                end % Fin del séptimo for
                % Cálculo de centroide
                c_y = 0;
                c_z = mean(Circ(:,2,2));

                % Cálculo de momentos de inercia
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

                k = 1;
                for ii = 1 : length(Vz_Ic)-1
                    L_I(ii) = (((Vz_Ic(ii+1)) - Vz_Ic(ii))^2 + ((Vy_Ic(ii+1)) - Vy_Ic(ii))^2 )^0.5;
                    V_longy_I(ii) = Vy_Ic(k) - Vy_Ic(k+1);
                    V_ang_I(ii) = acosd(V_longy_I(ii)/L_I(ii));
                    k = k+1;
                    if ii == 1
                        dy_I(ii) = (L_I(ii)*sind(V_ang_I(ii)) * 0.5) + (c_z*-1);
                        dz_I(ii) = Circ(ii,2,1) - (L_I(ii)*cosd(V_ang_I(ii)) * 0.5);
                    else
                        dy_I(ii) = Circ(ii,2,2) + (L_I(ii)*sind(V_ang_I(ii)) * 0.5 + (c_z*-1));
                        dz_I(ii) = Circ(ii,2,1) - (L_I(ii)*cosd(V_ang_I(ii)) * 0.5);
                    end
                end

                for ii = 1:length(V_ang_I)
                    Iy_I(ii) = 1/12 * L_I(ii) * t(i)^3;
                    Iz_I(ii) = 1/12 * L_I(ii)^3 * t(i);
                    Iy_prima_I(ii) = ((Iy_I(ii) + Iz_I(ii)) * 0.5) + (((Iy_I(ii) - Iz_I(ii))* 0.5) * cosd(2*V_ang_I(ii)));
                    Iz_prima_I(ii) = ((Iy_I(ii) + Iz_I(ii)) * 0.5) - (((Iy_I(ii) - Iz_I(ii))* 0.5) * cosd(2*V_ang_I(ii)));
                    A_I(ii) = L_I(ii) * t(i); % Área de cada elemento diferencial 
                end

                % Cuadrante II
                Alpha = 0: 2*pi/Nseg : 2*pi;
                j = 1;
                for ii = 1 : Nseg
                    y_uni = cos(Alpha);
                    z_uni = sin(Alpha);
                    j = j+1;
                    if sign(y_uni(j)) == -1 && z_uni(j) < 1 && Circ(j,2,2) < z_i
                        Vy_II(j) = Circ(j,2,1);
                        Vz_II(j) = Circ(j,2,2);
                    end
                    if Circ(j,2,2) < 0
                        break
                    end
                end
                Vz_II(:,length(Vz_II)) = [];
                j = 1;
                r = 1;
                for ii = 1:length(Vz_II)
                    if Vz_II(ii) ~= 0 & Vy_II(ii) ~= 0
                        Vz_IIc(j) = horzcat(Vz_II(ii));
                        Vy_IIc(j) = horzcat(Vy_II(ii));
                        j = j+1;					
                    else
                        r = r + 1;
                    end
                end
                k = 1;
                for ii = 1 : (length(Vz_IIc)-1)
                    L_II(ii) = (((Vz_IIc(ii+1)) - Vz_IIc(ii))^2 + ((Vy_IIc(ii+1)) - Vy_IIc(ii))^2 )^0.5;
                    V_longy_II(ii) = Vy_IIc(k+1) - Vy_IIc(k);
                    V_ang_II(ii) = acosd(-V_longy_II(ii)/L_II(ii));
                    k = k+1;
                    dy_II(ii) = Circ(r,2,2) - L_II(ii)*sind(V_ang_II(ii)) * 0.5 + (c_z*-1);
                    dz_II(ii) = Circ(r,2,1) - L_II(ii)*cosd(V_ang_II(ii)) * 0.5;
                    r = r+1;
                end
                for ii = 1:length(V_ang_II)
                    Iy_II(ii) = 1/12 * L_II(ii) * t(i)^3;
                    Iz_II(ii) = 1/12 * L_II(ii)^3 * t(i);
                    Iy_prima_II(ii) = ((Iy_II(ii) + Iz_II(ii)) * 0.5) + (((Iy_II(ii) - Iz_II(ii))* 0.5) * cosd(2*V_ang_II(ii)));
                    Iz_prima_II(ii) = ((Iy_II(ii) + Iz_II(ii)) * 0.5) - (((Iy_II(ii) - Iz_II(ii))* 0.5) * cosd(2*V_ang_II(ii)));
                    A_II(ii) = L_II(ii) * t(i); % Área de cada elemento diferencial 
                end

                % Cuadrante III
                j = 1;
                for ii = 1 : Nseg
                    y_uni = cos(Alpha);
                    z_uni = sin(Alpha);
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
                k = 1;
                r = r+1;
                for ii = 1 : (length(Vz_IIIc)-1)
                    L_III(ii) = (((Vz_IIIc(ii+1)) - Vz_IIIc(ii))^2 + ((Vy_IIIc(ii+1)) - Vy_IIIc(ii))^2 )^0.5;
                    V_longy_III(ii) = Vy_IIIc(k+1) - Vy_IIIc(k);
                    V_ang_III(ii) = 180 - acosd(-V_longy_III(ii)/L_III(ii));
                    k = k+1;
                    dy_III(ii) = Circ(r,2,2) - (L_III(ii)*sind(V_ang_III(ii)) * 0.5) - c_z;
                    dz_III(ii) = Circ(r,2,1) + (L_III(ii)*cosd(V_ang_III(ii)) * 0.5);
                    r = r+1;
                end
                for ii = 1:length(V_ang_III)
                    Iy_III(ii) = 1/12 * L_III(ii) * t(i)^3;
                    Iz_III(ii) = 1/12 * L_III(ii)^3 * t(i);
                    Iy_prima_III(ii) = ((Iy_III(ii) + Iz_III(ii)) * 0.5) + ((Iy_III(ii) - (Iz_III(ii))* 0.5) * cosd(2*V_ang_III(ii)));
                    Iz_prima_III(ii) = ((Iy_III(ii) + Iz_III(ii)) * 0.5) - ((Iy_III(ii) - (Iz_III(ii))* 0.5) * cosd(2*V_ang_III(ii)));
                    A_III(ii) = L_III(ii) * t(i); % Área de cada elemento diferencial 
                end

                % Cuadrante IV
                for ii = 1 : Nseg+1
                    y_uni = cos(Alpha);
                    z_uni = sin(Alpha);
                    if sign(y_uni(ii)) == 1 && sign(z_uni(ii)) == -1
                        Vy_IV(ii) = Circ(ii,2,1);
                        Vz_IV(ii) = Circ(ii,2,2);
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
                Vy_IVc(:,length(Vy_IVc)+1) = [delta + R(i)];
                Vz_IVc(:,length(Vz_IVc)+1) = [0];
                k = 1;
                r = r+1;
                for ii = 1 : (length(Vz_IVc)-1)
                    L_IV(ii) = (((Vz_IVc(ii+1)) - Vz_IVc(ii))^2 + ((Vy_IVc(ii+1)) - Vy_IVc(ii))^2 )^0.5;
                    V_longy_IV(ii) = Vy_IVc(k+1) - Vy_IVc(k);
                    V_ang_IV(ii) = 180 - acosd(-V_longy_IV(ii)/L_IV(ii));
                    k = k+1;
                    dy_IV(ii) = Circ(r,2,2) + (L_IV(ii)*sind(V_ang_IV(ii)) * 0.5) - c_z;
                    dz_IV(ii) = Circ(r,2,1) + (L_IV(ii)*cosd(V_ang_IV(ii)) * 0.5);
                    r = r+1;
                end
                for ii = 1:length(V_ang_IV)
                    Iy_IV(ii) = 1/12 * L_IV(ii) * t(i)^3;
                    Iz_IV(ii) = 1/12 * L_IV(ii)^3 * t(i);
                    Iy_prima_IV(ii) = ((Iy_IV(ii) + Iz_IV(ii)) * 0.5) + (((Iy_IV(ii) - Iz_IV(ii))* 0.5) * cosd(2*V_ang_IV(ii)));
                    Iz_prima_IV(ii) = ((Iy_IV(ii) + Iz_IV(ii)) * 0.5) - (((Iy_IV(ii) - Iz_IV(ii))* 0.5) * cosd(2*V_ang_IV(ii)));
                    A_IV(ii) = L_IV(ii) * t(i); % Área de cada elemento diferencial 
                end

                dy = horzcat(dy_I, dy_II, dy_III, dy_IV);
                dz = horzcat(dz_I, dz_II, dz_III, dz_IV);
                Iy_prima = horzcat(Iy_prima_I, Iy_prima_II, Iy_prima_III, Iy_prima_IV);
                Iz_prima = horzcat(Iz_prima_I, Iz_prima_II, Iz_prima_III, Iz_prima_IV);
                VA = horzcat(A_I, A_II, A_III, A_IV);
                for ii = 1 : length(dy)-1
                    Iy_t = Iy_prima(ii) + (VA(ii) * dy.^2);
                    Iz_t = Iz_prima(ii) + (VA(ii) * dz.^2);
                end

                L_ach = cuerda + 2*delta;
                Iy_ach = 1/12 * L_ach * t(i)^3;
                Iz_ach = 1/12 * L_ach^3 * t(i);
                A_ach = L_ach*t(i);
                d_acha = z_i + (c_z*-1);
                Iy_achatada_centro = Iy_ach + (A_ach * d_acha^2);
                Iz_achatada_centro = Iz_ach;

                Iy_t_damaged = sum(Iy_t) + Iy_achatada_centro;
                Iz_t_damaged = sum(Iz_t) + Iz_achatada_centro;

                R_ext(i) = 0.5*D(i);
                I_ext = pi/4 * R_ext(i)^4;
                R_int(i) = (0.5*D(i)) - t(i);
                I_int = pi/4 * (R_int(i))^4;
                I_undamaged = I_ext - I_int;
                Dif_y = (Iy_t_damaged - I_undamaged);
                Porcentaje_reduccion_y = Dif_y*100 / I_undamaged;
                Dif_z = (Iz_t_damaged - I_undamaged);
                Porcentaje_reduccion_z = Dif_z*100 / I_undamaged;

                VIy(p) = Iy_t_damaged;
                VIz(p) = Iz_t_damaged;

                clearvars -except Long D t L_d R A_d A G J E z_s Lseg Nseg x V Vz_s i L P p pi z_i z_dent theta cuerda L1 L2 delta Circ Yi Zi Alpha Sig lim VIy VIz I_undamaged Slong prop_geom t_corro t_d D_d R_d A1_d R_interior_d A2_d A_d long_elem_con_dano hoja_excel datos_para_long elementos_y_long no_elemento_a_danar elem_con_dano_long_NE index ceros_agregar mat_zero ke_d R_ext_d I_ext_d I_int_d I_d archivo_excel tirante tiempo d_agua densidad_crec pathfile caso_dano dano_porcentaje coordenadas vxz conectividad matriz_restriccion matriz_cell_secciones masas_en_cada_nodo M_cond NE IDmax NEn elements nodes damele eledent Iy Iz ID KG KGtu vigas_long brac_long col_long num_de_ele_long f_AA_d

            end % Fin del ciclo for que va iterando sobre cada sección longitudinal del elemento i (elemento tubular con daño)

            VIy = horzcat(I_undamaged,VIy,I_undamaged); % en mm^4
            VIz = horzcat(I_undamaged,VIz,I_undamaged); % en mm^4
            x_f = 0 : L_d/Slong : L_d;

            grado = 4;
            poly_y = polyfit(x_f, VIy, grado);

            ec_y_03_03 = @(x) x.^2 ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_05_05 = @(x) 1 ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));

            poly_z = polyfit(x_f, VIz, grado);
            ec_z_02_02 = @(x) x.^2 ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));            
            ec_z_06_06 = @(x) 1 ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));

            ec_y_03_05 = @(x) -x ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_05_03 = @(x) -x ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_02_06 = @(x) x ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            ec_y_06_02 = @(x) x ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));

            ec_z_06_12 = @(x) -1 ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            ec_z_06_08 = @(x) (1-x) ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            ec_y_03_09 = @(x) (x-x.^2) ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_05_11 = @(x) -1 ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_05_09 = @(x) (-1+x) ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_03_11 = @(x) x ./ ((E(i))*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_z_02_12 = @(x) -x ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            ec_z_02_08 = @(x) (x-x.^2) ./ ((E(i))*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));

            f_02_02 = integral(ec_z_02_02, 0, L_d(i));
            f_03_03 = integral(ec_y_03_03, 0, L_d(i));
            f_05_05 = integral(ec_y_05_05, 0, L_d(i));
            f_06_06 = integral(ec_z_06_06, 0, L_d(i));
            f_02_06 = integral(ec_y_02_06, 0, L_d(i));
            f_06_02 = integral(ec_y_06_02, 0, L_d(i));
            f_03_05 = integral(ec_y_03_05, 0, L_d(i));        
            f_05_03 = integral(ec_y_05_03, 0, L_d(i));
            f_02_08 = integral(ec_z_02_08, 0, L_d(i));
            f_03_09 = integral(ec_y_03_09, 0, L_d(i));
            f_05_11 = integral(ec_y_05_11, 0, L_d(i));
            f_06_12 = integral(ec_z_06_12, 0, L_d(i));
            f_06_08 = integral(ec_z_06_08, 0, L_d(i));
            f_05_09 = integral(ec_y_05_09, 0, L_d(i));
            f_03_11 = integral(ec_y_03_11, 0, L_d(i));
            f_02_12 = integral(ec_z_02_12, 0, L_d(i));

            f_AA_d(:,:,i) = [
                L_d(i)/(E(i)*A_d(i)) 0 0 0 0 0; ...
                0 f_02_02 0 0 0 f_06_02; ...
                0 0 f_03_03 0 f_05_03 0; ...
                0 0 0 L_d(i)/(G(i)*j) 0 0; ...
                0 0 f_03_05 0 f_05_05 0; ...
                0 f_02_06 0 0 0 f_06_06
            ];

            T = [
                -1 0 0 0 0 0; 0 -1 0 0 0 0; 0 0 -1 0 0 0; 0 0 0 -1 0 0; ...
                0 0 L_d(i) 0 -1 0; 0 -L_d(i) 0 0 0 -1; 1 0 0 0 0 0; ...
                0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1
            ];
            fprintf('Elemento: %d, Daño: %s\n',no_elemento_a_danar(i),caso_dano{i})
            ke_d(:,:,i) = T * (f_AA_d(:,:,i))^(-1) * T';
            clearvars VIy VIz
        end % Fin del bucle for de abolladura

    end % Fin del ciclo for que itera sobre cada elemento a dañar
    ke_d_total = real(ke_d);
    clc
    [KG_damaged, KG_undamaged] = ensamblaje_matriz_rigidez_global_ambos_modelos(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent,   A, Iy, Iz, J, E, G,  vxz, elem_con_dano_long_NE);

    % Función Condensación estática    
        KG_damaged_cond   = condensacion_estatica(KG_damaged);
        KG_undamaged_cond = condensacion_estatica(KG_undamaged);
    %%
    % Modos y frecuencias de estructura condensados y globales
         [modos_cond_u,frec_cond_u] = modos_frecuencias(KG_undamaged_cond,M_cond);
         [modos_cond_d,frec_cond_d] = modos_frecuencias(KG_damaged_cond,M_cond);

    % % RMSE para las frecuencias naturales
    %     vector_rmse_frec(iteraciones_modelo) = sqrt(mean((frec_cond_d - frec_cond_u).^2));

    % RMSE adimensional para las frecuencias naturales expresado en porcentaje
        vector_rmse_frec(iteraciones_modelo) = 100 * sqrt(mean(((frec_cond_d - frec_cond_u).^2) ./ (frec_cond_u.^2)));


    % % Normalizacion de modos (normalización por el máximo componente)
    %     % Se debe escoger el mayor valor de cada dirección de cada gdl de cada modo
    %     [n, m] = size(modos_cond_u);
    %     num_gdl = 3; % Número de grados de libertad por nodo
    %     for j = 1:m % Para cada modo
    %         for i = 1:num_gdl:num_gdl*round(n/num_gdl) % Para cada gdl
    %             max_val = max(abs(modos_cond_u(i:i+num_gdl-1, j))); % Encuentra el valor máximo
    %             modos_cond_u(i:i+num_gdl-1, j) = modos_cond_u(i:i+num_gdl-1, j) / max_val; % Normaliza
    %         end
    %     end
    % 
    %     [n, m] = size(modos_cond_d);
    %     num_gdl = 3; % Número de grados de libertad por nodo
    %     for j = 1:m % Para cada modo
    %         for i = 1:num_gdl:num_gdl*round(n/num_gdl) % Para cada gdl
    %             max_val = max(abs(modos_cond_d(i:i+num_gdl-1, j))); % Encuentra el valor máximo
    %             modos_cond_d(i:i+num_gdl-1, j) = modos_cond_d(i:i+num_gdl-1, j) / max_val; % Normaliza
    %         end
    %     end

    % % RMSE para las formas modales normalizadas
    %     % Supongamos que n es el número total de filas, m es el número total de columnas (modos)
    %     [n, m] = size(modos_cond_u);
    %     num_gdl = 3;  % Número de grados de libertad por nodo
    % 
    %     % Inicializar matriz de RMSE
    %     rmse_matrix = zeros(n/num_gdl, m);  % Una fila por cada nodo, una columna por cada modo
    % 
    %     for j = 1:m  % Para cada modo
    %         for i = 1:num_gdl:n  % Para cada nodo
    %             % Extraer las filas correspondientes a los 3 grados de libertad del nodo actual
    %             u_node = modos_cond_u(i:i+num_gdl-1, j);
    %             d_node = modos_cond_d(i:i+num_gdl-1, j);
    % 
    %             % Calcular el RMSE para este nodo y modo
    %             rmse_matrix((i-1)/num_gdl + 1, j) = sqrt(mean((u_node - d_node).^2));
    %         end
    %     end
    %     matriz_rmse_formas_modales(:,:,iteraciones_modelo) = rmse_matrix;
end
toc
%%
clc
close all
% % Analisis de la matriz de formas modales
% maximos_por_modelo = zeros(28, 1);  % Pre-alojamos para los máximos de cada modelo
% indices_maximos = zeros(28, 2);  % Para almacenar los índices de los máximos
% 
% for i = 1:28
%     % Extraemos la matriz para cada modelo
%     matriz_actual = matriz_rmse_formas_modales(:, :, i);
% 
%     % Buscamos el máximo en esta matriz
%     [max_val, idx_linear] = max(matriz_actual(:));
%     maximos_por_modelo(i) = max_val;
% 
%     % Convertimos el índice lineal a subíndices
%     [idx_row, idx_col] = ind2sub(size(matriz_actual), idx_linear);
%     indices_maximos(i, :) = [idx_row, idx_col];
% end
% 
% [max_global, idx_modelo] = max(maximos_por_modelo);
% idx_nodo_grado_libertad = indices_maximos(idx_modelo, :);
% 
% fprintf('El modelo %d tiene el RMSE más alto de %f en el nodo %d y grado de libertad %d.\n', ...
%         idx_modelo, max_global, idx_nodo_grado_libertad(1), idx_nodo_grado_libertad(2));
% 
% % Análisis del vector de frecuencias naturales
% num_modelos = length(vector_rmse_frec);
% 
% % Encontrar el máximo valor de RMSE y su índice correspondiente
% [max_rmse, idx_max_rmse] = max(vector_rmse_frec);
% 
% % Mostrar los resultados
% fprintf('El máximo RMSE para las frecuencias naturales es %f, obtenido en el modelo %d.\n', max_rmse, idx_max_rmse);

% Configuración inicial para todos los tamaños de texto y estilo
fontSizeAxes = 24;  % Tamaño de fuente para ejes y números de ejes
fontSizeTicks = 20; % Tamaño de fuente para los números en los ejes
fontSizeTitle = 24; % Tamaño de fuente para títulos
lineWidth = 2;      % Ancho de las líneas de la gráfica
markerSize = 10;    % Tamaño de las marcas en la gráfica

% Crea una figura para la gráfica
figure;
hold on;  % Mantiene la figura activa para múltiples plots

% Datos de los puntos a marcar y sus etiquetas
xPoints = [ 10, 16, 28]; % Números de modelo
yPoints = [ 7.22, 5.42, 2.26]; % Valores de RECM en porcentaje
labels = { '(10, 7.22%)', '(16, 5.42%)', '(28, 2.26%)'};  % Etiquetas de texto para cada punto

% Plot de los puntos del 1 al 19 (Corrosión)
plot(1:19, vector_rmse_frec(1:19), 'b-o', 'MarkerFaceColor', 'b', 'LineWidth', lineWidth, 'MarkerSize', markerSize);
% Plot de los puntos del 20 al 28 (Abolladura)
plot(20:28, vector_rmse_frec(20:28), 'r-o', 'MarkerFaceColor', 'r', 'LineWidth', lineWidth, 'MarkerSize', markerSize);

% Agregar las etiquetas de texto en los puntos especificados
for i = 1:length(xPoints)
    text(xPoints(i), yPoints(i), labels{i}, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', 'FontSize', fontSizeAxes);
end

% Ajustar el tamaño de los ticks en los ejes
ax = gca; % Obtiene el handle del eje actual
ax.FontSize = fontSizeTicks; % Establece el tamaño de la fuente para los ticks

% Añadir leyendas específicas
legend('Corrosión', 'Abolladura', 'Location', 'northeast', 'FontSize', 20);

% Añadir etiquetas y título
xlabel('Escenario de daño', 'FontSize', fontSizeAxes);
ylabel('Porcentaje de RECM de Frecuencias Naturales', 'FontSize', fontSizeAxes);
title('RECM de Frecuencias Naturales por Modelo', 'FontSize', fontSizeTitle);


hold off;  % No se agregan más plots a esta figura


% 
% 
% % Dimensiones
% gdl = 72; % Grados de libertad por modo
% num_modos = 3; % Número de modos
% num_modelos = 28; % Número de modelos
% 
% % Encuentra los máximos RMSE para cada modo y sus índices
% max_rmse = zeros(num_modos, 1);
% max_idx = zeros(num_modos, 1);
% 
% for modo = 1:num_modos
%     [max_rmse(modo), max_idx(modo)] = max(max(matriz_rmse_formas_modales(:, modo, :), [], 1));
% end
% 
% % Graficar los modos con mayores cambios
% figure;
% for i = 1:num_modos
%     subplot(num_modos, 1, i);
%     modo_actual = squeeze(matriz_rmse_formas_modales(:, i, max_idx(i)));
%     plot(1:gdl, modo_actual, 'b-o', 'MarkerFaceColor', 'r');
%     xlabel('Grado de Libertad');
%     ylabel('RMSE');
%     title(sprintf('RMSE del Modo %d en el Modelo %d con RMSE Máximo: %f', i, max_idx(i), max_rmse(i)));
%     grid on;
% end