# Informe de Investigación Técnica: Análisis Exhaustivo de la Integridad Estructural y la Cinética de la Corrosión Uniforme en Plataformas Offshore Tipo Jacket

**Subtítulo:** Evolución de la Pérdida de Espesor ($t_{loss}/t_{nom}$) y Evaluación de Vida Remanente

## Resumen Ejecutivo

El presente informe técnico constituye una monografía exhaustiva destinada a la evaluación de la integridad estructural de plataformas fijas de acero (tipo Jacket) frente al fenómeno de degradación por corrosión uniforme.

En un contexto industrial donde la extensión de vida útil (Life Extension) de activos envejecidos en cuencas maduras como el Mar del Norte, el Golfo de México y el Sudeste Asiático es una prioridad operativa, la cuantificación precisa de la pérdida de material se convierte en una variable estocástica crítica.

El informe se centra en la métrica adimensional de pérdida de espesor respecto al nominal inicial, denotada como la relación $\Phi = t_{loss}/t_{nom}$, analizando su variación en función de la zonificación vertical (atmosférica, salpicadura, marea, sumergida y subsuelo) y la edad cronológica de la instalación.

A través de la síntesis de datos empíricos provenientes de campañas de desmantelamiento (decommissioning) de activos mayores (campos Brent, Miller, Murchison, Ekofisk), y la contrastación con modelos predictivos avanzados (Yang et al., Melchers, Paik) y normativas internacionales (ISO 19902, API RP 2A-WSD, NORSOK N-006), se establece que la corrosión no sigue un modelo lineal determinista.

Por el contrario, se demuestra que la Zona de Salpicadura (*Splash Zone*) exhibe un comportamiento no lineal gobernado por distribuciones de Weibull, donde las tasas de corrosión pueden exceder en un 300% las previsiones de diseño tras la falla de los recubrimientos, impactando exponencialmente en la capacidad de carga última y la resistencia a colisiones.

Este documento desglosa la interacción entre la metalurgia, la microbiología marina y la mecánica estructural para proporcionar una base técnica sólida para la toma de decisiones en la gestión de integridad estructural (SIM).

---

## 1. Introducción: El Desafío de la Infraestructura Envejecida

La industria del petróleo y gas offshore se enfrenta a un desafío sin precedentes: la gestión de una flota global de estructuras fijas que han superado su vida útil de diseño original.

Las plataformas tipo Jacket, estructuras reticuladas de acero tubular ancladas al lecho marino mediante pilotes, fueron diseñadas típicamente para una vida operativa de 20 a 25 años. Sin embargo, debido a las técnicas de recuperación mejorada de petróleo (EOR) y al desarrollo de campos satélites (*tie-backs*), muchas de estas estructuras deben operar durante 40, 50 o incluso más años.

La degradación del material, específicamente la corrosión del acero estructural en un ambiente marino agresivo, es el principal mecanismo de deterioro dependiente del tiempo que amenaza la seguridad de estas instalaciones. A diferencia de la fatiga, que se manifiesta como agrietamiento en los nodos soldados debido a cargas cíclicas, la corrosión uniforme resulta en una pérdida directa de la sección transversal resistente, afectando la rigidez global, el periodo natural de vibración y la capacidad de colapso plástico de la estructura.

### 1.1 Definición y Alcance de la Corrosión Uniforme

La corrosión uniforme, o generalizada, se define como el adelgazamiento distribuido de la pared de los miembros tubulares. Aunque termodinámicamente el acero tiende a volver a su estado de óxido más estable, la cinética de esta reacción varía drásticamente según la disponibilidad de oxígeno, la temperatura, la salinidad y la protección aplicada.

Para efectos de evaluación de integridad estructural, la variable crítica no es la tasa de corrosión instantánea ($r_{corr}$), sino la integral de esta tasa en el tiempo, que determina el espesor remanente ($t_{rem}$) y la pérdida acumulada ($t_{loss}$).

La relación $t_{loss}/t_{nom}$ es fundamental porque los códigos de diseño y evaluación, como el **API RP 2A-WSD** [1] y la norma **ISO 19902** [2], establecen criterios de aceptación basados en la capacidad de la sección remanente para soportar cargas de diseño y accidentales.

