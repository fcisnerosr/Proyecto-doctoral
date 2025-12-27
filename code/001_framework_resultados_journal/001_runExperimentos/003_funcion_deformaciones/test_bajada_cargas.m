% test_bajada_cargas.m
% Script de validación del análisis estático de fuerzas axiales
% Integra con la arquitectura existente de main_launcher.m

clc; clear; close all;

fprintf('=======================================================\n');
fprintf('TEST: ANÁLISIS ESTÁTICO DE BAJADA DE CARGAS\n');
fprintf('=======================================================\n\n');

%% 1. SETUP DEL PROYECTO (igual que main_launcher.m)
fprintf('1. Configurando rutas del proyecto...\n');

% Agregar paths necesarios
repo_root = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
addpath(genpath(fullfile(repo_root, 'code', '001_framework_resultados_journal')));
addpath(genpath(fullfile(repo_root, 'pruebas_excel')));

% Rutas de archivos
pathfile_marco = fullfile(repo_root, 'pruebas_excel', 'marco3Ddam0.xlsx');
carpeta_excel = 'revision_6_jacket-subestructura_4NIVELES';
archivo_excel_base = 'datos_revision_5_jacket-subestructura_5NIVELES';
archivo_excel = fullfile(repo_root, 'pruebas_excel', carpeta_excel, ...
    [archivo_excel_base '.xlsx']);

fprintf('  Marco3D: %s\n', pathfile_marco);
fprintf('  Excel ETABS: %s\n', archivo_excel);

%% 2. LECTURA DE DATOS (igual que main_launcher.m)
fprintf('\n2. Leyendo datos del modelo...\n');

% Desde marco3Ddam0.xlsx
[NE, IDmax, NEn, elements, nodes, damele, eledent, ...
 A, Iy, Iz, J, E, G, vxz, ID, ~, ~] = lectura_hoja_excel(pathfile_marco);

fprintf('  Estructura: %d nodos, %d elementos\n', size(nodes,1), NE);
fprintf('  DOF libres: %d, DOF restringidos: %d\n', IDmax, NEn);

%% 3. PARÁMETROS DE CARGA
fprintf('\n3. Definiendo cargas...\n');

% Peso topside (dato del proyecto)
W_topside = 8290953.54;  % [N] (~846 ton)

% Incluir peso propio
incluir_peso_propio = true;

fprintf('  Peso topside: %.2f kN (%.1f ton)\n', W_topside/1e3, W_topside/9810);
fprintf('  Peso propio: %s\n', mat2str(incluir_peso_propio));

%% 4. EJECUCIÓN DEL ANÁLISIS ESTÁTICO
fprintf('\n4. Ejecutando análisis estático...\n');
fprintf('---------------------------------------------------\n');

tic;
[N_axial, rho, Pcr, diagnostico] = analisis_estatico_fuerzas_axiales(...
    nodes, elements, A, Iy, Iz, J, E, G, vxz, ID, W_topside, incluir_peso_propio);
tiempo_analisis = toc;

fprintf('---------------------------------------------------\n');
fprintf('Tiempo de análisis: %.3f segundos\n', tiempo_analisis);

%% 5. VALIDACIÓN CON ETABS (si disponible)
fprintf('\n5. Comparación con ETABS (si disponible)...\n');

% TODO: Si tienes resultados de ETABS, cargarlos aquí para comparar
% N_axial_ETABS = load(...);
% error_relativo = abs(N_axial - N_axial_ETABS) ./ abs(N_axial_ETABS);
% fprintf('  Error relativo medio: %.2f%%\n', 100*mean(error_relativo));

fprintf('  (Comparación pendiente - requiere tabla de ETABS)\n');

%% 6. IDENTIFICACIÓN DE ELEMENTOS ÓPTIMOS PARA DAÑO TIPO 3
fprintf('\n6. Elementos candidatos para deformación inicial...\n');

