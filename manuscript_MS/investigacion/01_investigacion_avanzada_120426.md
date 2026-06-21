# Avances en el Monitoreo de Salud Estructural de Plataformas Offshore Tipo Jacket: Optimización Inversa mediante Algoritmos Genéticos y Métricas de Localización Topológica (2018-2026)

La infraestructura energética global, en su transición hacia fuentes renovables y la optimización de los activos de hidrocarburos existentes, enfrenta el desafío crítico de garantizar la integridad de las estructuras marinas en entornos cada vez más hostiles. Las plataformas tipo jacket, caracterizadas por su configuración de celosía espacial de acero, constituyen la columna vertebral de las instalaciones de petróleo y gas en aguas someras y medias, así como de la creciente industria de la energía eólica marina (offshore wind). Entre los años 2018 y 2026, el campo del Monitoreo de Salud Estructural (SHM, por sus siglas en inglés) ha experimentado una transformación paradigmática, migrando de inspecciones visuales periódicas hacia sistemas de diagnóstico en tiempo real basados en datos, gemelos digitales y algoritmos de optimización de alta complejidad. La necesidad de extender la vida útil de estas estructuras, que a menudo superan sus 20 o 25 años de diseño original, ha impulsado el desarrollo de metodologías capaces de identificar daños incipientes antes de que deriven en fallas catastróficas.<sup>1</sup>

## Dinámica de Degradación y Vulnerabilidades Estructurales en Ambientes Marinos

El entorno marino impone sobre las plataformas jacket una combinación de cargas estocásticas y mecanismos de degradación química que comprometen su seguridad estructural. Estas estructuras deben soportar no solo el peso de la cubierta (topside), sino también fuerzas hidrodinámicas de oleaje, corrientes, vientos extremos y, en el caso de las turbinas eólicas, las complejas fuerzas inerciales transmitidas desde la góndola y las palas.<sup>1</sup> La degradación de la salud estructural se manifiesta principalmente a través de la corrosión, la fatiga y daños accidentales como abolladuras por colisión o socavación del lecho marino.

### Mecanismos de Corrosión y Acumulación de Carga Biológica

La corrosión representa uno de los factores de degradación más persistentes y costosos. Este proceso electroquímico se ve exacerbado por la salinidad, la humedad, los niveles de oxígeno y las variaciones de temperatura del agua de mar.<sup>2</sup> Los estudios realizados entre 2020 y 2025 indican que las tasas de corrosión no son uniformes a lo largo de la estructura, siendo la zona de salpicadura (splash zone) la más vulnerable debido a la alternancia de mojado y secado, donde las tasas pueden ser de un 140% a un 175% superiores a las previstas en el diseño original.<sup>6</sup> La pérdida de material reduce el área de la sección transversal de los miembros estructurales, lo que impacta directamente en el índice de aprovechamiento o Unity Check (UC), una métrica crítica que define la relación entre el esfuerzo actuante y la capacidad resistente del miembro. Un valor de UC superior a 0.8 suele considerarse crítico en la gestión de integridad.<sup>2</sup>

| **Zona de la Estructura** | **Tasa de Corrosión Observada (mm/año)** | **Porcentaje respecto al Diseño** | **Observaciones de Anomalías**                                    |
| ------------------------- | ---------------------------------------- | --------------------------------- | ----------------------------------------------------------------- |
| **Zona Atmosférica**      | 0.03 - 0.06                              | 60% - 120%                        | Corrosión por depósitos de sal y en conexiones atornilladas       |
| ---                       | ---                                      | ---                               | ---                                                               |
| **Zona de Salpicadura**   | 0.28 - 0.35                              | 140% - 175%                       | Picaduras localizadas máximas detectadas (ej. 4.8 mm en 18 meses) |
| ---                       | ---                                      | ---                               | ---                                                               |
| **Zona Sumergida**        | 0.10 - 0.15                              | 100% - 150%                       | Corrosión uniforme y potencial influencia microbiológica (MIC)    |
| ---                       | ---                                      | ---                               | ---                                                               |
| **Zona del Lecho Marino** | Variable                                 | N/A                               | Influencia de la socavación y cambios en la rigidez del suelo     |
| ---                       | ---                                      | ---                               | ---                                                               |

Simultáneamente, el crecimiento marino (marine growth) añade una masa significativa no estructural que altera la respuesta dinámica de la plataforma. La acumulación de organismos aumenta el diámetro efectivo de los miembros tubulares, incrementando las fuerzas de arrastre (drag) según la ecuación de Morison, lo que desplaza las frecuencias naturales de la estructura y puede enmascarar los cambios en la rigidez causados por el daño estructural.<sup>2</sup>

