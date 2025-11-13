# 📋 Registro del Pipeline de Procesamiento de Daños Estructurales

**Proyecto:** Detección de Daños con Algoritmos Genéticos  
**Autor:** Francisco Cisneros  
**Última actualización:** 12 de noviembre, 2025

---

## 🎯 Objetivo del Documento

Este documento registra el **pipeline completo de procesamiento** para los diferentes tipos de daño estructural analizados en el proyecto doctoral. Sirve como guía para replicar el procesamiento en futuros tipos de daño y documentar decisiones metodológicas.

---

## 📊 Tipos de Daño Analizados

| Tipo de Daño | Estado | Archivo Original AG | Ubicación |
|--------------|--------|---------------------|-----------|
| **Abolladuras (Denting)** | ✅ **Completado** | `todos_los_resultados_csv.csv` | `~/proyecto-doctoral/Resultados/resultados_abolladuras/` |
| **Corrosión (JSV)** | 🔄 **En proceso** | `todos_los_resultados.csv` | `~/proyecto-doctoral/Resultados/resultados_corrosion_JSV/` |
| **Grietas por Fatiga en Uniones** | ⏳ **Pendiente** | TBD | TBD |
| **Deformaciones Excesivas** | ⏳ **Pendiente** | TBD | TBD |

---

# 1️⃣ Pipeline para ABOLLADURAS (Denting)

## 📁 Estructura de Archivos

```
resultados_abolladuras/
├── jupyter_notebooks/
│   ├── todos_los_resultados_csv.csv                          [Original AG]
│   ├── todos_los_resultados_csv_remapeado.csv                [Intermedio: beams con 0.5]
│   ├── todos_los_resultados_csv_remapeado_final.csv          [FINAL: beams + inclined_legs]
│   ├── Elemento_design_type.csv                              [Mapeo auxiliar]
│   ├── analisis_datos_abolladura.ipynb                       [ANÁLISIS PRINCIPAL]
│   ├── add_nivel_column.ipynb                                [Auxiliar: agregó columna 'nivel']
│   └── temp_analysis.ipynb                                   [Temporal, no esencial]
│
├── remapeo_beams/
│   ├── nodos_beams.csv                                       [Mapeo elemento→nodos]
│   ├── remapeo_beams.ipynb                                   [Genera remapeado.csv]
│   └── salida_csvs/                                          [ID_0001.csv ... ID_2160.csv]
│       └── [Archivos del AG con detecciones por nodo]
│
└── remapeo_inclined_legs/
    ├── nodos_inclined_legs.csv                               [Mapeo elemento→nodos]
    ├── remapeo_inclined_legs.ipynb                           [Genera remapeado_final.csv]
    └── salida_csvs/                                          [ID_0001.csv ... ID_2160.csv]
        └── [Archivos del AG con detecciones por nodo]
```

---

## 🔄 Flujo de Procesamiento

### Etapa 1: Preparación Inicial
- **Input:** `todos_los_resultados_csv.csv` (salida directa del AG)
- **Columnas originales:**
  - `ID`, `Elemento`, `Porcentaje`, `DeteccionOK` (0/1)
  - `N_FalsosPositivos`, `MeanAbsDispersion`
  - `Tipo_elemento_a_buscar`, `nivel` (Story 1-4)

### Etapa 2: Remapeo de Beams
- **Notebook:** `remapeo_beams/remapeo_beams.ipynb`
- **Input adicional:** 
  - `nodos_beams.csv` → Mapeo de cada beam con sus 2 nodos más cercanos
  - `salida_csvs/ID_*.csv` → Archivos AG con columnas: `Numero_de_nodo`, `Estado` ("Daño"/"Sin Daño")
  - Nota importante: el `salida_csvs/ID_*.csv` está en `remapeo_beams` y en `remapeo_legs`: 
  - ejemplo:
  ```
    .
    ├── figuras
    ├── graficas_ID
    ├── jupyter_notebooks
    ├── remapeo_beams
    │   └── salida_csvs
    └── remapeo_inclined_legs
        └── salida_csvs
  ```
  
- **Proceso:**
  1. Cargar dataset original
  2. Para cada escenario (ID) donde `Elemento` es beam y `DeteccionOK == 0`:
     - Leer archivo `salida_csvs/ID_{escenario}.csv`
     - Verificar si alguno de los 2 nodos cercanos tiene `Estado == "Daño"`
     - Si SÍ → Cambiar `DeteccionOK` de `0` a `0.5` (detección parcial/indirecta)
  3. Guardar → `todos_los_resultados_csv_remapeado.csv`

- **Output:** Dataset con beams remapeados (valores 0, 0.5, 1)

### Etapa 3: Remapeo de Inclined Legs
- **Notebook:** `remapeo_inclined_legs/remapeo_inclined_legs.ipynb`
- **Input:** `todos_los_resultados_csv_remapeado.csv` (ya tiene beams con 0.5)
- **Input adicional:**
  - `nodos_inclined_legs.csv` → Mapeo de cada inclined_leg con nodos cercanos
  - `salida_csvs/ID_*.csv` → Mismos archivos AG
  
