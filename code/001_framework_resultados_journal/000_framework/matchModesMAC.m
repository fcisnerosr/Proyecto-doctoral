function [phi_matched, omega_matched, indices, MAC_matrix, MAC_diagonal] = matchModesMAC(phi_ref, phi_test, omega_test, metodo)
% matchModesMAC  Empareja modos de vibración usando el criterio MAC y reordena
%                los modos dañados para que correspondan físicamente con los intactos.
%
% Esta función resuelve el problema de "emparejamiento modal" (mode matching):
% cuando se calcula daño estructural, las frecuencias pueden cambiar de orden
% (fenómeno conocido como "cruce modal" o "mode veering"), haciendo que el
% modo i del sistema dañado NO corresponda al modo i del sistema intacto.
%
% Esta función encuentra la correspondencia correcta usando el Modal Assurance
% Criterion (MAC) y reordena los modos dañados para permitir comparación directa.
%
% Sintaxis:
%    [phi_matched, omega_matched, indices] = matchModesMAC(phi_ref, phi_test, omega_test)
%    [phi_matched, omega_matched, indices, MAC_matrix, MAC_diagonal] = matchModesMAC(...)
%
% Entradas:
%    phi_ref    : Matriz de modos intactos de referencia [nDOF × nModos]
%    phi_test   : Matriz de modos dañados sin emparejar [nDOF × nModos]
%    omega_test : Vector de frecuencias dañadas [nModos × 1] o [1 × nModos]
%    metodo     : (Opcional) Algoritmo de emparejamiento
%                 'hungarian' - Algoritmo húngaro (óptimo global, default)
%                 'greedy'    - Algoritmo codicioso (subóptimo pero más rápido)
%
% Salidas:
%    phi_matched   : Matriz de modos dañados reordenados [nDOF × nModos]
%                    Ahora phi_matched(:,i) corresponde a phi_ref(:,i)
%    omega_matched : Vector de frecuencias reordenadas [nModos × 1]
%                    Ahora omega_matched(i) corresponde a phi_ref(:,i)
%    indices       : Vector de índices de reordenamiento [1 × nModos]
%                    indices(i) indica qué columna de phi_test se asignó a la posición i
%    MAC_matrix    : Matriz MAC completa [nModos × nModos] (opcional)
%    MAC_diagonal  : Vector con valores MAC de la diagonal del emparejamiento (opcional)
%                    MAC_diagonal(i) = MAC entre modo_ref_i y su modo emparejado
%
% Ejemplo de uso:
%    % Después de calcular modos intactos y dañados:
%    [modos_intactos, ~, freq_intactas] = modos_frecuencias(KG_und, M);
%    [modos_danados, ~, freq_danadas] = modos_frecuencias(KG_dam, M);
%
%    % Emparejar modos dañados con intactos:
%    [modos_danados_matched, freq_matched, indices] = ...
%        matchModesMAC(modos_intactos, modos_danados, freq_danadas);
%
%    % Ahora se puede comparar directamente:
%    DI = abs(modos_intactos - modos_danados_matched);  % Comparación correcta
%
% Interpretación del vector indices:
%    Si indices = [1, 3, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12], significa:
%      - Modo intacto 1 corresponde a modo dañado 1 (sin cambio)
%      - Modo intacto 2 corresponde a modo dañado 3 (hubo cruce!)
%      - Modo intacto 3 corresponde a modo dañado 2 (hubo cruce!)
%      - Modos 4-12 sin cambios
%
% Nota sobre el Algoritmo Húngaro:
%    El método 'hungarian' resuelve el problema de asignación óptima maximizando
%    la suma total de los valores MAC. Esto garantiza el mejor emparejamiento
%    global posible, aunque puede ser ligeramente más lento que 'greedy'.
%    Requiere Optimization Toolbox o Statistics and Machine Learning Toolbox.
%
% Referencias:
%    - Allemang, R. J. (2003). The modal assurance criterion.
%    - Pastor, M., Binda, M., & Harčarik, T. (2012). Modal assurance criterion.
%      Procedia engineering, 48, 543-548.

    % Establecer método por defecto si no se especifica
    if nargin < 4 || isempty(metodo)
        metodo = 'hungarian';  % Óptimo global
    end
    
    % Validar que el método sea reconocido
    metodo = lower(metodo);
    if ~ismember(metodo, {'hungarian', 'greedy'})
        error('matchModesMAC:MetodoInvalido', ...
              'Método "%s" no reconocido. Use "hungarian" o "greedy".', metodo);
    end
    
    % =========================================================================
    % PASO 1: Calcular matriz MAC completa
    % =========================================================================
    % Cada elemento MAC_matrix(i,j) indica la correlación entre el modo i
    % de referencia (intacto) y el modo j de prueba (dañado)
    MAC_matrix = calcularMatrizMAC(phi_ref, phi_test);
    
    % =========================================================================
    % PASO 2: Encontrar el emparejamiento óptimo
    % =========================================================================
    % El objetivo es asignar cada modo dañado a un modo intacto de forma
    % que se maximice la correlación total (suma de MACs del emparejamiento)
    
    switch metodo
        case 'hungarian'
            % --- ALGORITMO HÚNGARO (óptimo global) ---
            % Este algoritmo resuelve el problema de asignación óptima.
            % Encuentra el emparejamiento 1-a-1 que maximiza la suma de MACs.
            %
            % Como matchpairs() minimiza costos, usamos (1 - MAC) como costo
            cost_matrix = 1 - MAC_matrix;
            
            % Ejecutar algoritmo húngaro
            % assignment es una matriz [n × 2] donde:
            %   assignment(i,1) = índice del modo de referencia
            %   assignment(i,2) = índice del modo de prueba asignado
            [assignment, ~] = matchpairs(cost_matrix, max(cost_matrix(:)));
            
            % Extraer vector de índices de reordenamiento
            % indices(i) indica qué columna de phi_test corresponde al modo i
            indices = assignment(:, 2)';
            
        case 'greedy'
            % --- ALGORITMO CODICIOSO (subóptimo pero simple) ---
            % Asigna secuencialmente cada modo intacto al modo dañado con
            % mayor MAC disponible, sin considerar optimización global
            indices = matchingGreedy(MAC_matrix);
    end
    
    % =========================================================================
    % PASO 3: Reordenar modos y frecuencias según el emparejamiento
    % =========================================================================
    % Aplicar el reordenamiento encontrado
    phi_matched = phi_test(:, indices);
    omega_matched = omega_test(indices);
    
    % =========================================================================
    % PASO 4: Calcular valores MAC del emparejamiento (para diagnóstico)
    % =========================================================================
    % Extraer los valores MAC de la "diagonal virtual" del emparejamiento
    % MAC_diagonal(i) = MAC entre modo_ref(i) y su modo emparejado
    nModos = size(phi_ref, 2);
    MAC_diagonal = zeros(nModos, 1);
    for i = 1:nModos
        j = indices(i);  % Índice del modo dañado asignado al modo i
        MAC_diagonal(i) = MAC_matrix(i, j);
    end
    
    % Nota: Si MAC_diagonal(i) es bajo (< 0.80), indica que ese modo cambió
    % significativamente o que apareció un modo local nuevo.

end

% =========================================================================
% FUNCIÓN AUXILIAR: Matching Greedy
% =========================================================================
function indices = matchingGreedy(MAC_matrix)
% matchingGreedy  Emparejamiento codicioso secuencial
%
% Para cada modo intacto (en orden), asigna el modo dañado con mayor MAC
% que aún no haya sido usado. No garantiza optimización global.

    n_modos = size(MAC_matrix, 1);
    indices = zeros(1, n_modos);
    modos_usados = false(1, n_modos);  % Máscara de modos ya asignados
    
    % Iterar sobre cada modo intacto
    for i = 1:n_modos
        % Copiar la fila i de MAC (correlaciones con todos los modos dañados)
        MAC_disponibles = MAC_matrix(i, :);
        
        % Excluir modos dañados ya asignados (poner -inf para que no se elijan)
        MAC_disponibles(modos_usados) = -inf;
        
        % Encontrar el modo dañado con mayor MAC disponible
        [~, idx_max] = max(MAC_disponibles);
        
        % Asignar este modo y marcarlo como usado
        indices(i) = idx_max;
        modos_usados(idx_max) = true;
    end
end