### 1.2 La Importancia de la Zonificación Vertical

La heterogeneidad del ambiente marino exige una segmentación vertical de la estructura para un análisis preciso. La literatura técnica y las normativas, incluyendo **DNV-RP-B401** y **ISO 19902**, reconocen cinco zonas distintas de corrosión en una plataforma Jacket fija [3]:

* **Zona Atmosférica:** Situada muy por encima del nivel del mar, expuesta a aerosoles marinos salinos y alta humedad, pero sin inmersión directa.
* **Zona de Salpicadura (Splash Zone):** La región más crítica, definida por el rango de variación de la marea más la altura de ola significativa y la zona de *run-up*. Aquí, el acero está sometido a ciclos continuos de humectación y secado, alta oxigenación y el impacto mecánico del oleaje que puede dañar los recubrimientos.
* **Zona de Marea (Tidal Zone):** La franja entre la Bajamar Astronómica (LAT) y la Pleamar Astronómica (HAT).
* **Zona Sumergida (Submerged Zone):** La porción de la estructura permanentemente bajo el agua, donde la disponibilidad de oxígeno disminuye con la profundidad y la temperatura es más estable. Esta zona depende casi exclusivamente de la Protección Catódica (CP).
* **Zona de Subsuelo (Subsoil/Mud Zone):** La parte de la estructura (pilotes y bases de las patas) enterrada en el sedimento, donde las condiciones son anaeróbicas y el riesgo principal proviene de la Corrosión Influenciada Microbiológicamente (MIC).

---

## 2. Fenomenología y Modelado Matemático de la Corrosión

La predicción de la pérdida de espesor $t_{loss}$ ha evolucionado desde modelos lineales simples hasta complejos modelos estocásticos variantes en el tiempo. La precisión en este modelado es vital para evitar tanto el conservadurismo excesivo (que llevaría a refuerzos innecesarios) como el optimismo imprudente (que podría resultar en fallos catastróficos).

### 2.1 Limitaciones de los Modelos Lineales Tradicionales

Históricamente, el diseño de estructuras offshore asumía una tasa de corrosión constante ($r_{corr}$) una vez consumido el margen de corrosión o fallado el sistema de protección. La ecuación básica utilizada en muchas evaluaciones preliminares es:

$$t_{rem}(T) = t_{nom} - r_{corr} \cdot (T - T_{init})$$

Donde $T_{init}$ es el tiempo hasta la iniciación de la corrosión (vida del recubrimiento).

Sin embargo, estudios de **Southwell et al. (1965)** y revisiones posteriores de **Guedes Soares (1988)** demostraron que este enfoque lineal no captura la realidad física. En la zona de inmersión, la formación de capas de óxido y *biofouling* (crecimiento marino) puede actuar como una barrera difusiva, desacelerando la corrosión. Inversamente, en la zona de salpicadura, la erosión mecánica puede eliminar estas capas protectoras, manteniendo tasas altas o aceleradas [3].

### 2.2 El Modelo Zonal Variante en el Tiempo (Yang et al., 2019)

Uno de los avances más significativos en la literatura reciente es el "Modelo de Corrosión Zonal Variante en el Tiempo" propuesto por Yang et al., basado en datos forenses de la plataforma **Bohai No. 8** en China. Este modelo es crucial para nuestra investigación porque diferencia explícitamente las funciones de pérdida de espesor $d(T)$ (en mm) para cada zona vertical [3].

#### 2.2.1 Zona de Salpicadura: El Modelo Weibull

Para la zona crítica de salpicadura, Yang propone un modelo basado en la distribución de Weibull, que refleja tres fases: iniciación lenta, aceleración rápida tras el fallo del recubrimiento, y desaceleración final por acumulación de productos de corrosión (si no son lavados).

$$d(T)_{splash} = D_{\infty} \left\{ 1 - \exp \left[ - \left( \frac{T}{\vartheta} \right)^\gamma \right] \right\}$$

Con parámetros calibrados empíricamente:
* $D_{\infty} = 10$ mm (Límite asintótico de corrosión profunda)
* $\vartheta = 20.9153$ (Parámetro de escala)
* $\gamma = 1.8052$ (Parámetro de forma)

