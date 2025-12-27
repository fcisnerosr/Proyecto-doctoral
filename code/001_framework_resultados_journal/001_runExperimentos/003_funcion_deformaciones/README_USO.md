# INTEGRACIÓN COMPLETADA: Daño Tipo 3 - Deformación Inicial

## ✅ Archivos Modificados

### 1. `main_launcher.m`
**Cambios**:
- Línea ~48: Agregado análisis estático de bajada de cargas
- Línea ~95: Pasar `N_axial_global`, `rho_global`, `matriz_cell_secciones` a `runExperimentos`

**Código agregado**:
```matlab
% 4.4) ANÁLISIS ESTÁTICO: Cálculo de fuerzas axiales
[N_axial_global, rho_global, Pcr_global, diagnostico_estatico] = ...
    analisis_estatico_fuerzas_axiales(...
        nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio);
```

### 2. `runExperimentos.m`
**Cambios**:
- Línea 1: Agregados 3 parámetros nuevos a la firma
- Línea ~30: Filtrado automático de elementos por ρ (si habilitado)
- Línea ~70: Pasar parámetros adicionales a `unaCorridaAG`

**Funcionalidad nueva**:
- Filtra elementos con ρ < 0.2 (baja detectabilidad)
- Filtra elementos con ρ > 0.75 (riesgo de inestabilidad)
- Reporta elementos rechazados con razones

### 3. `unaCorridaAG.m`
**Cambios**:
- Línea 1: Agregados 3 parámetros nuevos
- Línea ~23: Pasar parámetros a `switch_case_danos`

### 4. `switch_case_danos.m`
**Cambios**:
- Línea 1: Agregados 3 parámetros opcionales
- Línea ~62: Nuevo caso `'deformacion_inicial'`

**Funcionalidad nueva**:
- Extrae D, t desde `matriz_cell_secciones` (SECC01, SECC04, etc.)
- Valida e0/L < 5%
- Llama a `funcion_deformaciones.m` con N_axial precalculado
- Retorna Kt (rigidez tangente con efecto P-δ)

---

## ✅ Archivos Creados

### 1. `analisis_estatico_fuerzas_axiales.m`
Función que realiza bajada de cargas estática.

**Ubicación**: `code/001_framework_resultados_journal/001_runExperimentos/003_funcion_deformaciones/`

**Uso**:
```matlab
[N_axial, rho, Pcr, diag] = analisis_estatico_fuerzas_axiales(...
    nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, 8290953.54, true);
```

### 2. `config_deformacion_inicial.m`
Configuración específica para benchmark de deformación inicial.

**Ubicación**: `code/001_framework_resultados_journal/001_runExperimentos/`

**Parámetros clave**:
```matlab
config.tipo_dano = 'deformacion_inicial';
config.porcentajes = [0.5, 1.0, 2.0, 3.0];  % e0/L en %
config.rangoElem = 1:120;  % Subestructura completa
config.filtrar_elementos_por_rho = true;
config.rho_min = 0.20;
config.rho_max = 0.75;
```

### 3. Archivos de test (opcional)
- `test_bajada_cargas.m`: Validación standalone
- `README_integracion.md`: Guía técnica detallada

---

## 🚀 CÓMO USAR

### PASO 1: Configurar experimento
Editar o crear archivo de configuración:

```matlab
% Opción A: Usar config existente y cambiar tipo_dano
cd('/home/fcisnerosr/github/proyecto_doctoral/code/001_framework_resultados_journal/001_runExperimentos')

% Editar config.m
% Cambiar línea:
%   config.tipo_dano = 'corrosion';  % ANTES
%   config.tipo_dano = 'deformacion_inicial';  % AHORA

% Opción B: Usar configuración específica
% Renombrar o copiar:
%   config_deformacion_inicial.m → config.m
```

### PASO 2: Ejecutar main_launcher.m
```matlab
% En MATLAB:
cd('/home/fcisnerosr/github/proyecto_doctoral/code/001_framework_resultados_journal')
main_launcher
```

