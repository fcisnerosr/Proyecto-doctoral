# Configuración de secciones no prismáticas con secciones intermedias en ETABS

## 1. Definir segmentos S0 → S1 → S2 vs. S0 → S2 con interpolación  
La documentación oficial de CSI recomienda **modelar cada tramo de transición como un segmento separado**, en lugar de usar una sola interpolación sobre todo el elemento.  
En otras palabras, **sí conviene definir segmentos individuales** para S0→S1 y luego S1→S2, especialmente cuando S1 es una sección intermedia distinta (por ejemplo, una transición o abolladura parcial) y no simplemente un resultado de interpolación lineal entre S0 y S2.  

ETABS permite dividir la longitud del elemento en varios segmentos (usualmente hasta cinco) para representar variaciones de sección a lo largo de un mismo miembro. De hecho, las propiedades de sección pueden **cambiar discontinuamente de un segmento al siguiente**, reflejando cambios abruptos si es necesario.  

En la *Knowledge Base* de CSI se indica que:  

> “Para modelar una serie de tramos con variación de sección dentro de un mismo elemento, se sigue el mismo proceso mientras se ajusta la definición de Longitud en proporción a cada segmento.” (fuente: [CSI KB – Nonprismatic frame objects](https://wiki.csiamerica.com/display/kb/Nonprismatic+frame+objects))  

Esto implica asignar a cada segmento una porción de la longitud total, de modo que la geometría pase por S0, luego por S1, y finalmente alcance S2 al final del elemento.  

✅ *En resumen:* Es preferible **modelar explícitamente la sección intermedia (S1) mediante segmentos separados**, en lugar de suponer una única transición S0→S2.

---

## 2. Configuración de los campos en ETABS  

Al definir la propiedad de una sección no prismática en ETABS, debemos ingresar varios parámetros para cada segmento:

- **Start Section / End Section:**  
  En cada segmento, seleccione en *Start Section* la sección transversal al inicio (ej. S0) y en *End Section* la sección al final del tramo (ej. S1).  
  Para el siguiente segmento, *Start = S1* y *End = S2*.  
  *(El material debe ser el mismo en ambos extremos, aunque ETABS no obliga a ello.)*  
  (fuente: [ETABS Help – Frame Section Property Data](https://wiki.csiamerica.com/display/etabs/Frame+Section+Property+Data))

- **Length Type:**  
  Puede ser **Proportional (Variable)** o **Absolute (Absoluta)**.  
  - **Proportional:** se asigna un factor adimensional (ej. 1.0). Si varios segmentos son proporcionales, la longitud remanente se reparte según los factores ingresados.  
  - **Absolute:** se especifica la longitud real del segmento (ej. en mm).  
  (fuente: [ETABS Help – Frame Section Property Data](https://wiki.csiamerica.com/display/etabs/Frame+Section+Property+Data))

- **Length (mm o proporción):**  
  - Con *Absolute* se ingresa la longitud real.  
  - Con *Proportional* se usa un número adimensional (ej. 1.0 para 100% del tramo, o 1 y 2 si se quiere dividir en tercios).  
  (fuente: [CSI KB – Nonprismatic frame objects](https://wiki.csiamerica.com/display/kb/Nonprismatic+frame+objects))

- **EI33 Variation & EI22 Variation:**  
  Controlan cómo varía la rigidez a flexión en los ejes principales (33 = fuerte, 22 = débil).  
  Se puede elegir **Linear, Parabolic o Cubic**.  
  - Para vigas tipo I, CSI recomienda **Parabolic en EI33** (eje fuerte) y **Linear en EI22** (eje débil).  
  (fuente: [CSI KB – Nonprismatic frame objects](https://wiki.csiamerica.com/display/kb/Nonprismatic+frame+objects))

---

## 3. Ejemplo de configuración para tu caso

| Start Section | End Section | Length Type  | Length | EI33 Variation | EI22 Variation |
|---------------|-------------|--------------|--------|----------------|----------------|
| S0            | S1          | Proportional | 1.0    | Parabolic      | Linear         |
| S1            | S2          | Proportional | 1.0    | Parabolic      | Linear         |

---

# Configuración: Con sección intermedia (S1)

Si conoces dónde empieza la abolladura (**S1**) y dónde está el máximo (**S2**), se recomienda usar **4 segmentos** para modelar la transición completa:  
- De la sección intacta (**S0**) hacia la abolladura parcial (**S1**)  
- De la abolladura parcial (**S1**) al punto máximo (**S2**)  
- Y luego el regreso de **S2 → S1 → S0**

---

## Condición de longitudes
Definimos dos valores:
- **L1** = tramo S0 → S1  
- **L2** = tramo S1 → S2  

Debe cumplirse la ecuación:  
2L1 + 2L2 = Longitud total

En tu caso:  
2L1 + 2L2 = 4000 mm → L1 + L2 = 2000 mm

Ejemplo numérico:  
- **L1 = 1200 mm**  
- **L2 = 800 mm**

---

## Tabla de configuración en ETABS

| Start Section | End Section | Length Type | Length (mm) | EI33 Variation | EI22 Variation |
|---------------|-------------|-------------|-------------|----------------|----------------|
| S0            | S1          | Absolute    | 1200        | Cubic          | Cubic          |
| S1            | S2          | Absolute    | 800         | Cubic          | Cubic          |
| S2            | S1          | Absolute    | 800         | Cubic          | Cubic          |
| S1            | S0          | Absolute    | 1200        | Cubic          | Cubic          |

---

## Notas
- **EI33** corresponde al eje fuerte (local 3–3, asociado a tu VIy).  
- **EI22** corresponde al eje débil (local 2–2, asociado a tu VIz).  
- Con **Cubic** en ambos, la variación de rigidez será continua y más realista a lo largo de toda la zona dañada.  
- La suma de todas las longitudes de fila debe ser **4000 mm**, que corresponde al largo total del elemento tubular.
## 4. Referencias oficiales

- [ETABS Help – Frame Section Property Data](https://wiki.csiamerica.com/display/etabs/Frame+Section+Property+Data)  
- [CSI KB – Nonprismatic frame objects](https://wiki.csiamerica.com/display/kb/Nonprismatic+frame+objects)  
