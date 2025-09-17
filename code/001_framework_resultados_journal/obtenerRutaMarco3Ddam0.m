function pathfile = obtenerRutaMarco3Ddam0()
    % Función para obtener la ruta completa del archivo marco3Ddam0.xlsx
    %
    % Salida:
    %   pathfile: Ruta completa del archivo

    directorio_actual = pwd; % Obtiene el directorio actual
    ruta_relativa = fullfile('..', 'pruebas_excel', 'marco3Ddam0.xlsx'); % Ruta relativa fija
    pathfile = fullfile(directorio_actual, ruta_relativa); % Construcción de la ruta completa
end
