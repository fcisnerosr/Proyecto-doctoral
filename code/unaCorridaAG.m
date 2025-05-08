% unaCorridaAG.m
% Ejecuta una corrida del AG con un solo escenario de daño y devuelve resultados clave.
function resultado = unaCorridaAG( ...
    no_elemento, dano_porcentaje, ID_Ejecucion, ...
    archivo_excel, ...                          % Ruta al Excel de datos
    DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    tipo_dano, prop_geom, E, G)
    
    % 0. Caso de daño:
    caso_dano = repmat({ tipo_dano }, 1, numel(no_elemento));

    % 0.1) Extraer longitudes de los elementos dañados
    %      (no_elemento es el índice o vector de índices que estás dañando)
    L_d = extraer_longitudes_danadas(archivo_excel, no_elemento);

    % 1. Aplicar daño local y ensamblar matrices (suprimir salidas no usadas):
    [ke_d_total, ~,~] = switch_case_danos(...
         no_elemento, L_d, caso_dano, dano_porcentaje, prop_geom, E, G);
    [KG_dam,~,~] = ensamblaje_matriz_rigidez_global_con_dano( ...
        ke_d_total, archivo_excel, conectividad, no_elemento);

    % 2. Condensación y cálculo de modos del modelo dañado
    KG_dam_cond = condensacion_estatica(KG_dam);
    [modos_cond_d,~, Omega_cond_d] = modos_frecuencias(KG_dam_cond, M_cond);  % omitir frec_cond_d

    % 3. Aplicar máscara a los modos dañados
    modos_cond_d = modos_cond_d .* mask;

    % 4. Calcular DIs para el modelo dañado
    DI_danyado = calcularDIs( ...
        modos_intactos, modos_cond_d, Omega_intactos, Omega_cond_d);

    % 5. Generar vector T y umbral
    [T, threshold] = generarT(no_elemento, conectividad, DI_base.DI1);

    % 6. Ejecutar el AG
    [optimal_alpha, fval] = GA(DI_danyado, T, threshold);

    % 7. Combinar DIs con pesos y escalar P
    [w1, w2, w3, w4, w5, w6, w7, w8] = assignWeights(optimal_alpha);
    P = combinarDIs(w1,w2,w3,w4,w5,w6,w7,w8, DI_base, DI_danyado);
    [~, P_scaled] = createNodeTable(P, DI_base.DI1);  % suprimir Resultado_final si no se usa

    % 8. Calcular estadísticas de dispersión y falsos positivos
    [prom_dispersion, std_dispersion, mean_abs_dispersion, n_falsos_positivos] = calcularEstadisticasDispersion(P_scaled);

    % 9) Empaquetar resultados en struct
    resultado.ID                = ID_Ejecucion;
    resultado.Elemento          = no_elemento;
    resultado.Porcentaje        = dano_porcentaje;
    resultado.Tiempo_s          = toc;  
    resultado.ObjFinal          = fval;
    [~, domIdx]                 = max(P_scaled);
    resultado.DeteccionOK       = (domIdx == no_elemento);
    resultado.PromDispersion    = prom_dispersion;
    resultado.StdDispersion     = std_dispersion;
    resultado.MeanAbsDispersion = mean_abs_dispersion;
    resultado.N_FalsosPositivos = n_falsos_positivos;
end
