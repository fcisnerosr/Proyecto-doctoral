# Informe de Investigación Técnica Forense: Integridad Estructural y Evaluación Multidimensional de Abolladuras en Subestructuras Offshore Tipo Jacket

## 1. Introducción: El Paradigma de la Integridad Estructural en Activos Envejecidos

La industria del petróleo y gas offshore se enfrenta a una coyuntura crítica caracterizada por la extensión de la vida útil de activos que han superado su horizonte de diseño original. Las plataformas fijas de acero, comúnmente denominadas estructuras tipo "Jacket", constituyen la infraestructura predominante en aguas someras e intermedias.

Estas estructuras reticuladas, compuestas por una red compleja de miembros tubulares y nodos soldados, están sometidas a un régimen de carga ambiental severo y a riesgos operacionales constantes. Dentro de la patología estructural de estas instalaciones, el daño mecánico local en forma de abolladuras (*dents*) representa una de las amenazas más insidiosas y técnicamente desafiantes para la integridad global del activo.

Este reporte técnico, elaborado desde la perspectiva de la Ingeniería Forense y la Integridad de Activos, tiene como objetivo deconstruir el fenómeno de la abolladura no como un evento aislado, sino como una interacción sistémica de variables físicas, temporales y espaciales.

La gestión de la integridad estructural (SIM, por sus siglas en inglés) ha transitado de modelos deterministas prescriptivos a enfoques basados en riesgo y confiabilidad, lo que exige una caracterización precisa del daño. Las estadísticas globales, como las recopiladas en el *Worldwide Offshore Accident Databank* (WOAD) y los reportes del *Health and Safety Executive* (HSE) del Reino Unido, indican que los daños accidentales por impacto son una causa primaria de reducción de capacidad [1]. Sin embargo, la literatura técnica a menudo simplifica la abolladura a un mero parámetro geométrico de profundidad ($d/D$), ignorando la historia de carga, las tensiones residuales y la evolución por fatiga.

El análisis que se presenta a continuación integra una revisión exhaustiva de la mecánica del daño, contrastando la física del impacto con la respuesta estructural a largo plazo. Se examinará cómo la etiología del daño (colisión de buques, objetos caídos, errores de instalación) define la morfología de la abolladura y su potencial de propagación. Asimismo, se abordará la variable temporal, analizando cómo el envejecimiento de los materiales y la acumulación de ciclos de fatiga interactúan con la concentración de tensiones generada por el defecto.

Finalmente, se evaluarán los modelos de predicción de resistencia residual y las estrategias de reparación bajo los códigos normativos vigentes ISO y API, proporcionando una hoja de ruta técnica para la toma de decisiones en escenarios de extensión de vida útil.

---

## 2. Etiología y Mecánica del Daño: Análisis de la Causa Raíz

La génesis de una abolladura es fundamental para comprender su comportamiento futuro. A diferencia de los mecanismos de degradación progresiva como la corrosión generalizada, la abolladura es el resultado de un evento discreto de transferencia de energía cinética o potencial que excede la capacidad elástica local de la pared del tubo, resultando en deformación plástica permanente.

### 2.1 Dinámica de Colisiones de Embarcaciones (Ship Collision)

Las colisiones de embarcaciones representan la fuente más frecuente y energéticamente significativa de daños en los miembros de la subestructura. El análisis de las bases de datos de incidentes, específicamente los informes HSE OTO 2001 063 y sus actualizaciones subsecuentes, revela una distinción crítica entre los tipos de embarcaciones involucradas: "vessels passing" (buques mercantes en tránsito) y "attendant vessels" (embarcaciones de servicio y suministro) [1].

#### 2.1.1 Física del Impacto de Embarcaciones de Suministro (OSV)
Las embarcaciones de suministro (OSV) operan rutinariamente dentro de la zona de exclusión de 500 metros, realizando maniobras de carga y descarga que, bajo condiciones de mar adversas o falla de posicionamiento dinámico, pueden resultar en impactos laterales.

