# 📑 Esquema de validación del AG

## 1. Organización de casos de daño

Divide los escenarios en **tres niveles de severidad** (alineados con la literatura y con los criterios de inspección en campo):

- **Daño leve (menor)**
    - Abolladura: $(d/D < 10{\%})$ o justo debajo del umbral de “menor” del reporte (p. ej. 5–15%).
    - Corrosión: pérdida de espesor **< 5%** (zona de salpicadura o intermedia).
- **Daño medio (transición)**
    - Abolladura: $(10{\%} \leq d/D < 20{\%})$.
    - Corrosión: pérdida de espesor entre **5–10%**.
- **Daño severo (mayor)**
    - Abolladura: $(d/D > 30{\%})$ o $(d > 10t{\%})$ (criterio del JIP 2000).
    - Corrosión: pérdida de espesor **> 10–15%**, casos críticos en **splash zone** o cerca del **mudline**.

*(Estos rangos los puedes ajustar a tu geometría de referencia, pero la idea es cubrir los tres escalones).*

---

## 2. Protocolo de validación

1. **Generación de casos sintéticos**:
    - Define escenarios de daño en elementos representativos (piernas, braces diagonales, braces horizontales).
    - Ubícalos en zonas clave: **splash zone**, **nivel intermedio**, **mudline**.
2. **Simulación dinámica**:
    - Obtén frecuencias naturales y modos para cada escenario (con y sin daño).
    - Aplica tu AG con función objetivo (MAC, RMSE, índice de flexibilidad).
3. **Métricas de desempeño del AG**:
    - **Tasa de detección (TD)**: % de veces que el AG identifica correctamente el elemento dañado.
    - **Error relativo de estimación (ERE)**: diferencia entre daño simulado y detectado (%).

---

## 3. Cómo presentar los resultados

- **Tabla comparativa** por nivel de severidad:
    
    
    | Nivel | Tipo de daño | % detectado correctamente | Error promedio AG | Observación |
    | --- | --- | --- | --- | --- |
    | Leve | Abolladura (5–10% D) | XX% | YY% | Más difícil, aporta originalidad. |
    | Medio | Corrosión (5–10% t) | XX% | YY% | Zona de transición. |
    | Severo | Abolladura (>30% D) | ~100% | bajo | Fácil de detectar, valida el método. |
- **Gráficas** de convergencia del AG (fitness vs. generación) para un caso leve y uno severo.
- **Discusión**: enfatizar que el AG es útil porque puede **detectar daño incipiente (menor)**, donde inspecciones visuales o simples frecuencias no bastan.

---

## 4. Mensaje clave para tu tésis

- Detectar **casos severos** es casi obligatorio, pero no sorprende (son evidentes).
- El **aporte real** es mostrar que tu AG **logra identificar daños leves o intermedios**, que son **más frecuentes en la práctica** (según el JIP 2000 y tu segundo artículo de Nigeria).
- Eso le da **valor aplicado** y **originalidad** a tu trabajo, porque apoya la detección temprana → mantenimiento preventivo → ahorro en integridad estructural.

---

## Referencias

- JIP (2000). *Damage Data for Gulf of Mexico Fixed Offshore Platforms*. Informe de Joint Industry Project, OCS, Golfo de México. link: [https://www.bsee.gov/sites/bsee.gov/files/tap-technical-assessment-program//345aa.pdf#:~:text=remaining 1%2C232 dents%2C 10,the population of inspected platforms](https://www.bsee.gov/sites/bsee.gov/files/tap-technical-assessment-program//345aa.pdf#:~:text=remaining%201%2C232%20dents%2C%2010,the%20population%20of%20inspected%20platforms)
- Ayorinde, O. O. y otros (2011). *Reliability assessment of offshore jacket structures in Niger Delta*. Petroleum & Coal, 53(4):291–301.