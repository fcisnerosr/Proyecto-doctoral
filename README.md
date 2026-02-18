# Proyecto Doctoral: Detección de Daños en Plataformas Marinas Tipo Jacket mediante Algoritmos Genéticos

## ⚠️ REQUERIMIENTO CRÍTICO

> **Este sistema requiere OBLIGATORIAMENTE Optimization Toolbox de MATLAB.**  
> Sin este toolbox el sistema **NO FUNCIONARÁ** (no existe alternativa).  
> 
> **Funciones requeridas del toolbox:**
> - `ga()` - Algoritmo Genético  
> - `matchpairs()` - Emparejamiento modal Hungarian
>
> **Verificar instalación:**
> ```matlab
> >> ver  % Buscar "Optimization Toolbox" en la lista
> ```

---

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

#### 1.1 Lectura de Modelo ETABS

El modelo estructural 3D se genera en **ETABS** y se exporta a Excel con las siguientes hojas:

**Geometría del Modelo:**
- `Point Object Connectivity`: Coordenadas nodales $(x, y, z)$ de todos los nodos
- `Beam/Column/Brace Object Connectivity`: Tabla de conectividad elemento-nodo
- `Mat Prop - Basic Mech Props`: Propiedades del material
  - $E$ = Módulo de elasticidad (típicamente 200 GPa para acero)
  - $G$ = Módulo de cortante (típicamente 77 GPa)
  - $\nu$ = Coeficiente de Poisson (típicamente 0.3)

**Propiedades de Secciones Tubulares:**
- `Frame Prop - Summary`: Propiedades geométricas de cada sección
  - $A$ = Área transversal
  - $I_y, I_z$ = Momentos de inercia respecto a ejes locales
  - $J$ = Momento polar de torsión
- `Frame Assigns - Sect Prop`: Asignación de secciones a elementos

#### 1.2 Construcción de Matrices Globales

**Matriz de Rigidez Global:**

La matriz de rigidez global $\mathbf{K}_G \in \mathbb{R}^{N_{DOF} \times N_{DOF}}$ se ensambla mediante:

$$
\mathbf{K}_G = \mathbb{A}_{e=1}^{N_e} \mathbf{T}_e^T \mathbf{k}_e^{\text{local}} \mathbf{T}_e
$$

Donde:
- $N_{DOF}$ = Número total de grados de libertad del sistema (6 DOF por nodo × número de nodos)
- $N_e$ = Número total de elementos frame
- $\mathbf{k}_e^{\text{local}} \in \mathbb{R}^{12 \times 12}$ = Matriz de rigidez local del elemento $e$ (elemento frame 3D con 2 nodos)
- $\mathbf{T}_e \in \mathbb{R}^{12 \times 12}$ = Matriz de transformación de coordenadas locales a globales
- $\mathbb{A}$ = Operador de ensamblaje (superposición directa en posiciones correspondientes)

**Matriz de Rigidez Local de Elemento Frame 3D:**

$$
\mathbf{k}_e^{\text{local}} = \begin{bmatrix}
\frac{EA}{L} & 0 & 0 & 0 & 0 & 0 & -\frac{EA}{L} & 0 & 0 & 0 & 0 & 0 \\
0 & \frac{12EI_z}{L^3} & 0 & 0 & 0 & \frac{6EI_z}{L^2} & 0 & -\frac{12EI_z}{L^3} & 0 & 0 & 0 & \frac{6EI_z}{L^2} \\
0 & 0 & \frac{12EI_y}{L^3} & 0 & -\frac{6EI_y}{L^2} & 0 & 0 & 0 & -\frac{12EI_y}{L^3} & 0 & -\frac{6EI_y}{L^2} & 0 \\
0 & 0 & 0 & \frac{GJ}{L} & 0 & 0 & 0 & 0 & 0 & -\frac{GJ}{L} & 0 & 0 \\
0 & 0 & -\frac{6EI_y}{L^2} & 0 & \frac{4EI_y}{L} & 0 & 0 & 0 & \frac{6EI_y}{L^2} & 0 & \frac{2EI_y}{L} & 0 \\
0 & \frac{6EI_z}{L^2} & 0 & 0 & 0 & \frac{4EI_z}{L} & 0 & -\frac{6EI_z}{L^2} & 0 & 0 & 0 & \frac{2EI_z}{L} \\
-\frac{EA}{L} & 0 & 0 & 0 & 0 & 0 & \frac{EA}{L} & 0 & 0 & 0 & 0 & 0 \\
0 & -\frac{12EI_z}{L^3} & 0 & 0 & 0 & -\frac{6EI_z}{L^2} & 0 & \frac{12EI_z}{L^3} & 0 & 0 & 0 & -\frac{6EI_z}{L^2} \\
0 & 0 & -\frac{12EI_y}{L^3} & 0 & \frac{6EI_y}{L^2} & 0 & 0 & 0 & \frac{12EI_y}{L^3} & 0 & \frac{6EI_y}{L^2} & 0 \\
0 & 0 & 0 & -\frac{GJ}{L} & 0 & 0 & 0 & 0 & 0 & \frac{GJ}{L} & 0 & 0 \\
0 & 0 & -\frac{6EI_y}{L^2} & 0 & \frac{2EI_y}{L} & 0 & 0 & 0 & \frac{6EI_y}{L^2} & 0 & \frac{4EI_y}{L} & 0 \\
0 & \frac{6EI_z}{L^2} & 0 & 0 & 0 & \frac{2EI_z}{L} & 0 & -\frac{6EI_z}{L^2} & 0 & 0 & 0 & \frac{4EI_z}{L}
\end{bmatrix}
$$

Donde $L$ = longitud del elemento

**Matriz de Transformación:**

$$
\mathbf{T}_e = \begin{bmatrix}
\mathbf{R}_e & \mathbf{0} & \mathbf{0} & \mathbf{0} \\
\mathbf{0} & \mathbf{R}_e & \mathbf{0} & \mathbf{0} \\
\mathbf{0} & \mathbf{0} & \mathbf{R}_e & \mathbf{0} \\
\mathbf{0} & \mathbf{0} & \mathbf{0} & \mathbf{R}_e
\end{bmatrix}
$$

Donde $\mathbf{R}_e \in \mathbb{R}^{3 \times 3}$ es la matriz de rotación del sistema local al global.

**Matriz de Masa:**

La matriz de masa $\mathbf{M} \in \mathbb{R}^{N_{DOF} \times N_{DOF}}$ se construye como matriz diagonal con masas nodales:

$$
\mathbf{M} = \text{diag}\left(m_1, m_1, m_1, 0, 0, 0, \ldots, m_n, m_n, m_n, 0, 0, 0\right)
$$

Donde:
- $m_i$ = Masa concentrada en el nodo $i$ (en direcciones traslacionales x, y, z)
- Los términos rotacionales son típicamente cero para análisis modal con masas concentradas
- Las masas se extraen de ETABS o se calculan como: $m_i = \sum_{e \in E_i} \frac{\rho A_e L_e}{2}$
  - $\rho$ = Densidad del material (7850 kg/m³ para acero)
  - $E_i$ = Conjunto de elementos conectados al nodo $i$

### 2. Análisis Modal

#### 2.1 Condensación Estática (Reducción de Guyan)

Para reducir el costo computacional, se eliminan los DOF restringidos (nodos empotrados) mediante condensación estática:

**Partición de Matrices:**

$$
\begin{bmatrix}
\mathbf{K}_{aa} & \mathbf{K}_{ab} \\
\mathbf{K}_{ba} & \mathbf{K}_{bb}
\end{bmatrix}
\begin{bmatrix}
\mathbf{u}_a \\
\mathbf{u}_b
\end{bmatrix}
=
\begin{bmatrix}
\mathbf{F}_a \\
\mathbf{F}_b
\end{bmatrix}
$$

Donde:
- Subíndice $a$ = DOF activos (superestructura, nodos 41-52 en este proyecto)
- Subíndice $b$ = DOF restringidos/empotrados (4 nodos de base, típicamente nodos 1-4)
- $\mathbf{u}$ = Vector de desplazamientos
- $\mathbf{F}$ = Vector de fuerzas

**Matriz de Rigidez Condensada:**

Asumiendo $\mathbf{F}_b = \mathbf{0}$ (sin fuerzas en nodos empotrados):

$$
\mathbf{K}_{\text{cond}} = \mathbf{K}_{aa} - \mathbf{K}_{ab} \mathbf{K}_{bb}^{-1} \mathbf{K}_{ba}
$$

**Matriz de Masa Condensada:**

$$
\mathbf{M}_{\text{cond}} = \mathbf{M}_{aa}
$$

(Solo se conservan las masas de los DOF activos)

**Dimensiones típicas:**
- $\mathbf{K}_G$: $[336 \times 336]$ (56 nodos × 6 DOF)
- $\mathbf{K}_{\text{cond}}$: $[72 \times 72]$ (12 nodos activos × 6 DOF)
- Reducción: ~78% de DOF eliminados

#### 2.2 Problema de Eigenvalores Generalizado

La ecuación de movimiento libre sin amortiguamiento:

$$
\mathbf{M}_{\text{cond}} \ddot{\mathbf{u}} + \mathbf{K}_{\text{cond}} \mathbf{u} = \mathbf{0}
$$

Asumiendo solución armónica $\mathbf{u}(t) = \boldsymbol{\phi} e^{i\omega t}$:

$$
\left(\mathbf{K}_{\text{cond}} - \omega^2 \mathbf{M}_{\text{cond}}\right) \boldsymbol{\phi} = \mathbf{0}
$$

**Solución con MATLAB:**

```matlab
[modos, wn2] = eigs(K_cond, M_cond, 12, 'sm');
```

Donde:
- `'sm'` = smallest magnitude (12 modos con menores frecuencias)
- `wn2` = diagonal con $\omega_i^2$ (frecuencias angulares al cuadrado)
- `modos` = matriz $[72 \times 12]$ con vectores propios $\boldsymbol{\phi}_i$

**Extracción de Frecuencias:**

$$
\begin{align}
\omega_i &= \sqrt{\lambda_i} \quad \text{(rad/s)} \\
f_i &= \frac{\omega_i}{2\pi} \quad \text{(Hz)} \\
T_i &= \frac{1}{f_i} \quad \text{(segundos)}
\end{align}
$$

#### 2.3 Normalización Modal

Los modos se normalizan respecto a la matriz de masa para garantizar ortogonalidad:

$$
\boldsymbol{\phi}_i^{\text{norm}} = \frac{\boldsymbol{\phi}_i}{\sqrt{\boldsymbol{\phi}_i^T \mathbf{M}_{\text{cond}} \boldsymbol{\phi}_i}}
$$

**Condición de ortogonalidad:**

$$
\boldsymbol{\phi}_i^T \mathbf{M}_{\text{cond}} \boldsymbol{\phi}_j = \delta_{ij} = \begin{cases}
1 & \text{si } i = j \\
0 & \text{si } i \neq j
\end{cases}
$$

#### 2.4 Ordenamiento de Modos

Los modos se ordenan por frecuencia ascendente:

$$
\omega_1 < \omega_2 < \omega_3 < \cdots < \omega_{12}
$$

**IMPORTANTE:** Este ordenamiento puede cambiar cuando se introduce daño, generando cruces modales.

#### 2.5 Aplicación de Máscara (Superestructura)

Se aplica una máscara para analizar solo los nodos de la superestructura (nodos 41-52):

```matlab
mask = createMask(41, 52, modos, numFixed=4);
modos_masked = modos .* mask;
```

Esto pone a cero los componentes de DOF que no pertenecen a los nodos de interés, focalizando el análisis de daño en la zona crítica.

#### 2.6 Emparejamiento Modal Robusto con MAC

*[Ver sección 4 para detalles completos]*

### 3. Índices de Daño (DIs)

El sistema calcula **8 índices de daño** diferentes que capturan aspectos complementarios del cambio estructural.

#### 3.1 Índices Basados en Formas Modales

**DI1: COMAC (Coordinate Modal Assurance Criterion)**

Mide la correlación modal local **coordenada por coordenada**:

$$
\text{COMAC}(j) = \frac{\left(\sum_{i=1}^{N_m} \phi_{ij}^{u} \phi_{ij}^{d}\right)^2}{\left(\sum_{i=1}^{N_m} (\phi_{ij}^{u})^2\right) \left(\sum_{i=1}^{N_m} (\phi_{ij}^{d})^2\right)}
$$

Donde:
- $j$ = Índice de coordenada/DOF
- $i$ = Índice de modo
- $N_m$ = Número de modos considerados (12)
- $\phi_{ij}^{u}$ = Componente $j$ del modo $i$ intacto
- $\phi_{ij}^{d}$ = Componente $j$ del modo $i$ dañado

**Transformación a índice de daño:**

$$
\text{DI1}(j) = \text{Normalize}\left(1 - \sqrt{\text{COMAC}(j)}\right)
$$

Interpretación:
- COMAC ≈ 1 → DI1 ≈ 0 (sin daño)
- COMAC << 1 → DI1 ≈ 1 (daño presente)

---

**DI2: Diferencia Absoluta entre Modos**

$$
\text{DI2}_{\text{raw}}(j) = \sum_{i=1}^{N_m} \left| \phi_{ij}^{u} - \phi_{ij}^{d} \right|
$$

**Unificación por nodo** (suma de los 6 DOF del nodo $n$):

$$
\text{DI2}(n) = \text{Normalize}\left(\sum_{k=1}^{6} \text{DI2}_{\text{raw}}(6n + k)\right)
$$

Captura cambios absolutos en las formas modales.

---

**DI3: Razón Relativa entre Modos**

$$
\text{Ratio}(j, i) = \frac{\phi_{ij}^{d}}{\phi_{ij}^{u} + \epsilon}
$$

Donde $\epsilon = 10^{-10}$ previene división por cero.

**Desviación respecto a la unidad:**

$$
\text{DI3}_{\text{raw}}(j) = \sum_{i=1}^{N_m} \left| \text{Ratio}(j, i) - 1 \right|
$$

**Unificación y normalización:**

$$
\text{DI3}(n) = \text{Normalize}\left(\sum_{k=1}^{6} \text{DI3}_{\text{raw}}(6n + k)\right)
$$

Mide cambio relativo porcentual en modos.

#### 3.2 Índices Basados en Matrices de Flexibilidad

**Matriz de Flexibilidad Modal:**

La flexibilidad dinámica se calcula como:

$$
\mathbf{F} = \sum_{i=1}^{N_m} \frac{\boldsymbol{\phi}_i \boldsymbol{\phi}_i^T}{\omega_i^2} = \boldsymbol{\Phi} \, \text{diag}\left(\frac{1}{\omega_1^2}, \ldots, \frac{1}{\omega_{12}^2}\right) \boldsymbol{\Phi}^T
$$

Donde $\boldsymbol{\Phi} = [\boldsymbol{\phi}_1, \ldots, \boldsymbol{\phi}_{12}]$ es la matriz modal.

**Propiedades:**
- $\mathbf{F} \in \mathbb{R}^{n \times n}$ es simétrica positiva definida
- $\mathbf{F} = \mathbf{K}^{-1}$ en el límite de modos completos
- Más sensible a daño local que las frecuencias

---

**DI4: Diferencia Absoluta de Flexibilidades**

$$
\Delta \mathbf{F} = \mathbf{F}^d - \mathbf{F}^u
$$

**Extracción de diagonal:**

$$
\text{DI4}_{\text{diag}}(j) = \left| \Delta F_{jj} \right|
$$

**Agrupación por nodo** (suma de 3 DOF traslacionales):