### Agrietamiento por Fatiga y Fallas en Juntas Tubulares

El agrietamiento por fatiga es la causa predominante de falla en estructuras jacket, originado por la naturaleza cíclica del oleaje y las vibraciones operativas.<sup>8</sup> Las juntas tubulares (especialmente las configuraciones en T, K e Y) son puntos de alta concentración de esfuerzos donde las grietas suelen iniciarse en el pie de la soldadura (weld toe) y propagarse a través del espesor de la pared.<sup>5</sup> La identificación de estas grietas mediante sensores globales es extremadamente desafiante debido a que los cambios iniciales en la rigidez global son mínimos. No obstante, las investigaciones recientes han demostrado que el uso de sensores piezoeléctricos locales combinados con análisis de elementos finitos permite detectar de manera efectiva el inicio del daño en estas zonas críticas.<sup>8</sup>

## Fundamentos Teóricos de la Optimización Inversa en SHM

La identificación de daños en plataformas offshore se aborda matemáticamente como un problema de optimización inversa. El objetivo es ajustar los parámetros de un modelo numérico de elementos finitos (FEM) para que su respuesta dinámica coincida con los datos experimentales obtenidos de la estructura real.<sup>9</sup> Este proceso, conocido como actualización del modelo (model updating), utiliza la discrepancia entre las frecuencias naturales y los vectores de modo (mode shapes) medidos y simulados como función objetivo a minimizar.

### Análisis de Sensibilidad y Agrupamiento de Parámetros