Este modelo implica que la corrosión no es infinita; existe un límite físico donde la capa de óxido es tan gruesa que detiene la reacción, a menos que sea removida mecánicamente. Sin embargo, para una vida útil típica de 30 años, la curva está en su fase de crecimiento activo [3].

#### 2.2.2 Zonas Sumergida, Atmosférica y Subsuelo

Para las otras zonas, debido a la falta de datos de alta resolución o a la naturaleza más estable del entorno, el estudio de Yang retiene aproximaciones lineales, pero con tasas calibradas que difieren de los estándares de diseño genéricos:

* **Atmosférica:** $d(T) = 0.05 T$
* **Marea:** $d(T) = 0.1244 T$
* **Sumergida:** $d(T) = 0.0516 T$
* **Subsuelo:** $d(T) = 0.05 T$

> **Insight Analítico:** La diferencia de magnitud es notable. A los 20 años, la pérdida predicha en la zona de salpicadura según el modelo Weibull es aproximadamente **6.02 mm**, mientras que en la zona sumergida es solo **1.03 mm**. Esto significa que la relación $t_{loss}/t_{nom}$ en la zona de salpicadura degradará la capacidad estructural 6 veces más rápido que en las partes sumergidas, convirtiendo a la "cintura" de la plataforma en el punto de falla más probable ante cargas laterales [3].

### 2.3 El Modelo Fenomenológico de Melchers

El profesor Robert Melchers ha desarrollado modelos probabilísticos que son ampliamente aceptados para la corrosión marina a largo plazo [5]. Su modelo es multifásico:

1.  **Fase 0-1:** Control cinético (corrosión rápida inicial).
2.  **Fase 1-2:** Control por difusión de oxígeno (desaceleración debido a la capa de óxido).
3.  **Fase 3-4:** Fase anaeróbica. Aquí, Melchers introduce un factor crítico: la **Corrosión Influenciada Microbiológicamente (MIC)**.

Una vez que la capa de óxido es lo suficientemente gruesa para bloquear el oxígeno, las bacterias sulfato-reductoras (SRB) colonizan la interfaz metal-óxido, utilizando sulfatos como aceptores de electrones. Esto puede provocar un **aumento** repentino en la tasa de corrosión años después de la instalación [6]. Este fenómeno explica por qué algunas inspecciones de vida tardía (ej. >30 años) encuentran pérdidas de espesor inesperadas en zonas profundas o de subsuelo, contradiciendo los modelos que asumen una pasivación eterna [8].

---

## 3. Análisis de Datos Empíricos: Evidencia del Mar del Norte y Golfo de México

La teoría de modelos debe ser validada contra la realidad operativa. Los informes de la **Health and Safety Executive (HSE)** del Reino Unido, particularmente los derivados de los programas **KP3 (Key Programme 3 - Asset Integrity)** y **KP4 (Ageing and Life Extension)**, proporcionan la base de datos más robusta del mundo sobre degradación real.

### 3.1 Hallazgos del Programa KP3 de la HSE

El programa KP3 (2004-2007) y sus seguimientos revelaron un estado preocupante en muchas instalaciones del Mar del Norte. Se encontró que el mantenimiento de los tejidos de la estructura (*fabric maintenance*) había sido descuidado en favor de los sistemas de proceso.

* **Estado de los Conductores:** En plataformas como Leman Alpha, se documentaron fallos en los conductores de pozos debido a corrosión severa. Los conductores, al tener espesores de pared menores que las patas del jacket y estar sometidos a calor interno (fluidos de producción), mostraron tasas de corrosión acelerada [9].
* **Fallo de Revestimientos:** En la zona de salpicadura, se observó que los sistemas de pintura epóxica (*glass flake epoxy*) tienen una vida efectiva de 10-15 años. Más allá de este punto, la corrosión progresa rápidamente. Las tasas medidas en acero desnudo en esta zona oscilan entre **0.4 y 1.2 mm/año**, superando frecuentemente el margen de diseño estándar de 3-6 mm totales [10].

### 3.2 Estudios de Desmantelamiento (Forensic Decommissioning)

El desmantelamiento de grandes estructuras ofrece una oportunidad única para la "autopsia" estructural.