Aunque las velocidades de impacto suelen ser bajas (típicamente $< 2$ m/s para impactos por deriva), la masa desplazada de los OSV modernos, que frecuentemente supera las 5,000 toneladas, genera una energía cinética considerable:

$$E_k = 0.5 mv^2$$

La mecánica de la transferencia de energía durante una colisión es compleja. La energía total disipada se reparte entre la deformación del buque (zona de proa/popa o costado) y la deformación de la plataforma (miembros tubulares). Debido a que los miembros de la jacket son elementos de pared delgada con alta rigidez global pero susceptibilidad local, el daño se manifiesta típicamente como una combinación de abolladura local (*dent*) y flexión global del miembro (*bowing*).

Estudios experimentales han demostrado que las tensiones residuales de fabricación en los tubos (especialmente en aquellos formados por rolado en frío) reducen significativamente la capacidad de absorción de energía para una profundidad de abolladura dada, lo que implica que modelos simplificados pueden subestimar el daño real ante un evento de colisión de diseño [7].

#### 2.1.2 Estadísticas y Clasificación de Severidad
El análisis estadístico de los datos del HSE y WOAD permite categorizar la severidad del daño. La base de datos WOAD clasifica los daños en cinco categorías: "Insignificante", "Menor", "Significativo", "Severo" y "Pérdida Total" [3]. Las colisiones con buques de servicio tienden a generar daños en las categorías "Menor" a "Significativo", caracterizados por abolladuras con relaciones $d/D$ (profundidad/diámetro) que oscilan entre 0.05 y 0.20.

Sin embargo, incluso una abolladura "menor" puede ser crítica si se ubica en un miembro comprimido con alta utilización. La probabilidad de detección de estos eventos ha aumentado con los años, no necesariamente por un aumento en la frecuencia de accidentes, sino por mejoras en los protocolos de reporte y tecnologías de inspección [4].

### 2.2 Impacto por Objetos Caídos (Dropped Objects)

La segunda causa raíz predominante es la caída accidental de cargas durante operaciones de izaje. Este escenario presenta una física distinta: la energía es potencial gravitatoria transformada en cinética:

$$E_p = mgh$$

#### 2.2.1 Probabilidad de Impacto y Trayectorias Submarinas
La evaluación de riesgos de objetos caídos (Dropped Object Analysis - DOA) utiliza simulaciones de Monte Carlo para predecir la probabilidad de impacto en diferentes niveles de la subestructura. El modelo divide el análisis en tres zonas: Topsides, Subestructura (Jacket) y Subsea [8].

Un factor crítico a menudo subestimado es la hidrodinámica del objeto al entrar en la columna de agua. Objetos con geometrías irregulares o planas no caen verticalmente; experimentan excursiones laterales significativas debido a fuerzas de sustentación y arrastre, ampliando el cono de riesgo ("cone of influence") a medida que aumenta la profundidad [9]. Esto significa que miembros de la jacket ubicados fuera de la proyección vertical directa de la grúa no están exentos de riesgo.

#### 2.2.2 Efecto de la Orientación y Carga "Knife-Edge"
La severidad de la abolladura por objeto caído depende críticamente de la orientación del impacto. Un objeto tubular (como un *drill collar* o un *riser*) que golpea un miembro de la jacket con su extremo ("end-on impact") concentra toda la energía en un área mínima, actuando como un indentador rígido o carga de "filo de cuchillo" (*knife-edge loading*).

Investigaciones experimentales indican que la energía de impacto efectiva para causar daño local puede ser hasta 4.7 veces mayor en ciertas orientaciones desfavorables en comparación con impactos planos distribuidos [10]. Esto resulta en abolladuras profundas y agudas ("sharp dents") que actúan como elevadores de tensión extremos, iniciando grietas inmediatas o fatiga acelerada.

### 2.3 Daños Ocultos durante la Fase de Instalación

Un subconjunto significativo de abolladuras detectadas en plataformas maduras no se origina en la operación, sino en la fase de instalación, permaneciendo latentes durante años.

