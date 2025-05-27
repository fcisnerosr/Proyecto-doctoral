Prompts:
Te explico mi proyecto de doctorado:
Objetivo: Evaluar los daños ocasionados por la corrosión en los elementos tubulares de la subestructura de un modelo numérico representativo de una plataforma marina fija, con el propósito de optimizar las estrategias de mantenimiento mediante la reducción de inspecciones globales, enfocándose en inspecciones puntuales dirigidas a zonas críticas identificadas.

1. Tengo un modelo representativo de una plataforma marina en ETABS
2. Exporto todos las propiedades geométricas y nodos de los elementos tubulares
3. modifico la matriz de masas, añado masa atrapada, crecimiento marino y masa adherida
4. asigno un daño a un elemento con un numero asignado, con un porcentaje de daño, armo la matriz de flexibilidad de ese elemento, la invierto para tener la matriz de rigidez local
5. armo la matriz de rigidez global del modelo sin daño, es decir, intacto.
6. armo también la matriz de rigidez global con daño, reemplazando la matriz de rigidez local con daño de ese numero de elemento asignado, armo la matriz de rigidez con daño.  Este es el modelo con daño inicial que el AG debe indentificar
7. condenso ambas matricez de rigidez global, la intacta y la que tiene daño, así como la matriz de masas
8. calculo las formas modales de ambas matrices de los modelos
9. filtro los nodos de la superestructura, ya que no están dentro mi objetivo
10. Calculo 8 índices de daño (DIs)
_formas modales_
10.1 DI1 = COMAC de formas modales del modelo intacto y del modelo con daño
10.2 DI2 = es la diferencia absoluta de las formas modales del modelo intacto y del modelo con daño
10.3 DI3 = división de las formas modales del modelo intacto y del modelo con daño
_matriz de flexibilidad_
10.4 DI4 = diferencia de la matrices de flexibilidades del modelo intacto y del modelo con daño
10.5 DI5 = división de las matrices de flexibilidades del modelo intacto y del modelo con daño
10.6 DI6 = diferencia en porcentaje de la matrices de flexibilidades del modelo intacto y del modelo con daño
10.7 DI7 = z-score de la matriz de flexibilidades del modelo intacto y del modelo con daño
10.8 DI8 = probabilida del z-score del modelo intacto y del modelo con daño
1.  Calculo de AG (algoritmo genético)
11.1 se realiza una suma ponderada de 8 pesos que multiplican a cada uno de los DIs, la funcion objetivo es esta suma ponderada cuyo objetivo es minimizar la diferencia entre cada DI del modelo intacta y el modelo con daño
1.  Imprime los resultados



_Ejemplo de búsqueda y generación de párrafos para mi artículo_
    Te adjuntaré el artículo titulado Feasibility for Damage Identification in Offshore Wind Jacket Structures through Monitoring of Global Structural Dynamics. Estoy realizando una investigación relacionada con la detección de daños en plataformas marinas tipo *Jacket*, enfocándome específicamente en elementos corroidos de la subestructura. Mi objetivo es identificar daños de forma localizada mediante el análisis de formas modales y el uso de algoritmos genéticos (AG), con el fin de optimizar los costos de inspección evitando revisiones estructurales completas.

    Estoy particularmente interesado en el siguiente tema general y sus subpuntos:

    **5. Métodos numéricos avanzados en detección de daños:**
    - Modelación numérica de estructuras offshore utilizando software especializado (como ETABS, SAP2000, ANSYS, ABAQUS u OpenSees).
    - Técnicas basadas en dinámica estructural y análisis modal, especialmente *Operational Modal Analysis (OMA)*.

    Me gustaría que al revisar el artículo pudieras identificar si se presentan:
    1. Evidencias del uso de modelos matemáticos o numéricos en la detección de daños.
    2. Aplicaciones específicas de estos modelos en el contexto de plataformas marinas.
    3. Relación entre los métodos utilizados y su efectividad en la localización puntual de daños (en lugar de inspecciones estructurales globales).
    4. Contribuciones de estas metodologías al mantenimiento estructural y la reducción de costos operativos.

    Con base en los cuatro puntos anteriores, quisiera que generes un párrafo redactado en lenguaje técnico que pueda ser integrado en mi artículo de tesis. Dicho párrafo debe tener coherencia con lo que ya he escrito en mi artículo.

    A continuación te enviaré lo que ya llevo escrito hasta ahora.

    Este no es el fin de mi introducción, sino que estamos armando la introducción poco a poco.


De este proceso realicé 2160 corridas.
dañé del elemento no.1 hasta el elemento 120, cada corrida se daña un elemento desde el 5% hasta el 90% con pasos de 5. dando igual a las 2160 corridas
Las columnas de mi archivo.csv son:
ID: es el número de corrida
Element: elemento tubular con daño
Percentage: Porcentaje de corrosión del elemento tubular
Final_Objective: es la suma ponderada de la funcion objetivo del AG
DetectionOK: es el si AG detecta daño o no
AvgDispersion: cuando el AG trabaja e indica valor de DI que no es el elemento con daño, calcula una dispersión promedio de los elementos que no son los dañados en el modelo incial con daño
StdDispersion: es la desviacion estandar de PromDispersion
N_FalsePositives: Es el número de falsos positivos que identifica el AG
Type_of_element_to_search: es e tipo de elemento (piera es una columna inclinada, viga o elemento diagonal , x bracers) que se daña en el modelo inicial
Story: piso donde esta ubicado en el modelo numérico, tanto con daño e intacto

ID,Elemento,Porcentaje,Tiempo_s,ObjFinal,DeteccionOK,PromDispersion,StdDispersion,MeanAbsDispersion,N_FalsosPositivos,Tipo_elemento_a_buscar
1,1,5,4178.298416,0.312916615,VERDADERO,10.26405577,9.66860783,10.26405577,1,pierna
2,1,10,4234.230792,0.156594643,VERDADERO,7.835070522,6.578795869,7.835070522,1,pierna
3,1,15,4288.113483,0.140108301,VERDADERO,7.077522565,6.46771868,7.077522565,1,pierna
4,1,20,4353.540449,0.136951236,VERDADERO,6.742003473,6.516047718,6.742003473,1,pierna
5,1,25,4418.229896,0.134340811,VERDADERO,6.527849025,6.542074014,6.527849025,1,pierna
6,1,30,4483.913564,0.130853316,VERDADERO,6.371133919,6.522193133,6.371133919,1,pierna
7,1,35,4533.097503,0.12658566,VERDADERO,6.238905614,6.460642091,6.238905614,1,pierna
8,1,40,4582.662004,0.121818024,VERDADERO,6.127645504,6.359745944,6.127645504,1,pierna
9,1,45,4632.753268,0.116706221,VERDADERO,6.01334201,6.245797501,6.01334201,1,pierna
10,1,50,4678.552163,0.111366568,VERDADERO,5.893470995,6.125950793,5.893470995,1,pierna
11,1,55,4731.601217,0.105745186,VERDADERO,5.757510965,6.000611378,5.757510965,1,pierna

Sugiereme qué puedo calcular para sacar hallazgos para mi artículo cientíco con estas liberías:

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

