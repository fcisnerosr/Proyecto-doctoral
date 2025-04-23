function guardar_resultados_AG(Resultado_final, no_elemento_a_danar, dano_porcentaje, tiempo_ejecucion)
% guarda los resultados en un archivo Excel con ruta absoluta calculada automáticamente

    archivo_excel = obtenerRutaResultadosAG();  % ← SIEMPRE usa la ruta automática

    elementos_txt = join(string(no_elemento_a_danar), ', ');
    porcentajes_txt = join(string(dano_porcentaje), ', ');

    fila_resumen = {
        datetime('now'), ...
        elementos_txt, ...
        porcentajes_txt, ...
        tiempo_ejecucion
    };

    if ~isfile(archivo_excel)
        encabezados = {'Fecha', 'Elementos_dañados', 'Porcentaje_dañado', 'Tiempo_ejecución_s'};
        writecell(encabezados, archivo_excel, 'Sheet', 'Resumen', 'Range', 'A1');
    end

    [~, ~, raw] = xlsread(archivo_excel, 'Resumen');
    fila_nueva = size(raw, 1) + 1;
    writecell(fila_resumen, archivo_excel, 'Sheet', 'Resumen', 'Range', ['A' num2str(fila_nueva)]);

    Resultado_final.ID_Ejecucion = repmat(fila_nueva - 1, height(Resultado_final), 1);

    if fila_nueva == 2
        writetable(Resultado_final, archivo_excel, 'Sheet', 'Daño_nodos', 'WriteMode', 'replacefile');
    else
        writetable(Resultado_final, archivo_excel, 'Sheet', 'Daño_nodos', 'WriteMode', 'Append');
    end
end


% SUBFUNCIÓN INTERNA
function pathfile = obtenerRutaResultadosAG()
    directorio_actual = pwd;
    ruta_relativa = fullfile('..', 'resultados', 'resultados_AG.xlsx');
    pathfile = fullfile(directorio_actual, ruta_relativa);
end