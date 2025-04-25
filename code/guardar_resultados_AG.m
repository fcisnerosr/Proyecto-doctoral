function guardar_resultados_AG(Resultado_final, no_elemento_a_danar, dano_porcentaje, tiempo_ejecucion, ID_Ejecucion, P)
% Guarda resultados de AG en Excel, incluyendo archivos adicionales por variable

    %% Archivo principal con nombre dinámico
    archivo_excel = obtenerRutaResultadosAG(ID_Ejecucion);  % Usa el ID para nombrar el archivo

    % Crear carpeta si no existe
    carpeta = fileparts(archivo_excel);
    if ~exist(carpeta, 'dir')
        mkdir(carpeta);
    end

    %% HOJA 1: Resumen
    elementos_txt = join(string(no_elemento_a_danar), ', ');
    porcentajes_txt = join(string(dano_porcentaje), ', ');

    fila_resumen = {
        datetime('now'), ...
        elementos_txt, ...
        porcentajes_txt, ...
        tiempo_ejecucion
    };
    encabezados = {'Fecha', 'Elementos_dañados', 'Porcentaje_dañado', 'Tiempo_ejecución_s'};
    writecell(encabezados, archivo_excel, 'Sheet', 'Resumen', 'Range', 'A1');
    writecell(fila_resumen, archivo_excel, 'Sheet', 'Resumen', 'Range', 'A2');

    %% HOJA 2: Daño por nodo
    Resultado_final.ID_Ejecucion = repmat(ID_Ejecucion, height(Resultado_final), 1);
    writetable(Resultado_final, archivo_excel, 'Sheet', 'Daño_nodos', 'WriteMode', 'replacefile');

    %% HOJA 3: Elementos dañados
    tabla_danios = table( ...
        repmat(ID_Ejecucion, length(no_elemento_a_danar), 1), ...
        no_elemento_a_danar(:), ...
        dano_porcentaje(:), ...
        repmat(tiempo_ejecucion, length(no_elemento_a_danar), 1), ...
        'VariableNames', {'ID_Ejecucion', 'Elemento', 'Porcentaje_de_Daño', 'Tiempo_ejecución_s'} ...
    );
    writetable(tabla_danios, archivo_excel, 'Sheet', 'Elementos_dañados', 'WriteMode', 'replacefile');

    %% 📁 Archivos adicionales por variable

    % no_elemento_a_danar_ID.xlsx
    archivo1 = fullfile(carpeta, sprintf('no_elemento_a_danar_%d.xlsx', ID_Ejecucion));
    writematrix(no_elemento_a_danar(:), archivo1);

    % dano_porcentaje_ID.xlsx
    archivo2 = fullfile(carpeta, sprintf('dano_porcentaje_%d.xlsx', ID_Ejecucion));
    writeMatrixWithHeader(archivo2, dano_porcentaje(:), "Porcentaje_de_Daño");

    % P_ID.xlsx
    archivo3 = fullfile(carpeta, sprintf('P_%d.xlsx', ID_Ejecucion));
    writeMatrixWithHeader(archivo3, P, "P");
    
    % Resultado_final_ID.xlsx
    archivo4 = fullfile(carpeta, sprintf('Resultado_final_%d.xlsx', ID_Ejecucion));
    writetable(Resultado_final, archivo4);

    fprintf("✅ Archivos guardados correctamente en: %s\n", carpeta);
end

% Ruta principal para archivo general
function pathfile = obtenerRutaResultadosAG(ID)
    directorio_actual = pwd;
    nombre_archivo = sprintf('resultados_AG_ID%d.xlsx', ID);
    ruta_relativa = fullfile('..', 'resultados', nombre_archivo);
    pathfile = fullfile(directorio_actual, ruta_relativa);
end

% Función auxiliar para escribir matriz con encabezado
function writeMatrixWithHeader(filename, data, header)
    encabezado = cell(1, 1); encabezado{1} = header;
    writecell(encabezado, filename, 'Sheet', 1, 'Range', 'A1');
    writematrix(data, filename, 'Sheet', 1, 'Range', 'A2');
end