#### 2.3.1 Hincado de Pilotes (Pile Driving) y Vibración
Durante la instalación de los pilotes a través de las piernas de la jacket o mangas (*sleeves*), el uso de martillos hidráulicos de alta energía genera ondas de tensión y vibraciones severas. Si existe desalineación durante el hincado, el pilote puede golpear internamente la pared de la pierna o las guías, causando abolladuras internas (*bulges*) o deformaciones locales [12]. Estas abolladuras son particularmente perniciosas porque son invisibles a la inspección visual externa general (GVI) y a menudo se descubren solo mediante inspecciones avanzadas o cuando se manifiestan problemas de corrosión localizada.

Además, el proceso de hincado induce ciclos de fatiga de alto estrés en el acero antes de que la plataforma entre en servicio, consumiendo una fracción de la vida útil de fatiga de los miembros y soldaduras adyacentes [12].

#### 2.3.2 El Fenómeno "Shimmy" y Daños de Lanzamiento
El lanzamiento de la jacket desde la barcaza de transporte y su posterior verticalización son eventos traumáticos controlados. Errores en el lastrado o condiciones de mar inesperadas pueden provocar impactos contra el brazo basculante de la barcaza o, en aguas poco profundas, contra el lecho marino. Históricamente, se han documentado casos donde estructuras desarrollaron inestabilidades dinámicas ("shimmy") poco después de la instalación debido a daños en los sistemas de conexión pilote-jacket (*crown shims*), requiriendo reparaciones inmediatas mediante grouting para restaurar la rigidez [14].

### 2.4 Tabla Resumen: Caracterización Forense por Causa Raíz

La siguiente tabla sintetiza las características morfológicas y espaciales esperadas según la causa raíz, sirviendo como guía para el análisis forense in-situ.

| Causa Raíz | Mecanismo Físico | Ubicación Típica | Características Morfológicas (Huella Forense) | Referencias Clave |
| :--- | :--- | :--- | :--- | :--- |
| **Colisión de Buque (OSV)** | Impacto lateral (Masa elevada, baja velocidad). | Zona de Salpicadura (Splash Zone) $\pm 10$m LAT. | Abolladura alargada, deformación global (*bowing*), transferencia de pintura, daño a defensas/caissons. | [1] |
| **Objeto Caído (Carga)** | Impacto vertical/oblicuo (Alta velocidad terminal). | Bajo radio de grúa, miembros horizontales, fondo marino. | Abolladura puntual aguda (*Sharp dent*), geometría del objeto impactante, posible perforación. | [8] |
| **Instalación (Pilotes)** | Impacto interno / Vibración armónica. | Interior de piernas (*Legs*), Guías de pilotes (*Sleeves*). | Abolladura interna (*Bulging*), desgaste en guías, fatiga pre-servicio en uniones soldadas. | [12] |
| **Anclas / Cables** | Arrastre y tensión lateral. | Miembros basales, Nodos cercanos al lecho marino. | Abolladura profunda con desgarro (*Gouging*), abrasión metálica severa, deformación plástica masiva. | [16] |

---

## 3. La Variable Espacial: Zonificación de la Vulnerabilidad Estructural

La ubicación de una abolladura dentro de la topología de la jacket no es aleatoria ni sus consecuencias son uniformes. La evaluación de integridad requiere una zonificación que integre la probabilidad de ocurrencia con la criticidad estructural y ambiental.

### 3.1 La Zona de Salpicadura (Splash Zone): Convergencia de Amenazas
La zona de salpicadura es la región más hostil para la integridad estructural. Definida operativamente entre el nivel más bajo de marea astronómica (LAT) y la cresta de la ola de diseño (incluyendo marea de tormenta), esta zona concentra la máxima probabilidad de impacto de buques [6].

* **Sinergia Corrosión-Impacto:** En esta zona, el acero está expuesto a ciclos alternos de humectación y secado. Una abolladura en esta región compromete inmediatamente los sistemas de protección pasiva y activa. La presencia de una abolladura crea un concentrador de tensiones geométricas (SCF). Cuando este SCF se combina con un ambiente corrosivo y cargas cíclicas, se crea el escenario perfecto para la **fatiga por corrosión**. La vida a fatiga de un miembro abollado aquí se reduce drásticamente [18].
* **Desafíos de Inspección:** Paradójicamente, aunque es la zona más crítica, es la más difícil de inspeccionar. El crecimiento marino (*marine growth*) oculta la profundidad real de las abolladuras y la acción de las olas dificulta el uso de herramientas de metrología precisas [20].

