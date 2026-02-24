% config.m (función)
function config = config()
  % ========================================================================
  % CONFIGURACIÓN GENERAL DEL ANÁLISIS
  % ========================================================================
  config.tipo        = "simple";                                            % Tipo de análisis: "simple" = un elemento a la vez
  
  % ┌──────────────────────────────────────────────────────────────────────┐
  % │ SELECCIÓN DE TIPO DE DAÑO                                            │
  % └──────────────────────────────────────────────────────────────────────┘
  % Opciones: 'corrosion', 'abolladura', 'deformacion_inicial'
  % Descomentar SOLO UNA línea:
  
  % config.tipo_dano   = 'corrosion';                                       % Daño tipo 1: Corrosión uniforme en elemento tubular
  config.tipo_dano   = 'abolladura';                                      % Daño tipo 2: Abolladura longitudinal (denting)
  % config.tipo_dano   = 'deformacion_inicial';                               % Daño tipo 3: Deformación inicial (bow imperfection) bajo compresión
  
  % ┌──────────────────────────────────────────────────────────────────────┐
  % │ PARÁMETROS ESPECÍFICOS POR TIPO DE DAÑO                              │
  % └──────────────────────────────────────────────────────────────────────┘
  % Los parámetros se configuran automáticamente según tipo_dano seleccionado
  
  switch config.tipo_dano
      case 'corrosion'
          % CORROSIÓN: Porcentaje de reducción de espesor (% depth/t)
          config.porcentajes = 5:5:20;                                      % [5%, 10%, 15%, 20%] reducción espesor
          
      case 'abolladura'
          % ABOLLADURA: Parámetros de segmentación y profundidad (% D)
          config.ab = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);        % Nseg=segmentos integración, Slong=longitud abolladura, lim=límite convergencia
          config.porcentajes = 5:5:45;                                      % [5%, 10%, 15%, ..., 45%] profundidad/diámetro (9 niveles)
          
      case 'deformacion_inicial'
          % DEFORMACIÓN INICIAL: Magnitud de bow imperfection (e0/L en %)
          % ──────────────────────────────────────────────────────────────
          % QUÉ ES: Imperfección geométrica inicial en centro del elemento
          %         (curvatura permanente tipo "bow" bajo compresión axial)
          %
          % RANGOS BASADOS EN INSPECCIONES IN SITU (WOAD, HSE, Casos Reales):
          %   0.5-1.5%  → Daños leves a moderados (90% de casos)
          %   1.5-2.5%  → Daños significativos a severos
          %   2.5-3.0%  → Casos extremos límite (colapso inminente)
          %
          % FUENTE: Análisis Golfo Pérsico (δ/L=3.2%), submarino Oseberg B,
          %         colisiones buques con bulbo de proa, objetos caídos.
          %
          % EFECTO: Amplifica desplazamientos bajo compresión (P-δ effect)
          %         Reduce frecuencias naturales proporcional a (1-ρ-g(e0))
          %         donde ρ = |N|/Pcr (ratio carga crítica)
          % ──────────────────────────────────────────────────────────────
          config.porcentajes = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0];              % [0.5% - 3.0%] rango completo in situ
          
          % FILTROS DE SEGURIDAD: Seleccionar elementos con compresión óptima
          % ──────────────────────────────────────────────────────────────
          % RAZÓN: La detectabilidad del daño depende del ratio ρ = |N|/Pcr
          %
          % - Si ρ < 0.2  → Efecto P-δ despreciable, difícil detectar
          % - Si ρ ∈ [0.3, 0.7] → Detectabilidad óptima (sensibilidad alta)
          % - Si ρ > 0.85 → Cercano a pandeo (inestabilidad numérica)
          %
          % IMPLEMENTACIÓN: runExperimentos.m filtrará automáticamente
          %                 elementos fuera de [rho_min, rho_max]
          % ──────────────────────────────────────────────────────────────
          config.rho_min = 0.20;                                            % Ratio mínimo |N|/Pcr para incluir elemento
          config.rho_max = 0.75;                                            % Ratio máximo |N|/Pcr (margen vs pandeo)
          config.filtrar_elementos_por_rho = true;                          % Activar filtrado automático
          
      otherwise
          error('config:TipoDanoInvalido', 'tipo_dano "%s" no reconocido', config.tipo_dano);
  end
  
  % ========================================================================
  % ELEMENTOS A ANALIZAR
  % ========================================================================
  config.rangoElem   = 1:120;                                               % Rango de elementos a evaluar (1 a 120 para subestructura)
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
