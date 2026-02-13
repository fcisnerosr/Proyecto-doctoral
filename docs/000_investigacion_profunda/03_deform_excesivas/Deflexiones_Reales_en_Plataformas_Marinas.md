# Análisis Técnico Exhaustivo de la Deflexión Global en Elementos Tubulares de Plataformas Jacket: Datos de Inspección, Mecánica del Daño y Distribución Espacial

## 1. Introducción a la Integridad Estructural y la Problemática de las Deformaciones Geométricas

La industria del petróleo y gas *offshore* se enfrenta a un desafío sin precedentes relacionado con el envejecimiento de su infraestructura crítica. Una vasta proporción de las plataformas fijas de acero tipo *Jacket* instaladas globalmente ha superado su vida útil de diseño original, típicamente estipulada entre 20 y 30 años.1 En este contexto de extensión de vida útil (*Life Extension*), la evaluación precisa de la integridad estructural no es meramente un ejercicio de cumplimiento normativo, sino una necesidad imperativa para garantizar la seguridad operativa y la prevención de desastres ambientales.

Entre las diversas amenazas que comprometen la capacidad de carga de estas estructuras, los daños mecánicos por impacto ocupan un lugar preponderante, siendo las colisiones de buques y la caída de objetos (*dropped objects*) las causas más frecuentes de alteraciones geométricas severas en los miembros tubulares.3

Este informe técnico tiene como objetivo principal diseccionar, con un nivel de detalle granular, el fenómeno de la deflexión global permanente —técnicamente denominada *global bow*, *out-of-straightness* (OOS) o falta de rectitud— en los elementos tubulares que conforman la subestructura de las plataformas.

A diferencia de los defectos de fabricación, que se mantienen dentro de tolerancias estrictas, las deflexiones inducidas por impacto introducen excentricidades masivas que alteran fundamentalmente el comportamiento del miembro bajo carga axial, exacerbando los momentos de segundo orden (efecto P-delta) y precipitando el pandeo prematuro.5

El análisis presentado a continuación se basa en una revisión exhaustiva de bases de datos de accidentes, como el *Worldwide Offshore Accident Databank* (WOAD) y los informes técnicos del *Health and Safety Executive* (HSE) del Reino Unido, así como en literatura académica avanzada sobre mecánica de colisiones y fiabilidad estructural. Se busca no solo identificar los rangos numéricos de estas deflexiones encontrados en inspecciones reales, sino también comprender su distribución espacial (nivel del mar frente al fondo marino) y las implicaciones directas para la capacidad residual de la estructura.

### 1.1. Definición y Caracterización de la Deflexión Global (Out-of-Straightness)

En el ámbito de la ingeniería *offshore*, la "falta de rectitud" o deflexión global se define como la desviación lateral máxima del eje neutro del miembro deformado respecto a la cuerda teórica que une sus nodos extremos.

Esta imperfección geométrica ($\delta$) se normaliza frecuentemente respecto a la longitud total del miembro ($L$) o su diámetro ($D$), proporcionando parámetros adimensionales ($\delta/L$ o $\delta/D$) que permiten la comparación entre diferentes configuraciones estructurales.7

Es crucial distinguir entre dos tipos de desviaciones:

* **Imperfecciones Iniciales de Construcción:** Son inherentes al proceso de fabricación y montaje. Las normas como API RP 2A e ISO 19902 establecen tolerancias estrictas, típicamente del orden de $\delta_0/L \approx 0.001$ (0.1%).8 Estas imperfecciones son tenidas en cuenta en las curvas de diseño de columnas (curvas de pandeo) y representan el estado "intacto" de la estructura.
* **Deflexiones por Daño Accidental:** Son deformaciones plásticas permanentes resultantes de eventos de alta energía. Estas deflexiones suelen ser órdenes de magnitud mayores que las tolerancias de fabricación y vienen acompañadas casi invariablemente de daños locales en la sección transversal, conocidos como abolladuras (*dents*).10

La interacción entre la abolladura local y la deflexión global es compleja. Mientras que la abolladura reduce el momento de inercia local y provoca concentraciones de tensión, la deflexión global reduce la rigidez axial del miembro y amplifica los momentos flectores globales bajo cargas de compresión. En inspecciones reales, es común encontrar miembros que presentan ambos modos de daño simultáneamente, lo que complica significativamente la evaluación de su capacidad remanente.12