**Salida esperada en consola**:
```
=======================================================
main_launcher.m - Análisis de detección de daño
=======================================================

1) Carga configuración...
  Tipo de daño: deformacion_inicial

2) Lectura de datos del modelo...
  51 nodos, 136 elementos

...

4.4) Calculando fuerzas axiales estáticas (bajada de cargas)...

=== ANÁLISIS ESTÁTICO: BAJADA DE CARGAS ===
Estructura: 51 nodos, 136 elementos
Peso topside: 8290.95 kN (846.0 ton)
Peso propio: true
Ensamblando matriz de rigidez global...
  Matriz K ensamblada: 282×282 (DOF libres)
  Condicionamiento: κ(K) = 1.23e+08
Construyendo vector de cargas...
  Agregando peso propio de elementos...
    Peso propio total: XXXX kN
  Agregando peso topside...
    Peso topside: 8290.95 kN distribuido en 12 nodos
Resolviendo sistema estático K·U = F...
  Solución obtenida
Extrayendo fuerzas axiales por elemento...

--- RESULTADOS DEL ANÁLISIS ---
Elementos en tensión: XX (YY%)
Elementos en compresión: ZZ (WW%)

Ratio de carga crítica (ρ = |N|/Pcr):
  Máximo: 0.XXXX (elemento NN)
  Media: 0.YYYY

Distribución de elementos por ρ:
  ρ < 0.2 (bajo):       AA elementos
  0.2 ≤ ρ < 0.5 (medio): BB elementos
  0.5 ≤ ρ < 0.75 (alto): CC elementos
  ρ ≥ 0.75 (crítico):    DD elementos

=== ANÁLISIS COMPLETADO ===

  ✓ Fuerzas axiales calculadas para 136 elementos
  ✓ Elementos con ρ∈[0.3,0.7]: XX (óptimos para deformación inicial)
  ✓ Elemento más cargado: YY (ρ=0.ZZZZ)

...

--- FILTRADO DE ELEMENTOS POR ρ ---
Rango permitido: 0.20 ≤ ρ ≤ 0.75
  Elementos rechazados: MM
  Elementos a probar: NN (XX% del total)

=== INICIANDO CORRIDAS DEL AG ===
Total de corridas: TTT (NN elementos × 4 niveles de daño)
Tipo de daño: deformacion_inicial

Corrida 1/TTT: Elemento 1, e0/L=0.5%
...
```

### PASO 3: Monitorear progreso
El AG imprimirá progreso de cada corrida. Para corrida típica:
- Tiempo estimado: 30-60 segundos por corrida
- Total: ~10-20 minutos para 20 elementos × 4 niveles

### PASO 4: Analizar resultados
Al finalizar:
```matlab
% Archivo generado:
% Resultados/benchmark_deformacion_inicial_YYYYMMDD_HHMMSS.csv

% Cargar resultados
T = readtable('Resultados/benchmark_deformacion_inicial_*.csv');

% Tasa de detección por nivel de daño
for e0 = [0.5, 1.0, 2.0, 3.0]
    idx = T.Porcentaje == e0;
    tasa = 100 * sum(T.DeteccionOK(idx)) / sum(idx);
    fprintf('e0/L = %.1f%%: Detectado en %.1f%% de casos\n', e0, tasa);
end

% Elementos más detectables
T_sorted = sortrows(T, 'DeteccionOK', 'descend');
top10 = T_sorted(1:10, :);
disp(top10);
```

---

## 📊 RESULTADOS ESPERADOS

### Según teoría (Vlajic 2014, tu análisis):

| Rango ρ | Detectabilidad | Elementos típicos |
|---------|----------------|-------------------|
| < 0.2 | ★ Baja | Braces superiores |
| 0.2-0.4 | ★★ Media-baja | Braces medios |
| 0.4-0.6 | ★★★★★ Muy alta | Legs inferiores |
| 0.6-0.75 | ★★★★ Alta | Legs nivel 1-2 |
| > 0.75 | ⚠️ Inestable | (rechazados) |

### Comparación con otros daños:

| Tipo daño | e0/L o % | Δf₁/f₁ esperado | Detectabilidad típica |
|-----------|----------|-----------------|----------------------|
| **Deformación inicial** | 1% | ~2-5% | Media (depende de ρ) |
| **Deformación inicial** | 2% | ~5-10% | Alta (si ρ∈[0.4,0.7]) |
| Corrosión 10% | - | ~3-7% | Media |
| Abolladura 15% | - | ~5-12% | Alta |

