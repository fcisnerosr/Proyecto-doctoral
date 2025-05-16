function resultado = unaCorridaAG( ID_Ejecucion,...
    elem, dano_porcentaje, ...
    archivo_excel, tipo_dano, prop_geom, E, G, ...
    DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    ID, NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, outputFolder)
    % unaCorridaAG   Ejecuta una sola corrida del AG y devuelve resultados.
    % Esta función asume que las lecturas estáticas (lectura_hoja_excel, etc.)
    % se hicieron una vez en main_launcher y se pasaron como argumentos.
    % 0) Generar cell-array con tipo de daño para cada elemento
    caso_dano = repmat({tipo_dano}, 1, numel(elem));

    % 1) Extraer longitudes de todos los elementos (solo prop_geom necesario)
    % num_de_ele_long = extraer_longitudes_elementos(prop_geom, archivo_excel);

    % 2) Extraer longitudes de los elementos dañados
    L_d = extraer_longitudes_danadas(archivo_excel, elem);

    % 3) Mapear nodos afectados por daño
    elem_con_dano_long_NE = vector_asignacion_danos(elem, NE);

    % 4) Aplicar daño local y ensamblar matrices locales
    [ke_d_total,~,~] = switch_case_danos(elem, L_d, caso_dano, dano_porcentaje, prop_geom, E, G);

    % 5) Ensamble de matriz de rigidez global con daño
    [KG_dam,~,~] = ensamblaje_matriz_rigidez_global_con_dano( ...
        ID, NE, ke_d_total, elements, nodes, IDmax, NEn, damele, ...
        eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
    
    % 6) Condensación y cálculo de modos del modelo dañado
    KG_dam_cond = condensacion_estatica(KG_dam);
    [modos_cond_d,~, Omega_cond_d] = modos_frecuencias(KG_dam_cond, M_cond);
    % [modos_cond_u,~, Omega_cond_u] = modos_frecuencias(KG_dam_cond, M_cond);

    % 7) Aplicar máscara a los modos dañados
    modos_cond_u = modos_intactos .* mask;
    modos_cond_d = modos_cond_d .* mask;

    % 8) Calcular DIs para el modelo dañado
    [DI1_COMAC_d, DI2_Diff_d, DI3_Div_d, DI4_Diff_Flex_d, DI5_Div_Flex_d, DI6_Perc_Flex_d, DI7_Zscore_Flex_d, DI8_Prob_Flex_d] = ...
        calcular_DIs(modos_cond_u, modos_cond_d, Omega_intactos, Omega_cond_d);
    DI_danado = struct( ...
        'DI1_COMAC',       DI1_COMAC_d, ...
        'DI2_Diff',        DI2_Diff_d, ...
        'DI3_Div',         DI3_Div_d, ...
        'DI4_Diff_Flex',   DI4_Diff_Flex_d, ...
        'DI5_Div_Flex',    DI5_Div_Flex_d, ...
        'DI6_Perc_Flex',   DI6_Perc_Flex_d, ...
        'DI7_Zscore_Flex', DI7_Zscore_Flex_d, ...
        'DI8_Prob_Flex',   DI8_Prob_Flex_d ...
    );


    % 9) Generar vector T y umbral
    [T, threshold] = generarT(elem, conectividad, DI_base.DI1);

    % 10) Ejecutar el AG
    [optimal_alpha, fval] = GA(DI_danado, T, threshold, ID_Ejecucion, outputFolder);

    % 11) Combinar DIs y escalar P
    [w1,w2,w3,w4,w5,w6,w7,w8] = assignWeights(optimal_alpha);
    P = combinarDIs( w1, w2, w3, w4, w5, w6, w7, w8, ...
                 DI_danado.DI1_COMAC,    ...
                 DI_danado.DI2_Diff,     ...
                 DI_danado.DI3_Div,      ...
                 DI_danado.DI4_Diff_Flex, ...
                 DI_danado.DI5_Div_Flex, ...
                 DI_danado.DI6_Perc_Flex, ...
                 DI_danado.DI7_Zscore_Flex, ...
                 DI_danado.DI8_Prob_Flex );

    [~, P_scaled] = createNodeTable(P, DI_base.DI1);

    % 12) Contar y listar falsos positivos: nodos que el AG marcó (P_scaled>=50) pero que en T==0 no están dañados
    fpMask = (P_scaled >= 50) ...   % el AG los consideró dañados
           & ~isnan(P_scaled) ...   % excluye NaN
           & (T == 0);              % pero en verdad no tenían daño
    
    falsePositiveNodes  = find(fpMask);        % índices (nodos) de falsos positivos
    falsePositiveValues = P_scaled(fpMask);    % sus valores
    n_falsos_positivos  = numel(falsePositiveNodes);

    % 13) Calcular estadísticas de dispersión y falsos positivos
    [prom_dispersion, std_dispersion, mean_abs_dispersion, n_falsos_positivos] = ...
        calcularEstadisticasDispersion(P_scaled);

    % 13.5) Falsos positivos
    % nodos reales:
    fila       = conectividad(:,1)==elem;
    trueNodes  = conectividad(fila,2:3);
    
    % máscara de falsos positivos
    fpMask = (P_scaled >= 50) & ~isnan(P_scaled);
    fpMask(trueNodes) = false;
    
    n_falsos_positivos = sum(fpMask);

    % 14) Construye la tabla nodal
    offset  = 4;                          % 4 nodos empotrados
    nodeIdx = ( (1:numel(P_scaled)) + offset )';
    valores    = P_scaled;
    % Definimos el umbral de daño al 50%
    umbralEstado = 50;
    estado     = repmat({'-'}, numel(P_scaled),1);
    % Marcamos “Daño” donde el valor normalizado supera o iguala el umbral
    estado(valores >= umbralEstado) = {'Daño'};
    Tnodal = table(nodeIdx,valores,estado, ...
    'VariableNames',{'Numero_de_nodo','Valor_de_daño_normalizado','Estado'});
    
    % 15) Guárdala en DetalleTodasCorridas.xlsx
    outputFile = fullfile(outputFolder,'DetalleTodasCorridas.xlsx');
    sheetName  = sprintf('ID_%04d',ID_Ejecucion);   % p.ej. "ID_001"
    writetable(Tnodal, outputFile, ...
    'Sheet',sheetName, ...
    'WriteRowNames',false);
    
    % 16) Guardar la figura de esta corrida con nombre ID_0001.png, ID_0002.png, …
    fig = gcf;  % o la handle que estés usando para tu gráfica
    figFile = fullfile(outputFolder, sprintf('ID_%04d.png', ID_Ejecucion));
    saveas(fig, figFile);


    % 17) Empaquetar resultados en struct
    resultado.ID                = ID_Ejecucion;
    resultado.Elemento          = elem;
    resultado.Porcentaje        = dano_porcentaje;
    resultado.Tiempo_s          = toc;
    resultado.ObjFinal          = fval;
    resultado.DeteccionOK       = esDeteccionCorrecta(conectividad, elem, P_scaled);
    resultado.PromDispersion    = prom_dispersion;
    resultado.StdDispersion     = std_dispersion;
    resultado.MeanAbsDispersion = mean_abs_dispersion;
    resultado.N_FalsosPositivos = n_falsos_positivos;
end
