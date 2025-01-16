ddddfunction masas_en_cada_nodo = modificacion_matriz_masas_estructura_sencilla(archivo_excel)
    % Creación de la matriz de masas diagonal condensada de la estructura
    % Proceso de extracion de masas de la penstana de excel
    tabla_excel_masas = readmatrix(archivo_excel);  % Extracción de la pestana excel de masas del modelo
    masas_extraidas = tabla_excel_masas(:,4);       % Columna de masas extraidas
    
    % Proceso de eliminacion de los nodos empotrados
    nodos_masas_todos = unique(tabla_excel_masas(:, 2:3), 'rows', 'stable');     % Nodos (todos)
    pestana = 'Joint Assigns - Restraints';
    nodos_excel_empotrados = readmatrix(archivo_excel, 'Sheet', pestana);       % nodos empotrados con NaN
    nodos_excel_empotrados = nodos_excel_empotrados(:,3);                       % Nodos empotrados sin NaN
    nodos_empotrados = nodos_excel_empotrados(~isnan(nodos_excel_empotrados));  % nodos emportados y ordenados
    masas_con_nodos = horzcat(nodos_masas_todos, masas_extraidas);              % nodos con masa
    
    % Proceso de eliminacion de nodos con empotramiento
    filas_a_eliminar = ismember(masas_con_nodos(:,1), nodos_empotrados) & ismember(masas_con_nodos(:,2), nodos_empotrados);
    % Eliminar filas completas si ambas columnas contienen valores de nodos_empotrados
    masas_con_nodos(filas_a_eliminar, :) = [];
    % Reemplazar valores en las primeras dos columnas si están en nodos_empotrados sin eliminar la fila
    masas_con_nodos(:,1) = arrayfun(@(x) x * ~ismember(x, nodos_empotrados), masas_con_nodos(:,1));
    masas_con_nodos(:,2) = arrayfun(@(x) x * ~ismember(x, nodos_empotrados), masas_con_nodos(:,2));
    masas_con_nodos(masas_con_nodos(:,2) == 0, :) = [];
    masas_con_nodos(:,1) = [];      % Nodos involucrados (sin empotramiento) y con masa
    
    % Formacion de matriz diagonal de masas (con solo 3 gdl por efecto de la condensacion)
    masas_con_nodos = sortrows(masas_con_nodos, 1);
    valores = repelem(masas_con_nodos(:,2), 3, 1); % Repite cada valor 3 veces
    masas_en_cada_nodo = diag(valores); % Crea la matriz diagonal

end
