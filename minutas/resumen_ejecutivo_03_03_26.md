# RESUMEN EJECUTIVO - PROYECTO DOCTORAL
**Manuscrito para Applied Ocean Research (Elsevier Q1)**

**Fecha creación:** 03 de marzo de 2026 — **Última actualización:** 25 de marzo de 2026  
**Autor:** Francisco Javier Cisneros Ruiz  
**Estado del Proyecto:** Análisis de datos en curso — 5/6 puntos completados

---

## 📊 ESTADO ACTUAL DEL PROYECTO

### Progreso General
```
█████████████████████████████████████████░░ 83.3% (5/6 puntos completados)
```

### Logros Completados ✅
- **3,240 simulaciones ejecutadas** (26-27 Feb 2026)
  - 1,080 corridas abolladura (5-45% severidad)
  - 2,160 corridas corrosión (5-90% severidad)
- **Hungarian Algorithm** activo en todas las corridas
- **Vectores alpha (α₁-α₈)** exportados correctamente
- **Código MATLAB** validado y funcional

#### Puntos de análisis completados (sesiones 13-21 Mar 2026)
- **Punto 1 ✅** — `07_tabla_resumen_casos.ipynb`: `cases.csv` (3,240 filas), `elements_catalog.csv` (120 elementos), 2 figuras distribución, 2 tablas LaTeX (`tabla_casos_experimentales.tex`, `tabla_desglose_casos.tex`)
- **Punto 2 ✅** — `04_analisis_alpha.ipynb` + `05_alpha_dispersión.ipynb`: boxplots de α₁–α₈, heatmap correlación, CV por componente. Hallazgo: α₅ (COMAC) y α₈ (z-score flexibilidad) dominan. Tablas LaTeX exportadas.
- **Punto 5 ✅** — `06_metricas_clasificacion.ipynb`: Precision/Recall/F1/ROC por tipo de elemento y severidad. Hallazgo: Recall = 0.95–1.0, Precision = 0.08–0.41. Mejor F1 = 0.57 (Brace/Abolladura 10%). 2 tablas LaTeX + 4 figuras exportadas.
- **Punto 3 ✅** — `08_POD_Wilcoxon_baseline.ipynb`: Mejor DI individual = DI₆ (AUC=0.782/0.795). ICD supera DI₆ en 6/6 combinaciones (Wilcoxon p<0.0001). Mejoras AUC-POD: +23% a +433%. 4 figuras + tabla LaTeX (`tabla_wilcoxon_POD.tex`) exportadas.
- **Punto 4 ✅** — `09_ruido_gaussiano_SNR.ipynb`: Robustez AWGN del ICD. Brace mantiene AUC-ROC ≥ 0.965 hasta 5 dB SNR (degradación <3.5%). Inclined_leg: -25.6% @ 5dB, SNR crítico=10 dB. Beam/IL-Corrosión: detección perfecta (AUC N/A). 3 figuras + tabla LaTeX (`tabla_snr_robustness.tex`) exportadas.

---

## 🎯 6 PUNTOS MÍNIMOS PARA PUBLICACIÓN EN AOR

**⚠️ PREREQUISITO CRÍTICO:** Estos 6 puntos deben completarse **ANTES** de iniciar la redacción del manuscrito.

| # | Punto | Estado | Prioridad | Dependencias |
|---|-------|--------|-----------|--------------|
| **1** | Tabla/resumen de casos + figura de elementos | ✅ COMPLETADO (21-Mar) | 🔴 ALTA | Independiente |
| **2** | Análisis vectores α (media, std, CV, gráficas) | ✅ COMPLETADO (18-Mar) | 🔴 CRÍTICA | Independiente |
| **3** | Comparación ICD vs mejor DI individual (baseline) | ✅ COMPLETADO (21-Mar) | 🟡 MEDIA | Requiere Punto 2 |
| **4** | Simulación de ruido (SNR, robustez) | ✅ COMPLETADO (25-Mar) | 🟡 MEDIA | Independiente |
| **5** | Métricas de clasificación (TP/FP/Precision/Recall/F1) | ✅ COMPLETADO (21-Mar) | 🔴 ALTA | Independiente |
| **6** | Referencias actualizadas (2023-2025) | ⏸️ PENDIENTE | 🟢 BAJA | Durante redacción |