% Rango óptimo de ρ para detectabilidad
rho_min_optimo = 0.3;
rho_max_optimo = 0.7;

idx_optimos = find(rho >= rho_min_optimo & rho <= rho_max_optimo);
n_optimos = length(idx_optimos);

fprintf('  Elementos con %.2f ≤ ρ ≤ %.2f: %d (%.1f%%)\n', ...
    rho_min_optimo, rho_max_optimo, n_optimos, 100*n_optimos/NE);

if n_optimos > 0
    fprintf('\n  Top 10 elementos más adecuados:\n');
    fprintf('  %-6s  %-10s  %-10s  %-8s\n', 'Elem', 'N [kN]', 'Pcr [kN]', 'ρ');
    fprintf('  %s\n', repmat('-', 1, 42));
    
    % Ordenar por ρ descendente dentro del rango óptimo
    [~, orden] = sort(rho(idx_optimos), 'descend');
    top10 = idx_optimos(orden(1:min(10, n_optimos)));
    
    for k = 1:length(top10)
        elem_id = top10(k);
        fprintf('  %-6d  %10.2f  %10.2f  %8.4f\n', ...
            elem_id, N_axial(elem_id)/1e3, Pcr(elem_id)/1e3, rho(elem_id));
    end
end

%% 7. VISUALIZACIÓN DE RESULTADOS
fprintf('\n7. Generando gráficas...\n');

figure('Name', 'Análisis Estático: Fuerzas Axiales', 'Position', [100 100 1400 800]);

% Subplot 1: Histograma de fuerzas axiales
subplot(2,3,1);
histogram(N_axial/1e3, 30, 'FaceColor', [0.2 0.5 0.8]);
hold on;
xline(0, 'r--', 'LineWidth', 2);
xlabel('Fuerza axial [kN]');
ylabel('Número de elementos');
title('Distribución de fuerzas axiales');
grid on;
legend('Elementos', 'N=0 (neutro)');

% Subplot 2: Histograma de ratio de carga
subplot(2,3,2);
histogram(rho, 30, 'FaceColor', [0.8 0.3 0.2]);
hold on;
xline(rho_min_optimo, 'g--', 'LineWidth', 1.5, 'Label', 'ρ_{min}');
xline(rho_max_optimo, 'g--', 'LineWidth', 1.5, 'Label', 'ρ_{max}');
xline(0.85, 'r--', 'LineWidth', 2, 'Label', 'Límite');
xlabel('Ratio de carga ρ = |N|/P_{cr}');
ylabel('Número de elementos');
title('Distribución del ratio de carga crítica');
grid on;
xlim([0 max(rho)*1.1]);

% Subplot 3: N_axial vs elemento
subplot(2,3,3);
stem(1:NE, N_axial/1e3, 'Marker', 'none', 'LineWidth', 0.8);
hold on;
yline(0, 'k--', 'LineWidth', 1);
xlabel('ID de elemento');
ylabel('Fuerza axial [kN]');
title('Fuerza axial por elemento');
grid on;
ylim([min(N_axial/1e3)*1.1, max(N_axial/1e3)*1.1]);

% Subplot 4: ρ vs elemento
subplot(2,3,4);
stem(1:NE, rho, 'Marker', 'none', 'LineWidth', 0.8, 'Color', [0.8 0.3 0.2]);
hold on;
yline(rho_min_optimo, 'g--', 'LineWidth', 1.5);
yline(rho_max_optimo, 'g--', 'LineWidth', 1.5);
yline(0.85, 'r--', 'LineWidth', 2);
% Resaltar elementos óptimos
if ~isempty(idx_optimos)
    scatter(idx_optimos, rho(idx_optimos), 50, 'g', 'filled', 'MarkerEdgeColor', 'k');
end
xlabel('ID de elemento');
ylabel('Ratio de carga ρ');
title('Ratio de carga crítica por elemento');
grid on;
legend('Todos', 'ρ_{min}=0.3', 'ρ_{max}=0.7', 'Límite=0.85', 'Óptimos');

