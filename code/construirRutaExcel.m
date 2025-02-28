function archivo_excel = construirRutaExcel(carpeta, archivo)
    % Función para construir la ruta completa de un archivo Excel
    % 
    % Parámetros:
    %   carpeta: Nombre de la carpeta donde está el archivo
    %   archivo: Nombre del archivo Excel
    % 
    % Salida:
    %   archivo_excel: Ruta completa del archivo Excel
    
    directorio_actual = pwd; % Obtiene el directorio actual
    ruta_relativa = fullfile('..', 'pruebas_excel', 'ETABS_modelo', 'ETABS', carpeta, archivo);
    archivo_excel = fullfile(directorio_actual, ruta_relativa);
end
