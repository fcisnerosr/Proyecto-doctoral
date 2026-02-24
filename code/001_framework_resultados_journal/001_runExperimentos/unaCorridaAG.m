function resultado = unaCorridaAG( ID_Ejecucion,...
    elem, dano_porcentaje, ...
    archivo_excel, tipo_dano, prop_geom, E, G, ...
    DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    ID, NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, outputFolder, config, ...
    N_axial_global, rho_global, matriz_cell_secciones)
    % unaCorridaAG   Ejecuta una sola corrida del AG y devuelve resultados.
    % Esta función asume que las lecturas estáticas (lectura_hoja_excel, etc.)
    % se hicieron una vez en main_launcher y se pasaron como argumentos.
    %
    % NUEVOS PARÁMETROS:
    %   N_axial_global : [nElem×1] Fuerzas axiales precalculadas [N]
    %   rho_global     : [nElem×1] Ratios de carga crítica
    %   matriz_cell_secciones : Cell array con info de secciones (D, t, etc.)
    
    % 0) Generar cell-array con tipo de daño para cada elemento
    caso_dano = repmat({tipo_dano}, 1, numel(elem));

    % 1) Extraer longitudes de todos los elementos (solo prop_geom necesario)
    % num_de_ele_long = extraer_longitudes_elementos(prop_geom, archivo_excel);

    % 2) Extraer longitudes de los elementos dañados
    L_d = extraer_longitudes_danadas(archivo_excel, elem);

    % 3) Mapear nodos afectados por daño
    elem_con_dano_long_NE = vector_asignacion_danos(elem, NE);

    % 4) Aplicar daño local y ensamblar matrices locales
    % ─────────────────────────────────────────────────────────────────────
    % EXTRACCIÓN DE PARÁMETROS DE ABOLLADURA (si aplica)
    % ─────────────────────────────────────────────────────────────────────
    % Para tipo_dano = 'abolladura', config.ab contiene {Nseg, Slong, lim}
    % Para otros tipos de daño, ab_opts = [] y switch_case_danos usa defaults
    if isfield(config, 'ab')
        ab_opts = config.ab;  % struct con Nseg, Slong, lim
    else
        ab_opts = [];  % switch_case_danos manejará defaults internos
    end
    
    % Llamada a switch_case_danos con TODOS los parámetros
    % NOTA: ab_opts debe pasarse ANTES de N_axial, rho, matriz_cell_secciones
    [ke_d_total,~,~] = switch_case_danos(elem, L_d, caso_dano, dano_porcentaje, prop_geom, E, G, ab_opts, ...
        N_axial_global, rho_global, matriz_cell_secciones);

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

    % =========================================================================
    % 7.5) EMPAREJAMIENTO MODAL CON MAC (si está habilitado en configuración)
    % =========================================================================
    % Este bloque resuelve el problema de "cruce modal" (mode veering):
    % Cuando se introduce daño, las frecuencias naturales pueden cambiar de
    % orden, haciendo que el modo i del sistema dañado NO corresponda
    % físicamente al modo i del sistema intacto.
    %
    % EJEMPLO DE CRUCE MODAL:
    %   Sistema intacto:  ω₁ < ω₂ < ω₃ < ω₄ ...
    %   Sistema dañado:   ω₁' < ω₃' < ω₂' < ω₄' ...  (modos 2 y 3 se cruzaron)
    %
    % Sin matching, compararíamos incorrectamente:
    %   DI2 = abs(modo_intacto_2 - modo_dañado_2)  ← modo_dañado_2 es físicamente el modo 3!
    %   DI3 = abs(modo_intacto_3 - modo_dañado_3)  ← modo_dañado_3 es físicamente el modo 2!
    %
    % Esto produce índices de daño contaminados que confunden al AG.
    %
    % SOLUCIÓN:
    % Usamos el Modal Assurance Criterion (MAC) para identificar la
    % correspondencia física correcta entre modos y reordenamos los modos
    % dañados antes de calcular los DIs.
    %
    % El MAC(i,j) mide la correlación entre modo i intacto y modo j dañado:
    %   MAC = (φᵢᵀ·φⱼ)² / [(φᵢᵀ·φᵢ)·(φⱼᵀ·φⱼ)]
    %   Rango: [0, 1]
    %   - MAC ≈ 1: modos físicamente idénticos
    %   - MAC ≈ 0: modos ortogonales (sin relación)
    
    % Inicializar variables de diagnóstico (se guardarán en resultado)
    MAC_matrix_completa = [];
    MAC_diagonal_emparejamiento = [];
    hubo_cruces_modales = false;
    indices_matching = 1:size(modos_cond_d, 2);  % Por defecto: sin reordenamiento
    
    if config.usarMACmatching
        % --- MATCHING MODAL ACTIVO ---
        % Emparejar modos dañados con modos intactos usando MAC
        [modos_cond_d, Omega_cond_d, indices_matching, MAC_matrix_completa, MAC_diagonal_emparejamiento] = ...
            matchModesMAC(modos_cond_u, modos_cond_d, Omega_cond_d, config.MAC_metodo);
        
        % Detectar si hubo cruces modales (reordenamiento)
        % Si indices_matching = [1,2,3,...,12], no hubo cruces
        % Si indices_matching = [1,3,2,...,12], hubo cruce entre modos 2 y 3
        hubo_cruces_modales = ~isequal(indices_matching, 1:length(indices_matching));
        
        % Nota: Ahora modos_cond_d(:,i) corresponde físicamente a modos_cond_u(:,i)
        % y Omega_cond_d(i) es la frecuencia del modo que corresponde al modo i intacto
    else
        % --- MATCHING DESACTIVADO (comportamiento original) ---
        % Se asume que modo i dañado corresponde a modo i intacto
        % (ordenamiento por frecuencia ascendente de ambos sistemas)
        % Esto funciona solo si no hay cruces modales
    end
    % =========================================================================

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
    
    % 13) Calcular falsos positivos (nodos que el AG marcó como dañados pero no lo están)
    % nodos reales dañados:
    fila       = conectividad(:,1)==elem;
    trueNodes  = conectividad(fila,2:3);
    
    % máscara de falsos positivos: P_scaled>=50 pero no son nodos reales
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
    resultado.N_FalsosPositivos = n_falsos_positivos;
    
    % =========================================================================
    % VECTORES ALPHA OPTIMIZADOS POR EL GA (α₁...α₈)
    % =========================================================================
    % Estos pesos indican la importancia relativa de cada índice de daño (DI)
    % en la función objetivo. Son la contribución metodológica clave del paper.
    % Valores altos de α_i indican que DI_i fue seleccionado como más útil
    % para localizar el daño en este escenario específico.
    resultado.alpha1 = optimal_alpha(1);  % Peso de DI1 (COMAC)
    resultado.alpha2 = optimal_alpha(2);  % Peso de DI2 (Diferencia modos)
    resultado.alpha3 = optimal_alpha(3);  % Peso de DI3 (División modos)
    resultado.alpha4 = optimal_alpha(4);  % Peso de DI4 (Diferencia flexibilidad)
    resultado.alpha5 = optimal_alpha(5);  % Peso de DI5 (División flexibilidad)
    resultado.alpha6 = optimal_alpha(6);  % Peso de DI6 (Porcentaje flexibilidad)
    resultado.alpha7 = optimal_alpha(7);  % Peso de DI7 (Z-score flexibilidad)
    resultado.alpha8 = optimal_alpha(8);  % Peso de DI8 (Probabilidad flexibilidad)
    % =========================================================================
    
    % =========================================================================
    % OTROS DATOS DE SALIDA: Información sobre emparejamiento modal
    % =========================================================================
    % Estos campos proporcionan información de diagnóstico sobre el
    % emparejamiento modal realizado con MAC. Son útiles para:
    % - Análisis post-procesamiento de resultados
    % - Identificar casos con cruces modales significativos
    % - Validar que el matching funcionó correctamente
    % - Detectar daños severos que causan cambios modales drásticos
    
    if config.usarMACmatching && ~isempty(MAC_diagonal_emparejamiento)
        % MAC_minimo: Valor mínimo de correlación modal en el emparejamiento
        % Si es bajo (< 0.70), indica que algún modo cambió drásticamente
        % o que apareció un modo local nuevo debido al daño.
        resultado.MAC_minimo = min(MAC_diagonal_emparejamiento);
        
        % MAC_promedio: Correlación modal promedio del emparejamiento
        % Valores altos (> 0.90) indican que los modos se preservaron bien
        % Valores bajos (< 0.80) sugieren cambios modales significativos
        resultado.MAC_promedio = mean(MAC_diagonal_emparejamiento);
        
        % Hubo_cruces_modales: Indicador booleano de reordenamiento
        % - true:  Los modos se reordenaron (hubo cruces modales)
        %          Esto confirma que el matching fue necesario
        % - false: No hubo reordenamiento (modo i dañado = modo i intacto)
        %          El daño no causó cambios en el orden de frecuencias
        resultado.Hubo_cruces_modales = hubo_cruces_modales;
        
        % Opcional: Guardar matriz MAC completa e índices (comentado por espacio)
        % Descomentar si se necesita análisis detallado del matching
        % resultado.MAC_matrix = MAC_matrix_completa;
        % resultado.Indices_matching = indices_matching;
    else
        % Si el matching está desactivado o no se aplicó, llenar con NaN
        resultado.MAC_minimo = NaN;
        resultado.MAC_promedio = NaN;
        resultado.Hubo_cruces_modales = false;  % No se verificó
    end
    % =========================================================================
end
