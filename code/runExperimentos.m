function resultsTable = runExperimentos(config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad)
% runExperimentos   Ejecuta un barrido completo de corridas del AG
%   Esta función itera según la configuración definida en 'config',
%   ejecuta la función unaCorridaAG para cada escenario, acumula
%   los resultados y los exporta a un archivo Excel.
%
%   Inputs:
%     config           Struct con campos:
%                      - tipo: 'simple' o 'combinado' (determina el patrón de iteración)
%                      - rangoElem: vector de índices de elementos a dañar
%                      - porcentajes: vector de porcentajes de daño a aplicar
%                      - archivo_excel: ruta al archivo Excel de modelo original
%                      - outputFolder: carpeta donde se guardarán los resultados
%     DI_base          Struct con los 8 índices de daño calculados para el modelo intacto
%     M_cond           Matriz de masas condensada usada en el análisis modal
%     mask             Vector lógico o numérico que filtra los DOF relevantes
%     modos_intactos   Matriz de modos del sistema intacto
%     Omega_intactos   Vector de frecuencias asociadas a modos_intactos
%     conectividad     Matriz o estructura que define la topología del modelo
%
%   Output:
%     resultsTable     Tabla MATLAB con una fila por corrida y columnas con métricas

    %-------------------------------------------
    % 1) Determinar número total de corridas
    %-------------------------------------------
    nElem = numel(config.rangoElem);
    nDano = numel(config.porcentajes);
    switch config.tipo
        case 'simple'
            % Corridas de un solo elemento dañado por porcentaje
            totalRuns = nElem * nDano;
        case 'combinado'
            % Corridas de pares de elementos dañados simultáneamente
            totalRuns = (nElem*(nElem-1)/2) * nDano;
        otherwise
            error('Tipo de corrida desconocido: %s', config.tipo);
    end

    %-------------------------------------------
    % 2) Preasignar array de structs para resultados
    %-------------------------------------------
    % Prealocamos 'results' de longitud totalRuns para evitar
    % redimensionamientos costosos dentro del bucle.
    results(totalRuns) = struct();

    % Inicializar contadores
    ID  = 1;    % Identificador secuencial de cada corrida
    idx = 1;    % Índice para recorrer 'results'

    %-------------------------------------------
    % 3) Bucle principal de corridas
    %-------------------------------------------
    switch config.tipo
        case 'simple'
            % Para cada elemento y porcentaje de daño
            for elem = config.rangoElem
                for dano = config.porcentajes
                    % Ejecuta una corrida del AG
                    results(idx) = unaCorridaAG(
                        elem, ...                   % Índice de elemento dañado
                        dano, ...                   % Porcentaje de daño aplicado
                        ID, ...                     % ID de ejecución
                        config.archivo_excel, ...   % Ruta al Excel de modelo
                        DI_base, M_cond, mask, ...  % Datos estáticos precomputados
                        modos_intactos, Omega_intactos, conectividad);
                    % Avanza índices
                    idx = idx + 1;
                    ID  = ID  + 1;
                end
            end
        case 'combinado'
            % Para cada par único de elementos y porcentaje de daño
            for i = 1:nElem
                for j = i+1:nElem
                    pair = [config.rangoElem(i), config.rangoElem(j)];
                    for dano = config.porcentajes
                        results(idx) = unaCorridaAG(
                            pair, ...                 % Pareja de elementos dañados
                            dano, ...
                            ID, ...
                            config.archivo_excel, DI_base,
                            M_cond, mask, modos_intactos,
                            Omega_intactos, conectividad);
                        idx = idx + 1;
                        ID  = ID  + 1;
                    end
                end
            end
    end

    %-------------------------------------------
    % 4) Convertir a tabla y guardar en Excel
    %-------------------------------------------
    % Transforma el array de structs en una tabla para facilidad de manipulación
    resultsTable = struct2table(results);

    % Construye ruta de salida y escribe el archivo
    outputFile = fullfile(config.outputFolder, 'todos_los_resultados.xlsx');
    writetable(resultsTable, outputFile);

    % Mensaje opcional al usuario
    fprintf('✅ Resultados guardados en %s\n', outputFile);
end
