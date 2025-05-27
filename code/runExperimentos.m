function resultsTable = runExperimentos( ...
    config, DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
    tipo_dano, prop_geom, E, G, ...
    NE, IDmax, NEn, elements, nodes, damele, eledent, ...
    A, Iy, Iz, J, vxz, ID)

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


    % 1) Número total de corridas
    % totalRuns = numel(config.rangoElem) * numel(config.porcentajes);
    % results    = repmat(template, totalRuns, 1);

    nElem     = numel(config.rangoElem);
    nDano     = numel(config.porcentajes);
    totalRuns = nElem * nDano;  % o la fórmula de combinado…
    
    % 2) Crear un "template" con los mismos campos que devuelve unaCorridaAG
    template = struct( ...
        'ID',                 [], ...
        'Elemento',           [], ...
        'Porcentaje',         [], ...
        'Tiempo_s',           [], ...
        'ObjFinal',           [], ...
        'DeteccionOK',        [], ...
        'PromDispersion',     [], ...
        'StdDispersion',      [], ...
        'MeanAbsDispersion',  [], ...
        'N_FalsosPositivos',  []  ...
    );
    
    % 3) Pre‐alocar el array results con ese template
    results = repmat(template, totalRuns, 1);
    
    % 4) Inicializar contadores
    ID_Ejecucion = 1;
    idx          = 1;
    
    % 5) Bucle de corridas…
    switch config.tipo
      case 'simple'
        for elem = config.rangoElem
          for dano = config.porcentajes
            % Ejecutar la corrida
            out = unaCorridaAG( ID_Ejecucion, elem, dano, ...
                config.archivo_excel, tipo_dano, prop_geom, E, G, ...
                DI_base, M_cond, mask, modos_intactos, Omega_intactos, conectividad, ...
                ID, NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, vxz, config.outputFolder);
    
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