Dada la gran cantidad de miembros estructurales en una plataforma jacket, la actualización de parámetros individuales (stiffness, mass) conduce a un problema de alta dimensionalidad computacionalmente ineficiente. Las metodologías avanzadas propuestas entre 2022 y 2026 introducen el agrupamiento basado en sensibilidad (sensitivity clustering).<sup>9</sup> Primero, se establecen índices de sensibilidad numérica para los parámetros de corrección estructural. La sensibilidad del ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAcAAAAYCAYAAAA20uedAAABQ0lEQVR4ATyQrUpFQRSFv30wiY9gUTDb1GwRTGowCGLxAcQHsBnNglUQwSD4AGIRH8Bitghmg2381pnB4d69114/M5szFZ5RRpPov6mlj9KiitOwTNHmvwOqo4GmLg6mZORmIdSUOCbCzMJMZIIpQhKD2xd/ifewTPGMIJ4l0980PsIrSqmWzd8t1LpYEa81Hpc6/TSDHfkRvKg4pdVzwbPejUhiJhNrCrsusi1epHGGx4jXtjpUuFJYodWmiaSVS5F2qeuVxrGmX/E9OrNH35ZaAE7kHuw/mvDtJMveDiyrJq4Llk1fiJnicthy+BC/ic+NPYrdlpy68Y1Pr71zehG/ixlvtnyRHRpHBU8a1GGIGSuFJAIy/Yt5w6XmRETf7sm45oRMcER0uq3mMEOwgYLs2LYz471Skij6teSUZdw9Gn8AAAD//92d5oUAAAAGSURBVAMAxs1xNGujY6UAAAAASUVORK5CYII=)\-ésimo autovalor (![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABEAAAAYCAYAAAAcYhYyAAACh0lEQVR4AZSTv49NcRDFzzwS2YJKIyISIhoJidj4D1QiIRYRFa2EiEItaglKKpJXiBUJiUqjsESnw0r86KgUKjE+c+beZ992br7fMzPnnO/c+d63OwnxGCQHg/7rmWTZCzhcQYYihw2vbq/xWU9NRmHtYZsskLmpwUz1qyoMTXUTvF3qPvED+kVTdqrOafYgFpHAIIsmIRdh2zlwhX0rpe3jdORQrPao+SQ0QZMqMMycukNVa6lgbpfH54I5SmmCJlX0jgqh14TP5LMm5FC9eurhxaayruNM1TobxPOQ/DCHd5MzdmHvrFCAWGntSZ2rpJ2lulqui6filL0G8wNA5JASJj0eGd2QRJAUryR9pNGSvQYYRHv8xqAqTuKPLfBS0C2LTnIlZHwD9lPtYw9r/lvYisJ1KsXuUODvdJfOq1lNpRP4WHjApnSZ9KYGqq+jhGOlNoJT9k/2Bf6A3hPP2Muk5PQ2vgSnI8V1KHttIjziwA7iVXYdeELcm4pFvwdR/fq3kt7AE8ToUTEWwKfsPQjHiL/bG8uWladVRGoz012X9AJ+a72FnCacouAnjYMIRzF9Fwd61FxJqa50HB5ZZ+FvSNoFv4XoNQEXUA/Q6HwqVjFBrfkVQrchdnKdI/R+ltIi/h9wn9hQYhLpF8I2iMc0wisLGp9U/S8F5XNe8JV4Ev8Uor6d/TWJxlMIqichnBuK6Q2/gWwJ+QH5FctAN0kkVqISWHUd1CT1ikHJP5RfmOgaU9+zDHSTwYKAJ9i1UEeeU0mOkiiHgEvEd1AE+ZuQQIO91ufBD1NKTVfx36a3CyYJJ911yM3EQPXhMDcPiaN4mqSV7tq5Cb57YiK4TCNQp2ahX/AXAAD//73YomAAAAAGSURBVAMANGm8NZDu0aAAAAAASUVORK5CYII=)) respecto a un parámetro de corrección (![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAYCAYAAAAYl8YPAAAC2ElEQVR4AXyTz4vOURTGn/PNRikWbGRjw8aPGknMTEhKY0lWLGz8A6QoYxZYiERZ2LBgoSxHNlKapkGm7FlQdmI1ZJR8fZ5z731nXmlu99zznOec+5xz3/lOp5VWOBmK4nwus2RVkso1EKupJAdHb9SruOGKKKyas+hArB+utYrzKodYKYmPpFoEoUZ0IZYPsnZE7IKyQR5Quc0zqR1xdUxXUJe1CJGrEweNlojBc2C5pX+cvFpNVxXMVRvuXGXJVTTk3DhbkA+V3yzEimwKyGwAyr0ofEC0XbEnKjVO9Ig5Ud/aEkk5n8ak9iTNG/o1xlAZtiOf6Q6FiJyiFEWjiucsPIDdcK2CCSZTvuoM7jnoKUNuAj8Dz+E/qo/j+OG9pKAmSn2KbaZyP/mT+KNkEdU1RtwnxRRFDyRtxKB8YnTkVCGiuRQ7Juk++a2CDumcpFlEifqv4DXYKLwpoHedB+efiLv0lPzR3iD9gsoDMD/JvyRGiEjapkRayAtSiVRW4KjPQqC6DIykPVTOSPFDrMqPuTPhPM1w7V5QCo6kBgffWTKrYEa5wFTIJKUNuENEt6Twcy9ImsZOI3MJ/i7196iB8g4/Ezo0ImktiR14hgma6A5Pmye+yOX1+G/YJ2yCsa7ip6g/QQ3Qm48WKWo1RrgAfo+fQ+0NFz6r12HiRfCiFA9Vforb8H/AI9R/AAPLZoKgFrGQvys+Be2l226KzlPyy0n18Z2Oq8FbwK/hvY9wTIe0TnXx1+z9RzioXm9JiAvcU1kmUGZSx+PUzIJ/O8AmSD8mPQnO3RHsAln9Hfi/QjyHEm3nmKkYqC/gSRo8ceAh/L/5KAPpsnqdVVsoBwQXYALTFS5cN0gLjeNPYa8whgjxm4kvnzLFTkk3sdwplBoOkTTGOXI1fRImTtSnWEKktZTIKA9ryItJ7dIadhJs57ueLPN5LEs4dhGUIdbGAraxoPIFlfoLAAD//y3QvkQAAAAGSURBVAMAgdPXNxqMx44AAAAASUVORK5CYII=)) se deriva de la ecuación de autovalores no amortiguados:
\frac{\partial \lambda_i}{\partial p_n} = \phi_i^T \left( \frac{\partial K}{\partial p_n} - \lambda_i \frac{\partial M}{\partial p_n} \right) \phi_i

Donde $K$ y $M$ son las matrices de rigidez y masa, y $\phi_i$ es el autovector correspondiente.$^9$

### Formulación de Funciones Objetivo Multiobjetivo

La precisión de la actualización del modelo depende de la robustez de la función objetivo. En el contexto de las plataformas jacket, se emplean comúnmente dos funciones que deben minimizarse simultáneamente:
1. **Error en Frecuencias Naturales ($f_1$):**

$$f_1 = \frac{1}{n_i} \sum_{j=1}^{n_i} \left| \frac{\lambda_i^e}{\lambda_i^*} - 1 \right|$$
2. **Discrepancia en Formas Modales ($f_2$):**

$$f_2 = \frac{1}{n_i} \sum_{j=1}^{n_i} |MAC(\phi_i^e, \phi_i^*) - 1|$$