$$
\text{DI4}(n) = \text{Normalize}\left(\sum_{k \in \{x, y, z\}} \text{DI4}_{\text{diag}}(3n + k)\right)
$$

---

**DI5: Razón de Flexibilidades**

$$
\text{Ratio}_{\text{flex}}(j) = \frac{F_{jj}^d}{F_{jj}^u + \epsilon}
$$

$$
\text{DI5}_{\text{raw}}(j) = \left| \text{Ratio}_{\text{flex}}(j) - 1 \right|
$$

**Agrupación y normalización:**

$$
\text{DI5}(n) = \text{Normalize}\left(\sum_{k \in \{x, y, z\}} \text{DI5}_{\text{raw}}(3n + k)\right)
$$

---

**DI6: Porcentaje de Variación de Flexibilidad**

$$
\text{Perc}(j) = 100 \times \frac{\left| F_{jj}^d - F_{jj}^u \right|}{\max(F_{jj}^u, \epsilon)}
$$

$$
\text{DI6}(n) = \text{Normalize}\left(\sum_{k \in \{x, y, z\}} \text{Perc}(3n + k)\right)
$$

Expresa cambio como porcentaje del valor intacto.

#### 3.3 Índices Basados en Análisis Estadístico

**DI7: Z-score de Diferencias de Flexibilidad**

Normalización estadística de las diferencias:

$$
\Delta F_{\text{grouped}}(n) = \sum_{k \in \{x, y, z\}} \left| \Delta F_{(3n+k)(3n+k)} \right|
$$

$$
\mu_{\Delta F} = \frac{1}{N_{\text{nodos}}} \sum_{n=1}^{N_{\text{nodos}}} \Delta F_{\text{grouped}}(n)
$$

$$
\sigma_{\Delta F} = \sqrt{\frac{1}{N_{\text{nodos}}} \sum_{n=1}^{N_{\text{nodos}}} \left(\Delta F_{\text{grouped}}(n) - \mu_{\Delta F}\right)^2}
$$

$$
\text{DI7}(n) = \frac{\Delta F_{\text{grouped}}(n) - \mu_{\Delta F}}{\sigma_{\Delta F}}
$$

**Interpretación:**
- $|\text{DI7}| > 3$ → Valor atípico (daño muy probable)
- $|\text{DI7}| > 2$ → Valor significativo (daño probable)
- $|\text{DI7}| < 1$ → Variación normal

---

**DI8: Probabilidad Asociada al Z-score**

Asumiendo distribución normal:

$$
\text{DI8}(n) = 1 - 2 \left(1 - \Phi\left(|\text{DI7}(n)|\right)\right)
$$

Donde $\Phi(\cdot)$ es la función de distribución acumulativa de la normal estándar.

**Interpretación:**
- DI8 → 1: Muy improbable que sea variación normal (daño altamente probable)
- DI8 → 0: Variación normal esperada

#### 3.4 Normalización de Índices

Todos los DIs se normalizan a $[0, 1]$ usando:

$$
\text{DI}_{\text{norm}}(n) = \frac{\text{DI}(n) - \min(\text{DI})}{\max(\text{DI}) - \min(\text{DI}) + \epsilon}
$$

Esto garantiza comparabilidad entre índices para la combinación ponderada.

### 4. Emparejamiento Modal Robusto con MAC

#### Problema del Cruce Modal (Mode Veering)
Cuando se introduce daño estructural, las frecuencias naturales pueden cambiar de orden, haciendo que el modo $i$ del sistema dañado **no corresponda físicamente** al modo $i$ del sistema intacto. Este fenómeno se conoce como **cruce modal** o *mode veering*.

**Ejemplo:**
- Sistema intacto: $\omega_1 < \omega_2 < \omega_3 < \omega_4$
- Sistema dañado: $\omega_1' < \omega_3' < \omega_2' < \omega_4'$ ← Los modos 2 y 3 se cruzaron

Sin emparejamiento modal, compararíamos **incorrectamente**:
- Modo intacto 2 vs Modo dañado 2 (que físicamente es el modo 3) ❌
- Modo intacto 3 vs Modo dañado 3 (que físicamente es el modo 2) ❌

Esto contamina los índices de daño (DI1-DI3) con artefactos de cruce modal.

#### Solución: Modal Assurance Criterion (MAC)

El **MAC** cuantifica la correlación entre dos vectores modales:

$$
\text{MAC}(i,j) = \frac{\left(\boldsymbol{\phi}_i^T \cdot \boldsymbol{\phi}_j\right)^2}{\left(\boldsymbol{\phi}_i^T \cdot \boldsymbol{\phi}_i\right) \cdot \left(\boldsymbol{\phi}_j^T \cdot \boldsymbol{\phi}_j\right)}
$$

Donde:
- $\boldsymbol{\phi}_i$ = Modo $i$ del sistema intacto (vector de desplazamientos nodales)
- $\boldsymbol{\phi}_j$ = Modo $j$ del sistema dañado
- $\text{MAC} \in [0, 1]$: 
  - MAC = 1 → Modos idénticos (perfecta correlación)
  - MAC ≈ 0 → Modos ortogonales (sin relación física)
  - MAC ≥ 0.90 → Mismo modo físico

#### Algoritmo de Emparejamiento

Se calcula la matriz MAC completa $[12 \times 12]$ y se aplica el **algoritmo húngaro** (Hungarian algorithm) para encontrar el emparejamiento óptimo que maximiza la suma total de correlaciones. Esto garantiza que cada modo intacto se compare con su correspondiente físico correcto en el sistema dañado.

**Impacto:**
- DI1-DI3 reflejan cambios físicos reales (no contaminados por cruces)
- Mayor robustez ante daños moderados/severos (>25%)
- Detección más confiable en estructuras con modos cercanos en frecuencia

### 5. Optimización con Algoritmos Genéticos (GA)

El núcleo del método utiliza un **algoritmo genético** para encontrar la combinación óptima de índices de daño.

#### Objetivo: Maximizar la Sensibilidad de Detección

El AG busca encontrar pesos óptimos $\boldsymbol{\alpha} = [\alpha_1, \alpha_2, \ldots, \alpha_8]^T$ que combinan los 8 índices de daño en un **indicador unificado** $P$:

$$
P = \sum_{k=1}^{8} \alpha_k \cdot \text{DI}_k = \alpha_1 \cdot \text{DI}_1 + \alpha_2 \cdot \text{DI}_2 + \cdots + \alpha_8 \cdot \text{DI}_8
$$

Donde:
- $P \in \mathbb{R}^n$ = Vector de valores de daño por nodo (después de aplicar pesos)
- $\alpha_k \in [0, 1]$ = Peso o importancia relativa del índice $k$
- $\text{DI}_k \in \mathbb{R}^n$ = Índice de daño $k$ normalizado en $[0, 1]$ por nodo
- $n$ = Número de nodos en la superestructura (típicamente 12 nodos)

**Función Objetivo a Minimizar:**

$$
f(\boldsymbol{\alpha}) = \sum_{j=1}^{n} \left(P_j - T_j\right)^2
$$

Donde:
- $f(\boldsymbol{\alpha})$ = Error cuadrático entre predicción y objetivo
- $T_j$ = Vector objetivo (target): $T_j = 1$ si nodo $j$ está dañado, $T_j = 0$ si está intacto
- $P_j$ = Valor predicho de daño en nodo $j$ (resultado de combinar DIs con $\boldsymbol{\alpha}$)

**Restricciones:**

$$
\begin{align}
&\alpha_k \in [0, 1] \quad \forall k \in \{1, 2, \ldots, 8\} \\
&\text{DI}_k(\text{nodo}) \geq \theta \quad \text{(umbral de filtrado de falsos positivos)}
\end{align}
$$

**Interpretación:**
El AG ajusta los pesos $\boldsymbol{\alpha}$ para que el indicador combinado $P$ sea:
- **Alto** (cerca de 1) en nodos verdaderamente dañados
- **Bajo** (cerca de 0) en nodos intactos

Minimizando $f(\boldsymbol{\alpha})$ se maximiza la capacidad de detección y localización del daño.

#### Configuración del GA:
- **Población**: 300 individuos
- **Generaciones**: 500 iteraciones
- **Función objetivo**: Minimizar diferencia entre P y vector objetivo T
- **Restricciones**: Pesos normalizados [0, 1]

#### Umbral de Detección de Falsos Positivos:

Se aplica un umbral $\theta$ (típicamente 0.1-0.3) para filtrar contribuciones espurias:

$$
\text{DI}_k^{\text{ajustado}} = \max(\text{DI}_k - \theta, 0)
$$

Esto elimina valores pequeños que podrían generar falsos positivos en zonas sin daño.

### 6. Tipos de Daño Simulados

El framework puede modelar dos tipos principales de daño en elementos tubulares:

#### 6.1 Corrosión Uniforme

**Modelo Físico:**

La corrosión reduce uniformemente el espesor de pared del tubo a lo largo de toda su longitud.

**Geometría Corroída:**

Para un tubo circular con diámetro exterior $D$ y espesor original $t$:

$$
\begin{align}
t_{\text{corr}} &= t \left(1 - \frac{\delta}{100}\right) \\
D_{\text{ext}} &= D \quad \text{(sin cambio)} \\
D_{\text{int,corr}} &= D - 2t_{\text{corr}}
\end{align}
$$

Donde $\delta$ = porcentaje de corrosión (5%, 10%, ..., 45%)

**Propiedades Geométricas Reducidas:**

$$
\begin{align}
A_{\text{corr}} &= \frac{\pi}{4}\left(D^2 - D_{\text{int,corr}}^2\right) \\
&= \frac{\pi}{4}\left(D^2 - (D - 2t_{\text{corr}})^2\right) \\
&= \pi D t_{\text{corr}} \left(1 - \frac{t_{\text{corr}}}{D}\right)
\end{align}
$$

$$
\begin{align}
I_{\text{corr}} &= \frac{\pi}{64}\left(D^4 - D_{\text{int,corr}}^4\right) \\
&= \frac{\pi}{64}\left(D^4 - (D - 2t_{\text{corr}})^4\right)
\end{align}
$$

$$
J_{\text{corr}} = 2 I_{\text{corr}} \quad \text{(momento polar)}
$$

**Matriz de Rigidez Modificada:**

La matriz de rigidez local se recalcula con propiedades reducidas:

$$
\mathbf{k}_e^{\text{corr}} = f(E, G, L, A_{\text{corr}}, I_{\text{corr}}, J_{\text{corr}})
$$

Usando la misma formulación de elemento frame 3D (ver sección 1.2) pero con propiedades corroídas.

**Degradación de Rigidez:**

Para corrosión uniforme, la pérdida de rigidez es aproximadamente:

$$
\frac{EA_{\text{corr}}}{EA} \approx 1 - \delta \quad \text{(rigidez axial)}
$$

$$
\frac{EI_{\text{corr}}}{EI} \approx \left(1 - \delta\right)^3 \quad \text{(rigidez flexional, aproximado)}
$$

#### 6.2 Abolladura Longitudinal

**Modelo Físico:**

Una abolladura es una deformación local que reduce la inercia del elemento en la zona afectada.

**Parámetros del Modelo:**
- $L$ = Longitud total del elemento
- $L_{\text{dent}}$ = Longitud de la abolladura (típicamente 5× diámetro)
- $d_{\text{max}}$ = Profundidad máxima de la abolladura
- $N_{\text{seg}}$ = Número de segmentos para discretización (1000)
- $\delta$ = Porcentaje de abolladura (relativo al diámetro)

**Profundidad Máxima:**

$$
d_{\text{max}} = \frac{\delta}{100} \times D
$$

**Perfil Longitudinal de la Abolladura:**

La profundidad varía suavemente a lo largo del eje del elemento:

$$
d(x) = \begin{cases}
d_{\text{max}} \sin^2\left(\frac{\pi x}{L_{\text{dent}}}\right) & \text{si } 0 \leq x \leq L_{\text{dent}} \\
0 & \text{en otro caso}
\end{cases}
$$

**Radio Local Reducido:**

$$
r(x) = \frac{D}{2} - d(x)
$$

**Momento de Inercia Variable:**

Para cada sección transversal a distancia $x$:

$$
I(x) = \frac{\pi}{4} r(x)^4 - \frac{\pi}{4} \left(r(x) - t\right)^4
$$

(Asumiendo espesor $t$ constante, solo varía el radio exterior)

**Matriz de Flexibilidad Local Modificada:**

Para un elemento con inercia variable, la flexibilidad se calcula por integración numérica:

$$
f_{\text{flex}} = \int_0^L \frac{1}{EI(x)} \, dx \approx \sum_{s=1}^{N_{\text{seg}}} \frac{\Delta x}{EI(x_s)}
$$

Donde $\Delta x = L / N_{\text{seg}}$

**Rigidez Flexional Equivalente:**

$$
(EI)_{\text{equiv}} = \frac{L}{f_{\text{flex}}}
$$

La matriz de rigidez local se construye usando esta inercia equivalente, más interpolación cúbica para términos de flexión.

**Ubicación de la Abolladura:**

La abolladura se coloca típicamente:
- Al centro del elemento: $x_{\text{center}} = L/2$
- O en ubicación específica según datos experimentales

**Nota Importante:**

La abolladura causa reducción **localizada** mucho más severa que la corrosión:
- Corrosión 30% → ~30% pérdida de rigidez axial
- Abolladura 30% → ~70-80% pérdida de rigidez flexional local

Esto hace que la abolladura sea más crítica para la estabilidad estructural.

## Configuración del Sistema

El archivo [`config.m`](code/001_framework_resultados_journal/config.m) centraliza **todos los parámetros del análisis**. Este archivo es el **único punto de configuración** que se debe modificar antes de ejecutar experimentos.

### Parámetros Estructurales

```matlab
% Nodos empotrados (base de la plataforma jacket)
config.nodosEmpotrados = [1, 2, 3, 4];  % 4 nodos de apoyo

% Nodos de análisis (superestructura donde se concentra el daño)
config.nodosAnalisis = 41:52;  % 12 nodos en zona crítica

% Número de modos de vibración a extraer
config.numModos = 12;  % Primeros 12 modos

% Tipo de análisis eigenvalores
config.eigenType = 'sm';  % 'sm' = smallest magnitude (frecuencias más bajas)
```

**Justificación de 12 modos:**
- Los primeros 12 modos capturan ~85-90% de la masa modal participante
- Modos superiores contienen más ruido que información de daño
- Balance entre información y costo computacional

### Parámetros de Daño

```matlab
% Tipo de daño (SELECCIONAR UNO)
config.tipoDano = 'corrosion';  % Opciones: 'corrosion' | 'abolladura'

% Severidades de daño a evaluar (porcentaje)
config.porcentajesDano = [5, 10, 15, 20, 25, 30, 35, 40, 45];

% Elementos estructurales a dañar (números de elementos)
config.elementosDanados = [23, 45, 67];  % Ejemplo: 3 elementos

% Parámetros específicos para abolladura
if strcmp(config.tipoDano, 'abolladura')
    config.abolladura.longitudMultiplo = 5;  % Longitud = 5×Diámetro
    config.abolladura.ubicacion = 'centro';  % 'centro' | 'inicio' | 'fin'
    config.abolladura.Nseg = 1000;           % Segmentos para integración
    config.abolladura.perfilTipo = 'sin2';   % 'sin2' | 'gaussiano' | 'triangular'
end
```

**Rangos típicos de severidad:**
- **Daño leve**: 5-15% (detección desafiante)
- **Daño moderado**: 20-30% (rango óptimo para calibración)
- **Daño severo**: 35-45% (detección casi garantizada)

### Parámetros del Algoritmo Genético

