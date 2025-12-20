# Proyecto Doctoral: Detección de Daños en Plataformas Marinas Tipo Jacket mediante Algoritmos Genéticos

## Resumen General

Este proyecto desarrolla un **sistema automatizado de detección y localización de daños estructurales** en plataformas marinas fijas tipo jacket mediante el uso de **propiedades dinámicas** y **algoritmos genéticos (GA)**.

## Contexto y Motivación

Las plataformas offshore tipo jacket operan en ambientes marinos agresivos donde sufren degradación estructural por:
- **Corrosión** en elementos tubulares (especialmente cerca del lecho marino)
- **Abolladuras** locales por impactos o cargas
- Pérdida progresiva de rigidez y capacidad estructural

La detección temprana de estos daños es crítica para:
- Prevenir fallas catastróficas
- Reducir costos de mantenimiento correctivo
- Extender la vida útil de la estructura
- Garantizar seguridad operacional

## Metodología

### 1. Modelación Estructural
- Lectura de modelos 3D desde **ETABS** (software de análisis estructural)
- Extracción de geometría, conectividad y propiedades de elementos tubulares
- Construcción de matrices de rigidez global (`KG`) y masa (`M`)

### 2. Análisis Modal
- Condensación estática de matrices (eliminación de DOF restringidos)
- Cálculo de **12 modos de vibración** y frecuencias naturales mediante eigenvalores
- Comparación entre modelo intacto y modelo con daño

### 3. Índices de Daño (DIs)
El sistema calcula **8 índices de daño** diferentes basados en:

#### Basados en formas modales:
- **DI1 (COMAC)**: Coordenada Modal de Correlación
- **DI2**: Diferencia absoluta entre vectores modales
- **DI3**: Razón entre modos dañado/intacto

#### Basados en matrices de flexibilidad:
- **DI4**: Diferencia absoluta de flexibilidades
- **DI5**: Razón de flexibilidades
- **DI6**: Porcentaje de variación

#### Basados en análisis estadístico:
- **DI7**: Z-score de diferencias de flexibilidad
- **DI8**: Probabilidad asociada al z-score

### 4. Optimización con Algoritmos Genéticos (GA)

El núcleo del método utiliza un **algoritmo genético** para:

#### Objetivo:
Encontrar pesos óptimos (`α₁, α₂, ..., α₈`) que combinan los 8 índices de daño:
P = α₁·DI₁ + α₂·DI₂ + α₃·DI₃ + ... + α₈·DI₈


#### Configuración del GA:
- **Población**: 300 individuos
- **Generaciones**: 500 iteraciones
- **Función objetivo**: Minimizar diferencia entre P y vector objetivo T
- **Restricciones**: Pesos normalizados [0, 1]

#### Umbral de detección:
Se aplica un umbral para filtrar falsos positivos, considerando solo valores significativos de los DIs.

### 5. Tipos de Daño Simulados

El framework puede modelar:

#### a) **Corrosión Uniforme**
- Reducción del espesor de pared del elemento tubular
- Pérdida de área transversal
- Actualización de propiedades de inercia (Iy, Iz, J)

#### b) **Abolladura Longitudinal**
- Deformación local en elementos tubulares
- Modelación por segmentos (Nseg = 1000)
- Cálculo de inercias variables a lo largo del elemento
- Generación de matriz de flexibilidad local modificada

### 6. Flujo de Ejecución
```text
Configuración (config.m)
↓
Lectura de modelo ETABS sin daño
↓
Ensamble de matrices KG y M
↓
Cálculo de modos intactos (12 modos)
↓
Creación de máscara para nodos de superestructura
↓
Cálculo de DIs base (modelo intacto)
↓
Loop de experimentos (runExperimentos.m)
│
└──→ Para cada combinación (elemento, % daño):
├─ Aplicar daño local (switch_case_danos.m)
├─ Ensamblar KG dañada
├─ Calcular nuevos modos (12)
├─ Calcular 8 DIs del modelo dañado
├─ Ejecutar AG para optimizar pesos
├─ Combinar DIs → Indicador P
├─ Escalar y normalizar P
├─ Evaluar detección correcta
├─ Calcular estadísticas (dispersión, falsos positivos)
└─ Guardar resultados y gráficas
```