## 2. Mecánica del Impacto y Génesis de la Deformación Global

Para interpretar correctamente los datos estadísticos de inspección, es fundamental comprender primero los mecanismos físicos que generan la deflexión global. La magnitud de la deformación final no es aleatoria, sino el resultado determinista de la disipación de energía cinética a través del trabajo plástico de la estructura.

### 2.1. Dinámica de la Colisión Buque-Plataforma

El escenario de impacto más común y estudiado es la colisión de un buque de suministro (*Offshore Supply Vessel*, OSV) contra una riostra (*brace*) o una pierna (*leg*) de la *Jacket*. La energía cinética involucrada en tales eventos es considerable; un buque de 5,000 toneladas desplazándose a una velocidad de deriva de 2 m/s posee una energía cinética aproximada de 11 a 14 MJ, considerando la masa añadida hidrodinámica.6

Cuando esta energía se transfiere a un miembro tubular, la respuesta estructural pasa por fases secuenciales:

1.  **Fase de Abolladura Local (Local Denting):** Inicialmente, la pared del tubo se deforma localmente bajo la zona de contacto. Esta fase absorbe energía mediante la deformación de la sección transversal.
2.  **Fase de Flexión Global (Global Bending):** A medida que la resistencia a la abolladura aumenta (o si el impactador golpea cerca de un nodo), el miembro comienza a deformarse globalmente como una viga. Si la carga supera el momento plástico de la sección, se forma un mecanismo de colapso plástico, típicamente un mecanismo de tres articulaciones (una en el punto de impacto y dos en los extremos empotrados).10
3.  **Fase de Tensión de Membrana:** En deflexiones muy grandes (superiores al diámetro del tubo), el miembro desarrolla fuerzas de tracción de membrana que ayudan a resistir la carga lateral, siempre que las conexiones en los extremos (nodos) sean capaces de soportar dicha tensión.14

La literatura indica que la transición entre el daño local y la deflexión global depende críticamente de la rigidez relativa del miembro y del impactador. La investigación de Amdahl y otros sugiere que para impactos de buques con proas o costados "blandos", la deformación global de la plataforma es limitada, pero si el impacto ocurre con partes rígidas (como el bulbo de proa o la popa reforzada), la deflexión global del miembro tubular se convierte en el mecanismo dominante de absorción de energía.7

### 2.2. El Efecto de la Precarga Axial en la Magnitud de la Deflexión

Un factor crítico a menudo subestimado en el diseño simplificado, pero vital en el análisis forense de daños, es el estado de carga del miembro en el momento del impacto. La mayoría de los elementos de una *Jacket* están sometidos a cargas axiales de compresión debido al peso de la cubierta (Topside) y a las cargas ambientales.

Investigaciones experimentales detalladas, como las presentadas en 5 y 5, demuestran que la precarga axial tiene un efecto dramático en la magnitud de la deflexión global resultante. Un miembro pre-comprimido sufre una amplificación de la deformación lateral debido al efecto P-delta (el momento secundario generado por la carga axial actuando sobre la deflexión lateral creciente).

* **Resultados Experimentales:** Se ha observado que la presencia de precarga axial reduce significativamente la capacidad de absorción de energía antes del colapso. Esto significa que, para una misma energía de impacto (por ejemplo, una colisión de barco estándar), un miembro comprimido sufrirá una **deflexión global final mucho mayor** que un miembro descargado, o podría colapsar catastróficamente bajo la carga estática combinada con el impacto dinámico.5
* **Implicación para la Inspección:** Esto sugiere que los inspectores deben esperar encontrar mayores valores de "out-of-straightness" en las piernas principales (*legs*) y en las riostras verticales comprimidas que en los miembros horizontales o en tracción, asumiendo escenarios de impacto similares.

## 3. Análisis Estadístico de Datos de Inspección: Valores Reales de Deflexión

La recopilación de datos empíricos sobre la magnitud de las deflexiones globales es un desafío debido a la naturaleza confidencial de los informes de inspección de los operadores. Sin embargo, los metaanálisis realizados por organismos reguladores y la investigación académica sobre bases de datos de accidentes proporcionan una visión cuantitativa robusta.

