function [masas_en_cada_nodo] = modificacion_matriz_masas(archivo_excel, tirante, d_agua, matriz_cell_secciones, tiempo, densidad_crec)
%% Modificaciones a la matriz de masas
    %% SECCION: Preliminares de estracción de storys de la subestructra
    %% Bloque: Stories y stories acumulados
    % En este bloque se extraen los stories con sus respectivas profundidades y se calcula la profundidad acumulada de los stories de la superestructura
    hoja_excel = 'Story Definitions';   % Hoja con los stories de la estructura 
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Name, 'Super');
    tabla_filtrada = tabla_a_filtrar(indices, :);
    story = tabla_filtrada.Height;
    n = length(story); 
    story_vector = cell(length(story), 1); % Inicializar el vector columna.
    for i = 1:n
        story_vector{i} = ['story' num2str(i)]; % Concatenar "Story" con el número actual
    end
    story_vector = cellfun(@string, story_vector);
    story_matrix = horzcat(story_vector, story); % Vector columna con los n stories disponibles en el modelo

    % Contrucción de la profundidad acumulada
    prof_temporal = 0;
    for i = 1:n
        prof_temporal = prof_temporal + str2double(story_matrix(i,2));
        prof_acum(i)  = prof_temporal;
    end
    prof_acum = prof_acum';
    story_matrix = horzcat(story_matrix, prof_acum);    % Vector con los stories y sus profundidades acumuladas

    %% SECCION: MASA ATRAPADA HASTA EL PENÚLTIMO STORY AL QUE LLEGA EL TIRANTE:
        % Explicación: en esta sección se calcula masa atrapada en los nodos al story que llega el tirante, es decir,
        % no incluye cortes de distancias diagonales
   %% BLOQUE: Alturas y Story límite (story_limite)
    % Suma de altura acumulada
    i = 1;
    altura_acum = (str2double(story_matrix(:,3)));
    while i <= length(altura_acum)
        if tirante > altura_acum(i)            
        else
            story_limite = story_matrix(i-1,1); % Vector de stories con la primera letra minúscula. Sin embargo, este es un error es necesaria la primera letra en mayúscula para compararla con otra tabla de manera correcta
            break
        end
        i = i + 1;
    end
    % último story al cual rebaza el tirante de agua
    story_limite_minuscula = story_limite;
    % Conversión de la primera letra en mayúscula de la lista de Stories
    % Inicializar el vector para almacenar los "story"
    story_limite = {};
    % Iterar sobre la altura acumulada
    for i = 1:length(altura_acum)
        if tirante > altura_acum(i)
            story_limite = [story_limite; story_matrix(i, 1)];
        else
            break; % Detener la iteración cuando se alcanza la altura límite
        end
    end    
    % Número de elementos en la matriz
    numeroElementos = size(story_limite, 1);    
    % Crear una matriz de string vacía para la salida
    story_limite_mayuscula = cell(numeroElementos, 1);    
    % Recorrer cada elemento de la matriz
    for i = 1:numeroElementos
        primeraLetra = story_limite{i}(1);              % Obtener la primera letra del elemento actual
        primeraLetraMayuscula = upper(primeraLetra);    % Convertir la primera letra a mayúscula
        stringMayuscula = strcat(primeraLetraMayuscula, story_limite{i}(2:end));    % Concatenar la primera letra mayúscula con el resto del string    
        story_limite_mayuscula{i} = stringMayuscula;    % Asignar el string con la primera letra mayúscula a la matriz de salida
    end
    story_limite = story_limite_mayuscula;

    %% BLOQUE: UniqueName de los elementos tubulares y sus secciones (SECC_registr)
        % UniqueName son las etiquetas numeradas únicas que asigné en ETABS manualmente
    % En este bloque se calcula SECC_registr, matriz con los UniqueName de cada elemento y su sección correspondiente según el modelo de ETABS. Este proceso se
    % enfoca en la superestrucutra
    % SUBLOQUE: Estracción de diámetros exteriores y espesores
    % Espesores de cada elemento - Tabla de cada SECC.
    hoja_excel = 'Frame Sec Def - Steel Pipe';
    th_registr = readtable(archivo_excel, 'Sheet', hoja_excel);
    % Eliminación de columnas sobrantes
    th_registr(1, :) = [];
    th_registr(:, 2:3) = [];
    num_columnas = size(th_registr, 2);
    th_registr(:, 5:num_columnas) = [];
    th_registr(:, 4) = []; % Tabla final con todos los diámetros exteriores y espesores de SECC

    % SUBLOQUE: Estracción de diámetros exteriores y espesores
    % Importación de todos las secciones tubulares de todos los storys
    hoja_excel = 'Frame Assigns - Sect Prop';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    SECC_registr = tabla_a_filtrar(indices, :);
    % Filtración de las filas (junto con los elementos tubulares) que estén solo por debajo del último story del NMM
    % Obtener los valores únicos de 'Story' en SECC_registr
    stories_en_SECC_registr = SECC_registr.Story;
    % Encontrar las filas en SECC_registr cuyos valores en 'Story' no están en story_limite
    filas_a_eliminar = ~ismember(stories_en_SECC_registr, story_limite);
    % Eliminar las filas de SECC_registr que no están en story_limite
    SECC_registr(filas_a_eliminar, :) = [];
    SECC_registr(:,2) = [];
    SECC_registr(:,3) = [];
    SECC_registr(:,3) = [];
    SECC_registr(:,1) = [];

    %% BLOQUE: Cálculo de cell array que contiene cada UniqueName de cada elemento tubular, 
    %% entre qué nodos se encuentra y su longitud correspondiente (Total)
    % SUBLOQUE: Estracción de tabla de UniqueName, Story y nodos.  Este proceso se enfoca en la superestrucutra
    % Proceso de concatenacón de las longitudes de cada sección
    % Importación de todos las secciones tubulares de todos los storys
    hoja_excel = 'Brace Object Connectivity';
    Brace_registr = readtable(archivo_excel, 'Sheet', hoja_excel);
    % Obtener los valores únicos de 'Story' en SECC_registr
    stories_en_Brace_registr = Brace_registr.Story;
    % Encontrar las filas en SECC_registr cuyos valores en 'Story' no están en story_limite
    filas_a_eliminar = ~ismember(stories_en_Brace_registr, story_limite);
    % Eliminar las filas de SECC_registr que no están en story_limite
    Brace_registr(filas_a_eliminar, :) = [];    
    hoja_excel = 'Beam Object Connectivity';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    Beam_registr = tabla_a_filtrar(indices, :);

    % SUBLOQUE: Estracción de tabla de UniqueName, Story y nodos. Este proceso se enfoca en la superestrucutra
    % Obtener los valores únicos de 'Story' en SECC_registr
    stories_en_Beam_registr = Beam_registr.Story;
    % Encontrar las filas en SECC_registr cuyos valores en 'Story' no están en story_limite
    filas_a_eliminar = ~ismember(stories_en_Beam_registr, story_limite);
    % Eliminar las filas de SECC_registr que no están en story_limite
    Beam_registr(filas_a_eliminar, :) = [];
    Total = vertcat(table2cell(Brace_registr), table2cell(Beam_registr));
    Total(:,2) = [];
    Total(:,2) = [];
    Total(:,end) = [];

    %% BLOQUE: Tabla que contiene todos los elementos tubulares sumergidos, sus nodos, su longitud, su sección transversal, 
    %% así como diámetro exterior y espesor correspondiente (Tabla_completa)
        % "Tabla_completa" será usada para calcular la masa atrapada en el siguiente BLOQUE
    % SUBLOQUE: Tabla con los UniqueName, entre qué nodos se encuentra, su longitud correspondiente
    % su diámetro exterior y su espesor (Tabla_completa)
        % 'Total' es un cell que debe concatenarse con SECC_registr, pero el orden de ambos están dispersos.
    % Ambas matrices deben ser ordenadas y convertidas antes de ser concatenadas.
    % Organización y conversión de Total
    matrizTotal = cell2mat(Total);     
    Total_ordenada = sortrows(matrizTotal, 1);
    Total_ordenada_cell = num2cell(Total_ordenada);
    % Organización y conversión de Total
    SECC_registr_ordenada = sortrows(SECC_registr, 1);
    Tabla_secciones_masa_atrapada = horzcat(Total_ordenada_cell, SECC_registr_ordenada.SectionProperty);
    % Renombramiento de columnas para mejor entendimiento
    % Convertir el cell array en una tabla
    Tabla_secciones_masa_atrapada = cell2table(Tabla_secciones_masa_atrapada);
    Tabla_secciones_masa_atrapada.Properties.VariableNames = {'UniqueName', 'Nodo i', 'Nodo j', 'Long', 'SectionProperty'};
    % % Concatenación de las variables OutsideDiameter y WallThicknes a la Tabla_secciones_masa_atrapada
    % % Definición de Tabla_secciones_masa_atrapada y th_registr (ya definidos)
    Tabla_completa = join(Tabla_secciones_masa_atrapada, th_registr, 'LeftKeys', 'SectionProperty', 'RightKeys', 'Name');

    %% BLOQUE: Cálculo del peso de la masa atrapada de elementos sumergidos (masa_atrapada_nodal)
    % SUBLOQUE: Cálculo del volumen y masa de la masa atrapada en los nodos de cada elemento tubular
    for i = 1:height(Tabla_completa)
        r = 0.5 * (Tabla_completa.OutsideDiameter(i) - (2*Tabla_completa.WallThickness(i)));
        V(i) = pi * r^2 * Tabla_completa.Long(i);
    end
    vector_masas = (V * d_agua)';
    vector_masas_con_nodos = horzcat(vector_masas, Tabla_completa.("Nodo i"), Tabla_completa.("Nodo j"));   % Matriz usada para distribuir la mitad de la masa a los nodos correspondientes
    % SUBLOQUE: Repartición de cada masa/2 en cada nodo
    % Buscar no de nodo más grande
    no_mas_grande = vector_masas_con_nodos(:, end-1:end);
    vector_masas = no_mas_grande(:);
    [~, indice_maximo] = max(vector_masas);
    no_mas_grande = vector_masas(indice_maximo);
    % Proceso de asignación de cada masa atrapada a cada nodo de la estructura inferior al último nivel superior al NMM. Repartición de valores entre 2
    % Vector "valor" que contiene la división de cada v(i,1) entre 2
    valor = vector_masas_con_nodos(:, 1) / 2;
    % Vector para almacenar el resultado final
    resultado = zeros(no_mas_grande, 1);
    % Repartir cada elemento de "valor" en cada i elemento de V_masa
    for i = 1:size(vector_masas_con_nodos, 1)
        resultado(vector_masas_con_nodos(i, 2)) = resultado(vector_masas_con_nodos(i, 2)) + valor(i);
        resultado(vector_masas_con_nodos(i, 3)) = resultado(vector_masas_con_nodos(i, 3)) + valor(i);
    end      
    for i = 1:no_mas_grande
        nodo_masa(i) = i;
    end
    masa_atrapada_nodal = horzcat(nodo_masa',resultado); % Masa atrapada/2 a todos los nudos correspondientes. Exiten valores iguales a cero porque son los nodos que no están sumergidos por agua. Es decir superiores al NMM
    %% FIN DE LA SECCIÓN DE MASA ATRAPADA DE ELEMENTOS NO CORTADOS

    %% SECCIÓN: MASA ATRAPADA EN LOS ELEMENTOS DIAGONALES
        % Explicación: aquí se calculan las masas en los nodos de los elementos no incluidos en la sección anterior,
        % los elementos son los que van desde el story que el llega el tirante hasta el tirante, realiza un corte 
        % y calcula las distancias inclinadas.
    %% BLOQUE: Cálculo de las distancias inclinadas de cada elemento tubular (d_inc)
    % SUBLOQUE: Determinación del story siguiente a los elementos tubulares a cortar
    % Masa atrapada de elementos superiores al NMM
    story_matrix_inv = flipud(story_matrix);
    % Convierte solo la primera letra de cada cadena en la primera columna a mayúsculas
    story_matrix_inv_mayus = regexprep(story_matrix_inv, '^story', 'Story');
    % Cálculo de distancia inclinada en los elementos superiores al último story
    % Proceso de sumarle un 1 al siguiente story a fin de incluir los braces que están en el story superior
    story_limite = story_limite(end);
    numero_story = str2double(story_limite{1}(6:end));
    siguiente_numero = numero_story + 1;
    siguiente_story = strcat('Story', num2str(siguiente_numero));
    % SUBLOQUE: Extracción de todos los elementos de la subestructura.
    % Se usarán en el siguiente subloque para filtrarlos con el siguiente story de los elementos a cortar
    hoja_excel = 'Brace Object Connectivity';
    brace_story = readtable(archivo_excel, 'Sheet', hoja_excel);
    brace_story(:,3) = [];
    brace_story(:,3) = [];
    brace_story(:,3) = [];
    brace_story(:,4) = [];
    % SUBLOQUE: Determinación de los datos necesarios para 
    % Determinación de datos necesarios para calcular "dist", que es la distancia vertical ortogonal de los elementos a cortar
    % Tabla con los elementos que solo tienen el Story límite + 1 (el siguiente story con los elementos a cortar)
    tabla_filtrada = brace_story(strcmp(brace_story.Story, siguiente_story), :);
    % Ciclo donde se asigna hasta que límite está ubicado el último story
    for i = [1:length(story_matrix_inv_mayus)]
        if story_limite == story_matrix_inv_mayus(i,1)
            lim = story_matrix_inv_mayus(i,3);
        end
    end
    dist = tirante - str2num(lim);
    % SUBLOQUE: longitudes de distancias totales de los elementos a cortar y después el cálculo de "d_inc", que contiene los elementos cortados
    long = tabla_filtrada.Length; % Longitud de los elementos tubulares inclinados
    % distancia de los storys entre los que están los elementos inclinados después del Story límite hasta donde llega el NMM
    for i = [1:length(story_matrix_inv_mayus)]
        if story_limite == story_matrix_inv_mayus(i,1)
            Story = abs(str2num(story_matrix_inv_mayus(i+1,3)) - str2num(story_matrix_inv_mayus(i,3)));
        end
    end
    % Ciclo que calcula las distancias por encima del Story hasta donde llega el NMM
    for i = [1:length(long)]
        d_inc(i) = long(i)/Story * dist;    % d_inc = distancia inclinada
    end
    
    %% BLOQUE: Cálculo de la masa atrapada de los elementos cortados (m_atrapada_adicionales)
    % SUBLOQUE: Asignación de los diámetros exteriores y espesores según su tipo de sección para el cálculo del volumen y 
    % de la masa atrapada en elementos tubulares cortados (tabla_filtrada)
    % Subsubloque: 
    UniqueName_tabla = tabla_filtrada.UniqueName;
    nodos_matriz_cell = cell2mat(matriz_cell_secciones(:, 1));
    SECC_matriz_cell = matriz_cell_secciones(:, 2);
    % Inicializar una nueva columna en la tabla_filtrada para SECC
    tabla_filtrada.SECC_asignada = strings(height(tabla_filtrada), 1);    
    % Iterar sobre cada fila de tabla_filtrada
    for i = 1:height(tabla_filtrada)
        % Buscar el valor correspondiente en matriz_cell_secciones
        indice = find(nodos_matriz_cell == tabla_filtrada.UniqueName(i));
        % Si se encuentra el valor, asignar el SECC correspondiente
        if ~isempty(indice)
            tabla_filtrada.SECC_asignada(i) = SECC_matriz_cell{indice};
        end
    end
    % Crear una nueva columna en tabla_filtrada para OutsideDiameter y WallThickness
    tabla_filtrada.OutsideDiameter = zeros(height(tabla_filtrada), 1);
    tabla_filtrada.WallThickness = zeros(height(tabla_filtrada), 1);
     % Iterar sobre cada fila de tabla_filtrada
    for i = 1:height(tabla_filtrada)
        % Obtener la SECC_asignada para la fila actual
        SECC_actual = tabla_filtrada.SECC_asignada{i};

        % Buscar la correspondencia en th_registr
        indice_SECC = strcmp(th_registr.Name, SECC_actual);

        % Asignar los valores correspondientes de th_registr a tabla_filtrada
        tabla_filtrada.OutsideDiameter(i) = th_registr.OutsideDiameter(indice_SECC);
        tabla_filtrada.WallThickness(i) = th_registr.WallThickness(indice_SECC);
    end
    % Ciclo para calcular el volumen 
    for i = [1:height(tabla_filtrada)]
        r = 0.5*(tabla_filtrada.OutsideDiameter(i) - (tabla_filtrada.WallThickness(i)*2));
        Vol(i) = pi * r^2 * d_inc(i);
    end
    m_atrapada_adicionales = (Vol * d_agua)';

    %% BLOQUE: Asignación de los nodos a las masas atrapadas adicionales (m_atrapada_adicionaes_nod)
    hoja_excel = 'Brace Object Connectivity';
    brace_story_nod = readtable(archivo_excel, 'Sheet', hoja_excel);
    brace_story_nod(:,1) = [];
    brace_story_nod(:,2) = [];
    brace_story_nod(:,4) = [];
    brace_story_nod(:,4) = [];
    % Tabla de Story y entre qué nodos está de los Story que no salen en story_limite_mayuscula
    story_columna_brace_story_nod = brace_story_nod.Story;
    story_faltantes = setdiff(story_columna_brace_story_nod, story_limite_mayuscula);
    brace_story_nod_filtrada = brace_story_nod(ismember(story_columna_brace_story_nod, story_faltantes), :);
    brace_story_nod_filtrada = brace_story_nod_filtrada(:,2:3);
    brace_story_nod = table2array(brace_story_nod_filtrada);
    % Tabla final de las masas adicionales de la masa atrapada después del NMM y entre qué nodo se encuentran
    m_atrapada_adicionales_nod = horzcat(m_atrapada_adicionales,brace_story_nod);
    
    %% BLOQUE: Asignación de la masa en los nodos de los elementos cortados, del último story al NMM(masa_atrapada_nodal_del_ultimostory_al_NMM)
    % SUBLOQUE: Cálculo del número de nodo más grande (no_mas_grande)
    no_mas_grande = m_atrapada_adicionales_nod(:, end-1:end);
    vector_masas = no_mas_grande(:);
    [~, indice_maximo] = max(vector_masas);
    no_mas_grande = vector_masas(indice_maximo);
    % SUBLOQUE: Proceso de asignación de cada masa atrapada a cada nodo de la estructura inferior 
    % al último nivel superior al NMM. Repartición de valores entre 2 (masa_atrapada_nodal_del_ultimostory_al_NMM)
    % Vector "valor" que contiene la división de cada v(i,1) entre 2
    valor = m_atrapada_adicionales_nod(:, 1) / 2;
    % Vector para almacenar el resultado final
    resultado = zeros(no_mas_grande, 1);
    % Repartir cada elemento de "valor" en cada i elemento de V_masa
    for i = 1:size(m_atrapada_adicionales_nod, 1)
        resultado(m_atrapada_adicionales_nod(i, 2)) = resultado(m_atrapada_adicionales_nod(i, 2)) + valor(i);
        resultado(m_atrapada_adicionales_nod(i, 3)) = resultado(m_atrapada_adicionales_nod(i, 3)) + valor(i);
    end      
    for i = 1:no_mas_grande
        nodo_masa(i) = i;
    end
    masa_atrapada_nodal_del_ultimostory_al_NMM = horzcat(nodo_masa',resultado); % Masa atrapada/2 a todos los nudos correspondientes. Exiten valores iguales a cero porque son los nodos que no están sumergidos por agua. Es decir superiores al NMM
    %% FIN DE LA SECCIÓN DE MASA ATRAPADA DE ELEMENTOS CORTADOS
    
    %% SECCIÓN: MASAS EN CADA NODO DE LA SUBESTRUCTURA DEL MODELO EN ETABS
        %   Explicación: las masas en cada nodo son solo del peso propio de la estructura 
        %   y de las cargas adicionales que se le hayan asignado al modelo en ETABS, 
        %   no contiene ninguna modificación por la masa del agua de la parte sumergida
    
    %%  SECCION: Extracción de la masas en cada nodo de la SUBESTRUCTURA del modelo de ETABS (masas_en_cada_nodo)        
    hoja_excel = 'Assembled Joint Masses';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    masas_en_cada_nodo = tabla_a_filtrar(indices, :);
    masas_en_cada_nodo(:,1) = [];
    masas_en_cada_nodo = xlsread(archivo_excel, hoja_excel, '', 'A:A'); % Extracción de las masas del modelo de ETABS
    masas_en_cada_nodo(:, 1) = [];      % Eliminación de columnas inecesarias
    masas_en_cada_nodo(:, 3:end) = [];  % Eliminación de columnas inecesarias
    masas_en_cada_nodo = sortrows(masas_en_cada_nodo); % Se organizan porque son nodales
    masas_sin_agua = masas_en_cada_nodo;    % Valor usado para comprobocar cálculos
    %% FIN DE LA SECCIÓN DE EXTRACCIÓN DE LA MASA EN CADA NODO DE LA SUBESTRUCTURA DEL MODELO EN ETABS
    
    %% SECCION: CRECIMIENTO MARINO
        % Explicación: Cálculo del espesor del crecimiento marino y su el peso en cada nodo de la estrucutra en función a la profundidad del nodo
    %% BLOQUE: Ordenamiento de los story con sus alturas acumuladas de abajo hacia arriba (nivel_inv_con_suma)
        % NOTA IMPORTANTE: Se reutiliza story_limite_minuscula, y contiene todos los story cubiertos por el tirante de agua
    % SUBLOQUE: Convertir todos los elementos de story_matrix a minúsculas.
            % La razón de la conversión es que se comparar la variable que define hasta qué story llega el crec marino
            % y compararla con otros datos con "Story". Estos últimos tienen la S inicial mayúscula.
            % NOTA IMPORTANTE: "story_limite_minuscula" variable definida en la sección de Masa atrapada, de modo que reutiliza 
                              % la variable usada en la sección donde se calcular el último story al cual rebaza el tirante de agua
    numero_str = extractAfter(story_limite_minuscula, "story");
    numero = str2double(numero_str);
    nombres_stories = cell(numero, 1);
    for i = 1:numero
        nombres_stories{i} = "story" + num2str(i);
    end
    story_limite_minuscula = nombres_stories;
    len_limite_minuscula = length(story_limite_minuscula);
    len_matrix = size(story_matrix, 1);
    new_story_matrix = {};
    for i = 1:len_limite_minuscula
        current_story = story_limite_minuscula{i};
        idx = find(strcmp(story_matrix(:, 1), current_story));
        if ~isempty(idx)
            new_story_matrix = [new_story_matrix; story_matrix(idx, :)];
        end
    end
    new_story_matrix = string(new_story_matrix);
    new_story_matrix(:,3) = [];
    nivel_inv = flipud(new_story_matrix);
    % Suma de la profundidad acumulada desde el NMM hasta el fondo marino.
    [num_filas, num_columnas] = size(nivel_inv);
    suma_acumulativa = 0;
    nivel_inv_con_suma = strings(num_filas, num_columnas + 1);
    for i = 1:num_filas
        valor_actual = str2double(nivel_inv(i, 2));
        suma_acumulativa = suma_acumulativa + valor_actual;
        nivel_inv_con_suma(i, :) = [nivel_inv(i, :), num2str(suma_acumulativa)];
    end
    
    %% BLOQUE: Tabla con todos los elementos tubulares, sus SectionProperty, sus diámetros exteriores 
        % y espesores correspondientes sin sus longitudes correspondientes (Tabla_secc_datos_crecmar_sinlong)
        % NOTA: A esta tabla le hacen falta sus longitudes correspondientes, en el siguiente bloque se concatenan
    % Proceso de creación de tabla con diámetro y todos los story. 
    hoja_excel = 'Frame Assigns - Sect Prop';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    SECC_registr = tabla_a_filtrar(indices, :);
    SECC_registr(:,4) = [];
    SECC_registr(:,4) = [];
    % Proceso de eliminación de story que no es encuentra en el rango del crecimiento marino
    Tabla_secc_datos_crecmar_sinlong = join(SECC_registr, th_registr, 'LeftKeys', 'SectionProperty', 'RightKeys', 'Name');

    %% BLOQUE: Tabla con todos los elementos tubulares, sus SectionProperty, sus diámetros y longitudes correspondientes (Tabla_secc_datos_crecmar)
    % Proceso de concatenación de la longitud de cada elemento con crecimiento marino
    % Vigas
    hoja_excel = 'Brace Object Connectivity';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    Brace_registr = tabla_a_filtrar(indices, :);
    Brace_registr(:,end) = [];
    Brace_registr(:,3) = [];
    Brace_registr = table2cell(Brace_registr);
    % Columnas
    hoja_excel = 'Beam Object Connectivity';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    Beam_registr = tabla_a_filtrar(indices, :);
    Beam_registr(:,end) = [];
    Beam_registr(:,3) = [];
    Beam_registr = table2cell(Beam_registr);
    long_elementos = cell2table(vertcat(Brace_registr, Beam_registr));
    long_elementos.Properties.VariableNames = {'UniqueName', 'Story', 'Nodo i', 'Nodo j', 'Long'};
    % Concatenar la columna Long a Tabla_secc_datos_crecmar según su UniqueName
    Tabla_secc_datos_crecmar = join(Tabla_secc_datos_crecmar_sinlong, long_elementos(:, {'UniqueName', 'Long'}), 'Keys', 'UniqueName');
    
    %% BLOQUE: Profundid de arriba hacia abajo de la SUBESTRUCTURA hasta donde se desarrolla el crecimiento marino (ultima_ubi_crecamr)
    % SUBLOQUE: Modicicación de story_matrix (matriz de Storys) para poder usarla en la asignación de espesor a todos los elementos tubulares.
    % Conversión a cell, mayúscula en la primera letra de story, inversión de orden y suma acumulada
    story_matrix(:,3) = [];
    story_matrix = flipud(story_matrix);
    story_matrix(:, 2) = num2cell(str2double(story_matrix(:, 2)));
    story_matrix = cellstr(story_matrix);
    for i = 2:size(story_matrix, 1)
        story_matrix{i, 2} = num2str(str2double(story_matrix{i, 2}) + str2double(story_matrix{i-1, 2}));
    end
    for i = 1:numel(story_matrix)
        story_matrix{i} = regexprep(story_matrix{i}, '^s', upper(story_matrix{i}(1)));
    end
    for i = 1:size(story_matrix, 1)
        story_matrix{i, 2} = num2str(-str2double(story_matrix{i, 2}));
    end
    % Cálculo de la distancia de entre la subestructura y el tirante
    altura_total = sum(story);
    alt_menos_tirante = altura_total - tirante;
    % Story al que llega el tirante
    hoja_excel = 'Story Definitions';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Name, 'Super');
    story_complet = tabla_a_filtrar(indices, :);
    story_complet = story_complet(:, 1:2);
    % Suma acumulada de la columna Height
    acumulado = cumsum(story_complet.Height);
    story_complet.Acumulado = acumulado;
    story_complet(:,2) = []; %% Importante no modificiar este valor ya que se usa más adelante en el cálculo del crec mar.
    % Iterar sobre cada fila de la tabla story_complet para saber cuál es el primer story que abarca el crec mar
    for i = 1:height(story_complet)
        if alt_menos_tirante < story_complet.Acumulado(i)
            story_lim_crecmar_superior = story_complet.Name(i);
            break
        end
        if alt_menos_tirante > story_complet.Acumulado(i)
            story_lim_crecmar_superior = story_complet.Name(i);
        end
    end
    ultima_ubi_crecmar = alt_menos_tirante + 80000;     % 80,000 milímetros es la profundidad a la cual el crec marino se desarrolla a partir del NMM
        % Explicación de "ultima_ubi_crecmar": Si se calcula profunidad del último story superior de la SUBESTRUCTURA 
        % y se baja 80,000 milímetros, se tiene la profundad de desarrollo del crecimiento marino

    %% BLOQUE: Cálculo del story superior e inferior, que se desarrolla en crecimiento marino (superior, inferior)
        % Se usan en el siguiente BLOQUE
    for i = 1:height(story_complet)
        if ultima_ubi_crecmar < story_complet.Acumulado(i)
            story_lim_crecmar_inferior = story_complet.Name(i);
            break
        end
        if ultima_ubi_crecmar > story_complet.Acumulado(i)
            story_lim_crecmar_inferior = story_complet.Name(i);
        end
    end
    % Vector de story que abarca el crec marino
    superior = story_lim_crecmar_superior{1};
    inferior = story_lim_crecmar_inferior{1};

    %% BLOQUE: Modificación de tabla de elementos de crecimiento marino. Exclusión del último Story de dicha tabla (Tabla_secc_datos_crecmar)
        % Se eliminan las vigas en el último story, ya que no son cubiertas por el NMM y por tanto no se desarrolla crecimiento marino
    if strcmp(superior, inferior)
        vector_historia = {superior};
    else
        diferencia_indices = str2double(superior(end)) - str2double(inferior(end));
        vector_historia = cell(diferencia_indices + 1, 1);
        for i = 1:diferencia_indices + 1
            indice_historia = str2double(superior(end)) - i + 1;
            vector_historia{i} = ['Story' num2str(indice_historia)];
        end
    end
    Story_ultimo_crec_mar = vector_historia(1);
     % Modificación de Tabla_secc_datos_crecmar 
    % para excluir las vigas del Story_ultimo_crec_mar ya que no tendrán crecimiento marino.
    rows_to_remove = strcmp(Tabla_secc_datos_crecmar.Story, Story_ultimo_crec_mar) & startsWith(Tabla_secc_datos_crecmar.Label, 'B');
    Tabla_secc_datos_crecmar(rows_to_remove, :) = [];
    
    %% BLOQUE: Concatenación de los nodos y su UniqueName, de vigas y columnas, a la tabla de secciones de crecimiento marino (Tabla_secc_datos_crecmar)
        % Tabla_secc_datos_crecmar al final de este bloque, contiene todos los datos necesarios para el cálculo del crecimiento marino
    % SUBLOQUE: Elementos viga y sus nodos correspondientes excluidos del desarrollo del crecimiento marino (nodos_vigas)
        % nodos_vigas se usa en el siguiente bloque para extraer los elementos
    % Proceso de concatenación de elementos entre nodos
    hoja_excel = 'Beam Object Connectivity';
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices = ~contains(tabla_a_filtrar.Story, 'Super');
    nodos_vigas = tabla_a_filtrar(indices, :);
    nodos_vigas(:,2) = [];
    nodos_vigas(:,2) = [];
    nodos_vigas(:,4) = [];
    nodos_vigas(:,4) = [];
    % SUBLOQUE: Exclusión de las últimas vigas de la tabla con los elementos con crecimiento marino (Tabla_secc_datos_crecmar)
    %% IMPORTANTE:
    %%% INICIO DE BLOQUE DE CÓDIGO PARA OBSERVACIÓN
        % ESTE BLOQUE DE CÓDIGO NO FILTRA ELEMENTOS TIPO COLUMNA EN LA SUBESTRUCTURA YA QUE NO LOS HAY.
        % EN LA SUBESTRUCTURA SOLO EXISTEN ELEMENTROS BRACERS
        % EL PROGRAMA LEE LAS COLUMNAS RECTAS COMO COLUMNS POR LO QUE NO ES NECESARIO FILTRAR NINGUN ELEMENTO DIFERETE A VIGA ESTA SECCIÓN
        % EN CASO DE HABER BRACERS EN LA SUPERESTRUCTURA AHÍ SÍ ES NECESARIO FILTRARLOS DE LA TABLA.
    hoja_excel = 'Brace Object Connectivity';
    nodos_col = readtable(archivo_excel, 'Sheet', hoja_excel);
    nodos_col(:,2) = [];
    nodos_col(:,2) = [];
    nodos_col(:,4) = [];
    nodos_col(:,4) = [];
    nodos          = vertcat(nodos_vigas, nodos_col);
    Tabla_secc_datos_crecmar = join(Tabla_secc_datos_crecmar, nodos, 'Keys', 'UniqueName');
    %%% FIN DE BLOQUE DE CÓDIGO PARA OBSERVACIÓN
     
    %% BLOQUE: Alturas de cada nodo para cálculo de crecimiento marino en función de la profundidad (nodos_en_crecmar)
    % SUBLOQUE: Proceso de construcción de alturas de cada nodo
    % Extracción de alturas nodales
    hoja_excel          = 'Assembled Joint Masses';
    tabla_a_filtrar     = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices             = ~contains(tabla_a_filtrar.Story, 'Super');
    alturas_nodo        = tabla_a_filtrar(indices, :);
    alturas_nodo(:,1)   = [];
    alturas_nodo        = table2array(alturas_nodo);
    alturas_nodo        = alturas_nodo(:, [2, end]); % de la matriz 'double' alturas_nodo, se selecciona la última columna (alturas) y la segunda (UniqueName). Aunque en la hoja de excel se llama Point Element y no UniqueName.

    %% BLOQUE: Nodos en la subestructura (nodos_en_crecmar)
    % SUBLOQUE: Quitar los nodos que no se ven afectados por el crecimiento marino.
    nodos_en_crecmar = Tabla_secc_datos_crecmar(:,end-1:end);
    % en siguiente línea se concatenan las dos últimas columnas de Tabla_secc_datos_crecmar y eso genera nodos repeditos
    nodos_en_crecmar = vertcat(table2array(nodos_en_crecmar(:,1)),table2array(nodos_en_crecmar(:,2)));
    % Proceso para eliminar valores repetidos
    nodos_en_crecmar = unique(nodos_en_crecmar);    % nodos_en_crecmar contiene todos los nodos de la subestructura
        % nota: aunque aquí esten TODOS los nodos de la subestrucuta y no se haya hecho como tal un filtrado de los nodos que no son afectados por el crecimiento
        % marino, en el siguiente bloque se les asigna un valor de cero en caso de no ser tocados por el crecimiento marino

    %% BLOQUE: Profundidades de nodos de la subestructura (profundidad_nodos)
    % Proceso de quitar los nodos superiores que no son tocados por el NMM
    tabla_a_filtrar = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices         = ~contains(tabla_a_filtrar.Story, 'Super');
    tabla_completa  = tabla_a_filtrar(indices, :);
    Story_col       = tabla_completa.Story;
    for i = 1:length(Story_col)        
        if isequal(Story_ultimo_crec_mar, Story_col(i)) % Story_ultimo_crec_mar variable a donde llega el NMM
            break
        end
    end
    nodo = tabla_completa.Label(i);
    index = zeros(1,4);
    for j = 1:4
        if j == 1
            index = nodo;
        else
            nodo = nodo + 1;
            index(j) = [nodo];
        end        
    end
    nodos_a_quitar = index';
    nodos_en_crecmar = nodos_en_crecmar(~ismember(nodos_en_crecmar, nodos_a_quitar));
    % Nodos afectados por el crecimiento marino con sus coordenadas en z
    valores_asignados = zeros(size(nodos_en_crecmar));
    for i = 1:length(nodos_en_crecmar)
        indice = find(alturas_nodo(:,1) == nodos_en_crecmar(i));
        if ~isempty(indice)
            valores_asignados(i) = alturas_nodo(indice, 2);
        else
            valores_asignados(i) = NaN;
        end
    end
    profundidad_nodos = horzcat(nodos_en_crecmar,valores_asignados);
        % Explicación de qué significa profundidad_nodos hasta este punto
        % profundidad_nodos representa los nodos afectados por el crecimiento marino (sin los nodos cortados) con sus alturas nodales
        % alturas nodales son las coordenadas en el eje Z
    profundidad_nodos = sortrows(profundidad_nodos, 2, 'descend');
    % INTERRUPCIÓN DEL PROCESO. A PARTIR DE AQUÍ SE INICIA EL PROCESO DEL CÁLUCLO DE ALTURAS INCLINADAS DE LOS ELEMENTOS TUBULARES CORTADOS
    
    %% BLOQUE: Alturas inclinadas de los elementos cortados por el NMM (tabla_longcortada_nodos_crecmar)
        % Cálculo de la distancia nodal de los últimos elementos 'a cortar'
        % story_limite = es el último piso donde se encuentran completos los elementos. Último en referencia de NMM hacia el lecho marino
        % Creación de un cell donde se ecuentran todos los story con crec marino
    numero_story    = str2double(regexp(story_limite{1}, '\d+', 'match'));
    story_crecmar               = cell(numero_story, 1);
    for i = 1:numero_story
        story_crecmar{i} = ['Story', num2str(i)];
    end
    % Uso del story_crecmar para filtrar de Tabla_secc_datos_crecmar los elementos que no estén en story_crecmar.
    % De esta manera obtenemos los elementos que serán cortados para el cálculo del crec mar.
    % Verificar qué historias de story_crecmar no están presentes en Tabla_secc_datos_clong_irecmar
    filas_no_seleccionadas = ~ismember(Tabla_secc_datos_crecmar.Story, story_crecmar);
    Tabla_datos_cortar = Tabla_secc_datos_crecmar(filas_no_seleccionadas, :);
    % SUBLOQUE: datos necesarios para el cálculo de la longitud inclinada en el siguiente bloque (altura_crecmar)
        % Creación de vector de n dimensiones usado para almacenar las distancias inclinadas.
            % n es el número de elementos ubicados a 'cortar' entre últimos story. Últimos story que contiene los elementos cortados
        % Cálculo de altura de los últimos story. Últimos story que contiene los elementos cortados
            % altura_total  - variable con la altura total de la estructura. %% CUIDADO PORQUE SE ESTÁ SUMANDO TODOS LOS STORYS ES IMPORTANTE EXCLUIR LOS STORY QUE FORMAN PARTE DE LOS DECKS
            % tirante       - altura del tirante de agua. Del lecho marino al NMM
    hoja_excel              = 'Story Definitions';
    tabla_a_filtrar         = readtable(archivo_excel, 'Sheet', hoja_excel);
    indices                 = ~contains(tabla_a_filtrar.Name, 'Super');
    story_completo          = tabla_a_filtrar(indices, :);
    veccol_alt_completa     = story_completo.Height;
    acumulado               = flipud(cumsum(flipud(veccol_alt_completa)));
    alt_story_ultm          = acumulado(numero_story) - acumulado(numero_story+1);
    altura_ini_entre_story  = alt_story_ultm - alt_menos_tirante;
    altura_crecmar          = altura_ini_entre_story;
    % Explicación:
        % altura_ini_entre_story y altura_crecmar: valor entre el último story antes de "cortar" los elementos tubulares y el NMM
        % story_completo es una tabla con TODOS los story. Por todos son todos los Story de la subestructura
        % veccol_alt_completa son los valores de cada algura de nuvel de story_completo
        % altura_ini_entre_story distancia entre el NMM y el último story (de abajo hacia arriba). Dicho story es el antes de que se "corten" los elementos
        % tubulares con crecimiento marino
        % acumulado suma acumulada de storys. Desde el primero (más cercano al lecho marino) hasta el último antes de que "corten" los elementos tubulares con
        % crecmar
    % SUBLOQUE: Proceso de "cortar" los elementos tubulares
    long_incli = zeros(height(Tabla_datos_cortar),1); % Vector cuya longitud son los números de elementos inclinados. Ya que almacenará tantas distancias inclinados como tantos elementos inclinados a "cortar" haya
    for i = 1:length(long_incli)
        long_incli(i) = altura_crecmar * Tabla_datos_cortar.Long(i) / alt_story_ultm;
        %%%%%  Explicación long_incli = % Vector con distancias de elementos verticales cortados
    end
    long_incli = Tabla_datos_cortar.Long - long_incli;
    matriz_longcorta_nodos_crecmar = horzcat(long_incli, Tabla_datos_cortar.UniquePtI, Tabla_datos_cortar.UniquePtJ);
    % Conversión a tabla        
    nombres_columnas = {'long_crec_mar_inclinada', 'nodo_i', 'nodo_j'};
    tabla_longcortada_nodos_crecmar = array2table(matriz_longcorta_nodos_crecmar, 'VariableNames', nombres_columnas);

    %% BLOQUE: Profundidad de cada nodo a partir del NMM (referencia_altura)
        % REGRESO DEL PROCESO: Proceso del cálculo de actualización de profundidad nodos. Explicación:
        % En dicha actualización de profundidad_nodos se calcula la profundidad de cada nodo a apartir de donde está el NMM        
    % Cálculo de altura del lecho marino al story antes de los elementos cortados para la altura de referencia
    % Verificar qué historias de story_crecmar no están presentes en Tabla_secc_datos_clong_irecmar
    filas_no_seleccionadas  = ismember(story_completo.Name, story_crecmar);
    Story_alturas_crecmar   = story_completo(filas_no_seleccionadas, :);
    altura_story_crecmar    = sum(Story_alturas_crecmar.Height);
    referencia_altura       = zeros(length(profundidad_nodos),1);
    % Explicación de las variables:
        % Story_alturas_crecmar es una tabla de los story de profundidades de cada nivel antes de los elementos cortados
        % altura_story_crecmar  es la suma dichos niveles de Story_alturas_crecmar
    for i = 1:length(profundidad_nodos)
        referencia_altura(i) = ( altura_story_crecmar  + altura_ini_entre_story + 1000) - profundidad_nodos(i,2);    % Se le suma 1000 a partir del NMM por la variabilidad del NMM. Además de que lo marcan las NTR de PEMEX
        if referencia_altura(i) < 0
            referencia_altura(i) = 0;     % Este condicional se establece a fin de eliminar las distancias negativas, resultado de los nodos superiores de donde inicia el crecimiento marino. Al hacerlos cero se establece que no hay crecimiento marino en esos puntos.
        end
    end
    
    %% BLOQUE: Profundidad del NMM al lecho marino (profundidad_nodos)
    % Explicación de qué significa profundidad_nodos hasta este punto
        % profundidad_nodos representa las profundidades de arriba hacia abajo, a apartir de donde se cortan los elementos tubulares
        % alturas nodales son las coordenadas en el eje Z
        % NOTA:El filtrado de los nodos que llegan hasta abajo se hace en bloques más adelante,
        %      cuando el espesor del crecimiento marino equivaldría a cero respectivamente
    profundidad_nodos = horzcat(profundidad_nodos(:,1),referencia_altura);
    % Conversión a profundidad_nodos a tabla        
    nombres_columnas = {'Nodo', 'Profundidad a partir del NMM al lecho marino en mm'};
    tabla_nodos_delNMM_a_lech = array2table(profundidad_nodos, 'VariableNames', nombres_columnas);

    %% BLOQUE: Longitudes en nodos de los elementos inclinados (long_incli_nodos)
    % Repartir cada elemento de matriz_longcorta_nodos_crecmar a cada nodo
    valor = matriz_longcorta_nodos_crecmar(:, 1) / 2; % se divide entre dos por ser longitud nodal
    for i = 1:size(matriz_longcorta_nodos_crecmar, 1)
        resultado(matriz_longcorta_nodos_crecmar(i, 2)) = resultado(matriz_longcorta_nodos_crecmar(i, 2)) + valor(i);
        resultado(matriz_longcorta_nodos_crecmar(i, 3)) = resultado(matriz_longcorta_nodos_crecmar(i, 3)) + valor(i);
        % "resultado" es un vector columna en los que se van distribuyendo los valores de matriz_longcorta_nodos_crecmar
        % "resultado" cuenta con ceros ya que hay nodos de las dos columnas de matriz_longcorta_nodos_crecmar que no se ven afectados por el crec marino con
        % profundidades inclinadas
        % El vector columna "resultado" tiene solo los valores sin sus nodos
    end
    % Preparación 
        % % El vector columna "resultado" tiene solo los valores sin sus nodos, se le concatenará sus nodos en dicha matriz a fin de sumarla con la matriz de long
        % nodal
    indice = (1:length(resultado))';
    % Matriz con longitudes nodales inclinadas que se adiciona más adelante a "long_nodal"
    long_incli_nodos = [indice resultado];
    
    %% BLOQUE: Nodos, profundidades y espesores de crecimiento marino (nodos_y_esp)
    % Proceso de asignación de los espesores a diferentes profundiadades
    h = story_complet.Acumulado(end);
    prof_inicial_crec = (h - tirante); 
        % % h = altura total de la estructura
        % NOTA:La profundidad h es de la subestructura 
     esp_nodos = zeros(length(profundidad_nodos),1); % Vector de espesores que le corresponderán a cada nodo según su profundidad
    % Calculamos el espesor para cada nodo en función de los 20 años (tiempo límite de diseño)
    factor_esp1 = 75/20;   % 75 mm es espesor de diseño en 20 años
    factor_esp2 = 50/20;   % 50 mm es espesor de diseño en 20 años
    factor_esp3 = 35/20;   % 35 mm es espesor de diseño en 20 años
    % Espesor en función del tiempo
    esp1 = tiempo * factor_esp1;
    esp2 = tiempo * factor_esp2;
    esp3 = tiempo * factor_esp3;
    % SUBLOQUE: asignación de profundidades en cada nodo en función a su profundidad
    for i = 1:length(profundidad_nodos)
        % Condicionales que asigna el espesor en función de la profundidad
        if     profundidad_nodos(i,2) <= 20*1000
            esp_nodos(i) = esp1;
        elseif profundidad_nodos(i,2) >  20*1000 && profundidad_nodos(i,2) <= 50*1000
            esp_nodos(i) = esp2;
        elseif profundidad_nodos(i,2) >  50*1000 && profundidad_nodos(i,2) <= 80*1000
            esp_nodos(i) = esp3;
        else
            esp_nodos(i) = 0;
        end
        % Condicional que hace que los nodos arriba del NMM equivalgan a cero
        if referencia_altura(i) == 0
            esp_nodos(i) = 0;
        end
    end
    nombres_columnas = {'Nodo', 'Prof (mm)', 'Espesor (mm)'};
    nodos_y_esp = horzcat(profundidad_nodos,esp_nodos);
    nodos_y_esp_tabla = array2table(nodos_y_esp, 'VariableNames', nombres_columnas);
    
    %% BLOQUE: Nodos de los elementos tubulares afectados por el crecimiento marino,
    %% son concatenados en el siguiente bloque junto con el cálculo de la longitud nodal (col1)
    % Cálculo de longitudes nodales del crecimiento marino
        % Nota: es importante usar las longitudes que están en Tabla_secc_datos_crecmar 
        % ya que estas son las longitudes inclinadas.
    % SUBLOQUE: longitudes de los elementos de la subestructura afectados por el crecimient marino y entre qué nodos se encuentra
    long_y_nodos = Tabla_secc_datos_crecmar(:,7:9); 
    long_y_nodos = table2array(long_y_nodos);          % longitudes de los elementos afectados por el crecimiento marino y entre qué nodos se encuentran
    % Nodo de mayor valor dentro de long_y_nodos
    maximo = max(long_y_nodos(:, 2:3), [], 'all');
    col1 = zeros(maximo,1);
    for i = 1:maximo
        col1(i) = i;
    end

    %% BLOQUE: Longitud nodal de los elementos tubulares afectados por el crecimiento marino (long_nodal)
    % Proceso de asignación de longitud nodal a cada nodo
    % la longitud nodal es dividia entre dos
    valor = long_y_nodos(:, 1) / 2;
    % Vector para almacenar el resultado final
    long_nodal = zeros(maximo, 1);
    for i = 1:size(long_y_nodos, 1)
        long_nodal(long_y_nodos(i, 2)) = long_nodal(long_y_nodos(i, 2)) + valor(i);
        long_nodal(long_y_nodos(i, 3)) = long_nodal(long_y_nodos(i, 3)) + valor(i);
    end  
    % Adición de las longitudes nodales inclinadas
    long_nodal = long_nodal + long_incli_nodos(:,2);
    long_nodal = horzcat(col1,long_nodal);

    %% BLOQUE: Nodos, profundidad desde el NMM, espesor y longitud nodal. Todas las longitudes en milímetros (nodos_y_esp_concatenado)
    % Proceso de asignación de armado de matriz para el cálculo de la masa del crecimiento marino en nodos
    % En dicha tabla hay:
        % nodos
        % profundidad nodal
        % espesores variables a cierta profundidad
        % long nodal (ya con las longitudes inclinadas)
    valores_asignados = zeros(size(nodos_y_esp, 1), 1);
    for i = 1:size(nodos_y_esp, 1)
        numero_nodo = nodos_y_esp(i, 1);
        indice = find(long_nodal(:, 1) == numero_nodo);
        if ~isempty(indice)
            valores_asignados(i) = long_nodal(indice, 2);
        end
    end
    % Matriz
    nodos_y_esp_concatenado = [nodos_y_esp, valores_asignados];
    % Tabla:
    nombres_columnas = {'Nodo', 'Profundidad NMM en mm', 'Espesor (mm)', 'Longitud nodal (mm)'};
    tabla_nodos_y_esp_concatenado = array2table(nodos_y_esp_concatenado, 'VariableNames', nombres_columnas);
    
    %% BLOQUE: Repeticiones de un elemento tubular en un nodo (repeticiones)
    % Proceso para saber cuántas veces un nodo aparece en la tabla Tabla_secc_datos_crecmar para multiplicarlo en el cálculo
    nodos_a_evaluar = nodos_y_esp_concatenado(:,1);
    tabla_de_nodos  = table2array(Tabla_secc_datos_crecmar(:,8:9));
    numeros_unicos = unique(nodos_a_evaluar);
    repeticiones = zeros(size(numeros_unicos));
    for i = 1:length(numeros_unicos)
        repeticiones_en_columna_1 = sum(tabla_de_nodos(:, 1) == numeros_unicos(i));
        repeticiones_en_columna_2 = sum(tabla_de_nodos(:, 2) == numeros_unicos(i));
        repeticiones(i) = repeticiones_en_columna_1 + repeticiones_en_columna_2;
        % "repeticiones" es un vector columna que marca las repeticiones de un elemento en un nodo
    end

    %% BLOQUE: Nodos, profundidad, espesor y repeticiones de un elemento tubular en un nodo (nod_datos)
    % SUBLOQUE: Proceso de cálculo de cuántas repeciones de seccciones hay en cada nodo
    v1 = zeros(length(numeros_unicos),1);
    v2 = zeros(length(numeros_unicos),1);
    for i = 1:length(numeros_unicos)
        v1(i) = numeros_unicos(i);
        v2(i) = repeticiones(i);
        % fprintf('El número %d se repite %d veces en tabla_de_nodos.\n', numeros_unicos(i), repeticiones(i));
    end
    nodos_y_repeticiones = horzcat(v1,v2);
    % SUBLOQUE: Proceso de buscar las repeticiones en nodos_y_repeticiones y concatenarlos en nodos_y_esp_concatenado
    nod_datos = nodos_y_esp_concatenado;
    for i = 1:size(nodos_y_esp_concatenado, 1)
        valor_actual = nod_datos(i, 1);
        indice = find(nodos_y_repeticiones(:, 1) == valor_actual);
        nod_datos(i, 4) = nodos_y_repeticiones(indice, 2);
    end

    %% BLOQUE: Nodos, profundidad, espesor, longitud nodal y el diámetro promedio de todos los elementos tubulares (nod_datos)
    % Asignación de diámetro nodal - mediante un promedio de todos los diámetros en la estructura
   diam     = table2array(Tabla_secc_datos_crecmar(:,5));
   diam     = horzcat(tabla_de_nodos,diam);
   diam_cat = zeros(size(diam,1),1);
    for i = 1:size(diam, 1)
        diam_cat(diam(i, 1), diam(i, 2)) = diam(i, 3);
        diam_cat(diam(i, 2), diam(i, 1)) = diam(i, 3);
    end
    non_zero_elements = nonzeros(diam_cat);
    non_zero_elements = unique(non_zero_elements);
    prom              = mean(non_zero_elements);
    esp_nodal         = prom * ones(length(nod_datos), 1);
    nod_datos         = horzcat(nod_datos, esp_nodal);
    % Tabla 
    nombres_columnas = {'Nodo', 'Profundidad NMM en mm', 'Espesor (mm)', 'Longitud nodal (mm)', 'Diam promedio (mm)'};
    tabla_nod_datos  = array2table(nod_datos, 'VariableNames', nombres_columnas);

    %% BLOQUE: Cálculo de la masa del crecimiento marino en los nodos (M_crecmar_nod)
    % Cálculo del área transversal, volumen y espesores. Todos debidos al crecimiento marino
    % Declaración de variables con ceros donde irán almacennadoce los valores de cálculo
    A             = zeros(length(nod_datos),1); % área externa
    a             = A;                          % area interna
    At            = A;                          % área total
    V_crecmar     = A;                          % volumen del crecimiento marino    
    for i = 1:length(nod_datos)
        % un solo elemento tubular
            % Área
            A(i) = pi * ((nod_datos(i,5)*0.5) + (nod_datos(i,3)*0.5))^2;    % externa
            a(i) = pi *  (nod_datos(i,5)*0.5)^2;                            % interna
            At(i)= A(i)-a(i);                                               % total
            % Volumen   
            V_crecmar = At * nod_datos(i,2);
        % n elementos tubualres
            V_crecmar = V_crecmar * nod_datos(i,4);
    end
    % Matriz
    M_crecmar = densidad_crec * V_crecmar;
    M_crecmar_nod = horzcat(nod_datos(:,1),M_crecmar);
    % Tabla
    nombres_columnas = {'Nodo', 'masa del crec. marino (kg)'};
    tabla_nodos_y_esp_concatenado = array2table(M_crecmar_nod, 'VariableNames', nombres_columnas);
    
    %% SECCION: MASA ADHERIDA
    %% BLOQUE: Cálculo del volumen de la masa adherida
        % De la SECCIÓN: MASA ATRAPADA HASTA EL PENúLTIMO SORY AL QUE LLEGA EL TIRANTE, 
        % se trae la variable Tabla_completa, contiene los elementos cubiertos por el NMM:
            % de dichos elementos se tiene: UniqueName, long, SectionProperty, diámetro, espesor y entre qué nodos se encuentra
    Vol_masaad = zeros(height(Tabla_completa),1);
    for i = 1:height(Tabla_completa)
        R = Tabla_completa.OutsideDiameter(i)*0.5;
        r = (Tabla_completa.OutsideDiameter(i) - (2*Tabla_completa.WallThickness(i)))*0.5;
        A = (pi * R^2) - (pi * r^2);
        Vol_masaad(i) = Tabla_completa.Long(i) * A;
        % El volumen calculado aquí, es el volumen que desplaza la estructura la estructura,
        % todo esto, sin considerar nada del volumen de la masa atrapada dentro de los elementos tubulares
    end

    %% BLOQUE: Masa adherida, sin nodos (Masaadd)
    % SUBLOQUE: proceso de creación del Cb = 1.2 para elementos con crecimiento marino
        % "Tabla_completa" contiene todos los elementos tubulares sumergidos
    % Nodos de la tabla completa
    nodos1 = table2array(Tabla_completa(:, 2));
    nodos2 = table2array(Tabla_completa(:, 3));
    Cb = zeros(size(nodos1));
    for i = 1:length(nodos1)
        nodo1 = nodos1(i);
        nodo2 = nodos2(i);
        nodo1_index = find(nod_datos(:, 1) == nodo1);
        nodo2_index = find(nod_datos(:, 1) == nodo2);
        if nod_datos(nodo1_index, 3) == 0 && nod_datos(nodo2_index, 3) == 0
            Cb(i) = 1.6;  % Si ambos son cero
        else
            Cb(i) = 1.2;  % Si no, asignar 1.2 a Cb
        end
    end
    Masaadd = Vol_masaad .* Cb * d_agua;

    %% BLOQUE: Masa adherida nodal (masaadd_nodal)
    % SUBLOQUE: Masa adherida y entre qué nodos se encuentra
    nodos = table2array(Tabla_completa(:,2:3));
    matriz_masaadd_con_nodos = horzcat(Masaadd,nodos);
    % SUBLOQUE: Asignación de masa nodal
    % Buscar no de nodo más grande
    no_mas_grande = matriz_masaadd_con_nodos(:, end-1:end);
    vector_masasadd = no_mas_grande(:);
    [~, indice_maximo] = max(vector_masasadd);
    no_mas_grande = vector_masasadd(indice_maximo);
    % Proceso de asignación de cada masa adherida a cada nodo de la estructura inferior al último nivel superior al NMM. Repartición de valores entre 2
    % Vector "valor" que contiene la división de cada v(i,1) entre 2
    valor = matriz_masaadd_con_nodos(:, 1) / 2;
    % Vector para almacenar el resultado final
    resultado = zeros(no_mas_grande, 1);
    nodo_masaadd = resultado;
    % Repartir cada elemento de "valor" en cada i elemento de V_masa
    for i = 1:size(matriz_masaadd_con_nodos, 1)
        resultado(matriz_masaadd_con_nodos(i, 2)) = resultado(matriz_masaadd_con_nodos(i, 2)) + valor(i);
        resultado(matriz_masaadd_con_nodos(i, 3)) = resultado(matriz_masaadd_con_nodos(i, 3)) + valor(i);
    end    
    for i = 1:no_mas_grande
        nodo_masaadd(i) = i;
    end
    masaadd_nodal = horzcat(nodo_masaadd,resultado); % Masa atrapada/2 a todos los nudos correspondientes. Exiten valores iguales a cero porque son los nodos que no están sumergidos por agua. Es decir superiores al NMM

    %% SECCION: Suma de masas adicionales a las masas nodales del modelo en ETABS (masas_en_cada_nodo)
    % SUBLOQUE: Suma de masa atrapada
    % SUBSUBLOQUE: Suma de los elementos no cortados
        % Proceso de suma de las masas adicionales a cada nodo
        % Buscar el elemento i,1 en masas_en_cada_nodo y usar el i,2 para sumarlo al i,2 de masas_en_cada_nodo
        for i = 1:size(masa_atrapada_nodal, 1)
            idx = find(masas_en_cada_nodo(:, 1) == masa_atrapada_nodal(i, 1));
            masas_en_cada_nodo(idx, 2) = masas_en_cada_nodo(idx, 2) + masa_atrapada_nodal(i, 2);
        end
    % SUBSUBLOQUE: Suma de las masas de los elementos cortados
        for i = 1:size(masa_atrapada_nodal_del_ultimostory_al_NMM, 1)
            idx = find(masas_en_cada_nodo(:, 1) == masa_atrapada_nodal_del_ultimostory_al_NMM(i, 1));
            masas_en_cada_nodo(idx, 2) = masas_en_cada_nodo(idx, 2) + masa_atrapada_nodal_del_ultimostory_al_NMM(i, 2);
        end
    % SUBLOQUE: Suma de la masa por crecimiento marino
        % Proceso de suma de las masas adicionales por el crecimiento marino
        for i = 1:size(masas_en_cada_nodo, 1)
            idx = find(M_crecmar_nod(:,1) == masas_en_cada_nodo(i,1));
            if ~isempty(idx)
                masas_en_cada_nodo(i,2) = masas_en_cada_nodo(i,2) + M_crecmar_nod(idx,2);
            end
        end
    % SUBLOQUE: Suma de la masa adherida
            % Proceso de suma de las masas adicionales por la masa adherida
        for i = 1:size(masas_en_cada_nodo, 1)
            idx = find(masaadd_nodal(:,1) == masas_en_cada_nodo(i,1));
            if ~isempty(idx)
                masas_en_cada_nodo(i,2) = masas_en_cada_nodo(i,2) + masaadd_nodal(idx,2);
            end
        end
end