---

### Descripción Detallada de los Puntos

#### Punto 2 — Análisis estadístico de vectores α (media, std, CV, gráficas)

**Qué es:**  
El Algoritmo Genético (AG) optimiza un vector de pesos α = [α₁, α₂, ..., α₈], donde cada αₖ representa la importancia relativa del k-ésimo Índice de Daño (DI) en el ICD. Tras las 3,240 corridas, se dispone de 3,240 vectores α distintos — uno por corrida.

**Cómo se hace:**  
Se calcula para cada componente αₖ: la media μ(αₖ), la desviación estándar σ(αₖ) y el coeficiente de variación CV(αₖ) = σ/μ. Se generan boxplots (distribución por componente) y heatmaps (correlación entre αₖ) separados por tipo de daño (abolladura vs corrosión) y por nivel de severidad.

**Por qué es necesario:**  
El manuscrito debe argumentar cuáles DIs son informativos y cuáles son redundantes o irrelevantes. Un CV alto indica que el AG no tiene consenso sobre ese DI → posible candidato a eliminar o re-analizar. Un CV bajo con media alta indica que ese DI siempre resulta importante → es el hallazgo clave del artículo.

---

#### Punto 3 — Comparación ICD vs mejor DI individual (baseline)

**Qué es:**  
Demostrar que el ICD (combinación ponderada de α₁…α₈) supera a cualquier DI individual usado de forma aislada. El "mejor DI individual" se identifica a partir del Punto 2 (el de mayor media y menor CV).

**Cómo se hace:**  
Se comparan las curvas de Probabilidad de Detección (POD) del ICD contra las curvas POD del mejor DI単独, en función del porcentaje de daño (5%, 15%, 25%, etc.). Se aplica un test estadístico (t-test o Wilcoxon) para verificar que la diferencia es significativa. Opcionalmente se puede graficar el AUC (Área Bajo la Curva ROC) de ambos métodos.

**Por qué es necesario:**  
Todo revisore de un journal Q1 preguntará: *"¿Por qué necesito una combinación de 8 índices si uno solo podría funcionar?"*. Este punto responde esa pregunta con evidencia cuantitativa. Sin este análisis, la aportación del ICD no está justificada.

---

#### Punto 4 — Simulación de ruido (SNR, robustez)

**Qué es:**  
Evaluar qué tan robusto es el ICD cuando los datos de vibración están contaminados con ruido de medición, que es lo que ocurre en condiciones reales de monitoreo offshore.

**Cómo se hace:**  
Se inyecta ruido gaussiano blanco a los vectores de desplazamiento modal con distintos niveles de SNR (por ejemplo, 40 dB, 30 dB, 20 dB, 10 dB). Para cada nivel se recalculan los DIs y el ICD, y se registra si la detección sigue siendo correcta. Se grafica la tasa de detección correcta vs SNR.

**Por qué es necesario:**  
Applied Ocean Research publica investigación orientada a aplicaciones industriales reales en plataformas offshore. Un método que solo funciona con datos perfectos (sin ruido) no es publicable en ese contexto. Este punto valida la viabilidad práctica del método.

---

#### Punto 5 — Métricas de clasificación (TP, FP, Precision, Recall, F1-score)

**Qué es:**  
Cuantificar el desempeño del sistema de detección usando el vocabulario estándar de evaluación de clasificadores binarios: el sistema dice "hay daño en el elemento X" → ¿acertó o no?

**Cómo se hace:**  
Para cada corrida se tiene: elemento real dañado (ground truth) y elementos detectados como dañados (predicción del AG). Primero se definen los cuatro casos posibles de la matriz de confusión:

- **TP (True Positive — Verdadero Positivo):** el sistema detectó un elemento como dañado *y* realmente lo estaba. Es el acierto directo.
- **FP (False Positive — Falso Positivo):** el sistema detectó un elemento como dañado *pero* en realidad estaba intacto. Es una alarma falsa — el costo industrial de este error es movilizar inspección innecesaria.
- **FN (False Negative — Falso Negativo):** el sistema no detectó un elemento que *sí* estaba dañado. Es el error más peligroso en contextos estructurales reales.
- **TN (True Negative — Verdadero Negativo):** el sistema correctamente identificó un elemento intacto como intacto.

A partir de estos cuatro valores se calculan las métricas de desempeño:

- **Precision** = TP / (TP + FP): de todos los elementos que el sistema reportó como dañados, ¿qué fracción realmente lo estaba? Mide cuánto se puede confiar en una alarma positiva.
- **Recall** = TP / (TP + FN): de todos los elementos que realmente estaban dañados, ¿qué fracción detectó el sistema? Mide la capacidad de no dejar pasar daño real.
- **F1-score** = 2 × (Precision × Recall) / (Precision + Recall): media armónica entre Precision y Recall. Sintetiza ambas métricas en un solo número; es útil cuando hay desbalance entre clases (muchos elementos intactos vs pocos dañados, como ocurre en este problema).

Estas métricas se calculan por nivel de severidad (5%, 15%, 25%…) y por tipo de daño (abolladura vs corrosión).

**Por qué es necesario:**  
Son las métricas universalmente exigidas por reviewers en trabajos de SHM y detección de anomalías. Sin ellas, el artículo no puede compararse con el estado del arte, y los revisores lo señalarán directamente como una deficiencia mayor.

---

#### Punto 6 — Referencias actualizadas (2023–2025)

**Qué es:**  
Identificar y citar trabajos publicados en los últimos 2-3 años que sean relevantes para: SHM de plataformas jacket, índices de daño modales, algoritmos genéticos aplicados a detección de daño, y robustez ante ruido en sistemas de monitoreo.

**Cómo se hace:**  
Búsqueda sistemática en Scopus/Web of Science con términos: *"jacket platform SHM"*, *"damage index modal"*, *"genetic algorithm damage detection"*, *"offshore structural health monitoring 2023-2025"*. Se seleccionan los artículos de mayor relevancia (Q1 preferentemente) y se integran en la sección de Introduction y Discussion del manuscrito.

**Por qué es necesario:**  
Applied Ocean Research (CiteScore 5.3) exige que la Introduction demuestre conocimiento del estado del arte reciente. Referencias desactualizadas (anteriores a 2020) son señal de alerta para editores y revisores, y pueden derivar en rechazo sin revisión (desk rejection).

---

### Estado Detallado

#### ✅ Punto 2 (PARCIAL): Vector óptimo α + dispersión
**Completado (2.1-2.4):**
- ✓ Código modificado para exportar alpha1-alpha8
- ✓ 3,240 corridas ejecutadas con vectores α disponibles

**Pendiente (2.5-2.6):**
- Calcular estadísticas: μ(αₖ), σ(αₖ), CV(αₖ)
- Generar boxplots/heatmaps de dispersión
- Identificar DIs más relevantes
- Verificar convergencia del GA

---

## ⏱️ TIEMPOS DE PROCESO EN APPLIED OCEAN RESEARCH

Basado en estadísticas oficiales del journal (2024-2025):

| Etapa del Proceso | Tiempo Promedio | Descripción |
|-------------------|-----------------|-------------|
| **Submission → First Decision** | **6 días** | Decisión editorial inicial (desk review) |
| **Submission → Decision After Review** | **53 días** (~1.8 meses) | Proceso completo de peer review |
| **Submission → Acceptance** | **146 días** (~4.9 meses) | Desde envío hasta aceptación final |
| **Acceptance → Online Publication** | **9 días** | Publicación en línea tras aceptación |
| **TIEMPO TOTAL ESTIMADO** | **~5 meses** | Desde envío hasta publicación online |