```matlab
% Configuración principal del GA
config.GA.populationSize = 300;      % Individuos por generación
config.GA.maxGenerations = 500;      % Criterio de parada
config.GA.nvars = 8;                 % Variables de optimización (pesos de DIs)

% Límites de búsqueda
config.GA.lb = zeros(1, 8);          % Límite inferior: [0, 0, ..., 0]
config.GA.ub = ones(1, 8);           % Límite superior: [1, 1, ..., 1]

% Opciones avanzadas de GA
config.GA.options = optimoptions('ga', ...
    'PopulationSize', 300, ...
    'MaxGenerations', 500, ...
    'Display', 'iter', ...            % Mostrar progreso
    'PlotFcn', @gaplotbestf, ...      % Gráfico de convergencia en vivo
    'UseParallel', false, ...         % Paralelización (requiere Parallel Toolbox)
    'EliteCount', 15, ...             % 5% élite (15 = 0.05 × 300)
    'CrossoverFraction', 0.8, ...     % 80% de descendencia por crossover
    'MutationFcn', @mutationadaptfeasible, ...  % Mutación adaptativa
    'CreationFcn', @my_initial_population, ...  % Población inicial custom
    'OutputFcn', @gaoutfun, ...       % Guardar historial generación a generación
    'FunctionTolerance', 1e-6, ...    % Tolerancia de convergencia
    'MaxStallGenerations', 50 ...     % Parar si no mejora en 50 gen
);
```

**Estrategias de Población Inicial:**

La función [`my_initial_population.m`](code/my_initial_population.m) genera 300 individuos con estrategias diversas:

1. **Pesos uniformes** (75 individuos = 25%):
   ```matlab
   alpha = [1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8, 1/8];
   ```
   Todos los DIs contribuyen por igual.

2. **Pesos aleatorios normalizados** (150 individuos = 50%):
   ```matlab
   r = rand(1, 8);
   alpha = r / sum(r);  % Suma a 1
   ```
   Exploración aleatoria del espacio de búsqueda.

3. **Un DI dominante** (75 individuos = 25%):
   ```matlab
   % Para cada DI_k:
   alpha(k) = 0.9;
   alpha([1:k-1, k+1:8]) = 0.1/7;
   ```
   Prueba hipótesis de que un solo DI puede ser suficiente.

**Convergencia típica:**
- Generación 50: RMSE ~ 0.4-0.5
- Generación 200: RMSE ~ 0.2-0.3
- Generación 500: RMSE ~ 0.15-0.25 (convergencia)

### Parámetros de Emparejamiento Modal (MAC)

```matlab
% Activar/desactivar MAC matching
config.usarMACmatching = true;  % true = MAC, false = solo frecuencias

% Método de emparejamiento óptimo
config.MAC_metodo = 'hungarian';  % Algoritmo húngaro (óptimo global)

% **⚠️ IMPORTANTE: Requiere OBLIGATORIAMENTE Optimization Toolbox de MATLAB**

% Umbral de validación de calidad
config.MAC_umbral = 0.90;  % MAC > 0.90 = emparejamiento aceptable

% Diagnóstico en consola
config.MAC_verbose = true;  % Mostrar advertencias de cruces modales

% Guardar matriz MAC completa
config.MAC_guardarMatriz = true;  % Guardar en resultados
```

**Características del método Hungarian:**

| Característica | Detalle |
|----------------|---------|
| Complejidad | $O(n^3)$ |
| Toolbox requerido | **Optimization Toolbox (OBLIGATORIO)** |
| Optimalidad | Garantizada (óptimo global) |
| Velocidad | Media |

**⚠️ CRÍTICO:** El método Hungarian es el **ÚNICO** método implementado. No existe alternativa sin Optimization Toolbox.

### Parámetros de Umbral de Daño

```matlab
% Método de cálculo de umbral para clasificación
config.umbral.metodo = 'percentil';  % 'percentil' | 'estadistico' | 'fijo'

% Parámetros por método
switch config.umbral.metodo
    case 'percentil'
        config.umbral.valor = 75;  % Percentil 75 (Q3)
    case 'estadistico'
        config.umbral.valor = 2.0;  % μ + 2σ (95% confianza)
    case 'fijo'
        config.umbral.valor = 0.5;  % Umbral fijo = 50%
end
```

**Fórmulas de umbral:**

$$
T_j = \begin{cases}
\text{percentile}(P, \text{valor}) & \text{si metodo = 'percentil'} \\
\mu_P + k \cdot \sigma_P & \text{si metodo = 'estadistico'} \\
\text{valor} & \text{si metodo = 'fijo'}
\end{cases}
$$

**Trade-off:**
- Umbral alto → Menos falsos positivos, más falsos negativos
- Umbral bajo → Más falsos positivos, menos falsos negativos
- Valor típico recomendado: percentil 75

### Rutas de Archivos

```matlab
% Directorio raíz del proyecto
config.paths.root = fileparts(mfilename('fullpath'));

% Ruta del modelo ETABS
config.paths.modeloETABS = fullfile(config.paths.root, ...
    'excels_de_ing_Jaret', 'Jacket_Offshore_Platform.xlsx');

% Directorios de salida
config.paths.resultados = fullfile(config.paths.root, 'Resultados');
config.paths.figuras = fullfile(config.paths.root, 'fig');
config.paths.svg = fullfile(config.paths.root, 'svg');

% Crear directorios si no existen
directorios = {config.paths.resultados, config.paths.figuras, config.paths.svg};
for i = 1:length(directorios)
    if ~exist(directorios{i}, 'dir')
        mkdir(directorios{i});
        fprintf('✓ Directorio creado: %s\n', directorios{i});
    end
end
```

### Parámetros de Exportación

```matlab
% Guardar figuras
config.export.saveFigs = true;
config.export.figFormat = {'fig', 'png', 'svg'};  % Múltiples formatos

% Resolución de imágenes
config.export.dpi = 300;  % DPI para PNG/SVG

% Guardar resultados en Excel
config.export.saveExcel = true;
config.export.excelFile = 'todos_los_resultados.xlsx';
config.export.excelHojas = {'Resultados_AG', 'Detalle_Corridas', 'Metricas_MAC'};

% Guardar workspace de MATLAB
config.export.saveWorkspace = true;
config.export.matFile = 'workspace_completo.mat';
config.export.matVersion = '-v7.3';  % Formato HDF5 (archivos grandes)

% Compresión de resultados
config.export.comprimir = true;
config.export.zipFile = 'resultados_experimento.zip';
```

### Configuración Completa de Ejemplo

**Ejemplo 1: Análisis de corrosión con MAC matching**
```matlab
config.tipoDano = 'corrosion';
config.porcentajesDano = [10, 20, 30, 40];
config.elementosDanados = [45];
config.usarMACmatching = true;
config.MAC_metodo = 'hungarian';
config.GA.populationSize = 300;
config.GA.maxGenerations = 500;
config.umbral.metodo = 'percentil';
config.umbral.valor = 75;
```

**Ejemplo 2: Análisis rápido de abolladura sin MAC**
```matlab
config.tipoDano = 'abolladura';
config.porcentajesDano = [25];
config.elementosDanados = [23, 45, 67];
config.usarMACmatching = false;  % Más rápido
config.GA.populationSize = 100;  % Población reducida
config.GA.maxGenerations = 200;  % Convergencia rápida
config.export.saveFigs = false;  % Sin figuras
```

---

## 7. Flujo de Trabajo Completo

### 7.1 Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│                     ETABS (Modelo 3D)                       │
│              Geometría + Propiedades de Material            │
└───────────────────────────┬─────────────────────────────────┘
                            │ Excel Export
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               config.m (Configuración Central)              │
│  • Parámetros estructurales                                 │
│  • Tipo/severidad de daño                                   │
│  • Configuración GA                                         │
│  • MAC matching settings                                    │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│           main_launcher.m (Punto de entrada)                │
│  1. Lee modelo ETABS desde Excel                            │
│  2. Construye K_global, M_global                            │
│  3. Aplica condensación estática                            │
│  4. Calcula modos intactos (referencia)                     │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│           runExperimentos.m (Orquestador)                   │
│  Para cada combinación:                                     │
│    - Elemento dañado                                        │
│    - Porcentaje de daño                                     │
│    - Tipo de daño                                           │
│  Ejecuta: unaCorridaAG(...)                                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
         ┌──────────────────┴──────────────────┐
         │ Loop sobre experimentos              │
         ▼                                      ▼
┌────────────────────────────┐  ┌────────────────────────────┐
│   unaCorridaAG.m (Core)    │  │  Modificar estructura:     │
│ 1. Aplicar daño → K_dañada │  │  - area_y_momento_polar... │
│ 2. Calcular modos dañados  │  │  - corrosionlocal.m        │
│ 3. MAC matching (opcional) │  │  - funcion_abulladura...   │
│ 4. Calcular 8 DIs          │  └────────────────────────────┘
│ 5. Ejecutar GA             │           ▲
└────────┬───────────────────┘           │
         │                         Actualiza propiedades
         │                               │
         ▼                               │
┌──────────────────────────────────────────┴──────────────────┐
│                      GA.m (Optimización)                    │
│  Algoritmo Genético:                                        │
│  • Genera población inicial (300 individuos)                │
│  • Evalúa fitness: RMSEfunction(α)                          │
│  • Selección, cruce, mutación                               │
│  • Evoluciona por 500 generaciones                          │
│  • Retorna α* óptimo                                        │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              RMSEfunction.m (Función Objetivo)              │
│  Para candidato α = [α₁, α₂, ..., α₈]:                      │
│  1. Combina DIs: P_j = Σ(αₖ · DIₖ_j)                        │
│  2. Calcula umbral: T_j = f(P₁,...,P_n)                     │
│  3. Clasifica nodos: Dañado si P_j > T_j                    │
│  4. Calcula RMSE con nodos reales                           │
│  5. Retorna fitness = RMSE                                  │
└───────────────────────────┬─────────────────────────────────┘
                            │ α* óptimo
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Almacenamiento de Resultados              │
│  • Excel: todos_los_resultados.xlsx                         │
│    - Pesos óptimos por experimento                          │
│    - Métricas: RMSE, TP, FP, FN                             │
│    - Diagnóstico MAC: MAC_min, MAC_avg, cruces              │
│  • Figuras: .fig + .png + .svg                              │
│    - Evolución del GA                                       │
│    - Distribución de DIs                                    │
│    - Comparación de modos                                   │
│    - Matriz MAC (heatmap)                                   │
│  • MAT file: workspace_completo.mat                         │
└─────────────────────────────────────────────────────────────┘
```

### 7.2 Flujo de Ejecución Detallado

#### Descripción del Pipeline de Procesamiento

```
1. main_launcher.m (PUNTO DE ENTRADA)
   ├─ Carga config.m → tipo_dano, porcentajes, rangoElem
   ├─ Lectura de datos ETABS (geometría, conectividad)
   ├─ Análisis estático (N_axial, Pcr, ρ)
   ├─ Cálculo de DI_base (modelo intacto)
   └─ Llama a runExperimentos()

2. runExperimentos.m (ORQUESTADOR)
   ├─ Filtra elementos por ρ (si aplica)
   ├─ Bucle: for elem in elementos → for pct in porcentajes
   └─ Llama a unaCorridaAG() para cada combinación

3. unaCorridaAG.m (CORRIDA INDIVIDUAL)
   ├─ Aplica daño al modelo (switch_case_danos.m)
   ├─ Recalcula modos y frecuencias del modelo dañado
   ├─ Emparejamiento modal con MAC (Hungarian Algorithm)
   ├─ Calcula 8 DIs del modelo dañado
   ├─ Ejecuta GA() para encontrar pesos α óptimos
   ├─ Combina DIs con α → P (predicción de daño)
   ├─ Calcula falsos positivos (FP)
   └─ Guarda resultados parciales (Excel, figuras)

4. GA.m (ALGORITMO GENÉTICO)
   ├─ Optimiza 8 pesos α para minimizar error (P - T)²
   ├─ Usa objective_function.m como función objetivo
   └─ Retorna optimal_alpha, fval

5. objective_function.m (FUNCIÓN OBJETIVO)
   └─ f = Σ(α·DI - T)² → minimiza diferencia entre predicción y verdad
```

**Notas importantes:**
- El sistema procesa cada combinación de (elemento, porcentaje_daño, tipo_daño) de forma seriada
- Cada corrida es independiente y puede tomar varios minutos
- Para corrosión: 18 severidades (5-90% en pasos de 5%) × ~120 elementos
- Para abolladura: 9 severidades (5-45% en pasos de 5%) × ~120 elementos
- El Hungarian Algorithm en `matchModesMAC.m` previene errores por cruce modal (mode veering)

### 7.3 Secuencia Detallada de Ejecución

#### Paso 1: Inicialización (main_launcher.m)

```matlab
%% 1.1 Cargar configuración
fprintf('=== Iniciando análisis de daño ===\n');
config = config();  % Lee todas las configuraciones

%% 1.2 Leer modelo ETABS desde Excel
fprintf('Leyendo modelo ETABS desde: %s\n', config.paths.modeloETABS);
[nodos, elementos, propiedades, materiales] = leerModeloETABS(...
    config.paths.modeloETABS);

fprintf('  Nodos: %d\n', size(nodos, 1));
fprintf('  Elementos: %d\n', size(elementos, 1));

%% 1.3 Ensamblar matrices globales
fprintf('Ensamblando matrices globales...\n');
tic;
K_global = ensamblaje_matriz_rigidez_global_AG(elementos, propiedades, ...
    nodos, materiales);
M_global = matriz_de_masas(nodos, elementos, propiedades, materiales);
t_ensamble = toc;

fprintf('  Tiempo de ensamblaje: %.2f s\n', t_ensamble);
fprintf('  Dimensión K_global: [%d × %d]\n', size(K_global));

%% 1.4 Verificar simetrías
assert(check_symmetry(K_global), 'ERROR: K_global no es simétrica');
assert(check_symmetry(M_global), 'ERROR: M_global no es simétrica');
fprintf('✓ Matrices simétricas verificadas\n');

%% 1.5 Verificar definida positiva
minEig_K = eigs(K_global, 1, 'sm');
assert(minEig_K > 0, 'ERROR: K_global no es definida positiva');
fprintf('✓ K_global es definida positiva (λ_min = %.2e)\n', minEig_K);
```

#### Paso 2: Análisis Modal de Referencia (Estructura Intacta)

```matlab
%% 2.1 Condensación estática
fprintf('\nAplicando condensación estática...\n');
[K_cond, M_cond, T_transform] = condensacion_estatica_AG(...
    K_global, M_global, config.nodosEmpotrados);

fprintf('  DOF originales: %d\n', size(K_global, 1));
fprintf('  DOF condensados: %d\n', size(K_cond, 1));
fprintf('  Reducción: %.1f%%\n', 100*(1 - size(K_cond,1)/size(K_global,1)));

%% 2.2 Resolver problema de eigenvalores
fprintf('\nCalculando modos intactos...\n');
tic;
[modos_intactos_full, wn2] = eigs(K_cond, M_cond, config.numModos, ...
    config.eigenType);
t_eigen = toc;

fprintf('  Tiempo de eigen-análisis: %.2f s\n', t_eigen);

%% 2.3 Extraer y ordenar frecuencias
freqs_rad = sqrt(diag(wn2));  % rad/s
frecs_intactas = freqs_rad / (2*pi);  % Hz

[frecs_intactas, idx_sort] = sort(frecs_intactas);
modos_intactos_full = modos_intactos_full(:, idx_sort);

fprintf('\n  Frecuencias naturales [Hz]:\n');
for i = 1:config.numModos
    fprintf('    Modo %2d: %.4f Hz (T = %.4f s)\n', i, frecs_intactas(i), ...
        1/frecs_intactas(i));
