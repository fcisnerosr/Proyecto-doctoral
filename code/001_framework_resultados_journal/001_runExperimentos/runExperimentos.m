function resultsTable = runExperimentos( ...
    config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    tipo_dano, prop_geom, E, G, ...
    NE, IDmax, NEn, elements, nodes, damele, eledent, ...
    A, Iy, Iz, J, vxz, ID, ...
    N_axial_global, rho_global, matriz_cell_secciones)

% runExperimentos   Ejecuta un barrido completo de corridas del AG
%   resultsTable = runExperimentos(config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, tipo_dano, prop_geom, E, G, ...)
%
%   Inputs:
%     config         : Struct con campos tipo, rangoElem, porcentajes, archivo_excel, outputFolder
%     DI_base        : Struct con los 8 índices de daño para el modelo intacto
%     M_cond         : Matriz de masas condensada para análisis modal
%     mask           : Máscara para filtrar DOF de superestructura
%     modos_intactos : Modos del sistema intacto
%     Omega_intactos : Frecuencias asociadas a modos_intactos
%     conectividad   : Matriz de conectividad
%     tipo_dano      : Cadena con tipo de daño (e.g., 'corrosion')
%     prop_geom      : Propiedades geométricas de elementos sin daño
%     E, G           : Módulos elástico y de cortante del material
%     N_axial_global : [nElem×1] Fuerzas axiales de análisis estático [N] (NUEVO)
%     rho_global     : [nElem×1] Ratios de carga crítica ρ = |N|/Pcr (NUEVO)
%     matriz_cell_secciones : Cell array con secciones tipo SECC01, SECC04 (NUEVO)
%
%   Output:
%     resultsTable   : Tabla con resultados de cada corrida


    % =========================================================================
    % 0) FILTRADO DE ELEMENTOS (para deformación inicial)
    % =========================================================================
    elementos_a_probar = config.rangoElem;
    
    if isfield(config, 'filtrar_elementos_por_rho') && config.filtrar_elementos_por_rho
        % Filtrar elementos por ratio de carga crítica
        fprintf('\n--- FILTRADO DE ELEMENTOS POR ρ ---\n');
        fprintf('Rango permitido: %.2f ≤ ρ ≤ %.2f\n', config.rho_min, config.rho_max);
        
        % Elementos en rango óptimo
        idx_validos = find(rho_global >= config.rho_min & rho_global <= config.rho_max);
        elementos_validos = intersect(elementos_a_probar, idx_validos);
        
        % Elementos rechazados
        elementos_rechazados = setdiff(elementos_a_probar, elementos_validos);
        n_rechazados = length(elementos_rechazados);
        
        if n_rechazados > 0
            fprintf('  Elementos rechazados: %d\n', n_rechazados);
            if n_rechazados <= 10
                fprintf('    IDs: %s\n', mat2str(elementos_rechazados));
            end
            fprintf('  Razones:\n');
            for k = elementos_rechazados(:)'
                if rho_global(k) < config.rho_min
                    fprintf('    Elem %d: ρ=%.4f < %.2f (baja detectabilidad)\n', ...
                        k, rho_global(k), config.rho_min);
                elseif rho_global(k) > config.rho_max
                    fprintf('    Elem %d: ρ=%.4f > %.2f (riesgo inestabilidad)\n', ...
                        k, rho_global(k), config.rho_max);
                end
            end
        end
        
        fprintf('  Elementos a probar: %d (%.1f%% del total)\n', ...
            length(elementos_validos), 100*length(elementos_validos)/length(elementos_a_probar));
        
        % Actualizar lista
        elementos_a_probar = elementos_validos;
        
        if isempty(elementos_a_probar)
            error('runExperimentos:SinElementosValidos', ...
                'No hay elementos con ρ en rango [%.2f, %.2f]', config.rho_min, config.rho_max);
        end
    else
        fprintf('\n--- SIN FILTRADO DE ELEMENTOS ---\n');
        fprintf('  Probando %d elementos\n', length(elementos_a_probar));
    end
    
    % =========================================================================
    % 1) Número total de corridas
    % =========================================================================
    nElem     = numel(elementos_a_probar);  % Usar lista filtrada
    nDano     = numel(config.porcentajes);
    totalRuns = nElem * nDano;
    
    % 2) Crear un "template" con los mismos campos que devuelve unaCorridaAG
    template = struct( ...
        'ID',                 [], ...
        'Elemento',           [], ...
        'Porcentaje',         [], ...
        'Tiempo_s',           [], ...
        'ObjFinal',           [], ...
        'DeteccionOK',        [], ...
        'N_FalsosPositivos',  [], ...
        'alpha1',             [], ...
        'alpha2',             [], ...
        'alpha3',             [], ...
        'alpha4',             [], ...
        'alpha5',             [], ...
        'alpha6',             [], ...
        'alpha7',             [], ...
        'alpha8',             [], ...
        'MAC_minimo',         [], ...
        'MAC_promedio',       [], ...
        'Hubo_cruces_modales', [] ...
    );
    
    % 3) Pre‐alocar el array results con ese template
    results = repmat(template, totalRuns, 1);
    
    % 4) Inicializar contadores
    ID_Ejecucion = 1;
    idx          = 1;
    
    % 5) Bucle de corridas…
    fprintf('\n=== INICIANDO CORRIDAS DEL AG ===\n');
    fprintf('Total de corridas: %d (%d elementos × %d niveles de daño)\n', ...
        totalRuns, nElem, nDano);
    fprintf('Tipo de daño: %s\n\n', tipo_dano);
    
    switch config.tipo
      case 'simple'
        for elem = elementos_a_probar  % Usar lista filtrada
          for dano = config.porcentajes
            % Ejecutar la corrida
            out = unaCorridaAG( ID_Ejecucion, elem, dano, ...
                config.archivo_excel, tipo_dano, prop_geom, E, G, ...
                DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
                ID, NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, config.outputFolder, config, ...
                N_axial_global, rho_global, matriz_cell_secciones);
    
            % Guardar en el array pre‐alocado
            results(idx) = out;
    
            % Avanzar contadores
            ID_Ejecucion = ID_Ejecucion + 1;
            idx          = idx          + 1;
          end
        end
      % … caso 'combinado' similar …
    end
    
    % 6) Convertir a tabla y guardar
    resultsTable = struct2table(results);
    writetable(resultsTable, fullfile(config.outputFolder,'todos_los_resultados.xlsx'));
end
