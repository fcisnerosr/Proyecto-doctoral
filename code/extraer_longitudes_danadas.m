function L_d = extraer_longitudes_danadas(archivo_excel, no_elemento_a_danar)
    % EXTRAER_LONGITUDES_DANADAS - Extrae y organiza longitudes de los elementos a dañar.
    %
    % Esta función lee la información de longitudes desde la pestaña 'Frame Assigns - Summary' 
    % en un archivo Excel, filtra los elementos que deben ser dañados y devuelve sus longitudes.
    %
    % Entradas:
    %   - archivo_excel: Nombre o ruta del archivo Excel que contiene los datos.
    %   - no_elemento_a_danar: Vector con los identificadores de los elementos a dañar.
    %
    % Salida:
    %   - L_d: Vector con las longitudes de los elementos a dañar.
    %% SECCION: Longitudes de elementos a dañar (long_elem_con_dano)
    hoja_excel = 'Frame Assigns - Summary';
    datos_tabla = readtable(archivo_excel, 'Sheet', hoja_excel);
    datos_tabla(1,:) = [];  % Eliminar encabezados

    % Extraer columnas de interés
    uniqueName = datos_tabla.UniqueName;  % Columna C
    length_mm = datos_tabla.Length;       % Columna E

    % Fusionar datos y ordenarlos
    datos_para_long = horzcat(uniqueName, length_mm);
    elementos_y_long = sortrows(datos_para_long, 1);

    % Extraer longitudes de los elementos a dañar
    long_elem_con_dano = zeros(length(no_elemento_a_danar), 1);
    for i = 1:length(no_elemento_a_danar)
        long_elem_con_dano(i) = elementos_y_long(no_elemento_a_danar(i), 2);
    end

    L_d = long_elem_con_dano;    
end