El Criterio de Aseguramiento Modal (MAC) es una métrica escalar que evalúa la correlación entre los autovectores experimentales ($\phi_i^*$) y numéricos ($\phi_i^e$). Un valor de MAC cercano a 1 indica una coincidencia perfecta.$^9$ El desafío de asignar pesos adecuados a estas funciones se resuelve mediante el uso de algoritmos genéticos multiobjetivo, que generan un conjunto de soluciones óptimas de Pareto en lugar de una única solución ponderada arbitrariamente.$^9$

## Implementación de Algoritmos Genéticos y Estrategias Evolutivas

Los Algoritmos Genéticos (AG) se han consolidado como la herramienta preferida para la optimización inversa en SHM debido a su capacidad para explorar espacios de búsqueda complejos y evitar óptimos locales, a diferencia de los métodos basados en gradientes.<sup>10</sup>

### El Algoritmo Genético de Clasificación No Dominada (NSGA-II)

En el monitoreo de plataformas jacket de aguas profundas, se utiliza predominantemente el NSGA-II. Este algoritmo incorpora una estrategia de elitismo para preservar la diversidad de la población y manejar la no linealidad del modelo estructural.<sup>9</sup> El flujo de trabajo implica:
* **Generación de Población Inicial:** Se crean $N$ candidatos de soluciones para los coeficientes de corrección de rigidez y masa.
* **Evaluación de Aptitud (Fitness):** Cada candidato se evalúa mediante las funciones de error $f_1$ y $f_2$.
* **Clasificación No Dominada:** Las soluciones se organizan en frentes jerárquicos basados
- **Cómputo de Distancia de Hacinamiento (Crowding Distance):** Se utiliza para mantener una distribución uniforme de soluciones a lo largo de la frontera de Pareto, evitando que el algoritmo converja en un solo punto.<sup>9</sup>
- **Operadores Genéticos:** Se aplican técnicas de cruce (crossover) aritmético y mutación para generar la siguiente generación.<sup>10</sup>

### Robustez ante el Ruido en Datos Modales

Una de las contribuciones más significativas de las investigaciones recientes es la validación de estos algoritmos bajo condiciones de ruido realistas. Los datos recolectados en alta mar suelen estar contaminados por ruido ambiental y errores de medición. Los experimentos numéricos demuestran que, al añadir ruidos aleatorios del 1%, 2% y 3% a los datos modales simulados, los algoritmos genéticos pueden identificar la ubicación y severidad del daño con errores marginales de entre el 3% y el 5% en la estimación de la severidad.<sup>10</sup> En condiciones de bajo ruido, el error máximo en la actualización de modelos para jackets de aguas profundas se ha reducido a niveles tan bajos como el 0.05%, demostrando una precisión excepcional para la creación de gemelos digitales precisos.<sup>9</sup>

## Métricas de Localización y Optimización de Redes de Sensores

La efectividad de un sistema SHM depende críticamente de la ubicación estratégica de los sensores. Colocar sensores en nodos con baja energía modal resulta en datos irrelevantes, mientras que una red demasiado densa incrementa los costos de instalación y mantenimiento de manera prohibitiva.<sup>12</sup>

### Colocación Óptima de Sensores (OSP)

El modelo OSP utiliza algoritmos como el Algoritmo de Lichtenberg Multiobjetivo (MOLA) para equilibrar el costo del sensor con la precisión del cálculo modal.<sup>12</sup> Los criterios clásicos integrados en este proceso incluyen:

- **Independencia Efectiva (EFI):** Maximiza la independencia de las formas modales medidas.
- **Energía Cinética (KE):** Identifica nodos con mayores amplitudes de vibración.
- **Producto de Autovalores y Vectores (EVP):** Prioriza la sensibilidad a cambios en los autovalores.<sup>12</sup>

### Métricas de Localización Basadas en Grafos: TopoScore

En el periodo 2024-2026, ha surgido una nueva generación de métricas que tratand la red de sensores como un grafo topológico. El marco de aprendizaje automático de valores de tiempo (TVML) permite agrupar ubicaciones con comportamientos dinámicos similares.<sup>13</sup> La métrica **TopoScore** ($\psi_i$) se calcula ponderando y sumando medidas de centralidad para cada nodo de sensor dentro de un grupo:

$$\psi = \sum W_c \cdot C_{measure}$$

Donde $C_{measure}$ incluye centralidad de grado, centralidad de intermediación y accesibilidad local. El sensor con el **TopoScore** más alto en cada clúster se selecciona como el representante más informativo, reduciendo la redundancia de datos mientras se preserva la fidelidad de la representación del sistema.$^{13}$  



