function [documento_excel_dr_Rolando] = borrar_elementos_en_hoja(sheet_name)
    % Obtener el directorio actual
    directorio_actual = pwd;

    % Construir la ruta relativa al archivo Excel (subiendo un nivel)
    ruta_relativa = fullfile('..', 'pruebas_excel', 'marco3Ddam0.xlsx');

    % Construir la ruta completa del archivo Excel
    documento_excel_dr_Rolando = fullfile(directorio_actual, ruta_relativa);

    sheet_name2 = 'opensees';

    % Leer el contenido actual de la hoja
    data = xlsread(documento_excel_dr_Rolando, sheet_name2);

    % Obtener el tamaño de los datos
    [num_filas, num_columnas] = size(data);
    num_filas = num_filas * 20;
    num_columnas = num_columnas * 20;

    % Crear una matriz de celdas vacías del mismo tamaño que los datos originales
    empty_data = cell(num_filas, num_columnas);

    % Escribir la matriz de celdas vacías en el archivo Excel, sobrescribiendo el contenido actual
    xlswrite(documento_excel_dr_Rolando, empty_data, sheet_name);
end