### 3.2 Zonificación Vertical y Miembros Horizontales
A medida que se desciende en la estructura, la probabilidad de colisión disminuye, pero aumenta la exposición a objetos caídos.

* **Efecto de Sombra y Rebote:** Los miembros horizontales superiores protegen parcialmente a los inferiores, pero los objetos que golpean y rebotan ("efecto pinball") pueden adquirir trayectorias impredecibles.
* **Acumulación Histórica:** En plataformas maduras, los miembros horizontales en los primeros niveles sumergidos a menudo presentan una "topografía lunar" de múltiples abolladuras menores. Aunque individualmente pueden ser insignificantes ($d/D < 0.05$), su efecto acumulativo debe ser considerado [21].

### 3.3 Jerarquía Estructural: Piernas vs. Riostras
* **Piernas (Legs):** Son los elementos principales de soporte. Si están rellenas de concreto (*grouted piles*), una abolladura tiene una mecánica diferente: el concreto impide la deformación hacia el interior, pero la transferencia de carga cortante puede verse comprometida [22].
* **Riostras (Braces):** Trabajan predominantemente bajo ciclos de tracción-compresión axial. Una abolladura es devastadora para la capacidad de compresión debido a la inestabilidad por pandeo local. La ubicación es crítica; una abolladura en el centro del tramo amplifica el pandeo global mucho más que una cerca de los nodos debido al momento P-delta secundario [23].

---

## 4. La Variable Temporal: Envejecimiento, Fatiga y Evolución del Defecto

El tiempo actúa como un catalizador que transforma un daño estático en una amenaza dinámica.

### 4.1 Consumo de Vida a Fatiga y Factores de Concentración de Esfuerzos (SCF)
La introducción de una abolladura altera el flujo de tensiones, creando concentraciones en los "hombros" y el fondo de la misma.

* **SCF Geométrico:** El Factor de Concentración de Esfuerzos (SCF) en una abolladura puede variar típicamente entre 2.0 y 10.0 [24].
* **Curvas S-N y Daño Acumulado:** En una estructura envejecida, los miembros ya han acumulado daño por fatiga (Suma de Miner):
    $$D = \Sigma (n_i/N_i)$$
    Si una abolladura ocurre en la vida tardía, el alto SCF consume la reserva remanente a una tasa exponencialmente mayor. ISO 19902 advierte que los problemas de fatiga en abolladuras deben ser evaluados rigurosamente [26].

### 4.2 Degradación de Propiedades Materiales y Corrosión
* **Corrosión Preferencial:** La deformación plástica altera la estructura microcristalina, haciendo al acero anódico y acelerando la corrosión local (*stress corrosion*) si la protección catódica es inadecuada.
* **Crecimiento de Grietas:** Bajo cargas cíclicas, micro-grietas pueden iniciarse en el fondo de la abolladura, cambiando el modo de falla de pandeo plástico a fractura frágil o dúctil inestable [28].

### 4.3 Evolución de la Detectabilidad y Datos Históricos
El análisis forense debe normalizar los datos históricos. La implementación de técnicas modernas como la fotogrametría ha permitido detectar abolladuras con relaciones $d/D$ muy bajas que antes pasaban desapercibidas, creando un sesgo de tecnología [31].

---

## 5. Mecánica Estructural de la Abolladura: Análisis de Resistencia Residual

Para cuantificar el impacto de una abolladura en la seguridad de la plataforma, debemos traducir la geometría del daño en parámetros de capacidad estructural.

### 5.1 Parámetros Geométricos y Distribuciones Estadísticas (d/D)
El parámetro fundamental es la relación profundidad-diámetro ($d/D$).