| **Métrica Topológica**            | **Función en el SHM de Jackets**                  | **Impacto en el Diagnóstico**                               |
| --------------------------------- | ------------------------------------------------- | ----------------------------------------------------------- |
| **Centralidad de Grado**          | Identifica nodos con mayor conectividad física    | Localización rápida de fallas en juntas                     |
| ---                               | ---                                               | ---                                                         |
| **Centralidad de Intermediación** | Detecta sensores que actúan como puentes de datos | Crucial para detectar daños en riostras principales         |
| ---                               | ---                                               | ---                                                         |
| **TopoScore**                     | Clasifica la importancia relativa del sensor      | Optimización de la inversión en hardware (CAPEX)            |
| ---                               | ---                                               | ---                                                         |
| **MASDWP**                        | Precisión de localización ponderada por distancia | Mejora la exactitud en la identificación del miembro dañado |
| ---                               | ---                                               | ---                                                         |

La métrica de precisión ponderada por distancia (MASDWP) es especialmente relevante para la localización de daños, ya que penaliza los errores de detección en función de la distancia física entre el miembro identificado y el miembro realmente dañado, proporcionando una evaluación más honesta del rendimiento del algoritmo en estructuras de gran escala.<sup>14</sup>

## Integración de Gemelos Digitales y Aprendizaje Profundo (Deep Learning)

El concepto de Gemelo Digital (DT) ha evolucionado de ser una representación estática a un sistema dinámico y probabilístico. Un DT exitoso para una plataforma jacket consiste en un modelo físico, un modelo virtual, una base de datos gemela y un sistema de servicios en tiempo real.<sup>12</sup>

### Redes Neuronales de Grafos Espacio-Temporales (ST-GNN)

La estructura intrínseca de una plataforma jacket, compuesta por nodos y miembros interconectados, se presta naturalmente a ser modelada mediante Redes Neuronales de Grafos (GNN). Los modelos ST-GNN integran codificadores de características temporales (para las señales de aceleración) y espaciales (para la topología de la estructura).<sup>17</sup> Al emplear una matriz de adyacencia ponderada modalmente, que incorpora información de las formas modales del FEM, el proceso de "paso de mensajes" de la GNN se vuelve físicamente significativo, permitiendo la identificación de daños a pequeña escala (como picaduras de corrosión incipientes) que los métodos tradicionales suelen pasar por alto.<sup>17</sup>

### Mecanismos de Atención y Adaptación de Dominio

La variabilidad inducida por la temperatura y las condiciones de operación (ej. dirección del viento en turbinas eólicas) genera ruido que puede confundirse con daño estructural. Las arquitecturas de Redes de Atención en Grafos (GAT) permiten al modelo "enfocarse" en los sensores más relevantes para una condición de carga específica.<sup>18</sup> Además, el uso de técnicas de Adaptación de Dominio (DA) facilita la transferencia de modelos entrenados en simulaciones numéricas (dominio fuente) a plataformas reales (dominio objetivo), mitigando el problema de la falta de datos de falla en estructuras en servicio.<sup>18</sup>

## Marcos de Confiabilidad y Validación Estadística

La adopción industrial de estas tecnologías requiere métricas de validación rigurosas que cuantifiquen la incertidumbre de los diagnósticos. La confiabilidad del SHM se mide a través de la probabilidad de detección y la robustez estadística de los algoritmos de clasificación.

### **Probabilidad de Detección (PoD) y Curvas ROC**

La eficiencia de un algoritmo de detección de daños se define mediante el par PoD y PFA (Probabilidad de Falsa Alarma).$^{20}$ La PoD es una función del tamaño del daño ($a$) y el umbral de detección ($a_d$):

$$PoD(a) = P(a > a_d)$$

Las curvas de Característica Operativa del Receptor (ROC) permiten comparar diferentes algoritmos visualmente: un algoritmo ideal se situaría en el punto (PoD=1, PFA=0). Las investigaciones indican que la incertidumbre en la inspección suele reducir el índice de confiabilidad de por vida de la estructura, por lo que es vital integrar la PoD en los modelos de optimización de mantenimiento.<sup>20</sup>

### El Test de Wilcoxon para la Validación de Algoritmos

Para validar la superioridad de un nuevo algoritmo de optimización (como el QWSA comparado con algoritmos básicos de enjambre de partículas), se utiliza el test de rangos con signo de Wilcoxon.<sup>17</sup> Este test estadístico no paramétrico evalúa si los resultados de precisión y velocidad de convergencia de una metodología son significativamente mejores que los de la competencia con un nivel de confianza (típicamente del 95%). En estudios de estructuras de celosía a gran escala, se ha demostrado que los métodos híbridos de aprendizaje por refuerzo y algoritmos evolutivos superan consistentemente a los métodos tradicionales en todas las métricas de error evaluadas mediante Wilcoxon.<sup>22</sup>

