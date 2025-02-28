function [coordenadas, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones, VXZ] = lectura_datos_modelo_ETABS(archivo_excel)
    % % % Lectura de datos del modelo de ETABS
    % [coordenadas, conectividad, prop_geom, matriz_restriccion, matriz_cell_secciones, VXZ] = lectura_datos_modelo_ETABS(archivo_excel);
    %% SECCIÓN: pestaña "nudos"
    %% BLOQUE: Nodos y sus coordenadas (coordenadas)
    hoja_excel = 'Point Object Connectivity';
    coordenadas_crudo = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    % coordenadas_crudo = readmatrix(archivo_excel, 'Sheet', hoja_excel, 'Range', '');
    coordenadas = sortrows(coordenadas_crudo, 1);   % Extraccion de matriz de tabla de pestana de excel
    % proceso de limpieza de datos para armar correctamente la matriz para la hoja del dr Rolando
    primer_col = coordenadas(:,1);
    primer_col = primer_col(~isnan(primer_col));
    coordenadas_num = coordenadas(:, 6:8);
    coordenadas_num = coordenadas_num(~any(isnan(coordenadas_num), 2), :);
    coordenadas = horzcat(primer_col, coordenadas_num);

    %% SECCIÓN: pestaña "conectividad"
    %% BLOQUE: extracción de qué nudos está cada viga y columna del modelo (conectividad)
    % Extracción de datos de las vigas
    hoja_excel = 'Beam Object Connectivity';
    vigas = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    cols_con_nan = any(isnan(vigas), 1);
    vigas(:, cols_con_nan) = [];
    vigas(:,4) = [];
    vigas_conectividad = vigas;
    % Extracción de datos de las columas diagonales (tanto en la subestructura como en al superestructura)
    hoja_excel = 'Brace Object Connectivity'; % pestaña con elementos diagonales (generalmente ubicados en la subestructura)
    col_diag = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    cols_con_nan = any(isnan(col_diag), 1);
    col_diag(:, cols_con_nan) = [];
    col_diag(:,4) = [];
    col_diag_conectividad = col_diag;
    % Extracción de datos de las columas rectas (tanto en la subestructura como en al superestructura)
    hoja_excel = 'Column Object Connectivity'; % pestaña con columnas rectas (generalmente ubicados en la superestructura)
    col = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    cols_con_nan = any(isnan(col), 1);
    col(:, cols_con_nan) = [];
    col(:,4) = [];
    col_conectividad = col;
    % Concatenación de las vigas y columnas
    conectividad = vertcat(vigas_conectividad, col_diag_conectividad,col_conectividad);   % Matriz con todos los elementos y entre qué y qué nodos está conectados
    conectividad = sortrows(conectividad, 1);                           % Matriz organizada con todos los elementos y entre qué nudos está cada elemento frame
    conectividad = conectividad(:,1:3);

    %% SECCIÓN: pestaña "prop geom"
    %% BLOQUE: Estracción de módulos de elasticidad y cortante (E y G)
    % Datos en este proceso: extracción de las propiedades de los elementos y asignación
    % Propiedades del material (módulos)
    hoja_excel = 'Mat Prop - Basic Mech Props';
    % Lee los datos de la columna A desde la celda A4 hasta el final de la columna
    E = xlsread(archivo_excel, hoja_excel, 'E7');      % módulo de elasticidad en MPa del modelo en ETABS
    G = xlsread(archivo_excel, hoja_excel, 'F7');        % módulo de corte en MPa del modelo en ETABS
    % Secciones transversales a cada elemento en el modelo
    hoja_excel = 'Frame Prop - Summary';
    % Lee los datos de la columna A desde la celda A4 hasta el final de la columna
    [numeros, secciones] = xlsread(archivo_excel, hoja_excel, 'A4:A100');   % Contiene elementos tipo SECC01, SECC02, hasta extraer todos las secciones del modelo
    % %% Propiedades del material del modelo en ETABS
    % Extracción y organización de las propiedades de ETABS para EXCEL
    tabla_frame_prop_summary = readtable(archivo_excel, 'Sheet', hoja_excel);
    tabla_frame_prop_summary(1,:) = [];
    vector_organizado_con_propiedades = table2cell(tabla_frame_prop_summary(:,5:8));
    %% Proceso de organización de las columnas para que correspondan al EXCEL del dr. Rolando
    vector_organizado_con_propiedades = horzcat(...
            vector_organizado_con_propiedades(:,1),...  % Área transversal
            vector_organizado_con_propiedades(:,3),...  % I_yy, I_33 en ETABS
            vector_organizado_con_propiedades(:,4),...  % I_zz, I_22 en ETABS
            vector_organizado_con_propiedades(:,2));    % Módulo J
    % A la variable "vector_organizado_con_propiedades" le faltan las dos columnas del módulo de elasticidad y el módulo G.
    % Estas dos últimas columnas deben concatenadas al final de "vector_organizado_con_propiedades"
    % ya que así lo requiere el XLSX del dr. Rolando.
    %% Proceso de concatenación de los vectores columnas de E y G
    num_filas = size(vector_organizado_con_propiedades, 1);
    E_num_elementos = E * ones(num_filas, 1);
    G_num_elementos = G * ones(num_filas, 1);

    %% BLOQUE: Estracción de módulos de elasticidad y cortante (E y G)
    % Concatenación de la matriz "vector_organizado_con_propiedades" y los dos vectores columna E y G
    vector_organizado_con_propiedades = [cell2mat(vector_organizado_con_propiedades), E_num_elementos, G_num_elementos];
    vector_organizado_con_propiedades = num2cell(vector_organizado_con_propiedades);
    % Concateniacón de la lista de SECC01, SECC02, ..., SECCn en la subestructura
    % y SteelBm y SteelCol de la superestructura
    % secciones existentes en el modelo, con las propiedades mecánicas
    cell_seccion = horzcat(secciones,vector_organizado_con_propiedades); % cell con la sección la SECC01, SECC02, ..., SECCn y SteelBm y SteelCol
    % y sus repectivas propiedades mecánicas

    %% BLOQUE: Cell con todos los UniqueNames y los nombres de la secciones transversales (matriz_cell_secciones)
    % Asignación de cada elemento a su respectiva sección
    % Proceso concatenar la lista de SECC01, SECC02, ..., SECCn, SteelBm y SteelCol (Todos los elementos)
    % con el UniqueName del modelo en ETABS
    hoja_excel = 'Frame Assigns - Sect Prop';
    tabla_Frame_Assigns_Sect_Prop = readtable(archivo_excel, 'Sheet', hoja_excel);
    secciones_cada_elemento = tabla_Frame_Assigns_Sect_Prop.SectionProperty;
    unique_name = num2cell(tabla_Frame_Assigns_Sect_Prop.UniqueName);               % Vector columna con todos los "unique name" de cada elemento frame
    matriz_cell_secciones = horzcat(unique_name, secciones_cada_elemento);
    matriz_cell_secciones(:,1) = [];
    matriz_cell_secciones = sortrows(matriz_cell_secciones, 1);                     % Los elementos se extraen desorganizadamente, por lo que se ordena en esta línea
    % 
    %% BLOQUE: Áreas, inercia, mom. polar, elasticidades y corte (propiedades)
    % Bucle for para la asignación
    % "secciones" es una variable con los tipos de secciones en el modelo. Es un cell array pequeño de no más de 20 elementos
    prop_geom = cell(size(matriz_cell_secciones));  % valores_asignados es un cell que usa para asignar todos las propiedades
    % de las secciones del modelo organizadas acorde a la lista de elementos de toda la plataforma
    % Proceso de iteración sobre cada fila de matriz_cell_secciones
    for i = 1:size(matriz_cell_secciones, 1)
        % Obtener el valor de la primera columna de la fila actual
        % seccion_actual = matriz_cell_secciones{i, 2};   & ajustes por cambio de Jacket a marco
        seccion_actual = matriz_cell_secciones{i, 1};
        % Buscar la fila correspondiente en cell_seccion
        idx = find(strcmp(seccion_actual, cell_seccion(:, 1)));
        % Asignar los valores de cell_seccion a la matriz de salida
        if ~isempty(idx)
            prop_geom{i, 1} = cell_seccion{idx, 2};
            prop_geom{i, 2} = cell_seccion{idx, 3};
            prop_geom{i, 3} = cell_seccion{idx, 4};
            prop_geom{i, 4} = cell_seccion{idx, 5};
            % prop_geom{i, 5} = cell_seccion{idx, 6};   & ajustes por cambio de Jacket a marco
            % prop_geom{i, 6} = cell_seccion{idx, 7};   & ajustes por cambio de Jacket a marco
        end
    end
    propiedades = prop_geom;

    %% BLOQUE: Columnas adicionales de tabla (wo_vector, gamma_beta_vector, tipo)
    % Creación de vector 'wo'
    altura = size(prop_geom, 1);
    wo_vector = cell(size(prop_geom, 1),1);
    for i = 1:altura
        wo_vector{i} = ['wo'];
    end
    % Creación de vector 'gamma y beta'
    gamma_beta_vector = zeros(size(prop_geom, 1),2);
    for i = 1:length(gamma_beta_vector)
        gamma_beta_vector(i,1) = 7.809E-09;
        gamma_beta_vector(i,2) = 0.65;
    end
    gamma_beta_vector = num2cell(gamma_beta_vector);
    % Adicionar 3 columnas más: de tipo de elementos, radio y espesor en mm
    % tipo de elemento
    tipo = cell(size(prop_geom, 1), 1);
    for i = 1:length(tipo)
        tipo{i} = ['circular'];
    end

    %% BLOQUE: Diámetros y espesores de todos las secciones transversales de la plataforma
    % SUBLOQUE: Diámetros y espesores de los elementos tubulares de la subestructura (vector_thickness y vecto_diametros)
    % diam y espesor de elemento
    % tabla de donde extraen los diametros y espesores de cada tipo de sección en el modelo
    hoja_excel = 'Frame Sec Def - Steel Pipe';
    tabla_diam_thick = readtable(archivo_excel, 'Sheet', hoja_excel);
    tabla_diam_thick(1,:) = [];
    tabla_diam_thick(:,2:3) = [];
    tabla_diam_thick(:,4:end) = [];
    % tabla con todas las secciones, su UniqueName y SECC correspondiente
    hoja_excel = 'Frame Assigns - Summary';
    tabla_frame_assigns_summary = readtable(archivo_excel, 'Sheet', hoja_excel);
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    tabla_filtrada = tabla_a_filtrar(indices, :);
    tabla_frame_assigns_summary = tabla_filtrada;
    tabla_frame_assigns_summary(1,:) = [];
    tabla_frame_assigns_summary(:,1:2) = [];
    tabla_frame_assigns_summary(:,2:4) = [];
    tabla_frame_assigns_summary(:,3:4) = [];
    tabla_frame_assigns_summary = sortrows(tabla_frame_assigns_summary);
    % luego se realiza una asignación y de cada elemento y sección con su diámetro y su espesor
    vector_diametros = zeros(height(tabla_frame_assigns_summary), 1);
    vector_thickness = zeros(height(tabla_frame_assigns_summary), 1);
    % Recorrer cada fila de tabla_frame_assigns_summary
    for i = 1:height(tabla_frame_assigns_summary)
        % Obtener el DesignSection de la fila actual
        design_section = tabla_frame_assigns_summary.DesignSection{i};
        % Encontrar la fila correspondiente en tabla_diam_thick
        indice = find(strcmp(tabla_diam_thick.Name, design_section));
        % Extraer OutsideDiameter y WallThickness
        if ~isempty(indice)
            vector_diametros(i) = tabla_diam_thick.OutsideDiameter(indice);
            vector_thickness(i) = tabla_diam_thick.WallThickness(indice);
        else
            % Si el DesignSection no se encuentra, puedes asignar un valor por defecto o manejarlo según sea necesario
            vector_diametros(i) = NaN;
            vector_thickness(i) = NaN;
        end
    end
    vector_diametros_sub = vector_diametros;
    vector_thickness_sub = vector_thickness;
    vector_diametros_sub = num2cell(vector_diametros_sub);
    vector_thickness_sub = num2cell(vector_thickness_sub);
    UniqueName = tabla_frame_assigns_summary(:,1);
    diam_diam_thick_tube_sub = horzcat(UniqueName, vector_diametros_sub, vector_diametros_sub, vector_thickness_sub);

    % Esta seccion se omite porque en el marco de estudio no existe superestructura 
    % SUBLOQUE: Diametros y espesores de los elementos elementos tubulares de la superestructura (vector_diametros_tube_super y vector_thickness__tube_super)
    hoja_excel = 'Frame Assigns - Summary';
    tabla_frame_assigns_summary = readtable(archivo_excel, 'Sheet', hoja_excel);
    tabla_frame_assigns_summary(1,:) = [];
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    tabla_a_filtrar(1,:) = [];
    indices = ~contains(tabla_a_filtrar.Story, 'Story');
    tabla_filtrada = tabla_a_filtrar(indices, :);
    indices = ~contains(tabla_filtrada.DesignType, 'Beam');
    tabla_filtrada = tabla_filtrada(indices, :);
    tabla_frame_assigns_summary_tube_super = tabla_filtrada;
    tabla_frame_assigns_summary_tube_super(:,1:2) = [];
    tabla_frame_assigns_summary_tube_super(:,2:4) = [];
    tabla_frame_assigns_summary_tube_super(:,3:end) = [];
    % luego se realiza una asignación y de cada elemento y sección con su diámetro y su espesor
    vector_diametros_tube_super = zeros(height(tabla_frame_assigns_summary_tube_super), 1);
    vector_thickness_tube_super = zeros(height(tabla_frame_assigns_summary_tube_super), 1);
    % Recorrer cada fila de tabla_frame_assigns_summary
    for i = 1:height(tabla_frame_assigns_summary_tube_super)
        % Obtener el DesignSection de la fila actual
        design_section = tabla_frame_assigns_summary_tube_super.DesignSection{i};
        % Encontrar la fila correspondiente en tabla_diam_thick
        indice = find(strcmp(tabla_diam_thick.Name, design_section));
        % Extraer OutsideDiameter y WallThickness
        if ~isempty(indice)
            vector_diametros_tube_super(i) = tabla_diam_thick.OutsideDiameter(indice);
            vector_thickness_tube_super(i) = tabla_diam_thick.WallThickness(indice);
        else
            % Si el DesignSection no se encuentra, puedes asignar un valor por defecto o manejarlo según sea necesario
            vector_diametros_tube_super(i) = NaN;
            vector_thickness_tube_super(i) = NaN;
        end
    end
    vector_diametros_tube_super = num2cell(vector_diametros_tube_super);
    vector_thickness_tube_super = num2cell(vector_thickness_tube_super);
    UniqueName = tabla_frame_assigns_summary_tube_super(:,1);
    diam_diam_thick_tube_super = horzcat(UniqueName, vector_diametros_tube_super, vector_diametros_tube_super, vector_thickness_tube_super);

    %%% Parte comentada - inicio: en el marco no hay vigas en I
    % % SUBLOQUE: Diámetros y espesores de los elementos IR de la superestructura (vector_diametros_I y vector_thickness_I)
    % hoja_excel = 'Frame Sec Def - Steel I';
    % tabla_diam_thick_I = readtable(archivo_excel, 'Sheet', hoja_excel);
    % tabla_diam_thick_I(1,:) = [];
    % tabla_diam_thick_I(:,1:4) = [];
    % tabla_diam_thick_I(:,3) = [];
    % tabla_diam_thick_I(:,3) = [];
    % tabla_diam_thick_I(:,4:end) = [];
    % hoja_excel = 'Frame Assigns - Summary';    
    % tabla_frame_assigns_summary_I = readtable(archivo_excel, 'Sheet', hoja_excel);
    % tabla_frame_assigns_summary_I(1,:) = [];
    % tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    % indices = ~contains(tabla_a_filtrar.Story, 'Story');
    % tabla_filtrada = tabla_a_filtrar(indices, :);
    % tabla_filtrada(1,:) = [];
    % tabla_filtrada = sortrows(tabla_filtrada, {'DesignType', 'UniqueName'});
    % indices = ~contains(tabla_filtrada.Label, 'C');
    % tabla_filtrada = tabla_filtrada(indices, :);
    % tabla_frame_assigns_summary_I = tabla_filtrada;
    % tabla_frame_assigns_summary_I(:,1:2) = [];
    % tabla_frame_assigns_summary_I(:,2:4) = [];
    % tabla_frame_assigns_summary_I(:,3:end) = [];
    % tabla_frame_assigns_summary_I = sortrows(tabla_frame_assigns_summary_I);
    % vector_diametros_I = zeros(height(tabla_frame_assigns_summary_I), 1);
    % vector_thickness_I = zeros(height(tabla_frame_assigns_summary_I), 1);
    % % Recorrer cada fila de tabla_frame_assigns_summary_I
    % for i = 1:height(tabla_frame_assigns_summary_I)
    %     % Obtener el DesignSection de la fila actual
    %     design_section = tabla_frame_assigns_summary_I.DesignSection{i};
    %     % Encontrar la fila correspondiente en tabla_diam_thick
    %     indice = find(strcmp(tabla_diam_thick_I.SectionInFile, design_section));
    %     % Extraer OutsideDiameter y WallThickness
    %     if ~isempty(indice)
    %         vector_diametros_I(i) = tabla_diam_thick_I.TotalDepth(indice);
    %         vector_thickness_I(i) = tabla_diam_thick_I.WebThickness(indice);
    %     else
    %         % Si el DesignSection no se encuentra, puedes asignar un valor por defecto o manejarlo según sea necesario
    %         vector_diametros_I(i) = NaN;
    %         vector_thickness_I(i) = NaN;
    %     end
    % end
    % vector_diametros_I = num2cell(vector_diametros_I);
    % vector_thickness_I = num2cell(vector_thickness_I);
    % UniqueName = tabla_frame_assigns_summary_I(:,1);
    % diam_diam_thick_I = horzcat(UniqueName, vector_diametros_I, vector_diametros_I, vector_thickness_I);
    % diam_diam_th = vertcat(diam_diam_thick_tube_sub, diam_diam_thick_tube_super, diam_diam_thick_I);
    % diam_diam_th = sortrows(diam_diam_th);
    % diam_diam_th = table2cell(diam_diam_th);
    % diam_diam_th(:,1) = [];
    %%% Parte comentada - fin: en el marco no hay vigas en I

    % SUBLOQUE: Pasos finales (prop_geom)
    % Concatenación final y conversión final de los cell arrays en matrices
        % Se realizan algunos ajustes finales para ahora que se cambio la estructura a un marco sencillo
    hoja_excel = 'Frame Assigns - Frame Auto Mesh';
    % Leer la columna "C" desde la fila 4 en adelante
    rango = 'C4:C200'; % Se asume un límite alto (ajusta si es necesario)
    % Extraer los datos numéricos de la columna sin importar el número de filas
    numero_frame = readmatrix(archivo_excel, 'Sheet', hoja_excel, 'Range', rango);
    numero_frame = numero_frame(~isnan(numero_frame));
    E_columna = E * ones(length(numero_frame), 1);
    G_columna = G * ones(length(numero_frame), 1);
    elementos = num2cell(numero_frame);
    elementos = string(elementos);
    prop_geom = cellfun(@num2str, prop_geom, 'UniformOutput', false);
    prop_geom = string(prop_geom);
    prop_geom = [elementos, prop_geom];
    prop_geom = sortrows(prop_geom);            % Matriz organizada con cada elemento y sus propiedades extraídas del ETABS
    % Conversion de tablas a celdas para poder concatenar
    diam_diam_thick_tube_sub(:,1) = [];
    diam_diam_thick_tube_sub_cell = table2cell(diam_diam_thick_tube_sub);
    % Convertir la matriz de cadenas a celda
    prop_geom_cell = cellstr(prop_geom);
    E_columna_cell = num2cell(E_columna);
    G_columna_cell = num2cell(G_columna);
    % Concatenación final de la matriz de diámetros y espesores
    prop_geom = [prop_geom_cell, E_columna_cell, G_columna_cell, tipo, wo_vector, diam_diam_thick_tube_sub_cell, gamma_beta_vector]; % ajustes por cambio de Jacket a marco, se omitio diam_diam_th
    % Ordenamiento de prop_geo, ascendentemente, con respeco a la primera columna
    columna_numerica = cellfun(@str2double, prop_geom(:,1));    % Convertir la primera columna de cell a número
    [~, orden] = sort(columna_numerica);                        % Obtener el orden de índices para ordenar
    prop_geom = prop_geom(orden, :);                   % Reorganizar el cell array según el orden obtenido    

    %% SECCION: pestaña "fix nodes"
    hoja_excel = 'Joint Assigns - Restraints';
    nodos_restringidos = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    nodos_restringidos = nodos_restringidos(any(~isnan(nodos_restringidos), 2), :);
    nodos_restringidos(:,1:2) = [];
    nodos_restringidos(:,2:7) = [];
    matriz_restriccion = ones(length(nodos_restringidos),6);                % se les agrega numeros porque asi va la estructura de las hojas de excel del dr. Rolando Salgado
    matriz_restriccion = horzcat(nodos_restringidos, matriz_restriccion);

    %% SECCION: pestaña "vxz"
    %% SECCION: Creacion automatica de vectores VXZ para cada elemento del modelo
    % Reuso de variables de Nodos y sus coordenadas
    % Se concatenó cada columna en función a su dirección
    % Las columnas rectas están orientas de manera distinta a las vigas y a las diagonales. Las vigas y diagonales tienen la misma orientación de ejes locales
    % el eje global es:
        % Z mirando hacia arriba
        % X mirando hasta adelante
        % Y mirando hasta atrás
        % Sugerencia: Mejor ver el eje global en el modelo de ETABS ya que no se sabe cuál es adelante y atrás realmente hasta que lo ves en el gráfico

    % Extración de que tipos son cada elemento frame (si viga, columna o elemento diagonal)
    hoja_excel = 'Frame Assigns - Summary'; % Nombre de la pestaña
    columna_texto = readcell(archivo_excel, 'Sheet', hoja_excel, 'Range', 'D:D');   % Lectura de qué tipo de elemento es cada 
    columna_texto(1:2,:) = [];              % Limpieza 
    matriz_ceros = zeros(size(columna_texto, 1), 3);
    for i = 1:length(columna_texto)  % Iterar sobre cada elemento del cell
        if strcmp(columna_texto{i}, 'Beam')
            matriz_ceros(i,3) = 1; % Añadir un 1 en el elemento 3 de la fila i
            % VXZ = 0 0 1
        elseif strcmp(columna_texto{i}, 'Column')
            matriz_ceros(i,1) = 1; % Añadir un 1 en el elemento 1 de la fila i
            % VXZ = 1 0 0
        end
    end
    matriz_num_vxz = matriz_ceros;
    % Números UniqueName de cada elemento frame para despues contatenar con cada tipo y organizar de menor a mayor.
    UniqueName_frame = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    UniqueName_frame = UniqueName_frame(:,3);
    UniqueName_frame(1) = [];
    VXZ = sortrows(horzcat(UniqueName_frame, matriz_num_vxz),1);
end