* **Caso de Estudio: Plataforma Miller (BP).** Se encontró una biomasa adherida equivalente al 10% del peso de la estructura en aire. Aunque esto aumenta la carga hidrodinámica (coeficientes de arrastre $C_d$), la densa capa de crecimiento marino en la zona sumergida actuó en algunos casos como una barrera física contra la corrosión [11]. A pesar de la edad, muchas zonas sumergidas mostraron espesores cercanos al nominal, validando la eficacia de los ánodos de sacrificio cuando están correctamente dimensionados [12].
* **Caso de Estudio: Plataforma Brent Delta (Shell).** La inspección de las estructuras de gravedad (GBS) y los jackets asociados reveló que la corrosión interna en celdas y patas inundadas es mínima debido al agotamiento rápido del oxígeno en el agua estancada ($t_{loss}$ interno $\approx$ 0) [13].
* **Caso de Estudio: Murchison (CNR).** La interacción con la pila de recortes de perforación (*cuttings pile*) generó un ambiente químico complejo en la base de la estructura. La preocupación principal fue la corrosión localizada en los pilotes y arriostramientos inferiores enterrados en los recortes contaminados con lodos base aceite, propensos a comunidades bacterianas agresivas (MIC) [15].

**Tabla 1: Comparativa de Tasas de Corrosión: Diseño vs. Realidad Forense (Mar del Norte)**

| Zona Vertical | Tasa de Diseño Típica (CP activo/Revestido) | Tasa Empírica Observada (Fallo de Protección) | Factor de Desviación | Mecanismo Dominante |
| :--- | :--- | :--- | :--- | :--- |
| **Atmosférica** | 0.05 - 0.1 mm/año | 0.1 - 0.3 mm/año | 2x - 3x | Salinidad, condensación, falta de mantenimiento. |
| **Salpicadura (Splash)** | 0.4 mm/año (Margen) | 0.8 - 1.5 mm/año | 2x - 4x | Oxigenación máx., impacto olas, daño mecánico. |
| **Marea (Tidal)** | 0.2 mm/año | 0.4 - 0.6 mm/año | 2x - 3x | Efecto abrasivo, biopelículas, ciclos húmedo/seco. |
| **Sumergida** | 0.0 - 0.1 mm/año | 0.1 - 0.5 mm/año | 1x - 5x | Baja por CP. Alta si hay MIC o apantallamiento. |
| **Subsuelo (Mud)** | < 0.05 mm/año | 0.1 - 0.2 mm/año (Local) | 2x - 4x | Actividad bacteriana anaeróbica (SRB). |

---

## 4. Marco Normativo y Criterios de Evaluación

La gestión de la corrosión está regida por estándares estrictos. Es fundamental contrastar cómo diferentes códigos abordan el problema de $t_{loss}$.

### 4.1 ISO 19902: Estructuras de Acero Fijas

La norma ISO 19902 es el estándar internacional predominante.
* **Zona de Salpicadura:** Exige un sobre-espesor de sacrificio además del sistema de pintura. No especifica una tasa única, pero refiere a normas locales (como NORSOK).
* **Reevaluación:** En la Sección 24 (*Assessment of Existing Structures*), permite el uso de propiedades de material y dimensiones "actuales" (medidas). Si $t_{medido} < t_{diseño}$, se debe realizar un análisis de resistencia última (US) para demostrar que la estructura puede soportar cargas ambientales extremas con factores de seguridad reducidos [2].

### 4.2 API RP 2A-WSD: Práctica Recomendada (EE.UU.)
* **Sección 17 (Assessment):** Introduce un enfoque basado en el riesgo para plataformas existentes, clasificándolas por consecuencia de fallo (L-1, L-2, L-3).
* **Criterio de Espesor:** No define un $t_{loss}$ máximo permitido universal, pero exige que los esfuerzos recalculados con la sección corroída no excedan los esfuerzos permisibles aumentados (*allowable stress increase*) [1].

### 4.3 NORSOK N-006 y M-001: El Enfoque Noruego
NORSOK representa el estándar más riguroso.
* **Fórmula de Diseño (M-001):** Para vidas de diseño ($DL$) > 17.5 años, el margen de corrosión en zona de salpicadura se calcula como:
    $$CA = (DL - T_{vida\_recubrimiento}) \times 0.4 \text{ mm/año}$$
    Esto establece 0.4 mm/año como la tasa base de diseño tras la falla del recubrimiento [19].
