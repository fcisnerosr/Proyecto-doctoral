# Integración: Análisis Estático de Fuerzas Axiales

## Objetivo
Calcular las fuerzas axiales (N) y ratios de carga crítica (ρ) necesarios para usar `funcion_deformaciones.m` en elementos con deformación inicial.

## Archivos Creados

### 1. `analisis_estatico_fuerzas_axiales.m`
**Ubicación**: `code/001_framework_resultados_journal/001_runExperimentos/003_funcion_deformaciones/`

**Propósito**: Función principal que realiza bajada de cargas estática.

**Entradas**:
- `nodes`, `elements`, `A`, `Iy`, `Iz`, `J`, `E`, `G`, `vxz`, `ID` (desde `lectura_hoja_excel.m`)
- `W_topside`: Peso superestructura [N] (8290953.54 N en tu proyecto)
- `incluir_peso_propio`: true/false

**Salidas**:
- `N_axial`: [nElem×1] Fuerza axial por elemento [N]
- `rho`: [nElem×1] Ratio ρ = |N|/Pcr [-]
- `Pcr`: [nElem×1] Carga crítica de Euler [N]
- `diagnostico`: Struct con información adicional

### 2. `test_bajada_cargas.m`
**Ubicación**: `code/001_framework_resultados_journal/001_runExperimentos/003_funcion_deformaciones/`

**Propósito**: Script de validación y prueba de integración.

**Funciones**:
- Lee datos del modelo (igual que `main_launcher.m`)
- Ejecuta análisis estático
- Identifica elementos óptimos (0.3 ≤ ρ ≤ 0.7)
- Genera gráficas de diagnóstico
- Exporta resultados a CSV y MAT
- Prueba integración con `funcion_deformaciones.m`

## Flujo de Integración

### PASO 1: Ejecutar Test (Primera Vez)
```matlab
% Navegar al directorio
cd('/home/fcisnerosr/github/proyecto_doctoral/code/001_framework_resultados_journal/001_runExperimentos/003_funcion_deformaciones')

% Ejecutar test
test_bajada_cargas
```

**Qué hace**:
1. Lee estructura desde `marco3Ddam0.xlsx`
2. Calcula N_axial y ρ para los 136 elementos
3. Identifica elementos con 0.3 ≤ ρ ≤ 0.7 (óptimos para detección)
4. Genera figura con 6 subplots
5. Exporta:
   - `Resultados/fuerzas_axiales_estatico.csv`
   - `Resultados/analisis_estatico_workspace.mat`

**Tiempo esperado**: ~1-2 segundos

### PASO 2: Validar con ETABS (Opcional)
Si tienes tabla de fuerzas axiales de ETABS:
```matlab
% En test_bajada_cargas.m, línea 85 (descomenta y modifica):
N_axial_ETABS = readtable('tu_tabla_etabs.csv');
error_rel = abs(N_axial - N_axial_ETABS.Force) ./ abs(N_axial_ETABS.Force);
fprintf('Error relativo: %.2f%% ± %.2f%%\n', 100*mean(error_rel), 100*std(error_rel));
```

### PASO 3: Integrar en main_launcher.m
Agregar después de la línea 48 (antes de `ensamblaje_matriz_rigidez_global_sin_dano`):

```matlab
% -------------------------------------------------------------------------
% 4.0) ANÁLISIS ESTÁTICO DE FUERZAS AXIALES (para daño tipo 3)
% -------------------------------------------------------------------------
fprintf('Calculando fuerzas axiales estáticas...\n');

W_topside = 8290953.54;  % [N] Peso de superestructura
incluir_peso_propio = true;

[N_axial_global, rho_global, Pcr_global, diag_estatico] = ...
    analisis_estatico_fuerzas_axiales(...
        nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio);

fprintf('  ✓ Fuerzas axiales calculadas\n');
fprintf('  ✓ Elementos con ρ∈[0.3,0.7]: %d\n', ...
    sum(rho_global >= 0.3 & rho_global <= 0.7));
```

### PASO 4: Usar en Ensamblaje con Daño
Modificar `ensamblaje_matriz_rigidez_global_con_dano.m` para aceptar N_axial:

```matlab
% Firma actualizada
function [KG_damaged] = ensamblaje_matriz_rigidez_global_con_dano(...
    ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, ...
    elementos_danados, tipo_dano, severidad, prop_geom, N_axial_global)  % NUEVO
    
    % Dentro del loop de elementos:
    for i = 1:NE
        % ... código existente ...
        
        % Si elemento tiene daño tipo 3 (deformación inicial)
        if ismember(i, elementos_danados) && strcmp(tipo_dano{i}, 'deformacion_inicial')
            % Extraer propiedades
            L_elem = ...;  % Longitud del elemento
            D_elem = ...;  % Diámetro de prop_geom
            t_elem = ...;  % Espesor de prop_geom
            e0_sobre_L = severidad(i);  % Magnitud de deformación inicial
            
            % Usar N_axial del análisis estático
            N_comp = N_axial_global(i);  % CLAVE: usar precalculado
            
            % Calcular Kt con deformación inicial
            [~, Kt, ~, ~, ~, ~, ~, ~, ~] = funcion_deformaciones(...
                L_elem, D_elem, t_elem, E(i), 0.3, 7850, ...
                N_comp, e0_sobre_L, 5, false);
            
            % Transformar a coordenadas globales
            kg(:,:,i) = Gamma' * Kt * Gamma;  % Usar Kt en vez de ke
        else
            % Elemento intacto u otros tipos de daño
            ke(:,:,i) = localkeframe3D(...);
            kg(:,:,i) = Gamma' * ke(:,:,i) * Gamma;
        end
    end
end
```

