function resultsTable = runExperimentos( ...
    config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    tipo_dano, prop_geom, E, G, ...
    NE, IDmax, NEn, elements, nodes, damele, eledent, ...
    A, Iy, Iz, J, vxz)


% runExperimentos   Ejecuta un barrido completo de corridas del AG
%   resultsTable = runExperimentos(config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, tipo_dano, prop_geom, E, G)
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
%
%   Output:
%     resultsTable   : Tabla con resultados de cada corrida


    % 1) Determinar número total de corridas
    nElem = numel(config.rangoElem);
    nDano = numel(config.porcentajes);
    switch config.tipo
        case 'simple'
            totalRuns = nElem * nDano;
        case 'combinado'
            totalRuns = (nElem*(nElem-1)/2) * nDano;
        otherwise
            error('Tipo de corrida desconocido: %s', config.tipo);
    end

    % 2) Preasignar array de structs para resultados
    results(totalRuns) = struct();  % Prealocación para rendimiento

    % Inicializar contadores
    ID  = 1;
    idx = 1;

    % 3) Bucle principal de corridas
    switch config.tipo
        case 'simple'
            for elem = config.rangoElem
                for dano = config.porcentajes
                    % Ejecutar una corrida del AG
                    results(idx) = unaCorridaAG( ...
                        elem, dano, ID, ...
                        config.archivo_excel, tipo_dano, prop_geom, ...
                        DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
                        NE, IDmax, NEn, elements, nodes, damele, eledent, ...
                        A, Iy, Iz, J, E, G, vxz);

                    idx = idx + 1;
                    ID  = ID  + 1;
                end
            end
        case 'combinado'
            for i = 1:nElem
                for j = i+1:nElem
                    elemPair = [config.rangoElem(i), config.rangoElem(j)];
                    for dano = config.porcentajes
                        results(idx) = unaCorridaAG(...
                            elem, dano, ID, ...
                            config.archivo_excel, config.tipo_dano, prop_geom, E, G, ...
                            DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
                            NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz);
                        idx = idx + 1;
                        ID  = ID  + 1;
                    end
                end
            end
    end

    % 4) Convertir a tabla y guardar en Excel
    resultsTable = struct2table(results);
    outputFile   = fullfile(config.outputFolder, 'todos_los_resultados.xlsx');
    writetable(resultsTable, outputFile);
    fprintf('✅ Resultados guardados en %s\n', outputFile);
end





    