## Estándares y Normativas en la Gestión de Integridad (SIM)

A pesar de la madurez científica del SHM, existe una brecha significativa en su integración dentro de los códigos y estándares internacionales. Las organizaciones líderes (ISO, API, NORSOK, DNV) proporcionan directrices generales, pero el uso de gemelos digitales para la detección automática de daños todavía se encuentra en una etapa de estandarización incipiente.<sup>3</sup>

### Paisaje Normativo Actual

| **Organización** | **Estándar Relevante** | **Alcance y Aplicación**                                        |
| ---------------- | ---------------------- | --------------------------------------------------------------- |
| **ISO**          | ISO 19900 / 19902      | Requisitos generales y diseño de estructuras fijas de acero     |
| ---              | ---                    | ---                                                             |
| **NORSOK**       | N-001 / N-005          | Integridad, seguridad y monitoreo de condiciones                |
| ---              | ---                    | ---                                                             |
| **API**          | API RP 2SIM            | Gestión de integridad estructural para plataformas fijas        |
| ---              | ---                    | ---                                                             |
| **DNV**          | DNV-RP-C210            | Planificación de inspecciones basada en riesgo para fatiga      |
| ---              | ---                    | ---                                                             |
| **IEC**          | IEC 61400-3-1          | Requisitos de diseño para soportes de turbinas eólicas offshore |
| ---              | ---                    | ---                                                             |

Las directrices recientes de la Autoridad de Seguridad Petrolera (PSA) de Noruega subrayan la importancia de la fase de planificación del SHM, recomendando un mapeo exhaustivo de los elementos críticos y los modos de falla antes del despliegue del sistema.<sup>3</sup> El marco propuesto por Ramboll para la PSA divide la implementación del SHM en cinco niveles, estableciendo un acoplamiento directo entre las mediciones físicas y el gemelo digital para informar las decisiones de extensión de vida útil.<sup>3</sup>

## Conclusiones sobre el Futuro del Monitoreo Estructural Offshore

El análisis exhaustivo de la literatura y los desarrollos tecnológicos entre 2018 y 2026 revela un camino claro hacia la autonomía en la gestión de integridad de plataformas jacket. La convergencia de la optimización inversa mediante algoritmos genéticos multiobjetivo y el aprendizaje profundo sobre grafos ha superado las limitaciones de dimensionalidad y ruido que antes impedían el despliegue de sistemas globales de detección de daños. El uso de métricas de localización avanzadas, como el TopoScore, garantiza que las redes de sensores sean no solo precisas sino también económicamente viables.

De cara al futuro, la integración de la Ingeniería de Salud Digital (DHE) permitirá a los operadores pasar de esquemas de inspección anuales a evaluaciones continuas de la reserva de seguridad estructural.<sup>25</sup> Este cambio no solo reducirá los gastos operativos (OPEX) al evitar inspecciones submarinas innecesarias por parte de buzos o ROVs, sino que también aumentará drásticamente la seguridad de las operaciones en alta mar, mitigando los riesgos de colapso catastrófico y contaminación ambiental asociados a las fallas estructurales. La maduración de los estándares internacionales será el catalizador final para que el SHM se convierta en una exigencia regulatoria universal para todas las estructuras offshore de nueva generación.

### Apéndice A: Datos Técnicos y Bibliográficos (BibTeX)

Para facilitar la integración en gestores de referencias y la reproducibilidad de esta investigación, se presenta la siguiente recopilación de fuentes clave citadas en el informe:

Code snippet

