function resultsTable = runExperimentos(config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad)
% runExperimentos   Ejecuta barrido de corridas AG según configuración y datos estáticos
%   resultsTable = runExperimentos(config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad)
%
%   Input:
%     config           Struct con campos:
%                      - tipo: 'simple' o 'combinado'
%                      - rangoElem: vector de índices de elementos
%                      - porcentajes: vector de % de daño
%                      - archivo_excel: ruta al Excel de modelo ETABS
%                      - outputFolder: carpeta donde guardar resultados
%     DI_base          Struct con los 8 índices de daño del modelo intacto
%     M_cond           Matriz de masas condensada para modos
%     mask             Máscara para filtrar DOFs de superestructura
%     modos_intactos   Modos del modelo intacto
%     Omega_intactos   Frecuencias del modelo intacto
%     conectividad     Matriz de conectividad del modelo
%
%   Output:
%     resultsTable     Tabla con resultados de cada corrida

    % Calcula número de corridas para preasignar
    nElem     = numel(config.rangoElem);
    nDano     = numel(config.porcentajes);
    switch config.tipo
        case 'simple'
            totalRuns = nElem * nDano;
        case 'combinado'
            totalRuns = nElem*(nElem-1)/2 * nDano;
        otherwise
            error('Tipo de corrida desconocido: %s', config.tipo);
    end

    % Preasignar array de structs
    results(totalRuns) = struct();

    ID  = 1;
    idx = 1;
    % Bucle principal de corridas
    switch config.tipo
        case 'simple'
            for elem = config.rangoElem
                for dano = config.porcentajes
                    % Ejecuta corrida y guarda resultado
                    results(idx) = unaCorridaAG(elem, dano, ID, ...
                        config.archivo_excel, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad);
                    idx = idx + 1;
                    ID  = ID  + 1;
                end
            end
        case 'combinado'
            n = nElem;
            for i = 1:n
                for j = i+1:n
                    elemPair = [config.rangoElem(i), config.rangoElem(j)];
                    for dano = config.porcentajes
                        results(idx) = unaCorridaAG(elemPair, dano, ID, ...
                            config.archivo_excel, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad);
                        idx = idx + 1;
                        ID  = ID  + 1;
                    end
                end
            end
    end

    % Convertir a tabla y guardar
    resultsTable = struct2table(results);
    writetable(resultsTable, fullfile(config.outputFolder, 'todos_los_resultados.xlsx'));
end
