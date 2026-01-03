function config = config()
% CONFIG - Configuración de experimentos para detección de daño
%
% Retorna estructura config con parámetros para runExperimentos.m
%
% MODIFICACIONES PARA DAÑO TIPO 3 (deformación inicial):
%   - Agregar tipo_dano = 'deformacion_inicial'
%   - Ajustar porcentajes (e0/L en %)
%   - Seleccionar elementos con ρ óptimo

% =========================================================================
% TIPO DE EXPERIMENTO
% =========================================================================
% Opciones: 'simple' (un elemento), 'combinado' (múltiples)
config.tipo = 'simple';

% =========================================================================
% TIPO DE DAÑO
% =========================================================================
% Opciones: 'corrosion', 'abolladura', 'deformacion_inicial'
config.tipo_dano = 'deformacion_inicial';  % NUEVO: daño tipo 3

% =========================================================================
% ELEMENTOS A PROBAR
% =========================================================================
% Para benchmark: probar elementos con ρ ∈ [0.3, 0.7] (óptimos)
% Basado en análisis estático, estos elementos tendrán mayor detectabilidad

% OPCIÓN A: Prueba rápida con pocos elementos
% config.rangoElem = [10, 25, 40];  % 3 elementos de ejemplo

% OPCIÓN B: Elementos específicos (legs inferiores, esperados con ρ alto)
% config.rangoElem = [1, 2, 3, 4];  % Legs nivel 1 (más cargados)

% OPCIÓN C: Barrido completo de subestructura (120 elementos)
config.rangoElem = 1:120;  % Todos los elementos de subestructura

% NOTA: El script filtrará automáticamente elementos con ρ<0.3 o ρ>0.75
%       para evitar casos poco detectables o inestables

% =========================================================================
% MAGNITUDES DE DEFORMACIÓN INICIAL (e0/L en %)
% =========================================================================
% Rango típico:
%   - 0.1-0.5%: Imperfecciones de fabricación (API, ISO)
%   - 1-2%: Daño moderado
%   - 3-5%: Daño severo

switch config.tipo_dano
    case 'deformacion_inicial'
        % Niveles de deformación inicial a probar
        config.porcentajes = [0.5, 1.0, 2.0, 3.0];  % [%] e0/L
        
        % Descripción para reporte
        config.descripcion = 'Deformación inicial (bow imperfection) en elementos tubulares';
        
    case 'corrosion'
        % Niveles de corrosión uniforme
        config.porcentajes = [5, 10, 15, 20];  % [%] reducción de espesor
        config.descripcion = 'Corrosión uniforme en elementos tubulares';
        
    case 'abolladura'
        % Profundidad de abolladura
        config.porcentajes = [5, 10, 15, 20];  % [%] del diámetro
        config.descripcion = 'Abolladura local (dent) en elementos tubulares';
        
    otherwise
        error('Tipo de daño "%s" no reconocido', config.tipo_dano);
end

% =========================================================================
% FUENTE DE FUERZAS AXIALES (DECISION KEY)
% =========================================================================
% OPCIONES:
%   'codigo' - Calcula N_axial con FEM interno (analisis_estatico_fuerzas_axiales.m)
%              Ventajas: Autosuficiente, documentado, bajo control total
%              Desventajas: Puede diferir de ETABS (29% típico)
%
%   'etabs'  - Lee N_axial desde CSV exportado de ETABS
%              Ventajas: Consistencia con software comercial, fuerzas validadas
%              Desventajas: Requiere archivo externo, dependencia de export manual
%
% RECOMENDACIÓN: Usar 'etabs' para análisis de deformación inicial
%                (mayor ρ → mejor detectabilidad: ~40% incremento)
config.fuente_fuerzas_axiales = 'etabs';  % 'codigo' | 'etabs'

% Ruta al CSV de fuerzas ETABS (solo si fuente_fuerzas_axiales='etabs')
config.csv_fuerzas_etabs = fullfile(...
    fileparts(mfilename('fullpath')), ...
    '003_funcion_deformaciones', ...
    'carga_axial_ETABS.csv');

