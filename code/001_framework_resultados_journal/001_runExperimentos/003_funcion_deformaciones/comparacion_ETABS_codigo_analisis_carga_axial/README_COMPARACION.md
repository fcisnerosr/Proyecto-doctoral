# Comparación de Cargas Axiales: Código MATLAB vs ETABS

## Descripción

Este branch contiene código modificado para **comparar únicamente las cargas axiales** calculadas por el código MATLAB contra los resultados de ETABS (combinación DEAD + TOPSIDE).

**Objetivo:** Validar que el análisis estático de fuerzas axiales es correcto antes de implementar el cálculo de Pcr con factor K realista.

## Archivos Modificados

### 1. `analisis_estatico_fuerzas_axiales.m`
- **Cambio:** Calcula SOLO `N_axial`, comentando todo el cálculo de `Pcr` y `rho`
- **Salida:** `N_axial_codigo.csv` con formato:
  ```
  Elemento,N_axial_kN
  1,-8365.99
  2,-1560.99
  ...
  ```

### 2. `main_comparacion_etabs.m` (NUEVO)
- Script simplificado para ejecutar solo análisis de fuerzas axiales
- Lee el modelo, ejecuta análisis estático, guarda CSV

### 3. `comparar_con_etabs.py` (NUEVO)
- Script Python automatizado de comparación
- Lee `N_axial_codigo.csv` y `P_etabs_promedio.csv`
- Genera estadísticas detalladas y reportes

## Instrucciones de Uso

### Paso 1: Ejecutar Análisis en MATLAB

```matlab
% En MATLAB, desde el directorio:
% code/001_framework_resultados_journal/

main_comparacion_etabs
```

**Salida esperada:**
- Archivo: `N_axial_codigo.csv` (120 elementos con cargas axiales en kN)
- Consola: Estadísticas de tensión/compresión

### Paso 2: Comparar con ETABS usando Python

```bash
# En terminal, mismo directorio
python comparar_con_etabs.py
```

**Salida esperada:**
- Consola: Reporte detallado con estadísticas
- `comparacion_resultados.csv`: Tabla elemento por elemento
- `comparacion_estadisticas.txt`: Resumen estadístico

## Interpretación de Resultados

### Si error promedio < 5%:
✅ **Las fuerzas axiales son correctas**
- El problema con ρ > 1.0 está en el cálculo de Pcr
- Solución: Implementar factor K realista (0.65-0.80)

### Si error promedio >= 5%:
❌ **Hay un problema en el análisis estático**
- Revisar transformaciones (Gamma_gamma, Gamma_beta)
- Revisar ensamblaje de matriz de rigidez global
- Revisar aplicación de cargas

## Criterios de Evaluación

| Error Promedio | Calificación | Acción |
|----------------|--------------|--------|
| < 2%           | Excelente    | Continuar con K realista |
| 2-5%           | Muy bueno    | Continuar con K realista |
| 5-10%          | Aceptable    | Revisar casos extremos |
| > 10%          | Requiere revisión | Debuggear análisis estático |

## Archivos de Entrada Requeridos

1. **Modelo Excel:** `../../pruebas_excel/marco3Ddam0.xlsx` (obtenido automáticamente)
2. **Datos ETABS:** `001_runExperimentos/003_funcion_deformaciones/P_etabs_promedio.csv`

## Nota Importante

Este branch es **temporal** para validación. Una vez confirmado que las fuerzas axiales son correctas, se debe:

1. Volver al branch principal
2. Implementar factor K realista en `analisis_estatico_fuerzas_axiales.m`
3. Descomentar cálculos de Pcr y rho
4. Re-ejecutar el pipeline completo

## Contacto

Para dudas o problemas, revisar:
- `REPORTE_COMPARACION_ETABS.md`: Análisis teórico completo
- Logs de ejecución de MATLAB/Python