### 💰 Costos de Publicación (Open Access)
- **APC (Article Publishing Charge):** USD $3,380 (sin impuestos)
- **Programa:** GPOA (Global Plan for Open Access)
- **Modalidad:** Open Access (acceso abierto)

### 📅 Proyección de Timeline

Si enviamos el manuscrito el **1 de abril de 2026**:
- **First Decision:** ~7 de abril de 2026
- **Decision After Review:** ~24 de mayo de 2026
- **Acceptance (optimista):** ~25 de agosto de 2026
- **Online Publication:** ~3 de septiembre de 2026

**⚠️ NOTA:** Estos son tiempos promedio. El proceso puede extenderse si se requieren revisiones mayores.

---

## 🚀 RUTA CRÍTICA INMEDIATA

### Fase 1: Análisis de Datos (1-2 semanas)
**Objetivo:** Completar Puntos 1, 2.5-2.6, y 5

#### Semana 1 (Prioridad Máxima)
```
[🔴 CRÍTICO] Punto 2.5-2.6: Análisis estadístico de vectores α
├─ Crear notebook Jupyter para análisis
├─ Calcular μ, σ, CV de α₁-α₈
├─ Generar visualizaciones (boxplots, heatmaps)
├─ Identificar top 3 DIs más influyentes
└─ Documentar hallazgos
   Estimado: 2-4 horas

[🔴 ALTA] Punto 1: Tabla + figura de elementos
├─ Tabla LaTeX: resumen experimental
├─ Figura: elementos del jacket coloreados
└─ Exportar en formato publicable (EPS/PDF)
   Estimado: 1-2 horas

[🔴 ALTA] Punto 5: Métricas de clasificación
├─ Calcular TP, FP, Precision, Recall, F1
├─ Generar tablas por severidad
└─ Gráficas evolución vs %daño
   Estimado: 2-3 horas
```

#### Semana 2 (Análisis Comparativo)
```
[🟡 MEDIA] Punto 3: Comparación ICD vs baseline
├─ Identificar mejor DI individual (de Punto 2.5)
├─ Calcular curvas POD
└─ Test estadístico (t-test/Wilcoxon)
   Estimado: 3-4 horas
   ⚠️ DEPENDE: Requiere Punto 2.5 completado

[🟡 MEDIA] Punto 4: Simulación de ruido
├─ Implementar inyección ruido gaussiano
├─ Re-calcular ICD con datos ruidosos
└─ Gráficas ICD vs SNR
   Estimado: 2-3 horas
```

### Fase 2: Redacción del Manuscrito (2-3 semanas)
**Inicio:** Solo después de completar los 6 puntos mínimos

```
Semana 3-4: Redacción inicial
├─ Título y Abstract
├─ Introduction
├─ Methodology
├─ Results (con las 6 secciones completadas)
└─ Discussion

Semana 5: Revisión y pulido
├─ Actualizar referencias (Punto 6)
├─ Verificar formato Elsevier (CAS template)
├─ Revisión de idioma técnico
└─ Preparación de materials suplementarios
```

---

## 🎯 NOVEDAD TÉCNICA DEL MANUSCRITO

### Aportación Principal: ICD (Índice de Calidad de Detección)

**Fórmula:**
```
ICD = D × C_norm(δ) × P_FP(N_FP)
```

Donde:
- **D:** Factor de éxito de detección (0, 0.5, 1)
- **C_norm:** Factor de confianza logarítmico (función del % de daño)
- **P_FP:** Penalización exponencial por falsos positivos

**Ventaja sobre métodos existentes:**
- Pondera calidad de detección más allá de métricas binarias
- Integra severidad de daño y confiabilidad del diagnóstico
- Penaliza falsos positivos para aplicaciones industriales

### Mejora Metodológica Complementaria

**Hungarian Algorithm para emparejamiento modal:**
- Elimina errores de "mode veering" (cruce de modos)
- Asegura emparejamiento MAC correcto
- Validado en 3,240 simulaciones