### 3.1. Base de Datos WOAD y HSE OTO: Frecuencia y Severidad

El informe OTO 2001/063 del HSE y sus actualizaciones subsecuentes (como el RR1154) analizan incidentes en la Plataforma Continental del Reino Unido (UKCS). Los datos revelan que, si bien las colisiones son frecuentes, la distribución de la severidad del daño es altamente asimétrica.3

* **Volumen de Incidentes:** Entre 1975 y 2001, se registraron 557 colisiones de buques. De estas, aproximadamente el 15% (86 incidentes) resultaron en daño estructural "moderado o severo".
* **Definición de Daño Severo:** En este contexto, "severo" a menudo implica la necesidad de reparación estructural inmediata, lo que correlaciona con deflexiones globales que comprometen la estabilidad del miembro.
* **Tendencia de "Passing Vessels":** Aunque solo hubo 8 colisiones con buques mercantes "de paso" (*passing vessels*), estos eventos tienen el potencial de causar daños catastróficos totales. Sin embargo, la gran mayoría de los datos de deformación provienen de buques "de campo" (*in-field vessels*), como los de suministro (OSVs).15

### 3.2. Rangos de Valores de Deflexión Global (Out-of-Straightness)

A partir de la síntesis de múltiples estudios de caso, pruebas experimentales a escala real y reportes de integridad estructural 7, se pueden establecer los siguientes rangos de valores observados para la deflexión global ($\delta$) normalizada por la longitud del miembro ($L$):

#### 3.2.1. Línea Base: Imperfecciones de Fabricación
Antes de evaluar el daño, es esencial establecer el "cero".
* **Valor Típico Medido:** $\delta/L \approx 0.0003 - 0.0010$ (0.03% - 0.10%).
* **Tolerancia Normativa (API/ISO):** $\delta/L \le 0.0015$ (0.15%). Cualquier medición por debajo del 0.15% se considera generalmente dentro de las tolerancias de construcción y no se clasifica como daño por impacto a menos que haya evidencia visual corroborativa (rayaduras, pintura saltada).8

#### 3.2.2. Daños Leves a Moderados (Impactos de Baja Energía)
Este es el rango más común encontrado en inspecciones rutinarias, a menudo asociado con maniobras de atraque torpes.
* **Rango Observado:** $\delta/L \approx 0.2\% - 0.5\%$.
* **Características:** A menudo acompañados de abolladuras locales menores ($d/D < 5\%$). Aunque exceden la tolerancia de fabricación, estos miembros frecuentemente retienen suficiente capacidad residual para permanecer en servicio sin reparación inmediata, dependiendo de su factor de utilización (Unity Check) original.17

#### 3.2.3. Daños Significativos (Colisiones Operativas)
En este rango, la integridad del miembro está claramente comprometida.
* **Rango Observado:** $\delta/L \approx 0.5\% - 1.5\%$.
* **Implicaciones:** Una deflexión del 1% en una riostra de 20 metros equivale a 20 cm de desplazamiento lateral. Esto genera momentos de segundo orden masivos. Los estudios de fiabilidad indican que este nivel de imperfección puede reducir la capacidad de carga axial en más del 30-40%.18

#### 3.2.4. Daños Severos y Extremos (Casos Documentados)
La literatura proporciona datos específicos de "valores atípicos" (*outliers*) que representan el límite superior de lo que se puede encontrar en una estructura que no ha colapsado totalmente.
* **Caso de Estudio del Golfo Pérsico:** Se documenta un análisis de una plataforma existente donde se modeló un daño consistente en una abolladura del 22% del diámetro y una **deflexión lateral permanente del eje neutro de 0.68 metros**. Para la longitud del miembro en cuestión, esto representaba una relación $\delta/L$ del **3.2%**.7
* **Significado del 3.2%:** Este valor es extremadamente alto. Físicamente, implica que el miembro ha desarrollado articulaciones plásticas completas y ha entrado profundamente en el régimen de grandes deformaciones. En la mayoría de los análisis de redundancia (*pushover*), un miembro con este nivel de deformación se considera efectivamente "fallido" o con capacidad de carga nula para propósitos de compresión, actuando solo como un elemento de tensión (catenaria) si las conexiones lo permiten.

### 3.3. Correlación Estadística: Profundidad de Abolladura vs. Deflexión Global

