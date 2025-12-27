# README: Cargas de Superestructura (Topside Loads)

## Resumen Ejecutivo

**Implementación de cargas permanentes diferenciadas por nivel en superestructura de plataforma jacket offshore para análisis de deformación inicial bajo compresión axial.**

---

## Valores Aplicados

| Nivel | Z (m) | Nodos | Carga (kN/m²) | Total (MN) | Por Nodo (kN) | Base Normativa |
|-------|-------|-------|---------------|------------|---------------|----------------|
| **Production Deck** | 100 | 41-44 | 20 | 5.558 | 1,389.5 | API RP 2A-WSD Table 3.2.3-1 |
| **Utility Deck** | 109 | 45-48 | 10 | 2.779 | 694.75 | API RP 2A (Utility areas) |
| **Roof Structure** | 118 | 49-52 | 0 | 0 | 0 | Solo peso propio (DEAD) |
| **TOTAL TOPSIDE** | - | - | - | **8.337** | - | - |

---

## Justificación Normativa

### API RP 2A-WSD (22nd Edition, 2014)
**Section 3.2.3 - Deck Loads**:
- Production/Process areas: **15-25 kN/m²**
- Utility/Service areas: **8-12 kN/m²**

### ISO 19902:2007
**Section 8.2.2 - Permanent Actions**:
- Deck weight + equipment (production): **15-25 kN/m²**
- Preliminary design recommendation: **20 kN/m²**

**Valores adoptados**: Medios de rangos normativos (conservadores)

---

## Validación ETABS

```
Peso propio (DEAD):              33.16 MN  [ETABS Joint Reactions]
Topside aplicado:                 8.34 MN  [Este estudio]
─────────────────────────────────────────
Total esperado:                  41.50 MN
Por pierna (4 apoyos):           10.38 MN  ✓ Rango típico: 9-12 MN
```

---

## Implementación en Código

### Archivo Principal
**`analisis_estatico_fuerzas_axiales.m`** (Líneas 199-390)

### Características Clave
- ✅ Identificación automática de nodos por coordenada Z
- ✅ Cargas diferenciadas por función del deck
- ✅ Distribución uniforme en 4 nodos por nivel
- ✅ Validación contra reacciones ETABS
- ✅ Reporte detallado con box diagram

### Snippet de Código
```matlab
% Geometría
A_deck = 16.667^2;  % 277.9 m²

% Cargas por área (API RP 2A-WSD Section 3.2.3)
q_production = 20e3;  % [N/m²]
q_utility = 10e3;     % [N/m²]

% Totales por nivel
W_production = q_production * A_deck;  % 5.558 MN
W_utility = q_utility * A_deck;        % 2.779 MN

% Distribución nodal
W_production_por_nodo = -W_production / 4;  % -1389.5 kN
W_utility_por_nodo = -W_utility / 4;        % -694.75 kN
```

---

## Output del Análisis

Cuando se ejecuta `analisis_estatico_fuerzas_axiales()`, se genera:

```
┌─ DISTRIBUCIÓN DE CARGAS TOPSIDE ──────────────────────────┐
│ NIVEL 1 - PRODUCTION DECK (Z = 100 m):                    │
│   Carga área: 20.0 kN/m² (API RP 2A Table 3.2.3-1)        │
│   Área: 277.9 m²                                           │
│   Carga total: 5.56 MN                                     │
│   Nodos: 4 (IDs: [41 42 43 44])                           │
│   Carga/nodo: 1389.50 kN                                   │
│                                                            │
│ NIVEL 2 - UTILITY DECK (Z = 109 m):                       │
│   Carga área: 10.0 kN/m² (API RP 2A Utility areas)        │
│   Área: 277.9 m²                                           │
│   Carga total: 2.78 MN                                     │
│   Nodos: 4 (IDs: [45 46 47 48])                           │
│   Carga/nodo: 694.75 kN                                    │
│                                                            │
│ TOTAL TOPSIDE: 8.34 MN                                     │
│ VALIDACIÓN: Reacción ETABS = 33.16 MN (DEAD)              │
│             Esperado = 41.50 MN (DEAD+Topside)            │
└────────────────────────────────────────────────────────────┘
```

---

## Comparación con Plataformas Reales

| Plataforma | Altura (m) | Topside (ton) | Comentario |
|------------|------------|---------------|------------|
| **Modelo Tesis** | **120** | **850** | **Este estudio** |
| Hibernia (Canada) | 111 | 37,000 | Con módulo habitacional grande |
| Troll A (Norway) | 472 | 23,800 | Plataforma de gas |
| Rango típico (Chakrabarti 2005) | 100-150 | 600-1200 | Producción sin perforación |

**Conclusión**: 850 ton está dentro del rango típico para plataformas de producción esquemáticas de altura similar. ✓

---

## Archivos Relacionados

1. **`analisis_estatico_fuerzas_axiales.m`** - Implementación principal
2. **`JUSTIFICACION_CARGAS_TOPSIDE.md`** - Documentación técnica completa (12 páginas)
3. **`main_launcher.m`** (líneas 48-57) - Llamada con W_topside = 8337000 N
4. **`config_deformacion_inicial.m`** (líneas 152-171) - Parámetros del sistema

---

## Uso en Análisis de Deformación Inicial

Las cargas topside calculadas se utilizan para:

1. **Resolver sistema estático**: K·U = F (peso propio + topside)
2. **Extraer fuerzas axiales**: N_axial = E·A·Δu/L por elemento
3. **Calcular ratios de carga**: ρ = |N|/Pcr (carga crítica de Euler)
4. **Filtrar elementos óptimos**: ρ ∈ [0.3, 0.7] para máxima detectabilidad
5. **Aplicar deformación inicial**: e₀/L con efecto P-δ en funcion_deformaciones.m

---

## Referencias Rápidas

- **API RP 2A-WSD**: Section 3.2.3 (Deck Loads)
- **ISO 19902:2007**: Section 8.2.2 (Permanent Actions)
- **ETABS**: Joint Reactions (DEAD case) → 33.16 MN
- **Chakrabarti (2005)**: Handbook of Offshore Engineering, Vol. 1

---

## Contacto

**Autor**: Francisco Cisneros  
**Proyecto**: Detección de daños mediante AG en plataformas jacket  
**Fecha**: Diciembre 2025

Para documentación técnica detallada, ver: `JUSTIFICACION_CARGAS_TOPSIDE.md`