* **Límites de Comportamiento:** Una abolladura con $d/D \approx 0.10$ puede reducir la resistencia última a compresión axial en un 15-25%. Si alcanza $d/D \approx 0.30$, la reducción puede superar el 40-50%, dependiendo de la esbeltez ($\lambda$) y la relación $D/t$ [32].
* **Distribuciones Probabilísticas:** Los datos de campo sugieren que las profundidades siguen distribuciones Log-normal o Weibull [34].

### 5.2 Fenomenología del Colapso: El Momento P-Delta Local
El mecanismo de falla bajo compresión difiere del pandeo de Euler clásico. La excentricidad ($e_d$) del centroide de la sección dañada genera un momento flector adicional local:

$$M_{secundario} = P \cdot e_d$$

A medida que aumenta la carga axial $P$, este momento amplifica la profundidad de la abolladura, formando una articulación plástica prematura. El colapso ocurre cuando la rigidez tangencial se vuelve negativa [32].

### 5.3 Modelos Analíticos y Numéricos
* **Modelos Empíricos (Loh, Ellinas, Taby & Moan):** Calibrados experimentalmente. El modelo de Taby es reconocido por considerar la reducción del régimen elástico y la plastificación temprana [22].
* **Análisis de Elementos Finitos (FEA):** Herramientas como ABAQUS o USFOS son cruciales para modelar el proceso de indentación y capturar las tensiones residuales. Ignorarlas puede llevar a predicciones inseguras [7].

---

## 6. Marco Normativo y Criterios de Evaluación (ISO vs. API)

### 6.1 ISO 19902: Prescripción Detallada
La norma ISO 19902 establece requisitos explícitos.
* **Fórmulas Explícitas:** Sección 13.7 para resistencia de miembros abollados [26].
* **Límites de Aplicabilidad:** $h \leq 0.3 D$ y $h \leq 10 t$. Daños mayores requieren FEA o pruebas físicas.
* **Mandato de Fatiga:** Exige evaluación de fatiga en zonas abolladas.

### 6.2 API RP 2A y 2SIM: Gestión de Integridad
* **RP 2SIM:** Introduce la evaluación basada en desempeño (*Fitness-for-Service*). Permite operar con daños si el Índice de Reserva de Resistencia (RSR) global es suficiente, incluso si miembros individuales fallan el chequeo de diseño [20].
* **Criterios:** Menos prescriptivo que ISO, confía en la competencia del ingeniero para seleccionar métodos validados (Assessment Category) [39].

### 6.3 Comparación de Enfoques de Evaluación

| Criterio | Enfoque ISO 19902 | Enfoque API RP 2A / 2SIM |
| :--- | :--- | :--- |
| **Metodología Base** | Fórmulas analíticas calibradas y LRFD. | WSD histórico, moviéndose a LRFD y Evaluación Global (Pushover). |
| **Límites de Daño** | Estricto: $h \le 0.3D$. Más allá requiere validación especial. | Flexible: Se enfoca en la redundancia global del sistema (RSR). |
| **Fatiga** | Requerimiento explícito y detallado. | Referencia a prácticas recomendadas, énfasis en inspección. |
| **Reparación** | Fomenta la restauración a nivel de diseño. | Acepta el daño si el riesgo global (ALARP) es aceptable. |

---

## 7. Estrategias de Mitigación y Reparación

### 7.1 Grouting (Inyección de Cemento/Epoxi)
Técnica versátil y efectiva. Al rellenar el miembro, se previene la ovalización y el pandeo local, forzando la fluencia global. Pruebas demuestran que puede restaurar la resistencia a niveles superiores al 100% del original para daños moderados [22]. Su efectividad disminuye en abolladuras muy profundas ($>0.3D$) si no se combina con abrazaderas [33].

### 7.2 Abrazaderas Mecánicas y Grouteadas (Clamps)
* **Grouteadas:** Extremadamente efectivas, crean un camino de carga alternativo. Costosas de instalar.
* **De Fricción:** Más rápidas, pero menos tolerantes a irregularidades geométricas.

