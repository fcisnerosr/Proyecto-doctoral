% config.m (función)
function config = config()
  config.tipo        = "simple";
  % config.tipo_dano   = 'corrosion'; 
  config.tipo_dano   = 'abolladura'; 
  config.ab          = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);
  config.porcentajes = 5:5:45;   % [5,10,15,…,90]
  config.rangoElem   = 1:120;
  config.outputFolder = fullfile(pwd, "resultados_AG");
  
  % ========================================================================
  % CONFIGURACIÓN DE EMPAREJAMIENTO MODAL CON MAC
  % ========================================================================
  % Esta configuración controla cómo se relacionan los modos de vibración
  % del sistema intacto con los del sistema dañado antes de calcular los
  % índices de daño (DIs).
  %
  % PROBLEMA QUE RESUELVE:
  % Cuando se introduce daño en una estructura, las frecuencias naturales
  % pueden cambiar de orden (fenómeno llamado "cruce modal" o "mode veering").
  % Por ejemplo, si originalmente ω₁ < ω₂ < ω₃, después del daño podría
  % ocurrir ω₁' < ω₃' < ω₂', donde los modos 2 y 3 intercambiaron posiciones.
  %
  % Sin emparejamiento modal, compararíamos:
  %   - Modo intacto 2 vs Modo dañado 2 (que físicamente es el modo 3) ❌
  %   - Modo intacto 3 vs Modo dañado 3 (que físicamente es el modo 2) ❌
  % Esto produce índices de daño (DI1, DI2, DI3) incorrectos.
  %
  % SOLUCIÓN:
  % El Modal Assurance Criterion (MAC) es una métrica que mide la correlación
  % entre dos vectores modales. Usamos MAC para identificar qué modo dañado
  % corresponde físicamente a cada modo intacto, independientemente del orden
  % de frecuencias, y luego reordenamos los modos dañados para permitir
  % comparación directa correcta.
  %
  % CONFIGURACIÓN:
  config.usarMACmatching = true;
  % - true:  Activa el emparejamiento modal con MAC (RECOMENDADO)
  %          Los modos dañados se reordenan según su correlación física
  %          con los modos intactos antes de calcular DIs.
  %          Más robusto ante cruces modales y daños moderados/severos.
  %
  % - false: Desactiva el emparejamiento (comportamiento original)
  %          Asume que modo i dañado corresponde a modo i intacto.
  %          Funciona bien solo si el daño es leve y no hay cruces modales.
  %          Útil para comparar resultados con/sin matching.
  
  config.MAC_metodo = 'hungarian';
  % Algoritmo de emparejamiento a usar (solo si usarMACmatching = true):
  %
  % - 'hungarian': Algoritmo húngaro (óptimo global)
  %                Encuentra el emparejamiento que maximiza la suma total
  %                de valores MAC. Garantiza la mejor solución posible.
  %                Requiere Optimization Toolbox.
  %                RECOMENDADO por su optimalidad matemática.
  %
  % - 'greedy':    Algoritmo codicioso (subóptimo)
  %                Asigna secuencialmente cada modo al mejor disponible.
  %                Más rápido pero puede no encontrar el óptimo global.
  %                Útil si no se cuenta con Optimization Toolbox.
  %
  % NOTA: Ambos métodos producen resultados muy similares en la mayoría
  % de casos prácticos. La diferencia principal aparece cuando hay múltiples
  % cruces modales simultáneos (casos raros).
  %
  % CUÁNDO ES CRÍTICO USAR MAC MATCHING:
  % - Daños moderados a severos (> 25% de reducción en elemento)
  % - Estructuras con modos cercanos en frecuencia
  % - Cuando se observan inconsistencias en los resultados del AG
  % - Para análisis de investigación que requiera máxima precisión
  %
  % CUÁNDO ES OPCIONAL:
  % - Daños leves (< 15% de reducción)
  % - Estructuras con modos bien separados en frecuencia
  % - Análisis preliminares o pruebas de concepto
  %
  % IMPACTO EN RESULTADOS:
  % - Los valores de DI1-DI3 cambiarán (serán más precisos físicamente)
  % - Los pesos óptimos α del AG pueden cambiar
  % - La detección de daño será más robusta y confiable
  % - Tiempo de cómputo adicional: ~5-10% (negligible)
  % ========================================================================
  
end