### PASO 5: Benchmark para 120 Elementos
Script para probar cada elemento individualmente:

```matlab
% benchmark_deformacion_inicial.m
% Probar daño en cada uno de los 120 elementos de subestructura

% Cargar fuerzas axiales
load('Resultados/analisis_estatico_workspace.mat', 'N_axial', 'rho');

% Elementos de subestructura (IDs 1-120)
elementos_subestructura = 1:120;

% Filtrar elementos óptimos
idx_optimos = find(rho >= 0.3 & rho <= 0.7);
elementos_a_probar = intersect(elementos_subestructura, idx_optimos);

fprintf('Elementos óptimos a probar: %d\n', length(elementos_a_probar));

% Niveles de deformación inicial a probar
niveles_e0 = [0.005, 0.01, 0.02, 0.03];  % 0.5%, 1%, 2%, 3%

% Matriz de resultados
resultados = zeros(length(elementos_a_probar), length(niveles_e0));

for i = 1:length(elementos_a_probar)
    elem_id = elementos_a_probar(i);
    
    for j = 1:length(niveles_e0)
        e0 = niveles_e0(j);
        
        % Configurar daño
        config.elementos_danados = elem_id;
        config.tipo_dano = 'deformacion_inicial';
        config.severidad = e0;
        
        % Ejecutar AG
        [deteccion, error_pos] = ejecutar_AG_single(...
            config, N_axial, rho, ...);  % Pasar N_axial
        
        resultados(i, j) = deteccion;  % 1=éxito, 0=fallo
    end
    
    fprintf('Elemento %d: [%d/%d, %d/%d, %d/%d, %d/%d]\n', ...
        elem_id, resultados(i,:));
end

% Análisis de resultados
tasa_deteccion = mean(resultados, 1);
fprintf('\nTasa de detección por nivel:\n');
for j = 1:length(niveles_e0)
    fprintf('  e₀/L = %.1f%%: %.1f%%\n', ...
        niveles_e0(j)*100, tasa_deteccion(j)*100);
end
```

## Elementos Óptimos Esperados

Según tu estructura (4 legs × 5 niveles):

| Ubicación | Rango ρ esperado | Detectabilidad | N típico |
|-----------|------------------|----------------|----------|
| **Legs nivel 1-2** (inferior) | 0.5 - 0.7 | ★★★★★ Muy Alta | -300 a -500 kN |
| **Legs nivel 3-4** (medio) | 0.3 - 0.5 | ★★★ Media | -150 a -300 kN |
| **Legs nivel 5** (superior) | 0.2 - 0.3 | ★ Baja | -50 a -150 kN |
| **X-braces nivel 1-2** | 0.2 - 0.4 | ★★ Media-baja | -100 a -200 kN |
| **X-braces nivel 3-5** | 0.1 - 0.2 | ✗ Muy baja | -20 a -80 kN |

**Elementos más prometedores**: Legs en niveles inferiores (cercanos a mudline).

## Próximos Pasos

1. ✅ **Ejecutar test_bajada_cargas.m** → Validar que funciona
2. ⏳ Comparar con ETABS → Verificar N_axial es razonable
3. ⏳ Integrar en main_launcher.m → Agregar precálculo
4. ⏳ Modificar ensamblaje_con_dano.m → Aceptar N_axial
5. ⏳ Ejecutar benchmark → Probar 120 elementos

## Archivos a Modificar (Resumen)

| Archivo | Acción | Prioridad |
|---------|--------|-----------|
| `main_launcher.m` | Agregar llamada a `analisis_estatico_fuerzas_axiales` | Alta |
| `ensamblaje_matriz_rigidez_global_con_dano.m` | Agregar parámetro `N_axial_global`, integrar `funcion_deformaciones` | Alta |
| `runExperimentos.m` | Pasar `N_axial` a funciones hijas | Media |
| `GA.m` | Asegurar que pasa `N_axial` a ensamblaje | Media |

## Preguntas a Resolver

1. ¿Los resultados de N_axial son razonables comparados con ETABS?
2. ¿Cuántos elementos caen en el rango óptimo 0.3 ≤ ρ ≤ 0.7?
3. ¿El AG actual puede manejar parámetro adicional `N_axial`?

**¡LISTO PARA EJECUTAR EL TEST!**