- **Proceso:** Igual que Etapa 2, pero para `inclined_leg`
  
- **Output:** `todos_los_resultados_csv_remapeado_final.csv`

### Etapa 4: Análisis y Generación de Gráficas ICD
- **Notebook:** `jupyter_notebooks/analisis_datos_abolladura.ipynb`
- **Input:** `todos_los_resultados_csv_remapeado_final.csv`
  
- **Análisis realizados:**
  1. **Tasa de detección binaria** → `(DeteccionOK > 0).astype(int)` (0.5 y 1 → 1)
  2. **Índice de Calidad de Detección (ICD)** → Preserva valores 0, 0.5, 1
     - Fórmula: 
       ```
       ICD = DetOK * ( ln(1 + alpha * Porcentaje) / ln(1 + alpha * Porcentaje_max) ) * e^(-0.15 * N_FalsosPositivos)
       ```
  3. **Análisis por zona** (Story 1-4)
  4. **Análisis por tipo de elemento** (beam, inclined_leg, x_bracing)
  5. **Intervalos de confianza** (Wilson binomial 95%)

- **Output:** Gráficas PNG guardadas en carpetas `graficas_ID/` y `figuras/`

---

## 🔑 Decisiones Clave Documentadas

### ¿Por qué valores 0.5?
- **Problema:** AG detecta daño en nodos cercanos pero no directamente en el elemento
- **Solución:** Asignar valor intermedio (0.5) reconociendo detección "indirecta"
- **Justificación:** 
  - En análisis binario: 0.5 cuenta como detección (→1)
  - En ICD: 0.5 aporta 50% del peso vs. detección directa, reflejando calidad reducida

### ¿Por qué no se remapean x_bracing?
- Los x_bracing no tienen mapeo nodo-elemento en este análisis
- Se mantienen con valores binarios (0/1) originales del AG

### Normalización logarítmica del ICD
- **Factor α = 0.1**, **Porcentaje_max = 45%**, esto del 45% solo aplica para el caso de las abolladuras, para el resto de los daños se consideran otros límites de daño.
- Comportamiento: crecimiento rápido inicial, saturación gradual
- Garantiza ICD ∈ [0, 1] con máximo en (DetOK=1, N_FP=0, %=45)

---

## 📈 Métricas Finales Generadas

| Métrica | Descripción | Rango |
|---------|-------------|-------|
| **Tasa de Detección Binaria** | Proporción de casos detectados (0.5 y 1 cuentan como éxito) | [0, 1] |
| **ICD** | Índice de Calidad ponderado por severidad y penalizado por FP | [0, 1] |
| **IC Wilson 95%** | Intervalo de confianza para proporciones binomiales | [0, 1] |
| **Dispersión promedio** | Media de `MeanAbsDispersion` en detecciones exitosas | R⁺ |
| **N Falsos Positivos** | Promedio de elementos erróneamente identificados | ℕ |

---
Nota: el `MeanAbsDispersion` no se está tomando en cuenta para el post-procesamiento de datos, no aporta información util en las gráficas finales


# 📚 Lecciones Aprendidas y Buenas Prácticas

## ✅ Recomendaciones Generales

1. **Estructura de directorios consistente**
   ```
   resultados_{tipo_dano}/
   ├── jupyter_notebooks/
   ├── remapeo_{tipo_elemento}/  (si aplica)
   └── graficas_ID/
   ```

2. **Nomenclatura de archivos CSV**
   - `todos_los_resultados_csv.csv` → Original AG
   - `todos_los_resultados_csv_remapeado.csv` → Con remapeo parcial
   - `todos_los_resultados_csv_remapeado_final.csv` → Versión completa final

3. **Notebooks especializados**
   - `remapeo_{tipo}.ipynb` → Procesamiento de detecciones parciales
   - `analisis_datos_{tipo_dano}.ipynb` → Análisis estadístico y gráficas ICD

4. **Control de versiones**
   - Commits descriptivos en cada etapa
   - Branches: `main` (estable), `AG_DIs` (desarrollo)

5. **Limpieza de archivos**
   - Eliminar backups redundantes
   - Conservar solo CSVs esenciales del pipeline
   - Documentar archivos auxiliares (e.g., `Elemento_design_type.csv`)

---

## 🔧 Herramientas y Librerías Utilizadas

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| Python | 3.9+ | Lenguaje principal |
| pandas | Latest | Manipulación de datos |
| numpy | Latest | Cálculos numéricos |
| matplotlib | Latest | Visualización |
| seaborn | Latest | Gráficas estadísticas |
| statsmodels | Latest | Intervalos de confianza Wilson |
| scipy | Latest | Análisis estadístico |

---

## 📞 Contacto y Soporte

**Responsable:** Francisco Cisneros  
**Proyecto:** Detección de Daños Estructurales con AG  
**Repositorio:** `Proyecto-doctoral` (Branch: `AG_DIs`)

---