% =========================================================================
% FILTROS DE SEGURIDAD PARA DEFORMACIÓN INICIAL
% =========================================================================
if strcmp(config.tipo_dano, 'deformacion_inicial')
    % NOTA: Para estructuras offshore muy robustas (jacket con Pcr >> N_axial)
    % el ratio ρ típico es mucho menor que los valores de literatura (0.3-0.7)
    % Con fuerzas código: ρ_max ≈ 0.008 (0.8%)
    % Con fuerzas ETABS:  ρ_max ≈ 0.012 (1.2%, +50% detectabilidad)
    
    % Límites ajustados a estructura real
    config.rho_min = 0.001;  % 0.1% de carga crítica (mínimo razonable)
    config.rho_max = 0.050;  % 5% de carga crítica (elementos más cargados)
    
    config.e0_max = 5.0;     % [%] Máximo e0/L permitido
    
    % Deshabilitar filtro para permitir análisis de toda la estructura
    % (El AG identificará los elementos más sensibles automáticamente)
    config.filtrar_elementos_por_rho = false;
else
    % Sin filtros especiales para otros tipos de daño
    config.filtrar_elementos_por_rho = false;
end

% =========================================================================
% CONFIGURACIÓN DEL AG
% =========================================================================
% Parámetros del algoritmo genético (GA.m)
config.ga.MaxGenerations = 100;      % Generaciones máximas
config.ga.PopulationSize = 50;       % Tamaño de población
config.ga.CrossoverFraction = 0.8;   % Fracción de crossover
config.ga.MutationRate = 0.01;       % Tasa de mutación
config.ga.EliteCount = 5;            % Individuos elite preservados
config.ga.StallGenLimit = 20;        % Generaciones sin mejora para detener

% =========================================================================
% MATCHING MODAL (MAC)
% =========================================================================
% Para resolver cruce modal (mode veering)
config.usar_matching_modal = true;   % true: emparejar modos con MAC
config.mac_threshold = 0.90;         % Umbral MAC para considerar match válido

% =========================================================================
% OPCIONES DE ABOLLADURA (si aplica)
% =========================================================================
% Parámetros numéricos para ab_build_element_ke
config.ab.Nseg = 1000;  % Segmentos de integración
config.ab.Slong = 5;    % Longitud característica
config.ab.lim = 3e-3;   % Límite de convergencia

% =========================================================================
% SALIDA Y REPORTES
% =========================================================================
% Crear timestamp para identificar corrida
config.timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Nombre base para archivos de salida
config.nombre_experimento = sprintf('benchmark_%s_%s', ...
    config.tipo_dano, config.timestamp);

% Opciones de visualización
config.verbose = true;              % Mostrar progreso
config.guardar_figuras = true;      % Guardar gráficas
config.exportar_csv = true;         % Exportar tabla de resultados

% =========================================================================
% NOTAS Y REFERENCIAS
% =========================================================================
config.notas = {
    'DEFORMACIÓN INICIAL (bow imperfection):'
    '  - Basado en Vlajic et al. (2014) Int J Solids Struct'
    '  - Implementación: funcion_deformaciones.m'
    '  - Requiere análisis estático previo (N_axial, ρ)'
    ''
    'RANGO ÓPTIMO DE DETECTABILIDAD:'
    '  - ρ ∈ [0.3, 0.7]: máxima sensibilidad modal'
    '  - ρ < 0.2: cambios muy pequeños (baja detectabilidad)'
    '  - ρ > 0.75: cerca de pandeo (inestable)'
    ''
    'MAGNITUDES TÍPICAS (e0/L):'
    '  - API RP2A: 0.1% - 0.3% (tolerancia fabricación)'
    '  - ISO 19902: 0.5% - 1.0% (imperfección máxima)'
    '  - Daño severo: 2% - 5%'
};

% =========================================================================
% INFORMACIÓN DEL SISTEMA
% =========================================================================
config.info_sistema = struct(...
    'nNodos', 51, ...
    'nElementos_total', 136, ...
    'nElementos_subestructura', 120, ...
    'nElementos_superestructura', 16, ...
    'altura_total_m', 120, ...
    'tirante_m', 80, ...
    'peso_topside_N', 8337000, ...  % 8.337 MN según API RP2A-WSD / ISO 19902
    'topside_breakdown', struct(...
        'production_deck_MN', 5.558, ...  % Z=100m, 20 kN/m² × 277.9 m²
        'utility_deck_MN', 2.779, ...     % Z=109m, 10 kN/m² × 277.9 m²
        'roof_MN', 0.0, ...               % Z=118m, solo peso propio
        'area_deck_m2', 277.9, ...
        'referencia', 'API RP 2A-WSD Section 3.2.3, ISO 19902:2007 Section 8.2.2'), ...
    'validacion_ETABS', struct(...
        'reaccion_DEAD_MN', 33.16, ...
        'esperado_DEAD_plus_topside_MN', 41.50, ...
        'por_pierna_MN', 10.375) ...
);

end  % function
