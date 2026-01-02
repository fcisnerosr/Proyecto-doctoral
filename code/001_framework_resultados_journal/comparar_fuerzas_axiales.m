% Script para comparar fuerzas axiales de ETABS vs mi código

% 1. Leer datos de ETABS
data_etabs = readtable('001_runExperimentos/003_funcion_deformaciones/carga_axial_ETABS.csv');

% Extraer columnas
elem_raw = data_etabs.Element;
P_raw = data_etabs.P_kN;

% Promediar los 3 valores por elemento
n_elem = max(elem_raw);
P_etabs = zeros(n_elem, 1);

for i = 1:n_elem
    idx = find(elem_raw == i);
    P_etabs(i) = mean(P_raw(idx));
end

fprintf('Datos ETABS procesados: %d elementos\n', n_elem);

% 2. Ejecutar análisis estático si no existe el archivo
if ~exist('analisis_estatico_output.mat', 'file')
    fprintf('Ejecutando análisis estático...\n');
    run('main_launcher.m');
end

% 3. Cargar datos de mi código
load('analisis_estatico_output.mat', 'N_axial', 'rho', 'Pcr', 'elementos_validos');

fprintf('Datos de mi código cargados\n');

% 3. Comparar elementos válidos
fprintf('\n=== COMPARACIÓN ETABS vs MI CÓDIGO ===\n\n');
fprintf('Elem   P_ETABS(kN)   N_miCodigo(kN)   Diff(kN)   Diff(%%)\n');
fprintf('------------------------------------------------------------\n');

for i = 1:length(elementos_validos)
    elem = elementos_validos(i);
    P_etabs_elem = P_etabs(elem);
    N_codigo_elem = N_axial(elem) / 1000;  % Convertir N a kN
    diff_kN = abs(P_etabs_elem - N_codigo_elem);
    diff_pct = 100 * diff_kN / abs(P_etabs_elem);
    
    fprintf('%4d   %12.2f   %14.2f   %9.2f   %7.2f%%\n', ...
        elem, P_etabs_elem, N_codigo_elem, diff_kN, diff_pct);
end

% 4. Estadísticas globales para todos los elementos
fprintf('\n=== COMPARACIÓN TODOS LOS ELEMENTOS (1-120) ===\n\n');

N_codigo_kN = N_axial / 1000;  % Convertir todo a kN
diff_todos = abs(P_etabs - N_codigo_kN);
diff_pct_todos = 100 * diff_todos ./ abs(P_etabs);

% Filtrar casos donde P es muy pequeño (< 10 kN) para evitar porcentajes inflados
idx_validos = abs(P_etabs) > 10;

fprintf('Diferencia promedio: %.2f kN (%.2f%%)\n', ...
    mean(diff_todos(idx_validos)), mean(diff_pct_todos(idx_validos)));
fprintf('Diferencia máxima: %.2f kN (%.2f%%) en elemento %d\n', ...
    max(diff_todos), max(diff_pct_todos), find(diff_todos == max(diff_todos)));
fprintf('Diferencia mínima: %.2f kN (%.2f%%) en elemento %d\n', ...
    min(diff_todos(idx_validos)), min(diff_pct_todos(idx_validos)), ...
    find(diff_todos == min(diff_todos(idx_validos)), 1));

% 5. Mostrar algunos elementos problemáticos (rho > 1)
fprintf('\n=== ELEMENTOS CON RHO > 1 (PROBLEMÁTICOS) ===\n\n');
elem_problema = find(rho > 1.0);
if length(elem_problema) > 10
    elem_problema = elem_problema(1:10);  % Mostrar solo los primeros 10
end

fprintf('Elem   P_ETABS(kN)   N_miCodigo(kN)   Pcr(kN)   Rho    Diff(%%)\n');
fprintf('-----------------------------------------------------------------------\n');
for i = 1:length(elem_problema)
    elem = elem_problema(i);
    P_etabs_elem = P_etabs(elem);
    N_codigo_elem = N_axial(elem) / 1000;
    Pcr_elem = Pcr(elem) / 1000;
    rho_elem = rho(elem);
    diff_pct = 100 * abs(P_etabs_elem - N_codigo_elem) / abs(P_etabs_elem);
    
    fprintf('%4d   %12.2f   %14.2f   %9.2f   %5.2f   %7.2f%%\n', ...
        elem, P_etabs_elem, N_codigo_elem, Pcr_elem, rho_elem, diff_pct);
end

fprintf('\n=== CONCLUSIÓN ===\n');
if mean(diff_pct_todos(idx_validos)) < 5
    fprintf('✓ Las fuerzas axiales coinciden bien (< 5%% error promedio)\n');
    fprintf('→ El problema está en el cálculo de Pcr (factor K = 1.0 muy conservador)\n');
else
    fprintf('✗ Las fuerzas axiales NO coinciden (>= 5%% error promedio)\n');
    fprintf('→ Hay un error en el análisis estático (transformación o ensamblaje)\n');
end
