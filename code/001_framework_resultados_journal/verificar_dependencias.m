% verificar_dependencias.m
% Script para verificar que todas las funciones necesarias están disponibles

clc;
fprintf('=== VERIFICACIÓN DE DEPENDENCIAS ===\n\n');

% Lista de funciones críticas
funciones_criticas = {
    'extraer_longitudes_danadas'
    'vector_asignacion_danos'
    'ensamblaje_matriz_rigidez_global_con_dano'
    'convert_to_number'
    'funcion_abulladura_longitudinal'
    'corrosionlocal'
    'switch_case_danos'
    'GA'
    'objective_function'
    'calcularMatrizMAC'
    'matchModesMAC'
    'combinarDIs'
};

total = length(funciones_criticas);
encontradas = 0;
faltantes = {};

for i = 1:total
    func = funciones_criticas{i};
    if exist(func, 'file') == 2
        fprintf('✓ %s\n', func);
        encontradas = encontradas + 1;
    else
        fprintf('✗ %s  [FALTANTE]\n', func);
        faltantes{end+1} = func;
    end
end

fprintf('\n=== RESUMEN ===\n');
fprintf('Encontradas: %d/%d (%.1f%%)\n', encontradas, total, 100*encontradas/total);

if encontradas == total
    fprintf('✅ TODAS LAS DEPENDENCIAS DISPONIBLES\n');
    fprintf('\nPuedes ejecutar:\n');
    fprintf('  >> main_launcher\n\n');
else
    fprintf('❌ FALTAN %d DEPENDENCIAS:\n', length(faltantes));
    for i = 1:length(faltantes)
        fprintf('   • %s\n', faltantes{i});
    end
    fprintf('\nSolución sugerida:\n');
    fprintf('  >> rehash toolboxcache\n');
    fprintf('  >> rehash path\n\n');
end