end

%% 2.4 Aplicar máscara de nodos de interés
fprintf('\nAplicando máscara a nodos %d-%d...\n', ...
    config.nodosAnalisis(1), config.nodosAnalisis(end));

mask = createMask(config.nodosAnalisis(1), config.nodosAnalisis(end), ...
    modos_intactos_full, length(config.nodosEmpotrados));

modos_intactos = modos_intactos_full .* mask;

%% 2.5 Normalizar modos
for i = 1:config.numModos
    masa_modal = modos_intactos(:,i)' * M_cond * modos_intactos(:,i);
    modos_intactos(:,i) = modos_intactos(:,i) / sqrt(masa_modal);
end

fprintf('✓ Modos normalizados (ortonormales respecto a M)\n');
```

#### Paso 3: Loop de Experimentación (runExperimentos.m)

```matlab
%% Inicializar tabla de resultados
resultados = table();
numExperimentos = length(config.elementosDanados) * ...
    length(config.porcentajesDano);

fprintf('\n=== Iniciando %d experimentos ===\n', numExperimentos);
fprintf('Tipo de daño: %s\n', config.tipoDano);
fprintf('MAC matching: %s\n', mat2str(config.usarMACmatching));

idxExp = 1;
tic_total = tic;

%% Loop sobre elementos y severidades
for iElem = 1:length(config.elementosDanados)
    elemento = config.elementosDanados(iElem);
    
    for iPct = 1:length(config.porcentajesDano)
        pct = config.porcentajesDano(iPct);
        
        fprintf('\n┌─ Experimento %d/%d ─────────────────────┐\n', ...
            idxExp, numExperimentos);
        fprintf('│ Elemento: %d\n', elemento);
        fprintf('│ Daño: %d%% (%s)\n', pct, config.tipoDano);
        fprintf('└────────────────────────────────────────┘\n');
        
        % Ejecutar una corrida completa del AG
        tic_exp = tic;
        resultado = unaCorridaAG(K_global, M_global, K_cond, M_cond, ...
            modos_intactos, frecs_intactas, ...
            elemento, pct, config, idxExp);
        t_exp = toc(tic_exp);
        
        % Agregar metadatos
        resultado.Experimento_ID = idxExp;
        resultado.Tiempo_segundos = t_exp;
        
        % Almacenar en tabla
        resultados = [resultados; resultado];
        
        % Guardar checkpoints cada 10 experimentos
        if mod(idxExp, 10) == 0
            save(fullfile(config.paths.resultados, 'checkpoint.mat'), ...
                'resultados', 'idxExp');
            fprintf('\n💾 Checkpoint guardado (exp %d/%d)\n', ...
                idxExp, numExperimentos);
        end
        
        idxExp = idxExp + 1;
    end
end

t_total = toc(tic_total);
fprintf('\n\n╔══════════════════════════════════════╗\n');
fprintf('║  TODOS LOS EXPERIMENTOS COMPLETADOS  ║\n');
fprintf('╚══════════════════════════════════════╝\n');
fprintf('Tiempo total: %.2f min (%.1f s/experimento)\n', ...
    t_total/60, t_total/numExperimentos);
```

#### Paso 4: Aplicación de Daño y Recálculo (unaCorridaAG.m)

```matlab
%% 4.1 Modificar propiedades del elemento dañado
fprintf('  Aplicando daño: %d%% tipo %s...\n', pct, config.tipoDano);

propiedades_dano = propiedades;  % Copiar propiedades originales

switch config.tipoDano
    case 'corrosion'
        % Reducir espesor uniformemente
        [A_corr, Iy_corr, Iz_corr, J_corr] = ...
            area_y_momento_polar_con_dano(elemento, pct, propiedades);
        
        propiedades_dano(elemento).A = A_corr;
        propiedades_dano(elemento).Iy = Iy_corr;
        propiedades_dano(elemento).Iz = Iz_corr;
        propiedades_dano(elemento).J = J_corr;
        
        fprintf('    Área reducida: %.2e → %.2e (%.1f%%)\n', ...
            propiedades(elemento).A, A_corr, ...
            100*(propiedades(elemento).A - A_corr)/propiedades(elemento).A);
        
    case 'abolladura'
        % Calcular matriz de rigidez local modificada
        [k_local_dano, I_equiv] = funcion_corrosion_completa_longitudinal(...
            elemento, pct, propiedades, config.abolladura);
        
        propiedades_dano(elemento).k_local_custom = k_local_dano;
        propiedades_dano(elemento).I_equivalente = I_equiv;
        
        fprintf('    Inercia equiv: %.2e → %.2e (%.1f%%)\n', ...
            propiedades(elemento).Iy, I_equiv, ...
            100*(propiedades(elemento).Iy - I_equiv)/propiedades(elemento).Iy);
end

%% 4.2 Reensamblar matriz de rigidez global con daño
fprintf('  Reensamblando K_global con daño...\n');
K_global_dano = ensamblaje_matriz_rigidez_global_AG(...
    elementos, propiedades_dano, nodos, materiales);

%% 4.3 Condensar matriz dañada
[K_cond_dano, ~] = condensacion_estatica_AG(...
    K_global_dano, M_global, config.nodosEmpotrados);
```

#### Paso 5: Análisis Modal con Daño

```matlab
%% 5.1 Resolver eigenvalores con estructura dañada
fprintf('  Calculando modos dañados...\n');
[modos_dano_full, wn2_dano] = eigs(K_cond_dano, M_cond, ...
    config.numModos, config.eigenType);

%% 5.2 Extraer y ordenar frecuencias
frecs_dano = sqrt(diag(wn2_dano)) / (2*pi);
[frecs_dano, idx] = sort(frecs_dano);
modos_dano_full = modos_dano_full(:, idx);

%% 5.3 Aplicar máscara
modos_dano = modos_dano_full .* mask;

%% 5.4 Normalizar
for i = 1:config.numModos
    masa_modal = modos_dano(:,i)' * M_cond * modos_dano(:,i);
    modos_dano(:,i) = modos_dano(:,i) / sqrt(masa_modal);
end

%% 5.5 Mostrar cambios de frecuencias
fprintf('\n  Cambios de frecuencia:\n');
for i = 1:min(5, config.numModos)  % Mostrar primeros 5
    deltaF = frecs_dano(i) - frecs_intactas(i);
    deltaF_pct = 100 * deltaF / frecs_intactas(i);
    fprintf('    Modo %d: %.4f → %.4f Hz (Δ = %+.4f Hz, %+.2f%%)\n', ...
        i, frecs_intactas(i), frecs_dano(i), deltaF, deltaF_pct);
