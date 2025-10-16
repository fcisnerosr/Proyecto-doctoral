# Resultados del Análisis de Abolladuras

Este documento resume, sin código, las figuras y hallazgos clave del análisis realizado en el notebook `analisis_datos_abolladura.ipynb`. Incluye propósito, metodología y lectura de cada figura. Las imágenes referenciadas se encuentran (o pueden exportarse) en `../figuras/`.

Nota: Donde no existe un archivo de imagen exportado específico, se indica cómo generarlo desde el notebook.

---

## Figura 1 — Tasa de detección vs % de daño (IC 95% binomial)

Propósito: Mostrar la probabilidad de detección (POD empírica) para cada severidad de abolladura, junto con el intervalo de confianza (IC) del 95%.

Metodología:
- Para cada % de daño, se calcula la tasa de detección como éxitos/n (n=120 por nivel).
- El IC95% se calcula con el método de Wilson.

Lectura e interpretación:
- Barras verticales = incertidumbre estadística (IC95%).
- Barras cortas → alta consistencia; barras largas → mayor variabilidad.
- En el agregado, la curva es casi plana (~0.68). No hay diferencia significativa entre 5% y 10–45%.
- Mensaje: MDD90 > 45%; MDD50 < 5%.

Imagen: exportar desde el notebook (Figura 1). Sugerencia de nombre: `../figuras/fig_01_tasa_vs_dano.png`.

---

## Figura 2 — Sensibilidad por tipo de elemento

Propósito: Comparar la detectabilidad del algoritmo (POD) entre tipos de elementos (Brace, Inclined_leg, Beam).

Metodología:
- Tasa por tipo×% con IC95% (Wilson).
- Ajuste de curvas POD con GLM binomial (logit).
- Estimación cualitativa de MDD50/MDD90 por tipo.
- Métricas de localización: `MeanAbsDispersion` y `N_FalsosPositivos`.

Lectura e interpretación:
- Brace: desempeño excelente (POD ~1 a partir de 10%); MDD90 < 10%.
- Inclined_leg: desempeño bajo y plano (POD ~0.10).
- Beam: desempeño nulo (POD ~0).
- Dispersión y FP: Brace ~bajos; Inclined_leg/Beam ~altos.

Imágenes sugeridas (exportar desde el notebook):
- `../figuras/fig_02a_tasa_por_tipo.png`
- `../figuras/fig_02b_pod_por_tipo.png`
- `../figuras/fig_02c_dispersion_por_tipo.png`
- `../figuras/fig_02d_fp_por_tipo.png`

---

## Punto 12 — Extensión espacial: sensibilidad por Zona

Propósito: Evaluar cómo varía la POD y la calidad de localización según la zona vertical (`mudline`, `sub1`, `sub2`, `sub3`, `splash`, `atmos`).

Metodología:
- Tasa por Tipo×Zona×% con IC95% (Wilson).
- Curvas POD por zona y MDD50/MDD90 (delta method sobre GLM logit).
- Localización por zona: medianas de `MeanAbsDispersion` y `N_FalsosPositivos`.
- Modelos con interacción para contrastes globales.

Lectura e interpretación:
- Zonas con MDD90 menor → mayor sensibilidad.
- Menores dispersión/FP → mejor localización.
- Evidencia de modulación por zona si hay interacción significativa.

Imágenes sugeridas (exportar desde el notebook):
- `../figuras/fig_12a_tasa_tipo_por_zona.png`
- `../figuras/fig_12b_pod_por_zona.png`
- `../figuras/fig_12c_dispersion_por_zona.png`
- `../figuras/fig_12d_fp_por_zona.png`

---

## Punto 13 — Calidad de Detección (ICD) por Tipo

Definición de la métrica ICD:

ICD = DetOK × 1/(1 + MeanAbsDispersion + N_FalsosPositivos)

- DetOK (0/1): detección correcta.
- MeanAbsDispersion: dispersión de la localización (penaliza la calidad).
- N_FalsosPositivos: recuento de falsos positivos (penaliza la calidad).

Propósito: Evaluar calidad integral de detección por tipo, combinando éxito, precisión de localización y FP.

Metodología:
- Cálculo de ICD por corrida.
- Promedio e IC95% de la media por tipo×% de daño.

Lectura e interpretación:
- Curvas más altas → mejor calidad de detección.
- Bandas de IC → incertidumbre de la media.

Imágenes sugeridas:
- `../figuras/fig_13_icd_por_tipo.png`

---

## Punto 13.5 — Comparativa Global de ICD por Tipo

Propósito: Visualizar en una sola figura el ICD promedio (con IC95%) para todos los tipos a través del % de daño.

Lectura clave:
- Permite comparar robustez global de la detección entre tipos.
- Curvas altas y estables indican mayor calidad integral (detección+localización+FP bajos).

Imagen sugerida:
- `../figuras/fig_13_5_comparativa_icd_tipo.png`

---

## Punto 14 — ICD por Zona (nivel)

Fórmula:
ICD = DetOK × 1/(1 + MeanAbsDispersion + N_FalsosPositivos)

Propósito: Evaluar cómo varía la calidad de detección con la zona vertical del elemento dañado.

Metodología:
- Cálculo de ICD por corrida.
- Agregación por Zona×% de daño: media e IC95%.
- Gráfica consolidada por Zona con bandas de IC.

Lectura e interpretación:
- Curvas más altas → mejor calidad de detección en esa zona.
- Tendencias descendentes → peor localización o más FP con el aumento de daño.

Imagen sugerida:
- `../figuras/fig_14_icd_por_zona.png`

---

## Exportar/actualizar figuras desde el notebook (si faltan)

Para cada figura en el notebook, después de `plt.show()` puedes añadir una línea para guardar la imagen, por ejemplo:

```python
plt.savefig("../figuras/fig_XX_nombre_descriptivo.png", dpi=200, bbox_inches="tight")
```

Reemplaza `fig_XX_nombre_descriptivo.png` por los nombres sugeridos arriba. Asegúrate de que la ruta `../figuras` exista.

---

## Mensajes clave globales

- La severidad (5–45%) no incrementa apreciablemente la POD global del AG (~0.68); factores de tipo/ubicación dominan.
- Los braces son detectables y localizables de forma robusta; piernas inclinadas y vigas requieren ajustes o métodos alternativos.
- La métrica ICD integra detección, localización y FP, ofreciendo una visión más operativa que la tasa de acierto aislada.
