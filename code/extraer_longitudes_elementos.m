function [num_de_ele_long, prop_geom] = extraer_longitudes_elementos(prop_geom, archivo_excel)
    % EXTRAER_LONGITUDES_ELEMENTOS - Extrae y organiza longitudes de vigas, diagonales y columnas.
    % 
    % Esta función lee la información de longitudes desde diferentes pestañas del
    % archivo Excel y las organiza en una sola matriz, ordenándolas de menor a mayor.
    %
    % Entrada:
    %   - archivo_excel: Nombre o ruta del archivo Excel que contiene los datos.
    %
    % Salida:
    %   - num_de_ele_long: Matriz con el número de elemento y su longitud, ordenada.

    % Eliminación de columnas innecesarias en prop_geom
    prop_geom(:,8:9) = []; % Eliminación de 'circular' y 'wo', para conversión numérica

    % Lectura y procesamiento de las vigas
    hoja_excel = 'Beam Object Connectivity';
    vigas_long = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    vigas_long(:,2:5) = []; % Eliminación de columnas innecesarias
    vigas_long(:,3) = [];

    % Lectura y procesamiento de las diagonales
    hoja_excel = 'Brace Object Connectivity'; % Pestaña con elementos diagonales (subestructura)
    brac_long = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    brac_long(:,2:5) = [];
    brac_long(:,3) = [];

    % Lectura y procesamiento de las columnas rectas
    hoja_excel = 'Column Object Connectivity'; % Pestaña con columnas rectas (superestructura)
    col_long = readmatrix(archivo_excel, 'Sheet', hoja_excel);
    col_long(:,2:5) = [];
    col_long(:,3) = [];

    % Concatenación y ordenamiento
    num_de_ele_long = sortrows(vertcat(vigas_long, brac_long, col_long), 1);
end