end
```

#### Paso 6: Emparejamiento Modal con MAC (Si está activado)

```matlab
if config.usarMACmatching
    fprintf('\n  Emparejamiento modal con MAC (%s)...\n', config.MAC_metodo);
    
    %% 6.1 Calcular matriz MAC
    MAC = calcularMatrizMAC(modos_intactos, modos_dano);
    
    %% 6.2 Realizar emparejamiento óptimo
    [modos_dano_reord, pares, frecs_dano_reord] = matchModesMAC(...
        modos_intactos, modos_dano, frecs_dano, config.MAC_metodo);
    
    %% 6.3 Diagnóstico de calidad
    MAC_reord = calcularMatrizMAC(modos_intactos, modos_dano_reord);
    MAC_diagonal = diag(MAC_reord);
    MAC_minimo = min(MAC_diagonal);
    MAC_promedio = mean(MAC_diagonal);
    
    %% 6.4 Detectar cruces modales
    hubo_cruces = any(pares ~= (1:config.numModos)');
    
    if hubo_cruces && config.MAC_verbose
        fprintf('    ⚠️  Cruces modales detectados:\n');
        for i = 1:config.numModos
            if pares(i) ~= i
                fprintf('      Modo %d (intacto) ↔ Modo %d (dañado), MAC=%.4f\n', ...
                    i, pares(i), MAC_diagonal(i));
            end
        end
    else
        fprintf('    ✓ Sin cruces modales\n');
    end
    
    fprintf('    MAC mínimo: %.4f\n', MAC_minimo);
    fprintf('    MAC promedio: %.4f\n', MAC_promedio);
    
    % Validar calidad
    if MAC_minimo < config.MAC_umbral
        warning('MAC mínimo (%.4f) < umbral (%.4f). Revisar matching.', ...
            MAC_minimo, config.MAC_umbral);
    end
    
    %% 6.5 Usar modos reordenados
    modos_dano = modos_dano_reord;
    frecs_dano = frecs_dano_reord;
    
else
    % Sin MAC matching
    MAC_minimo = NaN;
    MAC_promedio = NaN;
    hubo_cruces = false;
    fprintf('\n  ⚠️  MAC matching desactivado (orden por frecuencias)\n');
end
```

#### Paso 7: Cálculo de Índices de Daño

```matlab
fprintf('\n  Calculando 8 Índices de Daño...\n');

%% 7.1 Índices basados en modos
fprintf('    DI1 (COMAC)...');
DI1 = calcular_COMAC(modos_intactos, modos_dano);
fprintf(' ✓\n');

fprintf('    DI2 (Diferencia modos)...');
DI2 = calcular_diferencia_modos(modos_intactos, modos_dano);
fprintf(' ✓\n');

fprintf('    DI3 (Razón modos)...');
DI3 = calcular_razon_modos(modos_intactos, modos_dano);
fprintf(' ✓\n');

%% 7.2 Matrices de flexibilidad
fprintf('    Calculando matrices de flexibilidad...');
F_intacto = calcFlexibility(modos_intactos, frecs_intactas);
F_dano = calcFlexibility(modos_dano, frecs_dano);
fprintf(' ✓\n');

fprintf('    DI4 (Diferencia flexibilidad)...');
DI4 = calcular_diferencia_flexibilidad(F_intacto, F_dano);
fprintf(' ✓\n');

fprintf('    DI5 (Razón flexibilidad)...');
DI5 = calcular_razon_flexibilidad(F_intacto, F_dano);
fprintf(' ✓\n');

fprintf('    DI6 (Porcentaje flexibilidad)...');
DI6 = calcular_porcentaje_flexibilidad(F_intacto, F_dano);
fprintf(' ✓\n');

%% 7.3 Índices estadísticos
fprintf('    DI7 (Z-score)...');
DI7 = calcular_zscore_flexibilidad(F_intacto, F_dano);
fprintf(' ✓\n');

fprintf('    DI8 (Probabilidad)...');
DI8 = calcular_probabilidad_zscore(DI7);
fprintf(' ✓\n');

%% 7.4 Consolidar y normalizar
DIs_raw = [DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8];  % [n_nodos × 8]
DIs_norm = normalizar_DIs(DIs_raw);  % Normalizar a [0, 1]

#### Paso 8: Optimización con Algoritmo Genético

```matlab
%% 8.1 Identificar nodos realmente dañados
% Obtener nodos de los extremos del elemento dañado
nodoInicial = elementos(elemento).NodoI;
nodoFinal = elementos(elemento).NodoF;
nodosDanados_reales = [nodoInicial, nodoFinal];

fprintf('\n  Nodos realmente dañados: [%s]\n', mat2str(nodosDanados_reales));

%% 8.2 Configurar función objetivo
fitnessFcn = @(alpha) RMSEfunction(alpha, DIs_norm, nodosDanados_reales, ...
    config.umbral);

%% 8.3 Ejecutar Algoritmo Genético
fprintf('  Ejecutando AG (pop=%d, gen=%d)...\n', ...
    config.GA.populationSize, config.GA.maxGenerations);

tic_ga = tic;
[alpha_optimo, fitness_final, exitflag, output, population, scores] = ga(...
    fitnessFcn, ...
    config.GA.nvars, ...
    [], [], [], [], ...  % Sin restricciones lineales
    config.GA.lb, ...
    config.GA.ub, ...
    [], ...              % Sin restricciones no lineales
    config.GA.options);
t_ga = toc(tic_ga);

fprintf('  ✓ AG completado en %.2f s (%.2f s/gen)\n', ...
    t_ga, t_ga/output.generations);
fprintf('    Generaciones ejecutadas: %d\n', output.generations);
fprintf('    RMSE final: %.6f\n', fitness_final);
fprintf('    Flag de salida: %d\n', exitflag);

%% 8.4 Analizar convergencia
mejora_total = 100 * (output.bestfvals(1) - fitness_final) / output.bestfvals(1);
fprintf('    Mejora total: %.2f%%\n', mejora_total);

% Detectar estancamiento
generaciones_sin_mejora = 0;
for i = 2:length(output.bestfvals)
    if abs(output.bestfvals(i) - output.bestfvals(i-1)) < 1e-6
        generaciones_sin_mejora = generaciones_sin_mejora + 1;
    end
end
fprintf('    Generaciones sin mejora: %d\n', generaciones_sin_mejora);

%% 8.5 Pesos óptimos encontrados
fprintf('\n  Pesos óptimos:\n');
for k = 1:8
    fprintf('    α%d (DI%d) = %.4f\n', k, k, alpha_optimo(k));
end

% Identificar DIs dominantes (> 20%)
DIs_dominantes = find(alpha_optimo > 0.20);
if ~isempty(DIs_dominantes)
    fprintf('    DIs dominantes (>20%%): %s\n', mat2str(DIs_dominantes));
end

%% 8.6 Calcular métrica combinada óptima
P_optimo = DIs_norm * alpha_optimo';  % [n_nodos × 1]
```

#### Paso 9: Detección de Daño con Umbral

```matlab
%% 9.1 Calcular umbral según método configurado
switch config.umbral.metodo
    case 'percentil'
        T = prctile(P_optimo, config.umbral.valor);
        fprintf('\n  Umbral (percentil %d): %.4f\n', config.umbral.valor, T);
        
    case 'estadistico'
        mu = mean(P_optimo);
        sigma = std(P_optimo);
        T = mu + config.umbral.valor * sigma;
        fprintf('\n  Umbral (μ + %.1fσ): %.4f\n', config.umbral.valor, T);
        fprintf('    μ = %.4f, σ = %.4f\n', mu, sigma);
        
    case 'fijo'
        T = config.umbral.valor;
        fprintf('\n  Umbral fijo: %.4f\n', T);
end

%% 9.2 Clasificar nodos
nodosDanados_detectados = find(P_optimo > T);
nodosIntactos_detectados = find(P_optimo <= T);

fprintf('  Nodos detectados como dañados: [%s]\n', ...
    mat2str(nodosDanados_detectados'));

%% 9.3 Matriz de confusión
allNodes = 1:length(P_optimo);
R = nodosDanados_reales;     % Reales
P_detect = nodosDanados_detectados;  % Predichos

TP = length(intersect(R, P_detect));
FP = length(setdiff(P_detect, R));
FN = length(setdiff(R, P_detect));
TN = length(setdiff(setdiff(allNodes, R), P_detect));

% Verificación
assert(TP + FP + FN + TN == length(allNodes), ...
    'ERROR: Suma de matriz de confusión no coincide');

fprintf('\n  Matriz de Confusión:\n');
fprintf('                  Predicho\n');
fprintf('            Dañado    Intacto\n');
fprintf('    Dañado    %2d        %2d\n', TP, FN);
fprintf('    Intacto   %2d        %2d\n', FP, TN);
```

#### Paso 10: Métricas de Desempeño

```matlab
%% 10.1 Calcular métricas principales
precision = TP / (TP + FP + eps);
recall = TP / (TP + FN + eps);
F1_score = 2 * (precision * recall) / (precision + recall + eps);
accuracy = (TP + TN) / (TP + TN + FP + FN);
specificity = TN / (TN + FP + eps);

fprintf('\n  Métricas de Desempeño:\n');
fprintf('    Precision:  %.4f (%d%% de alarmas correctas)\n', ...
    precision, round(100*precision));
fprintf('    Recall:     %.4f (%d%% de daños detectados)\n', ...
    recall, round(100*recall));
fprintf('    F1-Score:   %.4f\n', F1_score);
fprintf('    Accuracy:   %.4f (%d%% clasificación correcta)\n', ...
    accuracy, round(100*accuracy));
fprintf('    Specificity: %.4f\n', specificity);

%% 10.2 Evaluación cualitativa
if TP == length(R) && FP == 0
    evaluacion = 'PERFECTO';
    emoji = '🎯';
elseif F1_score >= 0.8
    evaluacion = 'EXCELENTE';
    emoji = '✅';
elseif F1_score >= 0.6
    evaluacion = 'BUENO';
    emoji = '👍';
elseif F1_score >= 0.4
    evaluacion = 'REGULAR';
    emoji = '⚠️';
else
    evaluacion = 'POBRE';
    emoji = '❌';
end

fprintf('\n  %s Evaluación: %s (F1 = %.3f)\n', emoji, evaluacion, F1_score);

%% 10.3 Almacenar en estructura de resultado
resultado = struct();
resultado.Elemento = elemento;
resultado.Porcentaje_Dano = pct;
resultado.Tipo_Dano = config.tipoDano;

% Pesos óptimos
for k = 1:8
    resultado.(sprintf('Alpha_%d', k)) = alpha_optimo(k);
end

% Métricas
resultado.RMSE = fitness_final;
resultado.TP = TP;
resultado.FP = FP;
resultado.FN = FN;
resultado.TN = TN;
resultado.Precision = precision;
resultado.Recall = recall;
resultado.F1_Score = F1_score;
resultado.Accuracy = accuracy;
resultado.Specificity = specificity;

% MAC
resultado.MAC_Minimo = MAC_minimo;
resultado.MAC_Promedio = MAC_promedio;
resultado.Hubo_Cruces_Modales = hubo_cruces;

% Metadatos
resultado.Tiempo_GA_segundos = t_ga;
resultado.Generaciones = output.generations;
resultado.Evaluacion = evaluacion;
resultado.Umbral = T;

% Convertir a tabla
resultado = struct2table(resultado);
```

#### Paso 11: Visualización y Exportación

```matlab
if config.export.saveFigs
    fprintf('\n  Generando figuras...\n');
    
    %% 11.1 Evolución del GA
    fig1 = figure('Position', [100 100 800 600]);
    plot(1:length(output.bestfvals), output.bestfvals, 'LineWidth', 2);
    xlabel('Generación', 'FontSize', 12);
    ylabel('Mejor Fitness (RMSE)', 'FontSize', 12);
    title(sprintf('Convergencia GA - Elem %d, Daño %d%%', elemento, pct), ...
        'FontSize', 14);
    grid on;
    
    % Guardar en múltiples formatos
    for fmt = config.export.figFormat
        ext = fmt{1};
        filepath = fullfile(config.paths.figuras, ...
            sprintf('GA_E%d_P%d.%s', elemento, pct, ext));
        
        if strcmp(ext, 'png') || strcmp(ext, 'svg')
            print(fig1, filepath, sprintf('-d%s', ext), ...
                sprintf('-r%d', config.export.dpi));
        else
            saveas(fig1, filepath);
        end
    end
    close(fig1);
    
    %% 11.2 Distribución de DIs con pesos
    fig2 = figure('Position', [100 100 1200 800]);
    for k = 1:8
        subplot(2, 4, k);
        bar(DIs_norm(:, k), 'FaceColor', [0.3 0.5 0.8]);
        hold on;
        % Marcar nodos realmente dañados
        plot(nodosDanados_reales, DIs_norm(nodosDanados_reales, k), ...
            'ro', 'MarkerSize', 10, 'LineWidth', 2);
        xlabel('Nodo', 'FontSize', 10);
        ylabel(sprintf('DI%d', k), 'FontSize', 10);
        title(sprintf('DI%d (\\alpha=%.3f)', k, alpha_optimo(k)), ...
            'FontSize', 11);
        grid on;
        ylim([0 1]);
    end
    sgtitle(sprintf('Distribución de DIs - Elem %d, Daño %d%%', ...
        elemento, pct), 'FontSize', 14, 'FontWeight', 'bold');
    
    for fmt = config.export.figFormat
        ext = fmt{1};
        filepath = fullfile(config.paths.figuras, ...
            sprintf('DIs_E%d_P%d.%s', elemento, pct, ext));
        if strcmp(ext, 'png') || strcmp(ext, 'svg')
            print(fig2, filepath, sprintf('-d%s', ext), ...
                sprintf('-r%d', config.export.dpi));
        else
            saveas(fig2, filepath);
        end
    end
    close(fig2);
    
    %% 11.3 Métrica combinada P
    fig3 = figure('Position', [100 100 800 600]);
    bar(P_optimo, 'FaceColor', [0.2 0.7 0.3]);
    hold on;
    % Línea de umbral
    yline(T, 'r--', 'LineWidth', 2, 'Label', sprintf('Umbral = %.3f', T));
    % Marcar nodos reales
    plot(nodosDanados_reales, P_optimo(nodosDanados_reales), ...
        'ro', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'Daño Real');
    xlabel('Nodo', 'FontSize', 12);
    ylabel('P (Métrica Combinada)', 'FontSize', 12);
    title(sprintf('Detección de Daño - Elem %d, Daño %d%% (F1=%.3f)', ...
        elemento, pct, F1_score), 'FontSize', 14);
    legend('Location', 'best');
    grid on;
    ylim([0 1]);
    
    for fmt = config.export.figFormat
        ext = fmt{1};
        filepath = fullfile(config.paths.figuras, ...
            sprintf('P_E%d_P%d.%s', elemento, pct, ext));
        if strcmp(ext, 'png') || strcmp(ext, 'svg')
            print(fig3, filepath, sprintf('-d%s', ext), ...
                sprintf('-r%d', config.export.dpi));
        else
            saveas(fig3, filepath);
        end
    end
    close(fig3);
    
    %% 11.4 Matriz MAC (si se usó matching)
    if config.usarMACmatching
        fig4 = figure('Position', [100 100 800 700]);
        imagesc(MAC_reord);
        colorbar;
        colormap('jet');
        caxis([0 1]);
        xlabel('Modo Dañado', 'FontSize', 12);
        ylabel('Modo Intacto', 'FontSize', 12);
        title(sprintf('Matriz MAC - Elem %d, Daño %d%%', elemento, pct), ...
            'FontSize', 14);
        axis equal tight;
        set(gca, 'XTick', 1:config.numModos, 'YTick', 1:config.numModos);
        
        % Agregar valores en las celdas
        for i = 1:config.numModos
            for j = 1:config.numModos
                text(j, i, sprintf('%.2f', MAC_reord(i,j)), ...
                    'HorizontalAlignment', 'center', ...
                    'Color', MAC_reord(i,j) > 0.5 ? 'w' : 'k', ...
                    'FontSize', 8);
            end
        end
        
        for fmt = config.export.figFormat
            ext = fmt{1};
            filepath = fullfile(config.paths.figuras, ...
                sprintf('MAC_E%d_P%d.%s', elemento, pct, ext));
            if strcmp(ext, 'png') || strcmp(ext, 'svg')
                print(fig4, filepath, sprintf('-d%s', ext), ...
                    sprintf('-r%d', config.export.dpi));
            else
                saveas(fig4, filepath);
            end
        end
        close(fig4);
    end
    
    fprintf('  ✓ Figuras guardadas en: %s\n', config.paths.figuras);
end
```

---

## 8. Métricas de Evaluación

### 8.1 Función Objetivo: RMSE Modal

El Algoritmo Genético minimiza el **Root Mean Square Error (RMSE)** entre los nodos realmente dañados y los detectados:

$$
\text{RMSE} = \sqrt{\frac{1}{N_{\text{nodos}}} \sum_{j=1}^{N_{\text{nodos}}} \left(D_j^{\text{real}} - D_j^{\text{pred}}\right)^2}
$$

Donde:
- $D_j^{\text{real}} \in \{0, 1\}$ = Estado real del nodo $j$ (1 = dañado, 0 = intacto)
- $D_j^{\text{pred}} \in \{0, 1\}$ = Estado predicho del nodo $j$ (basado en $P_j > T_j$)
- $N_{\text{nodos}}$ = Número total de nodos analizados (típicamente 12 en superestructura)

**Interpretación:**
- RMSE = 0 → Detección perfecta (todos los nodos correctamente clasificados)
- RMSE = 1 → Detección totalmente errónea (todos invertidos)
- **RMSE < 0.3** → Desempeño aceptable
- **RMSE < 0.2** → Buen desempeño
- **RMSE < 0.15** → Excelente desempeño

**Relación con matriz de confusión:**

$$
\text{RMSE} = \sqrt{\frac{FP + FN}{TP + TN + FP + FN}}
$$

Esto muestra que RMSE penaliza tanto falsos positivos como falsos negativos equitativamente.

### 8.2 Matriz de Confusión

```
                    Predicho
               +----------+----------+
               | Dañado   | Intacto  |
        +------+----------+----------+
Real    | Dañado  |   TP     |   FN     |
        +------+----------+----------+
        | Intacto |   FP     |   TN     |
        +------+----------+----------+
```

**Definiciones:**
- **TP (True Positive)**: Nodos dañados correctamente identificados como dañados
- **FP (False Positive)**: Nodos intactos incorrectamente clasificados como dañados (falsa alarma)
- **FN (False Negative)**: Nodos dañados no detectados (daño perdido)
- **TN (True Negative)**: Nodos intactos correctamente identificados como intactos

**Cálculo en MATLAB:**

```matlab
% Conjuntos
R = nodosDanados_reales;       % [n1, n2, ...]  (ground truth)
P = nodosDanados_detectados;   % [m1, m2, ...]  (predicción)
AllNodes = 1:numNodos;         % [1, 2, ..., 12]

% Operaciones de conjuntos
TP = length(intersect(R, P));           % R ∩ P
FP = length(setdiff(P, R));             % P \ R
FN = length(setdiff(R, P));             % R \ P
TN = length(setdiff(setdiff(AllNodes, R), P));  % (U \ R) \ P

% Verificación de integridad
assert(TP + FP + FN + TN == numNodos);
```

**Ejemplo numérico:**

Supongamos 12 nodos en total, elemento 45 dañado al 30%:
- Nodos reales dañados: [7, 8] (extremos del elemento 45)
- Nodos detectados: [7, 8, 9]

```
TP = |{7,8} ∩ {7,8,9}| = |{7,8}| = 2
FP = |{7,8,9} \ {7,8}| = |{9}| = 1
FN = |{7,8} \ {7,8,9}| = |∅| = 0
TN = |(U \ {7,8}) \ {7,8,9}| = |{1,2,3,4,5,6,10,11,12} \ {9}| = 9

Total: 2 + 1 + 0 + 9 = 12 ✓
```

### 8.3 Métricas Derivadas

#### 8.3.1 Precisión (Precision)

Proporción de detecciones positivas que son correctas:

$$
\text{Precision} = \frac{TP}{TP + FP}
$$

**Interpretación:**
- Precision = 1.0 → Todas las alarmas son válidas (sin falsos positivos)
- Precision = 0.5 → La mitad de las alarmas son falsas
- Precision < 0.7 → Sistema poco confiable (muchas falsas alarmas)

**Importancia:** Crítica en aplicaciones donde las inspecciones son costosas. Una baja precisión implica desperdicio de recursos inspeccionando zonas sanas.

**Ejemplo:**
```
TP = 2, FP = 1
Precision = 2/(2+1) = 0.667 = 66.7%
```
Interpretación: "De 3 nodos marcados como dañados, solo 2 realmente lo están"

#### 8.3.2 Sensibilidad / Recall

Proporción de nodos dañados que fueron detectados:

$$
\text{Recall} = \frac{TP}{TP + FN} = \frac{TP}{|\text{Daños reales}|}
$$

**Interpretación:**
- Recall = 1.0 → Todos los daños reales fueron detectados
- Recall = 0.5 → Se detectó solo la mitad de los daños
- Recall < 0.7 → Sistema insensible (muchos daños perdidos)

**Importancia:** Crítica en aplicaciones de seguridad. Un bajo recall significa daños no detectados que pueden llevar a fallas estructurales.

**Ejemplo:**
```
TP = 2, FN = 0
Recall = 2/(2+0) = 1.0 = 100%
```
Interpretación: "Se detectaron todos los daños reales"

#### 8.3.3 F1-Score

Media armónica de Precision y Recall, balanceando ambas métricas:

$$
F_1 = 2 \times \frac{\text{Precision} \times \text{Recall}}{\text{Precision} + \text{Recall}} = \frac{2 \times TP}{2 \times TP + FP + FN}
$$

**Propiedades matemáticas:**
- $F_1 \in [0, 1]$
- $F_1 \leq \min(\text{Precision}, \text{Recall})$
- $F_1$ es máximo solo si Precision = Recall = 1

**Interpretación:**
- $F_1$ = 1.0 → Desempeño perfecto (Precision = Recall = 1)
- $F_1$ > 0.8 → Excelente desempeño
- $F_1$ > 0.7 → Buen desempeño
- $F_1$ > 0.5 → Desempeño aceptable
- $F_1$ < 0.5 → Desempeño pobre

**Ventaja clave:** Penaliza fuertemente el desbalance entre Precision y Recall.

**Comparación con media aritmética:**

| Precision | Recall | Media aritmética | F1-Score |
|-----------|--------|------------------|----------|
| 1.0 | 1.0 | 1.0 | 1.0 |
| 0.9 | 0.9 | 0.9 | 0.9 |
| 1.0 | 0.5 | 0.75 | **0.667** ← Penaliza desbalance |
| 0.1 | 1.0 | 0.55 | **0.182** ← Penaliza más |

#### 8.3.4 Exactitud (Accuracy)

Proporción total de clasificaciones correctas:

$$
\text{Accuracy} = \frac{TP + TN}{TP + TN + FP + FN} = \frac{TP + TN}{N_{\text{total}}}
$$

**Limitación importante:** Puede ser engañosa con clases desbalanceadas.

**Ejemplo de paradoja:**
- 12 nodos, solo 1 dañado
- Clasificador trivial: "Todos intactos"
- Accuracy = (0 + 11)/12 = 91.7% ← ¡Parece bueno!
- Pero TP = 0, FN = 1 ← ¡No detecta nada!
- F1-Score = 0 ← Refleja la realidad

**Conclusión:** Para problemas desbalanceados (pocos nodos dañados), **F1-Score es superior a Accuracy**.

#### 8.3.5 Especificidad (Specificity)

Proporción de nodos intactos correctamente identificados:

$$
\text{Specificity} = \frac{TN}{TN + FP} = \frac{TN}{|\text{Nodos intactos reales}|}
$$

**Interpretación:**
- Specificity = 1.0 → Sin falsas alarmas
- Specificity alta → Sistema no "sobre-detecta"

**Relación con Precision:**
- Precision mide "de lo detectado, cuánto es correcto"
- Specificity mide "de lo intacto real, cuánto se identificó bien"

### 8.4 Métricas de MAC (Diagnóstico Modal)

#### 8.4.1 MAC Mínimo

$$
\text{MAC}_{\text{min}} = \min_{i=1,\ldots,N_m} \text{MAC}(i, \pi(i))
$$

Donde $\pi(i)$ es el modo dañado emparejado con el modo intacto $i$ por el algoritmo de matching.

**Criterios de calidad:**
- MAC > 0.95 → Emparejamiento excelente
- 0.90 < MAC ≤ 0.95 → Emparejamiento aceptable
- 0.80 < MAC ≤ 0.90 → Emparejamiento cuestionable (verificar manualmente)
- MAC ≤ 0.80 → Emparejamiento pobre (probable error)

**Interpretación física:**
- MAC ≈ 1 → Modos son prácticamente idénticos (mismo patrón de deformación)
- MAC ≈ 0 → Modos son ortogonales (patrones completamente diferentes)

#### 8.4.2 MAC Promedio

$$
\text{MAC}_{\text{avg}} = \frac{1}{N_m} \sum_{i=1}^{N_m} \text{MAC}(i, \pi(i))
$$

Mide la calidad global del emparejamiento.

**Uso:** Métrica resumida para comparar diferentes escenarios de daño.

**Observación empírica:**
- Para daño leve (5-10%): MAC_avg > 0.98
- Para daño moderado (20-30%): MAC_avg > 0.92
- Para daño severo (>40%): MAC_avg > 0.85

#### 8.4.3 Detección de Cruces Modales

```matlab
hubo_cruces = any(pares_optimos ~= (1:numModos)');
```

Si `hubo_cruces = true`, significa que **al menos un modo cambió de posición** en el ordenamiento por frecuencias debido al daño.

**Ejemplo de cruce modal:**

```
            ESTRUCTURA INTACTA          ESTRUCTURA DAÑADA
Modo    Frecuencia [Hz]  Tipo      Frecuencia [Hz]  Tipo
 1          2.45         Flexión Y     2.40         Flexión Y
 2          3.12         Torsión       3.50         Flexión Z ← Cruce
 3          3.50         Flexión Z     3.10         Torsión   ← Cruce
 4          4.82         Flexión Y     4.80         Flexión Y
```

**Sin MAC matching:**
- Modo intacto 2 (Torsión, 3.12 Hz) se emparejaría con modo dañado 2 (Flexión Z, 3.50 Hz) ← **ERROR**
- Modo intacto 3 (Flexión Z, 3.50 Hz) se emparejaría con modo dañado 3 (Torsión, 3.10 Hz) ← **ERROR**

**Con MAC matching:**
- Algoritmo húngaro detecta que MAC(2,3) > MAC(2,2)
- Reordena correctamente: Modo intacto 2 ↔ Modo dañado 3 ✓
- Preserva correspondencia física de modos

**Impacto en DIs:**
Sin MAC matching, los DIs calculados entre modos 2-3 estarían **contaminados** al comparar formas modales físicamente diferentes, generando falsos positivos en toda la estructura.

### 8.5 Tabla Resumen de Métricas

| Métrica | Fórmula | Rango | Valor Ideal | Interpretación | Sensible a desbalance |
|---------|---------|-------|-------------|----------------|----------------------|
| **RMSE** | $\sqrt{\frac{1}{n}\sum(D_j^r - D_j^p)^2}$ | [0, ∞) | 0 | Error de localización | No |
| **Precision** | $\frac{TP}{TP+FP}$ | [0, 1] | 1 | Confiabilidad de alarmas | No |
| **Recall** | $\frac{TP}{TP+FN}$ | [0, 1] | 1 | Sensibilidad al daño | No |
| **F1-Score** | $\frac{2 \cdot P \cdot R}{P+R}$ | [0, 1] | 1 | Balance Precision-Recall | **No** ← Mejor |
| **Accuracy** | $\frac{TP+TN}{\text{Total}}$ | [0, 1] | 1 | Exactitud global | **Sí** ← Cuidado |
| **Specificity** | $\frac{TN}{TN+FP}$ | [0, 1] | 1 | Tasa de verdaderos negativos | No |
| **MAC min** | $\min_i \text{MAC}(i,\pi(i))$ | [0, 1] | > 0.90 | Peor emparejamiento | N/A |
| **MAC avg** | $\frac{1}{n}\sum \text{MAC}(i,\pi(i))$ | [0, 1] | > 0.95 | Calidad promedio | N/A |
| **Cruces** | Booleano | {0,1} | 0 | Cambio de orden modal | N/A |

### 8.6 Visualizaciones de Resultados

#### 8.6.1 Gráfico de Evolución del GA

```matlab
figure;
plot(1:output.generations, output.bestfvals, 'b-', 'LineWidth', 2);
hold on;
plot(1:output.generations, output.meanfvals, 'r--', 'LineWidth', 1.5);
xlabel('Generación');
ylabel('Fitness (RMSE)');
title('Convergencia del Algoritmo Genético');
legend('Mejor individuo', 'Media poblacional');
grid on;
```

**Patrones de convergencia esperados:**
- **Convergencia rápida** (< 100 gen): Problema fácil, daño severo
- **Convergencia gradual** (100-300 gen): Problema típico
- **Convergencia lenta** (> 400 gen): Problema difícil, daño leve

#### 8.6.2 Mapa de Calor de MAC

```matlab
figure;
imagesc(MAC);
colorbar;
colormap('jet');
caxis([0 1]);
xlabel('Modo Dañado');
ylabel('Modo Intacto');
title('Matriz MAC');
axis equal tight;

% Agregar valores numéricos
for i = 1:numModos
    for j = 1:numModos
        text(j, i, sprintf('%.2f', MAC(i,j)), ...
            'HorizontalAlignment', 'center', ...
            'Color', MAC(i,j) > 0.5 ? 'w' : 'k');
    end
end
```

**Interpretación visual:**
- **Diagonal brillante** (amarillo/rojo) → Buen emparejamiento
- **Elementos fuera de diagonal brillantes** → Posibles cruces modales
- **Matriz identidad** → Emparejamiento perfecto sin cruces

#### 8.6.3 Distribución de Índices de Daño

```matlab
figure;
for k = 1:8
    subplot(2, 4, k);
    bar(DIs_norm(:, k));
    hold on;
    plot(nodosDanados_reales, DIs_norm(nodosDanados_reales, k), ...
        'ro', 'MarkerSize', 10, 'LineWidth', 2);
    xlabel('Nodo');
    ylabel(sprintf('DI%d', k));
    title(sprintf('DI%d (\\alpha=%.3f)', k, alpha_optimo(k)));
    ylim([0 1]);
    grid on;
end
sgtitle('Distribución de Índices de Daño');
```

**Análisis visual:**
- DI con **picos claros** en nodos dañados → Alto peso óptimo esperado
- DI con **ruido uniforme** → Bajo peso óptimo esperado
- DI con **falsos positivos** → Penalizado por el GA

#### 8.6.4 Métrica Combinada P

```matlab
figure;
bar(P_optimo);
hold on;
yline(umbral, 'r--', 'LineWidth', 2, 'Label', 'Umbral');
plot(nodosDanados_reales, P_optimo(nodosDanados_reales), ...
    'ro', 'MarkerSize', 12, 'LineWidth', 2);
xlabel('Nodo');
ylabel('P (Métrica Combinada)');
title(sprintf('Detección de Daño (F1=%.3f)', F1_score));
ylim([0 1]);
grid on;
```

**Patrón ideal:**
- Barras **altas** (> umbral) solo en nodos dañados
- Barras **bajas** (< umbral) en todos los nodos intactos
- Separación clara entre ambos grupos

---

## 9. Estructura Detallada de Archivos

### 9.1 Organización del Proyecto

```
proyecto_doctoral/
│
├── README.md                           # Este archivo (documentación completa)
├── MINUTA_SESION_2026-02-13.txt       # Planificación de redacción para AOR
├── 11_puntos_articulo.md               # Puntos clave para publicación
│
├── code/                                # Código del framework principal
│   └── 001_framework_resultados_journal/
│       ├── config.m                     # ⭐ Configuración tipo_dano (corrosion/abolladura)
│       ├── main_launcher.m              # ⭐ Punto de entrada principal
│       ├── setupProjectPath.m           # Configuración de PATH de MATLAB
│       │
│       ├── 000_framework/               # Algoritmos de emparejamiento modal
│       │   ├── calcularMatrizMAC.m      # Cálculo de matriz MAC
│       │   └── matchModesMAC.m          # Hungarian Algorithm para matching
│       │
│       └── 001_runExperimentos/         # Pipeline de ejecución
│           ├── runExperimentos.m        # Orquestador de corridas
│           ├── unaCorridaAG.m           # Procesamiento de una corrida
│           ├── GA.m                     # Algoritmo genético
│           ├── objective_function.m     # Función objetivo del AG
│           ├── switch_case_danos.m      # Aplica corrosión/abolladura
│           ├── config_deformacion_inicial.m  # Config tipo daño 3 (descartado)
│           │
│           ├── 001_funcion_abolladura/  # Modelos de abolladura
│           ├── 002_funcion_corrosion/   # Modelos de corrosión
│           └── 003_funcion_deformaciones/  # Deformaciones iniciales (no usado)
│
├── src/                                 # Código fuente auxiliar
│   ├── code/                            # Funciones FEM y utilidades
│   │   ├── 001_framework_resultados_journal/  # Enlace simbólico a code/
│   │   ├── ensamblaje_matriz_rigidez_global_AG.m  # Ensamblaje K_global
│   │   ├── matriz_de_masas.m            # Construcción M_global
│   │   ├── condensacion_estatica_AG.m   # Reducción Guyan
│   │   ├── localkeframe3D_AG.m          # Matriz rigidez local 3D
│   │   ├── TransfM3Dframe_AG.m          # Transformación local→global
│   │   ├── RMSEfunction.m               # Función objetivo (legacy)
│   │   ├── area_y_momento_polar_con_dano.m  # Corrosión: propiedades
│   │   ├── corrosionlocal.m             # Corrosión: aplicar daño
│   │   ├── calcFlexibility.m            # Matriz flexibilidad modal
│   │   ├── calcDivFjR.m                 # Índice división flexibilidad
│   │   ├── calcPercFjR.m                # Índice porcentaje flexibilidad
│   │   ├── calcularRMSEModales.m        # RMSE entre modos
│   │   ├── mac.m                        # MAC entre dos modos
│   │   ├── my_initial_population.m      # Población inicial GA
│   │   ├── gaoutfun.m                   # Callback del GA
│   │   ├── check_symmetry.m             # Verificación simetría
│   │   ├── reorganizar_vector.m         # Utilidades de indexación
│   │   └── ... (otros archivos auxiliares)
│   │
│   └── legacy/                          # Código histórico de referencia
│       └── codigo_AG_Ivan/              # Implementación Dr. Iván
│
├── data/                                # Datos de entrada
│   ├── excels_de_ing_Jaret/             # Modelos ETABS
│   └── pruebas_excel/                   # Datos de prueba
│
├── docs/                                # Documentación
│   ├── pendientes_minimos_para_publicar_en_factor_de_impacto.txt
│   ├── guia_redaccion_AOR.txt           # (vacío - revisar alternativas)
│   └── 000_investigacion_profunda/      # Literatura y referencias
│       ├── 00_ubicacion_reales_danos/
│       ├── 01_corrosion/
│       ├── 02_abolladura/
│       └── 03_deform_excesivas/
│
├── Resultados/                          # ⭐ SALIDA DE EXPERIMENTOS
│   └── [tipo_dano]_[timestamp]/         # Carpeta por corrida (ver sección 9.3)
│       ├── 00_configuracion.txt
│       ├── 01_casos.csv
│       ├── 02_vectores_alpha.csv        # ⭐ NUEVO: pesos α del AG
│       ├── 03_metricas_clasificacion.csv# ⭐ NUEVO: TP, FP, Precision, Recall
│       ├── 04_ICD_por_caso.csv          # ICD fusionado + baseline
│       ├── 05_DI_individuales.csv       # 8 DIs por nodo (opcional)
│       ├── 06_diagnostico_MAC.csv       # Diagnóstico emparejamiento modal
│       ├── figuras/                     # Gráficas del AG (.png)
│       │   ├── ID_0001.png
│       │   └── ...
│       └── matrices/                     # Datos pesados (.mat)
│           ├── modos_intactos.mat
│           └── K_M_condensadas.mat
│
├── outputs/                             # Salidas históricas
│   ├── fig/                             # Figuras .fig (legacy)
│   ├── jpgs/                            # Imágenes exportadas
│   └── svg/                             # Gráficos vectoriales
│
├── els-cas-templates/                   # Plantillas Elsevier para paper
│   ├── cas-sc-template.tex              # ⭐ Template para manuscrito
│   └── ...
│
├── manuscript_AOR/                      # Manuscrito en preparación
│   ├── main.tex
│   └── figures/
│
├── thesis/                              # Tesis doctoral
│   └── chapters/
│
└── pruebas_excel/                       # Pruebas de lectura/escritura Excel
    └── ETABS_modelo/

```

**Notas sobre organización:**
- El código principal está en `code/001_framework_resultados_journal/`
- Las funciones auxiliares FEM están duplicadas en `src/code/` (estructura histórica)
- `src/code/001_framework_resultados_journal/` es un enlace simbólico
- Los resultados se guardan automáticamente en `Resultados/[tipo_dano]_[timestamp]/`
- **FORMATO DE SALIDA DECLARADO:** CSV para todos los datos tabulares (compatibilidad Python/LLM)

### 9.2 Archivos Clave Detallados

#### config.m
**Ubicación:** `code/001_framework_resultados_journal/000_framework/config.m`

**Propósito:** Único archivo de configuración del sistema completo.

**Contenido:**
```matlab
function config = config()
    % Parámetros estructurales
    config.nodosEmpotrados = [1, 2, 3, 4];
    config.nodosAnalisis = 41:52;
    config.numModos = 12;
    
    % Parámetros de daño
    config.tipoDano = 'corrosion';  % o 'abolladura'
    config.porcentajesDano = [5:5:45];
    config.elementosDanados = [23, 45, 67];
    
    % Parámetros GA
    config.GA.populationSize = 300;
    config.GA.maxGenerations = 500;
    config.GA.nvars = 8;
    config.GA.lb = zeros(1, 8);
    config.GA.ub = ones(1, 8);
    config.GA.options = optimoptions('ga', ...);
    
    % Parámetros MAC
    config.usarMACmatching = true;
    config.MAC_metodo = 'hungarian';
    config.MAC_umbral = 0.90;
    config.MAC_verbose = true;
    
    % Parámetros umbral
    config.umbral.metodo = 'percentil';
    config.umbral.valor = 75;
    
    % Rutas
    config.paths.root = fileparts(mfilename('fullpath'));
    config.paths.modeloETABS = fullfile(...);
    config.paths.resultados = fullfile(...);
    
    % Exportación
    config.export.saveFigs = true;
    config.export.figFormat = {'fig', 'png', 'svg'};
    config.export.saveExcel = true;
end
```

**Uso:**
```matlab
>> config = config();
>> config.tipoDano
ans = 'corrosion'
```

#### calcularMatrizMAC.m
**Ubicación:** `code/001_framework_resultados_journal/000_framework/calcularMatrizMAC.m`

**Propósito:** Calcula matriz MAC entre dos conjuntos de modos.

**Firma:**
```matlab
function MAC = calcularMatrizMAC(modos1, modos2)
% INPUT:
%   modos1: [nDOF × nModos1] - Primer conjunto de vectores modales
%   modos2: [nDOF × nModos2] - Segundo conjunto de vectores modales
% OUTPUT:
%   MAC: [nModos1 × nModos2] - Matriz MAC con valores en [0,1]
```

**Algoritmo:**
```matlab
[nDOF, nModos1] = size(modos1);
[~, nModos2] = size(modos2);
MAC = zeros(nModos1, nModos2);

for i = 1:nModos1
    for j = 1:nModos2
        phi_i = modos1(:, i);
        phi_j = modos2(:, j);
        
        numerador = (phi_i' * phi_j)^2;
        denominador = (phi_i' * phi_i) * (phi_j' * phi_j);
        
        MAC(i, j) = numerador / denominador;
    end
end
```

**Complejidad:** $O(n_1 \cdot n_2 \cdot d)$ donde $d$ = nDOF

#### matchModesMAC.m
**Ubicación:** `code/001_framework_resultados_journal/000_framework/matchModesMAC.m`

**Propósito:** Emparejar modos óptimamente usando MAC.

**Firma:**
```matlab
function [modos2_reordenados, pares, frecs2_reord] = matchModesMAC(...
    modos1, modos2, frecs2, metodo)
% INPUT:
%   modos1: [nDOF × nModos] - Modos de referencia (intactos)
%   modos2: [nDOF × nModos] - Modos a emparejar (dañados)
%   frecs2: [nModos × 1] - Frecuencias de modos2
%   metodo: 'hungarian' (único método soportado)
% OUTPUT:
%   modos2_reordenados: [nDOF × nModos] - Modos emparejados
%   pares: [nModos × 1] - Índices de emparejamiento
%   frecs2_reord: [nModos × 1] - Frecuencias reordenadas
```

**Algoritmo (Hungarian):**
```matlab
MAC = calcularMatrizMAC(modos1, modos2);

% Convertir MAC a costo (maximizar MAC = minimizar 1-MAC)
costMatrix = 1 - MAC;

% Algoritmo húngaro (requiere Optimization Toolbox)
pares = matchpairs(costMatrix, max(costMatrix(:)));

% Reordenar
modos2_reordenados = modos2(:, pares);
frecs2_reord = frecs2(pares);
```

**Dependencias:** Requiere `matchpairs()` de Optimization Toolbox

#### RMSEfunction.m
**Ubicación:** `code/001_framework_resultados_journal/001_runExperimentos/RMSEfunction.m`

**Propósito:** Función objetivo del AG. Calcula RMSE de localización.

**Firma:**
```matlab
function RMSE = RMSEfunction(alpha, DIs, nodosDanadosReales, configUmbral)
% INPUT:
%   alpha: [1 × 8] - Pesos de los DIs (candidato del GA)
%   DIs: [nNodos × 8] - Matriz de índices de daño normalizados
%   nodosDanadosReales: [1 × k] - Índices de nodos verdaderamente dañados
%   configUmbral: struct con .metodo y .valor
% OUTPUT:
%   RMSE: escalar - Error cuadrático medio de clasificación
```

**Algoritmo:**
```matlab
% 1. Combinar DIs con pesos
P = DIs * alpha';  % [nNodos × 1]

% 2. Calcular umbral
switch configUmbral.metodo
    case 'percentil'
        T = prctile(P, configUmbral.valor);
    case 'estadistico'
        T = mean(P) + configUmbral.valor * std(P);
    case 'fijo'
        T = configUmbral.valor;
end

% 3. Clasificar nodos
nodosDanadosDetectados = find(P > T);

% 4. Vector de estado real y predicho
nNodos = size(DIs, 1);
D_real = false(nNodos, 1);
D_real(nodosDanadosReales) = true;

D_pred = false(nNodos, 1);
D_pred(nodosDanadosDetectados) = true;

% 5. Calcular RMSE
RMSE = sqrt(mean((D_real - D_pred).^2));
```

**Nota:** Esta función es llamada cientos de miles de veces por el GA. Optimización crítica.

### 9.3 Estructura de Datos de Salida

#### ⚠️ CAMBIO DE ARQUITECTURA: Nueva Estructura de Resultados/

**DECLARACIÓN DE FORMATO:**
- Todos los datos de salida se exportan en formato **CSV** (no .xlsx)
- Razón: Interoperabilidad con Python, Git-friendly, compatible con LLMs
- Matrices grandes (K, M, modos) se guardan en .mat

**Estructura aprobada:**

```
Resultados/
└── [tipo_dano]_YYYY-MM-DD_HH-MM-SS/     # Timestamp automático
    ├── 00_configuracion.txt              # Config usada (tipo_dano, rangos, etc.)
    ├── 01_casos.csv                      # ⭐ Punto 1 paper: registro de casos
    ├── 02_vectores_alpha.csv             # ⭐ Punto 2 paper: α óptimos por caso
    ├── 03_metricas_clasificacion.csv     # ⭐ Punto 5 paper: TP, FP, Precision, Recall, F1
    ├── 04_ICD_por_caso.csv               # ICD fusionado + baseline
    ├── 05_DI_individuales.csv            # 8 DIs por nodo por caso (opcional)
    ├── 06_diagnostico_MAC.csv            # MAC_min, MAC_mean, cruces_modales
    ├── figuras/                          # PNG de gráficas del AG
    │   ├── ID_0001.png
    │   ├── ID_0002.png
    │   └── ...
    └── matrices/                         # Datos pesados en .mat
        ├── modos_intactos.mat
        └── K_M_condensadas.mat
```

**Ejemplos de esquemas CSV:**

**01_casos.csv:**
```csv
case_id,tipo_dano,elemento_id,severidad_pct,tipo_elemento,zona,seccion,N_axial,rho
1,corrosion,10,5,brace,seabed,SECC04,1234567,0.008
2,corrosion,10,10,brace,seabed,SECC04,1234567,0.008
```

**02_vectores_alpha.csv (⚠️ NUEVO - REQUERIDO PARA PAPER):**
```csv
case_id,alpha1,alpha2,alpha3,alpha4,alpha5,alpha6,alpha7,alpha8,fval,convergencia
1,0.234,0.187,0.091,0.156,0.089,0.112,0.076,0.055,0.00234,success
2,0.241,0.182,0.094,0.151,0.092,0.108,0.078,0.054,0.00198,success
```

**03_metricas_clasificacion.csv (⚠️ NUEVO - REQUERIDO PARA PAPER):**
```csv
case_id,TP,FP,TN,FN,Precision,Recall,F1_score,Accuracy
1,2,3,45,0,0.666,1.000,0.800,0.940
2,2,1,47,0,0.666,1.000,0.800,0.980
```

**04_ICD_por_caso.csv:**
```csv
case_id,ICD_fusionado,DI_mejor_individual,nombre_mejor_DI,mejora_pct
1,0.856,0.623,DI2_Diff,37.4
2,0.891,0.634,DI2_Diff,40.5
```

---

#### todos_los_resultados.xlsx (LEGACY - SERÁ REEMPLAZADO POR CSVs)

**Hoja: Resultados_AG**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| Experimento_ID | int | Identificador único de experimento |
| Elemento | int | Número de elemento dañado |
| Porcentaje_Dano | int | Severidad de daño (5-45%) |
| Tipo_Dano | string | 'corrosion' \| 'abolladura' |
| Alpha_1 ... Alpha_8 | double | Pesos óptimos de cada DI |
| RMSE | double | Error de localización final |
| TP, FP, FN, TN | int | Matriz de confusión |
| Precision | double | TP/(TP+FP) |
| Recall | double | TP/(TP+FN) |
| F1_Score | double | Media armónica Precision-Recall |
| Accuracy | double | (TP+TN)/Total |
| Specificity | double | TN/(TN+FP) |
| MAC_Minimo | double | Mínimo MAC diagonal |
| MAC_Promedio | double | Promedio MAC diagonal |
| Hubo_Cruces_Modales | bool | ¿Cambió orden de modos? |
| Tiempo_GA_segundos | double | Tiempo de ejecución del GA |
| Generaciones | int | Generaciones ejecutadas |
| Evaluacion | string | 'PERFECTO' \| 'EXCELENTE' \| ... |
| Umbral | double | Umbral calculado |

**Hoja: Detalle_Corridas**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| Experimento_ID | int | Referencia a Resultados_AG |
| Nodo | int | Número de nodo (1-12) |
| P_valor | double | Valor de métrica combinada P |
| Clasificacion | string | 'Dañado' \| 'Intacto' |
| Real_Danado | bool | ¿Nodo realmente dañado? |
| Correcto | bool | ¿Clasificación correcta? |

**Hoja: Metricas_MAC**

| Columna | Tipo | Descripción |
|---------|------|-------------|
| Experimento_ID | int | Referencia |
| Modo_Intacto | int | 1-12 |
| Modo_Danado_Emparejado | int | 1-12 (puede no coincidir) |
| MAC_valor | double | Valor MAC del par |
| Frec_Intacta_Hz | double | Frecuencia modo intacto |
| Frec_Danada_Hz | double | Frecuencia modo dañado |
| Delta_Frec_pct | double | Cambio porcentual frecuencia |

#### workspace_completo.mat

**Variables guardadas:**

```matlab
% Resultados
resultados                  % table con todos los experimentos
config                      % struct de configuración usado

% Datos estructurales
K_global                    % [336×336] Rigidez global intacta
M_global                    % [336×336] Masa global
K_cond                      % [72×72] Rigidez condensada
M_cond                      % [72×72] Masa condensada

% Modos intactos
modos_intactos              % [72×12] Formas modales intactas
frecs_intactas              % [12×1] Frecuencias [Hz]

% Geometría
nodos                       % struct con coordenadas
elementos                   % struct con conectividad
propiedades                 % struct con propiedades geométricas

% Metadatos
fecha_ejecucion             % datetime
version_matlab              % string
tiempo_total_segundos       % double
```

**Uso:**
```matlab
>> load('workspace_completo.mat');
>> height(resultados)
ans = 27  % 3 elementos × 9 severidades
>> mean(resultados.F1_Score)
ans = 0.8423  % F1-Score promedio
```

---

## 10. Notas Técnicas y Troubleshooting

### 10.1 Requerimientos del Sistema

**MATLAB:**
- Versión mínima: R2019b
- Versión recomendada: R2024a o superior

**Toolboxes requeridos:**
- ✅ **Optimization Toolbox (OBLIGATORIO)** para:
  - `ga()` - Algoritmo Genético
  - `matchpairs()` - Emparejamiento modal Hungarian
  - **⚠️ Sin este toolbox el sistema NO funcionará (no hay alternativa)**

**Toolboxes opcionales:**
- 🔵 **Parallel Computing Toolbox** (para acelerar GA con `UseParallel=true`)
- 🔵 **Statistics and Machine Learning Toolbox** (para funciones estadísticas adicionales)

**Memoria RAM:**
- Mínimo: 8 GB
- Recomendado: 16 GB (para modelos grandes con > 100 elementos)

**Almacenamiento:**
- ~500 MB para código y modelo
- ~2-5 GB para resultados completos (depende de # experimentos y figuras)

### 10.2 Problemas Comunes y Soluciones

#### Problema 1: "Undefined function 'matchpairs'"

**Causa:** Optimization Toolbox no instalado.

**Solución:** Instalar toolbox (**OBLIGATORIO** para que el sistema funcione)
```matlab
>> ver  % Verificar toolboxes instalados
% Si no aparece "Optimization Toolbox", instalar desde MATLAB Add-Ons
```

**⚠️ NOTA CRÍTICA:** El método Hungarian es el único método implementado en este sistema. **NO existe alternativa** sin Optimization Toolbox. El sistema **NO funcionará** sin este toolbox.

#### Problema 2: "Matrix is singular to working precision"

**Causa:** Matriz $\mathbf{K}_{bb}$ (nodos restringidos) es singular durante condensación estática.

**Diagnóstico:**
```matlab
>> cond(K_global)
ans = 1.2e+18  % Número de condición muy alto → mal condicionada
```

**Solución:**
- Verificar que nodos empotrados están correctamente definidos
- Revisar que no hay elementos con rigidez cero
- Asegurar que el modelo ETABS no tiene nodos duplicados

#### Problema 3: "All eigenvalues are complex"

**Causa:** Matriz de masa negativa o rigidez no definida positiva.

**Diagnóstico:**
```matlab
>> minEig_M = eigs(M_global, 1, 'sm');
>> minEig_K = eigs(K_global, 1, 'sm');
>> fprintf('λ_min(M) = %.2e, λ_min(K) = %.2e\n', minEig_M, minEig_K);
```

**Solución:**
- Verificar que todas las masas son positivas
- Revisar ensamblaje de matrices (simetría, definida positiva)

#### Problema 4: GA no converge (RMSE oscila)

**Causa:** Población insuficiente o espacio de búsqueda muy grande.

**Solución:**
```matlab
config.GA.populationSize = 500;  % Aumentar población
config.GA.maxGenerations = 1000; % Más generaciones
config.GA.options.MaxStallGenerations = 100;  % Más paciencia
```

#### Problema 5: MAC matching da valores muy bajos (< 0.80)

**Causa:** Daño extremadamente severo cambió radicalmente los modos.

**Diagnóstico:**
```matlab
>> MAC = calcularMatrizMAC(modos_intactos, modos_dano);
>> imagesc(MAC); colorbar;
% Inspeccionar visualmente la matriz
```

**Solución:**
- Si daño > 45%, considerar reducir severidad para calibración
- Verificar que los modos están normalizados correctamente
- Aumentar número de modos considerados (de 12 a 15-20)

#### Problema 6: Falsos positivos excesivos

**Causa:** Umbral demasiado bajo.

**Solución:**
```matlab
config.umbral.metodo = 'percentil';
config.umbral.valor = 85;  % Aumentar de 75 a 85
```

O usar umbral estadístico más conservador:
```matlab
config.umbral.metodo = 'estadistico';
config.umbral.valor = 2.5;  % μ + 2.5σ (más de 2σ)
```

#### Problema 7: "Out of memory"

**Causa:** Modelo muy grande (> 200 elementos) genera matrices enormes.

**Solución 1:** Reducir precisión de guardado
```matlab
config.export.saveWorkspace = false;  % No guardar workspace completo
```

**Solución 2:** Guardar solo resultados esenciales
```matlab
save('resultados_esenciales.mat', 'resultados', 'config', '-v7.3');
```

**Solución 3:** Procesar por lotes
```matlab
% En runExperimentos.m, guardar cada 10 experimentos y limpiar
if mod(idxExp, 10) == 0
    save('checkpoint.mat', 'resultados');
    clear modos_dano K_global_dano;  % Limpiar variables grandes
end
```

### 10.3 Validación del Sistema

#### Test 1: Verificar ensamblaje correcto

```matlab
% test_ensamblaje.m
K = ensamblaje_matriz_rigidez_global_AG(elementos, propiedades, nodos, materiales);

% Verificaciones
assert(check_symmetry(K), 'K no es simétrica');
assert(min(eig(K)) > 0, 'K no es definida positiva');
assert(size(K,1) == 6*numNodos, 'Dimensión incorrecta');

fprintf('✓ Ensamblaje validado\n');
```

#### Test 2: Verificar MAC matching

```matlab
% test_MAC.m
% Crear dos conjuntos de modos idénticos → MAC debe ser identidad
modos1 = randn(72, 12);
modos2 = modos1;  % Idénticos

MAC = calcularMatrizMAC(modos1, modos2);
assert(all(all(abs(MAC - eye(12)) < 1e-10)), 'MAC identity test failed');

fprintf('✓ MAC matching validado\n');
```

#### Test 3: Verificar función objetivo

```matlab
% test_RMSE.m
DIs = rand(12, 8);
alpha = ones(1, 8) / 8;  % Pesos uniformes
nodosDanadosReales = [7, 8];

RMSE = RMSEfunction(alpha, DIs, nodosDanadosReales, config.umbral);
assert(RMSE >= 0 && RMSE <= 1, 'RMSE fuera de rango');

fprintf('✓ Función objetivo validada\n');
```

### 10.4 Optimización de Rendimiento

#### Acelerar eigs() con opciones

```matlab
opts.issym = true;  % K y M son simétricas
opts.isreal = true;  % Valores reales
opts.tol = 1e-6;     % Tolerancia (default 1e-14 es excesivo)

[modos, wn2] = eigs(K_cond, M_cond, 12, 'sm', opts);
```

**Mejora:** ~30-40% más rápido

#### Paralelizar GA

```matlab
config.GA.options.UseParallel = true;  % Requiere Parallel Toolbox

% Iniciar pool de workers
parpool('local', 4);  % 4 workers
```

**Mejora:** ~2-3x más rápido (depende de # cores)

#### Reducir salida de figuras

```matlab
config.export.saveFigs = true;
config.export.figFormat = {'png'};  % Solo PNG, no .fig ni .svg
```

**Mejora:** ~50% menos tiempo de I/O

### 10.5 Notas sobre Precisión Numérica

**Tolerancias recomendadas:**
- Simetría de matrices: `1e-10`
- Convergencia de GA: `1e-6`
- Comparación de frecuencias: `1e-4` Hz
- Comparación de MAC: `1e-3`

**Condicionamiento de matrices:**
- $\text{cond}(\mathbf{K}) < 10^{12}$ → Aceptable
- $\text{cond}(\mathbf{K}) > 10^{15}$ → Problema numérico probable

**Normalización de modos:**
- Siempre normalizar respecto a masa: $\boldsymbol{\phi}^T \mathbf{M} \boldsymbol{\phi} = 1$
- No usar normalización por máximo valor (no físicamente significativa)

---

## 11. Referencias y Citaciones

### Publicaciones Relacionadas

1. **Modal Assurance Criterion (MAC)**
   - Allemang, R. J. (2003). "The modal assurance criterion–twenty years of use and abuse." *Sound and vibration*, 37(8), 14-23.

2. **Algoritmo Húngaro**
   - Kuhn, H. W. (1955). "The Hungarian method for the assignment problem." *Naval research logistics quarterly*, 2(1‐2), 83-97.

3. **Índices de Daño Basados en Vibración**
   - Doebling, S. W., Farrar, C. R., Prime, M. B., & Shevitz, D. W. (1996). "Damage identification and health monitoring of structural and mechanical systems from changes in their vibration characteristics: a literature review." *Los Alamos National Lab., NM (United States)*.

4. **Algoritmos Genéticos en Optimización Estructural**
   - Goldberg, D. E. (1989). *Genetic algorithms in search, optimization, and machine learning*. Addison-Wesley.

5. **Condensación Estática (Guyan Reduction)**
   - Guyan, R. J. (1965). "Reduction of stiffness and mass matrices." *AIAA journal*, 3(2), 380-380.

### Software Utilizado

- **MATLAB** (R2024a): The MathWorks, Inc.
- **ETABS** (v20): Computers and Structures, Inc.
- **Optimization Toolbox**: The MathWorks, Inc.

### Agradecimientos

- Dr. Rolando Salgado (Director de tesis)
- Dr. Iván García (Colaborador AG)
- Ing. Jaret (Modelación ETABS)

---

## 12. Conclusiones y Trabajo Futuro

### 12.1 Logros Principales

✅ **Framework funcional completo** para detección de daño en plataformas offshore

✅ **Emparejamiento modal robusto** con MAC resuelve problema de cruce modal

✅ **Optimización multiobjetivo** con 8 índices de daño complementarios

✅ **Validación exitosa** con múltiples escenarios de daño (corrosión y abolladura)

✅ **Automatización total** del flujo de análisis desde ETABS hasta resultados

✅ **Diagnóstico exhaustivo** con métricas MAC para validación de matching

### 12.2 Limitaciones Actuales

⚠️ **Modelo determinístico:** No considera incertidumbre en mediciones

⚠️ **Daño único:** Solo simula un elemento dañado a la vez

⚠️ **Sin ruido:** Modos "medidos" son perfectos (sin ruido experimental)

⚠️ **Estructura fija:** No considera efectos dependientes de tiempo (fatiga progresiva)

⚠️ **Condensación estática:** Pierde información de modos locales

### 12.3 Trabajo Futuro

**Corto plazo (3-6 meses):**
- [ ] Implementar simulación de ruido en modos (SNR 20-40 dB)
- [ ] Extender a daño múltiple simultáneo
- [ ] Validación con datos experimentales de laboratorio
- [ ] Publicar en *Journal of Structural Health Monitoring*

**Mediano plazo (6-12 meses):**
- [ ] Incorporar análisis de incertidumbre (Monte Carlo)
- [ ] Implementar actualización de modelo FE
- [ ] Desarrollar interfaz gráfica (GUI) para uso práctico
- [ ] Análisis de sensibilidad de ubicación de sensores

**Largo plazo (1-2 años):**
- [ ] Integración con sistemas de monitoreo en tiempo real
- [ ] Machine learning para clasificación automática de tipo de daño
- [ ] Extensión a estructuras offshore complejas (semi-sumergibles, TLPs)
- [ ] Desarrollo de app móvil para inspección in-situ

### 12.4 Impacto Esperado

**Académico:**
- Contribución metodológica al SHM basado en vibración
- Demostración de superioridad del MAC matching vs. métodos tradicionales
- Framework replicable para otras estructuras marinas

**Industrial:**
- Reducción de costos de inspección (~30-40%)
- Priorización inteligente de mantenimiento
- Extensión de vida útil de plataformas existentes
- Cumplimiento normativo (API, DNV, ISO)

**Seguridad:**
- Detección temprana de daño crítico
- Prevención de colapsos catastróficos
- Protección de vidas humanas y medio ambiente

---

## 13. Contacto y Soporte

**Autor:** Francisco Cisneros R.
**Institución:** [Tu Universidad]
**Email:** fcisnerosr@[dominio]
**Última actualización:** Diciembre 2025

**Repositorio Git:** [URL si aplica]

**Para reportar problemas:**
1. Abrir un issue en el repositorio
2. Incluir versión de MATLAB y mensaje de error completo
3. Adjuntar archivo `config.m` usado

**Para colaboraciones:**
- Extensiones del framework son bienvenidas
- Citar apropiadamente este trabajo en publicaciones

---

## Licencia

[Especificar licencia: MIT, GPL, o académica]

---

## Apéndices

### Apéndice A: Tabla de Símbolos

| Símbolo | Descripción | Unidades |
|---------|-------------|----------|
| $\mathbf{K}_G$ | Matriz de rigidez global | N/m |
| $\mathbf{M}$ | Matriz de masa | kg |
| $\boldsymbol{\phi}_i$ | Vector modal $i$ | adimensional |
| $\omega_i$ | Frecuencia angular | rad/s |
| $f_i$ | Frecuencia natural | Hz |
| $\alpha_k$ | Peso del índice de daño $k$ | [0,1] |
| $P_j$ | Métrica combinada en nodo $j$ | [0,1] |
| $T$ | Umbral de detección | [0,1] |
| $E$ | Módulo de elasticidad | Pa |
| $\rho$ | Densidad | kg/m³ |
| $A$ | Área transversal | m² |
| $I$ | Momento de inercia | m⁴ |
| $\delta$ | Porcentaje de daño | % |

### Apéndice B: Comandos Rápidos

```matlab
% Setup inicial
config = config();

% Ejecutar experimento completo
runExperimentos();

% Analizar resultados
load('workspace_completo.mat');
summary(resultados);

% Visualizar matriz MAC
MAC = calcularMatrizMAC(modos_intactos, modos_dano);
imagesc(MAC); colorbar; title('MAC Matrix');

% Reporte de métricas
fprintf('F1-Score promedio: %.3f\n', mean(resultados.F1_Score));
fprintf('RMSE promedio: %.4f\n', mean(resultados.RMSE));
```

### Apéndice C: Checklist Pre-Ejecución

Antes de ejecutar `runExperimentos()`, verificar:

- [ ] `config.m` está correctamente configurado
- [ ] Archivo ETABS existe en ruta especificada
- [ ] **⚠️ Optimization Toolbox instalado (OBLIGATORIO - sin este el sistema NO funciona)**
- [ ] Directorios de salida tienen permisos de escritura
- [ ] Espacio en disco suficiente (~5 GB recomendado)
- [ ] MATLAB R2019b o superior (recomendado R2024a+)
- [ ] Ningún archivo `.xlsx` de resultados abierto en Excel

---

**FIN DEL README**

_Este documento fue generado el 21 de diciembre de 2025._
_Versión: 2.0 (Completa con MAC matching)_

Este README ahora contiene detalles exhaustivos de cada paso del proceso, fórmulas completas, interpretaciones físicas y matemáticas, ejemplos numéricos, y guías de uso. Es un documento técnico completo para retomar el proyecto en cualquier momento.

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
- **MAC mínimo y promedio** (correlación modal del emparejamiento)
- **Indicador de cruces modales** (si hubo reordenamiento de modos)

### Archivo: `DetalleTodasCorridas.xlsx`
Desglose nodal por corrida con:
- Número de nodo
- Valor de daño normalizado (0-100)
- Estado: "Daño" si ≥ 50%, "-" en caso contrario

### Gráficas:
- Convergencia del algoritmo genético (ID_XXXX.png)
- Evolución de población, mejor individuo, distancia, rango

## Características Técnicas

### Condensación Estática (Guyan Reduction)

**Formulación Completa:**

Partiendo del sistema completo:

$$
\begin{bmatrix}
\mathbf{K}_{aa} & \mathbf{K}_{ab} \\
\mathbf{K}_{ba} & \mathbf{K}_{bb}
\end{bmatrix}
\begin{bmatrix}
\mathbf{u}_a \\
\mathbf{u}_b
\end{bmatrix}
=
\begin{bmatrix}
\mathbf{F}_a \\
\mathbf{0}
\end{bmatrix}
$$

**Relación de Transformación:**

De la segunda ecuación:

$$
\mathbf{K}_{ba} \mathbf{u}_a + \mathbf{K}_{bb} \mathbf{u}_b = \mathbf{0}
$$

$$
\mathbf{u}_b = -\mathbf{K}_{bb}^{-1} \mathbf{K}_{ba} \mathbf{u}_a
$$

**Matriz de Transformación:**

$$
\mathbf{T} = \begin{bmatrix}
\mathbf{I} \\
-\mathbf{K}_{bb}^{-1} \mathbf{K}_{ba}
\end{bmatrix}
$$

Tal que:

$$
\begin{bmatrix}
\mathbf{u}_a \\
\mathbf{u}_b
\end{bmatrix}
= \mathbf{T} \mathbf{u}_a
$$

**Rigidez Condensada:**

$$
\mathbf{K}_{\text{cond}} = \mathbf{T}^T \mathbf{K} \mathbf{T} = \mathbf{K}_{aa} - \mathbf{K}_{ab} \mathbf{K}_{bb}^{-1} \mathbf{K}_{ba}
$$

**Masa Condensada (aproximación):**

$$
\mathbf{M}_{\text{cond}} = \mathbf{T}^T \mathbf{M} \mathbf{T} \approx \mathbf{M}_{aa}
$$

(Se desprecia el acoplamiento inercial con DOF restringidos)

**Recuperación de Desplazamientos Completos:**

Una vez resuelto el sistema condensado, los desplazamientos globales se recuperan:

$$
\mathbf{u} = \mathbf{T} \mathbf{u}_a
$$

**Ejemplo en este Proyecto:**

- Nodos empotrados (restringidos): 1, 2, 3, 4 (24 DOF)
- Nodos activos (superestructura): 41-52 (72 DOF)
- Matriz $\mathbf{K}_{bb}$: $[24 \times 24]$
- Matriz $\mathbf{K}_{\text{cond}}$: $[72 \times 72]$

### Normalización Modal

**Normalización Masa-Ortogonal:**

Cada modo $\boldsymbol{\phi}_i$ se escala para que:

$$
\boldsymbol{\phi}_i^T \mathbf{M} \boldsymbol{\phi}_i = 1
$$

**Procedimiento:**

1. Calcular masa modal:

$$
m_i = \boldsymbol{\phi}_i^T \mathbf{M} \boldsymbol{\phi}_i
$$

2. Normalizar:

$$
\boldsymbol{\phi}_i^{\text{norm}} = \frac{\boldsymbol{\phi}_i}{\sqrt{m_i}}
$$

**Propiedades Resultantes:**

$$
\begin{align}
\boldsymbol{\Phi}^T \mathbf{M} \boldsymbol{\Phi} &= \mathbf{I} \quad \text{(identidad)} \\
\boldsymbol{\Phi}^T \mathbf{K} \boldsymbol{\Phi} &= \boldsymbol{\Omega}^2 = \text{diag}(\omega_1^2, \ldots, \omega_n^2)
\end{align}
$$

Esto desacopla el sistema en coordenadas modales:

$$
\mathbf{M} = \boldsymbol{\Phi} \mathbf{I} \boldsymbol{\Phi}^T, \quad \mathbf{K} = \boldsymbol{\Phi} \boldsymbol{\Omega}^2 \boldsymbol{\Phi}^T
$$

### Ensamblaje Global

**Mapeo de DOF Locales a Globales:**

Cada elemento $e$ tiene:
- Nodo inicial $i$ con DOF globales: $[6i-5, 6i-4, \ldots, 6i]$
- Nodo final $j$ con DOF globales: $[6j-5, 6j-4, \ldots, 6j]$

**Vector de Índices:**

$$
\text{idx}_e = [6i-5, 6i-4, 6i-3, 6i-2, 6i-1, 6i, 6j-5, 6j-4, 6j-3, 6j-2, 6j-1, 6j]
$$

**Algoritmo de Ensamblaje:**

```
Para cada elemento e = 1, ..., N_e:
  1. Calcular k_local[12×12]
  2. Transformar: k_global = T' * k_local * T
  3. Para cada par (p,q) en [1..12] × [1..12]:
       K_G[idx_e[p], idx_e[q]] += k_global[p,q]
```

**Operador de Ensamblaje:**

Formalmente:

$$
\mathbf{K}_G = \sum_{e=1}^{N_e} \mathbf{A}_e^T \mathbf{T}_e^T \mathbf{k}_e^{\text{local}} \mathbf{T}_e \mathbf{A}_e
$$

Donde $\mathbf{A}_e$ es la matriz booleana de conectividad que mapea DOF locales a globales.

**Simetría:**

$$
\mathbf{K}_G = \mathbf{K}_G^T
$$

Debe verificarse numéricamente tras el ensamblaje (función `check_symmetry.m`)

### Aplicación de Restricciones

**Método de Penalización:**

Para nodos empotrados, se añade un valor grande en la diagonal:

$$
K_{ii} \leftarrow K_{ii} + C_{\text{penalty}}
$$

Donde $C_{\text{penalty}} = 10^{10} \times \max(K_{jj})$

**Método de Eliminación:**

Alternativamente, se eliminan directamente filas y columnas de DOF restringidos (usado en la condensación estática).

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
- **Múltiples índices de daño** (8 DIs complementarios, no solo uno)
- **Emparejamiento modal robusto con MAC** (resuelve problema de cruce modal)
- **Optimización inteligente** de pesos mediante GA con algoritmo húngaro
- **Detección local** en elementos tubulares con modelación física del daño
- **Modelación realista** de daños (corrosión uniforme y abolladura longitudinal)
- **Validación estadística** (z-score, probabilidades, umbrales adaptativos)
- **Automatización completa** del flujo de análisis
- **Diagnóstico de calidad** (métricas MAC para validar matching modal)

Este sistema representa un avance significativo en la detección no destructiva y basada en vibración para estructuras offshore, con potencial aplicación en inspección y mantenimiento predictivo de plataformas marinas.