Los datos de inspección muestran una fuerte correlación positiva entre la profundidad de la abolladura local ($d/D$) y la deflexión global ($\delta/L$). Es raro encontrar una deflexión global severa sin una abolladura local significativa, ya que la fuerza requerida para doblar plásticamente el miembro globalmente generalmente excede la resistencia local de la pared del tubo.12

Las fórmulas empíricas desarrolladas por investigadores como J.K. Paik y otros permiten estimar una variable en función de la otra si los datos de inspección son incompletos. Por ejemplo, en impactos de colisión lateral, una abolladura profunda tiende a actuar como un "fusible" que absorbe energía, pero si el miembro es lo suficientemente esbelto, la energía restante se canaliza hacia la deflexión global. Los datos experimentales sugieren que para miembros con alta esbeltez (ratio $L/r$ alto), la deflexión global domina el modo de fallo, mientras que en miembros robustos (stocky), domina la abolladura local.11

## 4. Distribución Espacial del Daño: Nivel del Mar vs. Fondo

La ubicación vertical del daño es un parámetro crítico que determina no solo la probabilidad de detección, sino también las causas probables y la severidad potencial. El análisis de los informes técnicos permite establecer una zonificación clara del riesgo.

### 4.1. Zona de Salpicadura y Nivel del Mar (+10m a -15m)

Esta zona representa el "punto caliente" (*hotspot*) estadístico para daños por impacto.

* **Frecuencia:** Muy Alta. La gran mayoría de los incidentes registrados en las bases de datos (WOAD, HSE) ocurren en esta franja.15
* **Causa Dominante:** Colisiones de buques de suministro y servicio (*Attendant Vessels*). Estos barcos operan diariamente en la proximidad inmediata de la estructura para transferencia de carga y personal.
* **Mecanismo:** El impacto suele ocurrir por error de maniobra, fallo de posicionamiento dinámico (DP) o deriva en mal tiempo. Las zonas de impacto se concentran en las áreas de atraque (*boat landings*) y las piernas adyacentes.
* **Rango de Profundidad:** Típicamente entre el nivel de marea astronómica más bajo (LAT) y la altura de la cubierta de los buques. Sin embargo, es crucial notar que los buques modernos con **bulbos de proa** (*bulbous bows*) pueden infligir daños significativos por debajo de la línea de flotación, hasta -10m o -15m, una zona que podría no ser inspeccionada visualmente desde la superficie.19
* **Magnitud del Daño:** Dado que las velocidades de impacto suelen ser bajas (maniobra), las deflexiones globales suelen estar en el rango "Moderado" (0.5% - 1.0%), aunque impactos a velocidad de servicio (2 m/s) pueden causar daños "Severos".21

### 4.2. Zona Intermedia y Profunda (Subsea / Seabed)

Aunque la frecuencia de impactos disminuye drásticamente con la profundidad, los daños en estas zonas presentan características únicas y desafíos severos para la integridad.

* **Frecuencia:** Baja a Media-Baja.
* **Causa Dominante 1: Objetos Caídos (Dropped Objects).** Durante las operaciones de grúa, objetos como tuberías de perforación (*drill pipes*), *containers*, preventores de reventones (BOPs) o andamios pueden caer al mar. La trayectoria de caída en el agua es impredecible; objetos planos o tubulares pueden "planear" y desviarse lateralmente, golpeando miembros diagonales profundos o las piernas de la *jacket* lejos de la vertical de la grúa.22 Existe un efecto de "apantallamiento" (*shielding*): los miembros superiores protegen a los inferiores, reduciendo la probabilidad de impacto en el fondo, excepto para objetos que caen por el perímetro exterior.23
* **Causa Dominante 2: Colisiones de Submarinos.** Este es un riesgo de baja probabilidad pero de consecuencias extremas. El caso documentado más notable es el de la plataforma *Oseberg B* en el Mar del Norte (1988), que fue golpeada por un submarino alemán a **25 metros de profundidad**.
    * **Consecuencias del Caso Oseberg B:** El impacto causó una deflexión global masiva y distorsión en una riostra diagonal principal. Debido a la inmensa masa del submarino, la energía transferida fue enorme, resultando en la necesidad de reemplazar el miembro completo mediante corte y soldadura hiperbárica, una operación extremadamente costosa y compleja.13