* **Evaluación (N-006):** Para la extensión de vida, si la corrosión medida excede las previsiones, se debe recalcular la probabilidad de fallo anual ($P_f$). El límite aceptable para $P_f$ en estado límite último (ULS) suele ser $10^{-4}$ o $10^{-5}$ anual [20].

> **Discrepancia Normativa:** Existe una clara brecha entre la tasa de diseño de NORSOK (0.4 mm/año) y las tasas extremas observadas en los estudios de HSE (hasta 1.2 mm/año).

---

## 5. Impacto Mecánico Estructural de la Pérdida de Espesor

La reducción de $t_{nom}$ no afecta a la resistencia estructural de manera lineal. La capacidad de los miembros tubulares es altamente sensible a la relación diámetro/espesor ($D/t$). Al disminuir $t$, aumenta la relación $D/t$, empujando al miembro hacia modos de fallo por inestabilidad elástica (pandeo local) antes de alcanzar la fluencia plástica.

### 5.1 Fórmulas de Reducción de Resistencia Residual

Investigaciones recientes [21] han derivado factores de reducción empíricos. Una formulación clave define el factor de reducción de resistencia $\rho_c$ como:

$$\rho_c = 0.91 \times \exp(-44.62 V_{non})$$

Donde $V_{non}$ es la relación volumétrica de corrosión (volumen perdido / volumen inicial). Esta fórmula se integra en la ecuación de interacción de colapso:

$$\left( \frac{P_c}{\rho_c \rho_L P_L} + \dots \right)^2 + \dots = 1$$

Donde $P_c$ es la presión de colapso residual. Esto demuestra que la corrosión uniforme no solo reduce el área axial ($A = \pi D t$), sino que penaliza severamente la resistencia al pandeo ($P_L, P_{OA}$) al amplificar los efectos de las imperfecciones geométricas iniciales [21].

### 5.2 Vulnerabilidad ante Impactos de Buques (Ship Collision)

Las plataformas Jacket están expuestas al riesgo de colisión con buques de suministro. La corrosión exacerba dramáticamente las consecuencias. Simulaciones no lineales utilizando ABAQUS muestran que la profundidad de indentación tras un impacto es directamente proporcional a la tasa de corrosión.

* **Dato Cuantitativo:** En escenarios de impacto de proa (*forecastle impacts*), el efecto acumulado de un segundo impacto en una estructura corroída es equivalente a añadir **10 años adicionales** de degradación corrosiva instantánea en términos de reducción de capacidad última [3].

### 5.3 Reducción del Ratio de Resistencia de Reserva (RSR)

El *Reserve Strength Ratio* (RSR) es el indicador global de la salud de la plataforma, definido como:

$$RSR = \frac{\text{Carga de Colapso Base (Base Shear)}}{\text{Carga Ambiental de Diseño (100-yr)}}$$

Estudios de sensibilidad [24] indican que la corrosión en la zona de salpicadura es el factor dominante en la degradación del RSR. Una reducción del 10% en el espesor de los miembros de esta zona puede resultar en una caída del RSR superior al **15-20%**, debido a la redistribución de esfuerzos hacia miembros adyacentes debilitados (efecto *zipper*) [25].

---

## 6. Evolución Temporal de la Relación $t_{loss}/t_{nom}$ por Edad

Basándonos en la integración de los modelos de Yang, Paik y los datos de HSE, trazamos la evolución esperada del daño porcentual.

**Fase 1: Vida Temprana (0 - 15 Años)**
* **Zona Salpicadura:** $t_{loss} \approx 0 - 1$ mm. Recubrimiento intacto.
* **Integridad:** $t_{loss}/t_{nom} < 4\%$. RSR estable.

**Fase 2: Transición y Degradación (15 - 25 Años)**
* **Zona Salpicadura:** Fallo del recubrimiento. Inicio modelo Weibull (0.4 - 0.8 mm/año).
* **Pérdida:** $t_{loss}$ acumulado: 3 - 5 mm.
* **Integridad:** $t_{loss}/t_{nom}$: 12 - 20%. Reducción medible del RSR.

