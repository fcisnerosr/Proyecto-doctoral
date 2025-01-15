function  [] = escritura_datos_hoja_excel_del_dr_Rolando(coordenadas, conectividad, prop_geom, matriz_restriccion, masas_en_cada_nodo)
%% Armado de la matriz de masas completa, ya con las modificaciones de la m. atrapada, crec. marino y la m. adherida
    % Limpiar datos de las pestañas a actualizar del dr. Rolando
    % Nombre del archivo Excel y nombre de la hoja
    sheet_name = 'nudos';
    borrar_elementos_en_hoja(sheet_name);
    % sheet_name = 'vxz';
    % borrar_elementos_en_hoja(sheet_name);
    sheet_name = 'conectividad';
    borrar_elementos_en_hoja(sheet_name);
    sheet_name = 'fix nodes';
    borrar_elementos_en_hoja(sheet_name);
    sheet_name = 'prop geom';
    borrar_elementos_en_hoja(sheet_name);
    sheet_name = 'masses';
    [documento_excel_dr_Rolando] = borrar_elementos_en_hoja(sheet_name);

    %% Escribir los datos recolectados en la hoja de EXCEL del dr. Rolando
    xlswrite(documento_excel_dr_Rolando, coordenadas, 'nudos');
    % xlswrite(documento_excel_dr_Rolando, vxz, 'vxz');
    xlswrite(documento_excel_dr_Rolando, conectividad, 'conectividad');
    xlswrite(documento_excel_dr_Rolando, prop_geom, 'prop geom');
    xlswrite(documento_excel_dr_Rolando, matriz_restriccion, 'fix nodes');
    % xlswrite(documento_excel_dr_Rolando, masas_en_cada_nodo, 'masses');   
end