---

## ⚠️ TROUBLESHOOTING

### Error: "Elemento XX con ρ=0.YYYY > 0.85"
**Causa**: Elemento demasiado cargado, cerca de pandeo.
**Solución**: 
```matlab
% En config.m:
config.rho_max = 0.75;  % Reducir límite superior
config.filtrar_elementos_por_rho = true;
```

### Error: "No se encontró sección SECC0X"
**Causa**: `matriz_cell_secciones` no pasada correctamente.
**Solución**: Verificar que `main_launcher.m` línea ~40 lee:
```matlab
[~, ~, ~, ~, matriz_cell_secciones, ~] = lectura_datos_modelo_ETABS(config.archivo_excel);
```

### Error: "e0/L = X% excede límite razonable (5%)"
**Causa**: Porcentaje de deformación demasiado alto.
**Solución**: En `config.m`:
```matlab
config.porcentajes = [0.5, 1.0, 2.0, 3.0];  % Mantener < 5%
```

### Frecuencias constantes en resultados
**Causa**: Si aparece para TODOS los elementos, verificar:
1. ¿`N_axial_global` está pasándose correctamente?
2. ¿Elementos están en compresión (N < 0)?

**Diagnóstico**:
```matlab
% En workspace después de crash:
histogram(N_axial_global/1e3);
xlabel('N [kN]'); ylabel('Frecuencia');
title('Distribución de fuerzas axiales');
% Debe mostrar valores negativos (compresión)
```

---

## 🔍 VALIDACIÓN CON ETABS

Si tienes resultados de ETABS:

```matlab
% 1. Exportar tabla de fuerzas axiales desde ETABS:
%    - Table: Element Forces - Frames
%    - Load Case: DEAD (o combo permanente)
%    - Columna: P (axial force)

% 2. Cargar en MATLAB
N_etabs = readtable('fuerzas_etabs.csv');

% 3. Comparar
figure;
plot(N_axial_global/1e3, 'b-', 'LineWidth', 1.5); hold on;
plot(N_etabs.P, 'r--', 'LineWidth', 1.5);
xlabel('Elemento'); ylabel('N [kN]');
legend('MATLAB', 'ETABS');
title('Validación: Fuerzas Axiales');
grid on;

% 4. Error relativo
err_rel = abs(N_axial_global - N_etabs.P*1000) ./ abs(N_etabs.P*1000);
fprintf('Error relativo medio: %.2f%%\n', 100*mean(err_rel));
fprintf('Error relativo máximo: %.2f%%\n', 100*max(err_rel));
```

**Error aceptable**: < 5% (típico para diferencias en modelado de conexiones)

---

## 📚 REFERENCIAS

1. **Vlajic et al. (2014)**: "Geometrically exact planar beams with initial pre-stress and large curvature", Int J Solids Struct 51:3361-3371
2. **HP Lee (1994)**: "Effects of initial shapes on natural frequencies", Mech Res Comm 21(6):593-598
3. **Bokaian (1988)**: "Natural frequencies under compressive axial loads", JSV 126(1):49-65

---

## ✅ CHECKLIST FINAL

Antes de ejecutar experimento completo:

- [ ] `config.tipo_dano = 'deformacion_inicial'` configurado
- [ ] `config.porcentajes` definidos (0.5-3%)
- [ ] `config.rangoElem` ajustado (prueba 5-10 elementos primero)
- [ ] `config.filtrar_elementos_por_rho = true`
- [ ] Verificado que archivos existen:
  - [ ] `analisis_estatico_fuerzas_axiales.m`
  - [ ] `funcion_deformaciones.m`
  - [ ] Modificaciones en `main_launcher.m`, `runExperimentos.m`, etc.
- [ ] Carpeta `Resultados/` existe y tiene espacio
- [ ] MATLAB cerrado y reabierto (limpiar cache)

**¡LISTO PARA EJECUTAR!**

```matlab
main_launcher  % GO!
```