---

## 📁 DATOS DISPONIBLES

### Archivos de Resultados
```
Resultados/
├── abolladura_2026-02-26_05-26-02/
│   ├── todos_los_resultados.xlsx (1,080 filas × 18 cols)
│   ├── DetalleTodasCorridas.xlsx (diagnóstico)
│   └── figuras/ (1,080 PNG)
│
└── corrosion_2026-02-27_06-07-17/
    ├── todos_los_resultados.xlsx (2,160 filas × 18 cols)
    ├── DetalleTodasCorridas.xlsx (diagnóstico)
    └── figuras/ (2,160 PNG)
```

### Estructura de Datos (18 columnas)
- **Identificación:** ID, Elemento, Porcentaje
- **Diagnóstico GA:** Tiempo_s, ObjFinal
- **Detección:** DeteccionOK, N_FalsosPositivos
- **Vectores α:** alpha1, alpha2, ..., alpha8
- **Diagnóstico MAC:** MAC_minimo, MAC_promedio, Hubo_cruces_modales

---

## 🎓 RECOMENDACIONES PARA ASESORES

### Para Discusión Inmediata
1. **Priorización de análisis:** ¿Comenzar con Punto 2.5-2.6 (alphas)?
2. **Recursos computacionales:** Notebooks requieren entorno Jupyter configurado
3. **Timeline objetivo:** ¿Apuntar a envío en abril/mayo 2026?
4. **Presupuesto APC:** Confirmar disponibilidad de USD $3,380

### Riesgos Identificados
- **Tiempo de análisis:** 10-15 horas estimadas (puede extenderse)
- **Revisión de idioma:** Manuscrito requiere inglés técnico de alto nivel
- **Baseline comparison:** Si no hay mejora vs DI individual, ajustar narrativa

### Fortalezas del Proyecto
- ✅ Datos completos y validados (3,240 corridas)
- ✅ Metodología robusta (Hungarian Algorithm)
- ✅ Novedad técnica clara (ICD)
- ✅ Código reproducible y documentado

---

## 📌 PRÓXIMOS PASOS ACCIONABLES

### Esta Semana (03-10 Marzo)
- [ ] **Hoy:** Ejecutar notebooks de análisis alpha (Punto 2.5-2.6)
- [ ] **Mié-Jue:** Generar tabla/figura de experimentos (Punto 1)
- [ ] **Vie:** Calcular métricas de clasificación (Punto 5)
- [ ] **Revisión:** Validar resultados con asesores

### Semana Siguiente (10-17 Marzo)
- [ ] Completar Punto 3 (comparación ICD vs baseline)
- [ ] Completar Punto 4 (simulación ruido)
- [ ] Iniciar búsqueda de referencias 2023-2025 (Punto 6)
- [ ] **Checkpoint:** Verificar que los 6 puntos estén completos

### Meta: Abril 2026
- [ ] Manuscrito completo redactado
- [ ] Revisión de asesores
- [ ] Preparación de submission a AOR
- [ ] **Target:** Envío antes del 15 de abril

---

## 📧 CONTACTO Y SEGUIMIENTO

**Investigador Principal:** Francisco Javier Cisneros Ruiz  
**Institución:** [Pendiente especificar]  
**Journal Objetivo:** Applied Ocean Research (Elsevier)  
**CiteScore 2023:** 5.3 (Q1)  
**Impact Factor:** [Verificar última actualización]

**Última Actualización:** 03 de marzo de 2026  
**Próxima Revisión:** 10 de marzo de 2026

---

**NOTA IMPORTANTE:** Este documento es un resumen ejecutivo. Para detalles técnicos completos, consultar:
- `MINUTA_SESION_2026-03-02.md` (minuta detallada)
- `docs/pendientes_minimos_para_publicar_en_factor_de_impacto.txt` (requisitos técnicos)
- `outputs/resultados_nuevos/README.md` (pipeline de análisis)
