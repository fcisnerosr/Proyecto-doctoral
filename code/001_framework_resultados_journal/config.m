% config.m (función)
function config = config()
  % ========================================================================
  % CONFIGURACIÓN GENERAL DEL ANÁLISIS
  % ========================================================================
  config.tipo        = "simple";                                            % Tipo de análisis: "simple" = un elemento a la vez
  % config.tipo_dano   = 'corrosion';                                       % Tipo de daño: corrosión uniforme en elemento tubular (comentar para usar abolladura)
  config.tipo_dano   = 'abolladura';                                        % Tipo de daño: abolladura longitudinal en elemento tubular (activo por defecto)
  config.ab          = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);      % Parámetros de abolladura: Nseg=segmentos, Slong=longitud, lim=límite
  config.porcentajes = 5:5:20;                                              % Porcentajes de daño a evaluar [5%, 10%, 15%, ..., 45%]
  config.rangoElem   = 1:5;                                               % Rango de elementos a evaluar (1 a 120)
  config.outputFolder = fullfile(pwd, "resultados_AG");                     % Carpeta de salida para resultados del AG
  
  % ========================================================================
  % CONFIGURACIÓN DE EMPAREJAMIENTO MODAL CON MAC
  % ========================================================================
  % PROBLEMA: Cuando se introduce daño, las frecuencias pueden cambiar de orden
  % (cruce modal o "mode veering"), haciendo que el modo i dañado NO corresponda
  % físicamente al modo i intacto. Esto contamina los índices de daño (DIs).
  %
  % SOLUCIÓN: El Modal Assurance Criterion (MAC) mide la correlación entre
  % vectores modales para identificar correspondencia física correcta y
  % reordenar modos dañados antes de calcular DIs.
  %
  % CUÁNDO ES CRÍTICO: Daños >25%, modos cercanos en frecuencia, inconsistencias
  % CUÁNDO ES OPCIONAL: Daños <15%, modos bien separados, análisis preliminares
  % ========================================================================
  
  config.usarMACmatching = true;                                            % true = Activa matching modal con MAC (RECOMENDADO para robustez ante cruces modales) | false = Desactiva (asume modo i dañado = modo i intacto, solo válido para daños leves)
  
  config.MAC_metodo = 'hungarian';                                          % Algoritmo de emparejamiento: 'hungarian' = óptimo global (requiere Optimization Toolbox, RECOMENDADO) | 'greedy' = subóptimo pero más rápido (sin toolbox)
  
  % IMPACTO EN RESULTADOS:
  % - DI1-DI3 serán físicamente correctos (no contaminados por cruces)
  % - Pesos óptimos α del AG pueden cambiar (reflejan importancia real)
  % - Detección de daño más robusta y confiable
  % - Tiempo adicional ~5-10% (negligible)
  
end