@article{Wang2024,  
author = {Wang, C. and Zhu, T. and Yang, B.},  
title = {Failure analysis of stress corrosion cracking in welded structures},  
journal = {Engineering Failure Analysis},  
year = {2024},  
volume = {163},  
pages = {108564},  
doi = {10.1016/j.engfailanal.2024.108564}  
}  
<br/>@article{Jiang2024,  
author = {Jiang, L. and Yan, R. and Soares, C. G.},  
title = {Structural Model Updating Method of Medium-Deep Water Jacket Platforms Based on Sensitivity Clustering},  
journal = {Journal of Marine Science and Engineering},  
year = {2024},  
volume = {12},  
number = {4},  
pages = {375},  
url = {<https://www.mdpi.com/2077-1312/14/4/375}>  
}  
<br/>@phdthesis{Hlaing2024,  
author = {Hlaing, Nandar},  
title = {Life-cycle management framework for offshore wind structures leveraging digital twin technology},  
school = {University of Liège},  
year = {2024},  
url = {<https://orbi.uliege.be/bitstream/2268/313058/1/PhDThesis_Nandar_Hlaing_revised16apr.pdf}>  
}  
<br/>@article{Li2024,  
author = {Li, L. and Zou, G.},  
title = {A novel computational approach for assessing system reliability and damage detection delay},  
journal = {Ocean Engineering},  
year = {2024},  
volume = {297},  
pages = {117023},  
doi = {10.1016/j.oceaneng.2024.117023}  
}  
<br/>@article{Mousavi2020,  
author = {Mousavi, M. and Gandomi, A. H.},  
title = {Developing deep neural network for damage detection of beam-like structures using dynamic response},  
journal = {Applied Acoustics},  
year = {2020},  
volume = {168},  
pages = {107402},  
doi = {10.1016/j.apacoust.2020.107402}  
}  
<br/>@report{Ramboll2022,  
author = {Petroleum Safety Authority Norway},  
title = {Bruk av digitale løsninger for å overvåke konstruksjoners sikkerhet},  
institution = {Ramboll},  
year = {2022},  
url = {<https://www.havtil.no/contentassets/a4dae83127e04a63a00ebf05676a7588/bruk-av-digitale-losninger-for-a-overvake-konstruksjoners-sikkerhet.pdf}>  
}

### Apéndice B: Resumen de Parámetros y Métricas de SHM (JSON)

La siguiente estructura de datos resume los parámetros técnicos y las métricas de evaluación discutidas a lo largo del reporte para su procesamiento en herramientas de análisis de datos:

JSON

{  
"shm_parameters": {  
"structural_mechanisms":  
},  
{  
"type": "Fatigue",  
"primary_index": "Crack Length / Depth",  
"hotspots": "Weld Toes in Tubular Joints",  
"monitoring_techniques":  
}  
\],  
"optimization_algorithms": {  
"genetic_algorithms":,  
"objective_functions":,  
"noise_resistance_level": "Up to 5% with pre-processing"  
},  
"localization_metrics": {  
"topology_based":,  
"accuracy_metrics":,  
"sensor_placement_criteria": \["EFI", "KE", "EVP", "IE"\]  
},  
"validation_methods": {  
"statistical_tests":,  
"reliability_metrics":  
}  
}  
}

### Apéndice C: Comparativa de Escenarios de Daño y Respuesta Estructural (CSV)

Este conjunto de datos tabulares permite una comparación rápida de cómo diferentes tipos de degradación afectan los parámetros dinámicos de una plataforma jacket típica:

Code snippet

Damage_Scenario,Frequency_Shift_Rate,MAC_Degradation,Localization_Difficulty,Metric_Priority  
Minor_Corrosion_Splash_Zone,Low,Minimal,High,Unity_Check  
Fatigue_Crack_K_Joint,Very_Low,Moderate,Extreme,Modal_Strain_Energy  
Marine_Growth_Accumulation,Moderate,Low,Moderate,Added_Mass_Factor  
Ship_Collision_Denting,High,High,Low,Geometric_Anomaly  
Seabed_Scour,Moderate,Moderate,High,Boundary_Condition_Sensitivity

#### Works cited

- An Overview on Structural Health Monitoring and Fault Diagnosis of Offshore Wind Turbine Support Structures - MDPI, accessed April 12, 2026, <https://www.mdpi.com/2077-1312/12/3/377>
- Structural Health Monitoring of An Offshore Platform Trend of Corrosion and Marine Growth With Predictive Maintenance - AAPG Datapages/Archives:, accessed April 12, 2026, <https://archives.datapages.com/data/ipa_pdf/2020/IPA20-SE-424.pdf>
- The use of digital solutions and structural health monitoring for integrity management of offshore structures - Havtil, accessed April 12, 2026, <https://www.havtil.no/contentassets/a4dae83127e04a63a00ebf05676a7588/bruk-av-digitale-losninger-for-a-overvake-konstruksjoners-sikkerhet.pdf>
- Offshore Wind Turbine Tower Design and Optimization: A Review and AI-Driven Future Directions - arXiv, accessed April 12, 2026, <https://arxiv.org/html/2502.02594v1>
- Experimental and numerical study on collapse of aged jacket platforms caused by corrosion or fatigue cracking | Request PDF - ResearchGate, accessed April 12, 2026, <https://www.researchgate.net/publication/291138377_Experimental_and_numerical_study_on_collapse_of_aged_jacket_platforms_caused_by_corrosion_or_fatigue_cracking>
- Comprehensive Integrity Assessment Framework for Ageing Offshore Platforms in Tropical Marine Environments - Journal (BIRCU-Publisher), accessed April 12, 2026, <https://bircu-journal.com/index.php/birci/article/download/8148/pdf>
- Spatio-temporal evolution and engineering implications of biofouling communities on floating wind turbines mooring lines - Tethys, accessed April 12, 2026, <https://tethys.pnnl.gov/sites/default/files/publications/Dubois-et-al-2025.pdf>
- Fatigue Crack Monitoring of T-Type Joints in Steel Offshore Oil and Gas Jacket Platform, accessed April 12, 2026, <https://pmc.ncbi.nlm.nih.gov/articles/PMC8126214/>
- Structural Model Updating Method of Medium-Deep Water Jacket ..., accessed April 12, 2026, <https://www.mdpi.com/2077-1312/14/4/375>
- (PDF) Damage Detection in an Offshore Jacket Platform Using ..., accessed April 12, 2026, <https://www.researchgate.net/publication/257726365_Damage_Detection_in_an_Offshore_Jacket_Platform_Using_Genetic_Algorithm_Based_Finite_Element_Model_Updating_with_Noisy_Modal_Data>
- Feasibility for Damage Identification in Offshore Wind Jacket ... - MDPI, accessed April 12, 2026, <https://www.mdpi.com/1996-1073/13/21/5791>
- Damage identification of offshore jacket platforms in a digital twin framework considering optimal sensor placement - arXiv, accessed April 12, 2026, <https://arxiv.org/pdf/2404.07959>
- Time-Vertex Machine Learning for Optimal Sensor Placement in Temporal Graph Signals: Applications in Structural Health Monitoring - arXiv, accessed April 12, 2026, <https://arxiv.org/html/2512.19309v1>
- Image-based detection of bolts and bolt-missing defects in multi, accessed April 12, 2026, <https://discovery.researcher.life/article/image-based-detection-of-bolts-and-bolt-missing-defects-in-multi-angle-and-complex-background-scenarios/d76dc409cdba31f589968b952d23da78>
- Beyond mAP: Towards Better Evaluation of Instance Segmentation, accessed April 12, 2026, <https://www.researchgate.net/publication/373308421_Beyond_mAP_Towards_Better_Evaluation_of_Instance_Segmentation>
- Structural integrity assessment of an offshore platform using RB-FEA - Emerald Publishing, accessed April 12, 2026, <https://www.emerald.com/ijsi/article-pdf/doi/10.1108/IJSI-10-2023-0099/9774377/ijsi-10-2023-0099.pdf>
- Bridge Structural Damage Identification Based on Parallel Multi ..., accessed April 12, 2026, <https://www.researchgate.net/publication/380290433_Bridge_Structural_Damage_Identification_Based_on_Parallel_Multi-head_Self-attention_Mechanism_and_Bidirectional_Long_and_Short-term_Memory_Network>
- Domain-Adaptive Graph Attention Semi-Supervised Network for Temperature-Resilient SHM of Composite Plates - MDPI, accessed April 12, 2026, <https://www.mdpi.com/1424-8220/25/22/6847>
- Developing deep neural network for damage detection of beam-like ..., accessed April 12, 2026, <https://www.researchgate.net/publication/341690093_Developing_deep_neural_network_for_damage_detection_of_beam-like_structures_using_dynamic_response_based_on_FE_model_and_real_healthy_state>
- (PDF) Reliability estimate of damage detection algorithms, accessed April 12, 2026, <https://www.researchgate.net/publication/235329354_Reliability_estimate_of_damage_detection_algorithms>
- A Probabilistic Method for Quantifying Uncertainty in Crack Detection and Its Effects on Marine Structural Integrity Management - MDPI, accessed April 12, 2026, <https://www.mdpi.com/2077-1312/13/12/2263>
- Structural damage detection and localization by response change diagnosis | Request PDF, accessed April 12, 2026, <https://www.researchgate.net/publication/227790443_Structural_damage_detection_and_localization_by_response_change_diagnosis>
- Fatigue Analysis of a Jacket-Supported Offshore Wind Turbine at Block Island Wind Farm - MDPI, accessed April 12, 2026, <https://www.mdpi.com/1424-8220/24/10/3009>
- Fatigue Analysis of a Jacket-Supported Offshore Wind Turbine at ..., accessed April 12, 2026, <https://pmc.ncbi.nlm.nih.gov/articles/PMC11125084/>
- Advancing digital healthcare engineering for aging ships and offshore structures: an in-depth review and feasibility analysis - Cambridge University Press, accessed April 12, 2026, <https://www.cambridge.org/core/journals/data-centric-engineering/article/advancing-digital-healthcare-engineering-for-aging-ships-and-offshore-structures-an-indepth-review-and-feasibility-analysis/F9FA754BEE7E2F1679D343240E16B843>