### 7.3 Rectificado (Grinding) y Arresto de Grietas
Para abolladuras superficiales ($d/D < 0.05$) donde la fatiga es la preocupación, el rectificado suave mejora la vida útil al eliminar concentradores de tensión y material endurecido [41].

### 7.4 Tabla Comparativa de Métodos de Reparación

| Método de Reparación | Aplicabilidad Principal | Ventajas Técnicas | Desventajas / Limitaciones | Referencias |
| :--- | :--- | :--- | :--- | :--- |
| **Monitoreo** | Daños menores ($d/D < 0.1$), RSR aceptable. | Costo inmediato cero. | Riesgo de propagación. Requiere inspección frecuente. | [42] |
| **Grouting Interno** | Abolladuras moderadas ($0.1 < d/D < 0.3$). | Restaura estabilidad local. Previene pandeo. | Aumenta masa dinámica. Difícil de remover. | [22] |
| **Clamp Grouteado** | Daños severos ($d/D > 0.3$), grietas. | Restaura 100%+ capacidad. Puentea fracturas. | Alto costo (buzos/ROV). Peso adicional. | [22] |
| **Reemplazo Hiperbárico** | Daño catastrófico en miembros críticos. | Restaura condición original. | Extremadamente costoso y arriesgado. | [33] |

---

## 8. Análisis Forense de Datos y Estadísticas

La validación técnica se apoya en datos empíricos:
* **Correlación Energía-Daño:** Permite estimar la velocidad del barco incidente basándose en la geometría forense del daño, crucial para aspectos legales [32].
* **Frecuencia de Accidentes:** Datos de WOAD y HSE confirman que las colisiones menores son frecuentes, justificando considerar las abolladuras como condición de carga "normal" en vida tardía [1].
* **Probabilidad de Detección (POD):** La población real de abolladuras es probablemente mayor a la reportada debido a limitaciones de inspección visual [20].
* **Impacto de la Instalación:** Es imperativo revisar los registros de instalación ("Driving logs") en análisis de fallas para correlacionar daños con eventos de hincado severo [12].

---

## 9. Conclusiones y Recomendaciones Técnicas

1.  **Complejidad Sistémica:** La abolladura es un iniciador de degradación compleja (P-delta, SCF, fatiga-corrosión), no un defecto estático simple.
2.  **Jerarquía de Riesgo Espacial:** La **Zona de Salpicadura** es la máxima amenaza, pero los **Objetos Caídos** en niveles inferiores son un "riesgo silencioso".
3.  **Importancia de la Historia:** La capacidad residual depende de la edad del daño; daños tempranos consumen más vida a fatiga.
4.  **Efectividad de la Reparación:** El **Grouting Interno** es la opción más eficiente para daños moderados en extensión de vida.
5.  **Imperativo Normativo:** Adherirse a los límites de ISO 19902 ($h < 0.3D$) y usar FEA avanzado para daños severos es obligatorio.

**Recomendaciones:** Implementar fotogrametría para digitalizar abolladuras, integrar daños en modelos *Digital Twin* y revisar registros históricos de instalación en análisis forenses.

---

## Referencias y Fuentes Citadas

* [433] Investigation and analysis of ship to platform collision incidents on the UK continental shelf. Taylor & Francis.
* [436] Ship/platform collision incident database (2001). Health and Safety Executive.
* [440] Dropped Object Risk Assessment for Fixed Offshore... OAKTrust.
* [445] Pile Fatigue Assessment During Driving. ResearchGate.
* [447] Repairing and strengthening of ageing offshore structures. Engineer Live.
* [454] Limiting Criteria of Dent Damage for Fixed Offshore Platform. UTPedia.
* [455] Residual Strength and Repair of Damaged and Deteriorated Offshore Structures. BSEE.
* [458] Assessment of Stress Concentration Factors of Dented Rigid Risers. ASME.
* [460] ISO 19902: Fixed Steel Offshore Structures Standard.
* [461] Fatigue Analysis of Jacket Structures. Cambridge University Press.
* [474] API Recommended Practice 2A-WSD. API.
* [476] A Corrosion- and Repair-Based Reliability Framework for Offshore Platforms. MDPI.