% Subplot 5: Scatter N vs Pcr
subplot(2,3,5);
scatter(Pcr/1e3, abs(N_axial)/1e3, 30, rho, 'filled');
hold on;
plot([0 max(Pcr/1e3)], [0 max(Pcr/1e3)], 'r--', 'LineWidth', 2, 'DisplayName', 'N=P_{cr}');
plot([0 max(Pcr/1e3)], 0.3*[0 max(Pcr/1e3)], 'g--', 'LineWidth', 1.5, 'DisplayName', 'ρ=0.3');
plot([0 max(Pcr/1e3)], 0.7*[0 max(Pcr/1e3)], 'g--', 'LineWidth', 1.5, 'DisplayName', 'ρ=0.7');
xlabel('P_{cr} [kN]');
ylabel('|N| [kN]');
title('Carga aplicada vs Carga crítica');
colorbar;
caxis([0 1]);
grid on;
legend('Location', 'northwest');
axis equal;
xlim([0 max(Pcr/1e3)*1.1]);
ylim([0 max(abs(N_axial)/1e3)*1.1]);

% Subplot 6: Estadísticas
subplot(2,3,6);
axis off;

% Tabla de resumen
txt = {
    '===== RESUMEN ESTADÍSTICO ====='
    ''
    sprintf('Estructura: %d elementos', NE)
    sprintf('DOF libres: %d', IDmax)
    ''
    '--- FUERZAS AXIALES ---'
    sprintf('Tensión: %d elem (%.1f%%)', ...
        length(diagnostico.elementos_tension), ...
        100*length(diagnostico.elementos_tension)/NE)
    sprintf('Compresión: %d elem (%.1f%%)', ...
        length(diagnostico.elementos_compresion), ...
        100*length(diagnostico.elementos_compresion)/NE)
    ''
    sprintf('N_{min}: %.2f kN', min(N_axial)/1e3)
    sprintf('N_{max}: %.2f kN', max(N_axial)/1e3)
    ''
    '--- RATIO DE CARGA ---'
    sprintf('ρ_{min}: %.4f', min(rho))
    sprintf('ρ_{max}: %.4f (elem %d)', diagnostico.rho_max, diagnostico.elem_mas_cargado)
    sprintf('ρ_{medio}: %.4f', mean(rho))
    ''
    '--- ELEMENTOS ÓPTIMOS ---'
    sprintf('Rango: %.2f ≤ ρ ≤ %.2f', rho_min_optimo, rho_max_optimo)
    sprintf('Candidatos: %d (%.1f%%)', n_optimos, 100*n_optimos/NE)
    ''
    '--- CARGAS APLICADAS ---'
    sprintf('Peso propio: %.2f kN', diagnostico.peso_propio_total/1e3)
    sprintf('Peso topside: %.2f kN', W_topside/1e3)
    sprintf('Total: %.2f kN', diagnostico.carga_total/1e3)
};

text(0.05, 0.95, txt, 'VerticalAlignment', 'top', 'FontName', 'Courier', ...
    'FontSize', 9, 'Interpreter', 'tex');

sgtitle(sprintf('Análisis Estático - Tiempo: %.3f s', tiempo_analisis), ...
    'FontSize', 14, 'FontWeight', 'bold');

%% 8. EXPORTAR RESULTADOS
fprintf('\n8. Exportando resultados...\n');

% Crear tabla de resultados
T = table((1:NE)', elements(:,2), elements(:,3), N_axial, Pcr, rho, ...
    'VariableNames', {'Elemento', 'Nodo_i', 'Nodo_j', 'N_axial_N', 'Pcr_N', 'rho'});