**Fase 3: Vida Extendida y Envejecimiento (> 25 Años)**
* **Zona Salpicadura:** Corrosión plenamente desarrollada o acelerada por erosión (0.8 - 1.2 mm/año).
* **Pérdida:** $t_{loss}$ acumulado: > 8 - 10 mm.
* **Integridad:** $t_{loss}/t_{nom}$: **30 - 40%**. Situación crítica. Riesgo de perforación en miembros secundarios [3].

---

## 7. Estrategias de Gestión de Integridad y Mitigación

### 7.1 Inspección Basada en Riesgo (RBI)
El enfoque RBI desplaza los recursos a áreas de alta probabilidad de fallo. En la zona de salpicadura, se utilizan técnicas de *Rope Access* o UAVs (drones) para escaneo láser de pérdida de volumen.

### 7.2 Retrofit de Protección Catódica
Para la zona sumergida, la instalación de "Anode Sleds" (trineos de ánodos) en el lecho marino es la solución estándar. El caso de la plataforma **Thistle Alpha** demuestra la complejidad de estas operaciones [27].

### 7.3 Reparación Estructural
Cuando $t_{loss}/t_{nom}$ excede los límites de seguridad:
* **Grouted Clamps:** Abrazaderas cementadas para transferir carga.
* **Member Replacement:** Reemplazo de miembros, complejo y costoso en zona de salpicadura [28].

---

## 8. Conclusiones

1.  **La Zona de Salpicadura es el Talón de Aquiles:** Con pérdidas que pueden alcanzar el 40% del nominal, esta zona controla la probabilidad de fallo global.
2.  **Insuficiencia de Modelos Lineales:** Es imperativo adoptar modelos no lineales (Yang, Melchers) para evaluaciones de extensión de vida.
3.  **Disparidad Normativa:** Existe una "brecha de corrosión" entre las tasas de diseño (0.4 mm/año) y las tasas forenses (1.2 mm/año).
4.  **Sensibilidad Estructural Exponencial:** Una reducción moderada de $t$ precipita una caída drástica en el RSR.
5.  **Valor de los Datos Forenses:** La zona sumergida suele comportarse mejor de lo predicho gracias al CP, permitiendo enfocar recursos en la zona de salpicadura.

---

## Referencias

[1] API Recommended Practice 2A-WSD. https://www.api.org/~/media/files/publications/whats%20new/2a-wsd_e22%20pa.pdf
[2] ISO 19902: Fixed Steel Offshore Structures. http://www.jstra.jp/html/PDF/ISO_19902_2007.pdf
[3] A numerical investigation into the strength of offshore jacket platforms considering time-variant zonal corrosion. NIH. https://pmc.ncbi.nlm.nih.gov/articles/PMC11681870/
[5] Professor Robert Melchers / Staff Profile. https://www.newcastle.edu.au/profile/rob-melchers
[6] Recent Progress in the Modeling of Corrosion of Structural Steel Immersed in Seawaters. ASCE.
[8] Material Risk - Ageing Offshore Installations Report No. 2006-3496. Havtil.
[9] Key programme final reports - HSE.
[10] Review of corrosion monitoring and prognostics in offshore wind turbine structures. Frontiers.
[11] Miller Decommissioning Programme | BP.
[12] CATHODIC PROTECTION OF OFFSHORE STRUCTURES - ABS.
[13] Brent Delta Topside Decommissioning Close-out Report. GOV.UK.
[15] MURCHISON DECOMMISSIONING COMPARATIVE ASSESSMENT REPORT. GOV.UK.
[19] NORSOK STANDARD M-001 Materials selection.
[20] New Standard for Assessment of Structural Integrity for Existing Load-Bearing Structures-Norsok N-006.
[21] Development of a Design Formula for Estimating the Residual Strength. MDPI.
[24] Assessment of Aged Offshore Jacket Type Platforms Considering Environmental Loads.
[25] Investigation of the corrosion factor to the global strength of aging offshore jacket platforms.
[27] Thistle Upper Jacket and Associated Riser Sections Decommissioning Programmes.
[28] Structural Evaluation of Repair Methods on Dented Tubular Members.