* **Magnitud del Daño:** Los objetos caídos pesados (como un BOP) pueden tener una energía cinética terminal muy alta, capaz de causar deflexiones globales locales severas o incluso la ruptura completa (cizallamiento) del miembro impactado cerca de los nudos.

### 4.3. Comparativa Estructurada de Ubicación y Daño

La siguiente tabla resume la correlación entre la ubicación, la causa y la magnitud típica de la deflexión global, basada en la síntesis de los datos:

| Ubicación Vertical | Causa Principal | Frecuencia Relativa | Magnitud Típica de Deflexión Global ($\delta/L$) | Detectabilidad |
| :--- | :--- | :--- | :--- | :--- |
| **Zona de Salpicadura** (+5m a -5m) | Buques de Suministro (Popa/Costado) | Muy Alta | **0.2% - 1.5%**. Frecuentes daños acumulativos. | Alta (Visual diaria) |
| **Sub-superficie** (-5m a -15m) | Buques con Bulbo de Proa | Media | **0.5% - 2.0%**. Impactos de alta energía (proa rígida). | Media (Requiere buceo/ROV) |
| **Profundidad Intermedia** (-20m a -50m) | Objetos Caídos, Submarinos (Raro) | Baja | **Variable**. Desde abolladuras puntuales hasta colapso global (>3%) en caso de submarinos. | Baja (Inspección dirigida) |
| **Fondo Marino** (Base) | Objetos Caídos Pesados (BOP, Pilotes) | Muy Baja | **Baja**. Generalmente daño local severo o ruptura, menos deflexión global. | Muy Baja (ROV específico) |

## 5. Impacto en la Capacidad Residual y Fiabilidad Estructural

La cuantificación de la deflexión global no es un fin en sí mismo, sino un input para evaluar la aptitud para el servicio (*Fitness-for-Service*) de la plataforma. La presencia de estas imperfecciones degrada la fiabilidad de la estructura.

### 5.1. Reducción de la Resistencia al Pandeo

La deflexión global ($\delta$) actúa como una excentricidad inicial amplificada. Según la teoría de columnas y las normativas (ISO 19902), la capacidad de carga axial ($P_u$) de un miembro tubular se reduce drásticamente con el aumento de $\delta$. Un aumento de la deflexión inicial del 0.1% al 0.2% puede resultar en una disminución del 15% al 20% en la resistencia a la compresión para miembros de esbeltez media, típicos en *Jackets*.18

Para deflexiones mayores (>1%), la capacidad de soportar carga axial se vuelve insignificante, y el miembro pasa a comportarse puramente a flexión o tensión, forzando una redistribución de cargas hacia los miembros adyacentes (redundancia).

### 5.2. Evaluación Probabilística y Fiabilidad

Los estudios de fiabilidad modernos (*Reliability Analysis*) utilizan funciones de densidad de probabilidad (PDF) para modelar la incertidumbre en la magnitud del daño. Investigaciones recientes 25 han ajustado distribuciones estadísticas (como Weibull o Log-Normal) a los datos de deflexión y abolladura.

En el análisis de fiabilidad de sistemas dañados, se ha demostrado que la incertidumbre en la variable "out-of-straightness" tiene un impacto significativo en el índice de fiabilidad ($\beta$) global de la plataforma. Modelos avanzados de elementos finitos (como los descritos en 28 y 29) incorporan estas variables aleatorias para determinar la probabilidad de fallo bajo cargas extremas de oleaje o sismo, permitiendo a los operadores tomar decisiones informadas sobre la necesidad de reparaciones costosas versus la aceptación del riesgo.

## 6. Conclusiones y Recomendaciones Técnicas

El análisis integral de la información disponible permite extraer conclusiones sólidas para la gestión de la integridad de plataformas *Jacket*:

* **Magnitud Real del Daño:** Las inspecciones reales revelan que, si bien la mayoría de los daños son menores ($\delta/L < 0.5\%$), existen casos documentados de daños extremos con deflexiones superiores al **3.0%** de la longitud del miembro. Estos valores exceden por mucho las tolerancias de diseño y requieren intervenciones estructurales inmediatas.
* **Correlación Causa-Ubicación:** Existe una clara estratificación del riesgo. La **zona de salpicadura** es el área crítica para la acumulación de daños por colisión de buques (deflexiones moderadas frecuentes), mientras que las **zonas profundas** están expuestas a eventos de baja probabilidad pero alta consecuencia (objetos caídos, submarinos) que pueden causar deformaciones masivas y difíciles de detectar.
* **Importancia de la Medición Precisa:** Dada la sensibilidad de la capacidad de pandeo a pequeñas variaciones en la rectitud (un cambio del 0.1% al 0.2% reduce la fuerza un 20%), es vital utilizar técnicas de metrología submarina precisas (fotogrametría, láser) en lugar de estimaciones visuales aproximadas.
* **Evaluación Sistemática:** Se recomienda que cualquier deflexión global observada que supere el **0.3%** de la longitud del miembro desencadene automáticamente un análisis estructural de Nivel 2 o 3 (según API RP 2SIM) para verificar la capacidad residual y la redundancia del sistema, considerando explícitamente la interacción con abolladuras locales y el estado de precarga del miembro.

Este informe subraya que la integridad de las plataformas maduras depende de trascender las asunciones de diseño idealizadas y gestionar activamente las imperfecciones geométricas reales introducidas por la historia operativa de la estructura.

---
### Fuentes citadas

* **133:** TUBULAR STRENGTH COMPARISON OF OFFSHORE JACKET STRUCTURES UNDER API RP2A AND ISO 19902 - IEM Journal
* **134:** Structural Integrity Assessment of Aging Fixed Steel Offshore Jacket Platforms: A Persian Gulf Case Study - ResearchGate
* **135:** Ship/platform collision incident database (2001) - Planning Inspectorate
* **136:** Ship/Platform Collision Incident Database (2015) for offshore oil and gas installations
* **137:** Effect of impact damage on the capacity of tubular steel members of offshore structures
* **138:** Design of offshore structures against accidental ship collisions - ResearchGate
* **139:** Residual Strength of Damaged Marine Structures. - DTIC
* **140:** SSC-381 RESIDUA'L STRENGTH OF DAMAGED MARINE STRUCTURES
* **141:** ultiguide (BSEE Technical Assessment)
* **142:** Impact Damage And Assessment Of Offshore Tubulars - ResearchGate
* **143:** A comparative study on damage assessment of tubular members subjected to mass impact
* **144:** Request PDF - ResearchGate
* **145:** Structural Characteristics of Damaged Offshore Tubular Members - ResearchGate
* **146:** Ship collision with offshore structures - Jørgen Amdahl - USFOS
* **147:** Plastic and Elastic Responses of a Jacket Platform Subjected to Ship Impacts - Semantic Scholar
* **148:** SPC/enforcement/177 - Collision risk management - guidance on enforcement - HSE
* **149:** Structural Integrity Assessment of Corrosion-Damaged Offshore Tubular Braces Subjected to Inelastic Cyclic Loading
* **150:** Full article: Investigation and analysis of ship to platform collision incidents on the UK continental shelf - Taylor & Francis
* **151:** Structural Safety Evaluation of Steel Jacket Platforms
* **152:** Study on the assessment of absorbed energy of bulbous bow in ship collision - EUDL
* **153:** The impact analysis characteristics of a ship's bow during collisions - ResearchGate
* **154:** Ship Impact Analysis Offshore Jacket fixed Well Head Platform - ResearchGate
* **155:** Dropped Object Impact Analysis Considering Frequency and Consequence for LNG-FPSO Topside Module - MDPI
* **156:** JIP: Risk informed decision support in development projects (RISP) - Offshore Norge
* **157:** Quantitative Collision Risk Assessment of a Fixed-Type Offshore Platform with an Offshore Supply Vessel - UCL Discovery
* **158:** A Probability Distribution Model for the Degree of Bending In Tubular KT-Joints... - University of Tasmania
* **159:** Seismic Reliability of Marine Platforms with Mechanical Damage
* **160:** A Probability Distribution Model for the Degree of Bending In Tubular KT-Joints... - Semantic Scholar
* **161:** Assessment of Structural Integrity Through On-Site Decision-Making Analysis for a Jacket-Type Offshore Platform - MDPI
* **162:** Offshore Structural Reliability Assessment by Probabilistic Procedures—A Review - MDPI