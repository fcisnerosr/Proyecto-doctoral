function [ke_d_total, ke_d, elem_con_dano_long_NE] = corrosionlocal(no_elemento_a_danar, dano_porcentaje, archivo_excel, NE, prop_geom, E, G, J);
    %% CORROSION LOCAL
    %% SECCION: variables de la corrosion local de ceros
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
    
    %% SECCION: Longitudes de elementos a danar (long_elem_con_dano)
    hoja_excel              = 'Frame Assigns - Summary';
    datos_para_long         = xlsread(archivo_excel, hoja_excel, 'C:E');
    datos_para_long(:,2)    = [];
    elementos_y_long        = sortrows(datos_para_long, 1);
    for i = 1:length(no_elemento_a_danar)
        long_elem_con_dano(i)  = elementos_y_long(no_elemento_a_danar(i),2);
    end

    %% SECCION: Vector que posiciona en un indice el elemento a danar (elem_con_dano_long_NE)
        % Vector de longitud NE con los elementos danados dentro que sirve como criterio en la siguiente seccion para saber que matriz de rigidez local intacta reemplazarla por
    % las que tienen dano
    % Inicializar elem_con_dano_long_NE como un vector vacío
    elem_con_dano_long_NE = []; % vector de long NE con todos los elementos danados en las posiciones correspondientes
    % Construir el elem_con_dano_long_NEls
    % Condicionales: cuando se elige no danar el elemento 1, el vector elem_con_dano_long_NE no tiene la long de NE, de modo que se contruye de manera diferente
    index = find(no_elemento_a_danar == 1);     % index verifica si existe o no el elemento 1 en no_elemento_a_danar, si no existe devuelve un cero si existe devuelve el lugar en el que está el 1
    if isempty(index)
        for i = 1:length(no_elemento_a_danar)
            if i < length(no_elemento_a_danar)
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
            else
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
            end
        end
        ceros_agregar           = NE - length(elem_con_dano_long_NE);
        mat_zero                = zeros(1,ceros_agregar);
        elem_con_dano_long_NE   = horzcat(mat_zero,elem_con_dano_long_NE);
    else  
        for i = 1:length(no_elemento_a_danar)
            if i < length(no_elemento_a_danar)
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
            else
                elem_con_dano_long_NE = [elem_con_dano_long_NE, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
            end
        end
    end

    %% SECCION: Matriz de rigidez local con corrosion cuya 3ra dimension equivale al numero de elementos con dano (ke_d)
    % SUBLOQUE: Matrices con ceros, f_AA_d es la matriz de flexibilidad pero solo el primer cuadrante de un extremo por eso de 6 x 6, ke_d es la matriz de rigidez local completa
    %     en el siguiente subloque se convierte se la matriz de transformacion T para convertirla en matriz de rigidez local completa. Ya que al intentar
    %     invertirla produce valores indeterminados
    f_AA_d  = zeros( 6,  6, length(no_elemento_a_danar));
    ke_d    = zeros(12, 12, length(no_elemento_a_danar)); 
    % SUBLOQUE: Asignación de corrosión al area y a las inercias de la seccion 
    for i = 1:length(no_elemento_a_danar)
        % reduccion de espesor por corrosion
        t(i)        = prop_geom(i,10);                      % Estraccion de espesor sin dano
        t_corro(i)  = dano_porcentaje(i) * t(i) / 100; % Espesor que va a restar al espesor sin dano
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

    %% SECCION: Matriz de rigidez total con corrosion cuya 3ra dimension equivale a NE, los elementos con dano estan ubicados en su lugar correspondientes (ke_d_total)
    % Generar una matriz de longitud NE con los ke_d en los indices correspondientes de no_elemento_a_danar para posterior
    ke_d_total  = zeros(12, 12, NE);                            % Matriz de ceros con NE longitud en su tercera dimension. NE es el num. de elementos
    for i = 1:length(no_elemento_a_danar)
        ke_d_total(:,:,no_elemento_a_danar(i)) = ke_d(:,:,i);   % matriz vacia de 12 por 12 por NE, pero con las matrices locales de ke_d posicionadas en su lugar para correspondientes
    end
    %% IMPORTANTE: LA MATRIZ ke_d_total CONTIENE EN SU MAYORIA CEROS PERO LOS ELEMENTOS DIFERENTES A CEROS CONTIENE LA MATRICES LOCALES CON DANO
                %% QUE SERA USADA EN EL ENSAMBLAJE GLOBAL PARA REEMPLAZAR LAS MATRICES LOCALES INTACTAS POR LAS QUE TIENEN DANO
end