### 7. Métricas de Desempeño

El sistema evalúa:
- **Detección correcta**: ¿Se identificó el nodo dañado?
- **Falsos positivos**: Nodos marcados erróneamente como dañados (P ≥ 50%)
- **Dispersión estadística**: Variabilidad del indicador P
- **Valor objetivo final**: Convergencia del GA

## Estructura de Datos de Entrada

### Desde ETABS (Excel):
- **Coordenadas nodales** (X, Y, Z)
- **Conectividad** de elementos (nodo inicial - nodo final)
- **Propiedades geométricas**: Área, Iy, Iz, J (momento polar)
- **Propiedades de material**: E (módulo elástico), G (módulo cortante)
- **Secciones tubulares**: Diámetro (D) y espesor (t)
- **Restricciones**: Nodos empotrados

### Desde marco3Ddam0.xlsx:
- Identificadores de elementos
- Propiedades adicionales para cálculo de rigideces

## Estructura de Salida

### Archivo: `todos_los_resultados.xlsx`
Por cada corrida experimental:
- ID de ejecución
- Elemento dañado
- Porcentaje de daño
- Tiempo de cómputo
- Valor de función objetivo final
- Detección correcta (sí/no)
- Estadísticas de dispersión
- Número de falsos positivos

### Archivo: `DetalleTodasCorridas.xlsx`
Desglose nodal por corrida con:
- Número de nodo
- Valor de daño normalizado (0-100)
- Estado: "Daño" si ≥ 50%, "-" en caso contrario

### Gráficas:
- Convergencia del algoritmo genético (ID_XXXX.png)
- Evolución de población, mejor individuo, distancia, rango

## Características Técnicas

### Condensación Estática
- Elimina DOF de nodos empotrados (típicamente 4 nodos de base)
- Reduce dimensionalidad del problema de eigenvalores
- Conserva DOF activos de superestructura (nodos 41-52)

### Normalización Modal
- Modos normalizados respecto a matriz de masa
- Garantiza ortogonalidad modal

### Ensamblaje Global
- Matrices de rigidez local 12×12 (elemento 3D tipo frame)
- Transformación a coordenadas globales
- Ensamblaje por superposición directa

## Aplicaciones

Este framework permite:
1. **Estudios paramétricos**: Evaluar sensibilidad a diferentes niveles de daño
2. **Comparación de DIs**: Identificar índices más efectivos
3. **Optimización de monitoreo**: Determinar ubicaciones óptimas de sensores
4. **Validación experimental**: Comparar con datos reales de plataformas
5. **Planificación de mantenimiento**: Priorizar inspecciones basadas en riesgo

## Tecnologías Utilizadas

- **MATLAB**: Lenguaje principal de desarrollo
- **ETABS**: Modelación estructural
- **Algoritmo Genético (GA)**: Toolbox de optimización de MATLAB
- **Análisis Modal**: Eigenvalores/eigenvectores (función `eigs`)
- **Procesamiento de datos**: Excel I/O

## Innovación

El enfoque combina:
- **Múltiples índices de daño** (no solo uno)
- **Optimización inteligente** de pesos mediante GA
- **Detección local** en elementos tubulares
- **Modelación realista** de daños (corrosión y abolladura)
- **Validación estadística** (z-score, probabilidades)
- **Automatización completa** del flujo de análisis

Este sistema representa un avance significativo en la detección no destructiva y basada en vibración para estructuras offshore, con potencial aplicación en inspección y mantenimiento predictivo de plataformas marinas.