% Agregar clasificación
T.Clasificacion = repmat({'bajo'}, NE, 1);
T.Clasificacion(rho >= 0.2 & rho < 0.5) = {'medio'};
T.Clasificacion(rho >= 0.5 & rho < 0.75) = {'alto'};
T.Clasificacion(rho >= 0.75) = {'critico'};
T.Clasificacion(rho >= rho_min_optimo & rho <= rho_max_optimo) = {'OPTIMO'};

% Guardar en CSV
output_file = fullfile(repo_root, 'Resultados', 'fuerzas_axiales_estatico.csv');
writetable(T, output_file);
fprintf('  Tabla exportada: %s\n', output_file);

% Guardar workspace
output_mat = fullfile(repo_root, 'Resultados', 'analisis_estatico_workspace.mat');
save(output_mat, 'N_axial', 'rho', 'Pcr', 'diagnostico', 'idx_optimos');
fprintf('  Workspace guardado: %s\n', output_mat);

%% 9. PRUEBA RÁPIDA CON funcion_deformaciones.m
fprintf('\n9. Prueba de integración con funcion_deformaciones.m...\n');

if n_optimos > 0
    % Tomar primer elemento óptimo
    elem_prueba = idx_optimos(1);
    
    fprintf('  Probando elemento %d:\n', elem_prueba);
    fprintf('    N_axial = %.2f kN\n', N_axial(elem_prueba)/1e3);
    fprintf('    ρ = %.4f\n', rho(elem_prueba));
    
    % Parámetros del elemento
    nodo_i = elements(elem_prueba, 2);
    nodo_j = elements(elem_prueba, 3);
    xi = nodes(nodo_i, 2:4)';
    xj = nodes(nodo_j, 2:4)';
    L_elem = norm(xj - xi);
    
    % Calcular D y t aproximados desde A y geometría
    % A = π(D²-(D-2t)²)/4 ≈ πDt para t<<D
    % Usar valores típicos de las secciones del proyecto
    if A(elem_prueba) > 0.2  % SECC04: grande
        D_elem = 2.184;  % m
        t_elem = 0.0381; % m
    else  % SECC01: estándar
        D_elem = 1.600;  % m
        t_elem = 0.0254; % m
    end
    
    fprintf('    L = %.2f m, D = %.3f m, t = %.4f m\n', L_elem, D_elem, t_elem);
    
    % Propiedades materiales
    E_elem = E(elem_prueba);
    nu = 0.3;  % Típico para acero
    rho_mat = 7850;  % kg/m³
    
    % Parámetros de deformación
    e0_sobre_L = 0.02;  % 2%
    nModos = 5;
    
    fprintf('    Llamando funcion_deformaciones con e₀/L = %.1f%%...\n', e0_sobre_L*100);
    
    try
        [q_eq, Kt, ~, ~, ~, omega, freq_Hz, ~, diag] = funcion_deformaciones(...
            L_elem, D_elem, t_elem, E_elem, nu, rho_mat, ...
            N_axial(elem_prueba), e0_sobre_L, nModos, false);
        
        fprintf('    ✓ Convergencia: %d iteraciones\n', diag.num_iteraciones);
        fprintf('    ✓ Frecuencias: [%.3f, %.3f, %.3f] Hz\n', freq_Hz(1), freq_Hz(2), freq_Hz(3));
        fprintf('    ✓ Integración exitosa!\n');
    catch ME
        fprintf('    ✗ Error: %s\n', ME.message);
    end
else
    fprintf('  No hay elementos óptimos para probar\n');
end

%% 10. RESUMEN FINAL
fprintf('\n=======================================================\n');
fprintf('TEST COMPLETADO\n');
fprintf('=======================================================\n');
fprintf('Elementos totales: %d\n', NE);
fprintf('Elementos óptimos para daño tipo 3: %d (%.1f%%)\n', n_optimos, 100*n_optimos/NE);
fprintf('Tiempo total: %.3f s\n', tiempo_analisis);
fprintf('Archivos generados:\n');
fprintf('  - %s\n', output_file);
fprintf('  - %s\n', output_mat);
fprintf('=======================================================\n\n');
