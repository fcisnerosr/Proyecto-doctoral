function MAC_matrix = calcularMatrizMAC(phi_ref, phi_test)
% calcularMatrizMAC  Calcula la matriz de Modal Assurance Criterion (MAC)
%                    entre dos conjuntos de modos de vibración.
%
% El MAC es una métrica que cuantifica la correlación entre dos vectores modales.
% Se usa para determinar qué modo del sistema dañado corresponde físicamente
% a cada modo del sistema intacto, incluso si el orden de frecuencias cambió.
%
% Sintaxis:
%    MAC_matrix = calcularMatrizMAC(phi_ref, phi_test)
%
% Entradas:
%    phi_ref  : Matriz de formas modales de referencia (intactas)
%               Dimensiones: [nDOF × nModos], típicamente [nDOF × 12]
%    phi_test : Matriz de formas modales a comparar (dañadas)
%               Dimensiones: [nDOF × nModos], típicamente [nDOF × 12]
%
% Salida:
%    MAC_matrix : Matriz de correlaciones modales [nModos_ref × nModos_test]
%                 MAC_matrix(i,j) indica la correlación entre el modo i de
%                 referencia y el modo j de prueba.
%                 Valores: [0, 1]
%                   - MAC = 1: modos idénticos (perfecta correlación)
%                   - MAC ≈ 0: modos ortogonales (sin relación física)
%                   - MAC ≥ 0.90: generalmente considerado mismo modo físico
%
% Fórmula del MAC:
%    MAC(i,j) = (phi_i^T * phi_j)^2 / [(phi_i^T * phi_i) * (phi_j^T * phi_j)]
%
% Ejemplo de interpretación:
%    Si MAC_matrix(2,3) = 0.95, significa que el modo 2 del sistema intacto
%    se correlaciona fuertemente con el modo 3 del sistema dañado, indicando
%    que son el "mismo modo físico" aunque tengan diferente orden de frecuencia.
%
% Referencias:
%    Allemang, R. J. (2003). The modal assurance criterion–twenty years of use
%    and abuse. Sound and vibration, 37(8), 14-23.

    % Obtener dimensiones de las matrices modales
    [nDOF_ref, nModos_ref] = size(phi_ref);
    [nDOF_test, nModos_test] = size(phi_test);
    
    % Validación: ambas matrices deben tener el mismo número de DOF
    if nDOF_ref ~= nDOF_test
        error('calcularMatrizMAC:DimensionMismatch', ...
              'Las matrices modales deben tener el mismo número de filas (DOF).\n' + ...
              'phi_ref tiene %d DOF, phi_test tiene %d DOF.', nDOF_ref, nDOF_test);
    end
    
    % Inicializar matriz MAC con ceros
    % Cada elemento MAC_matrix(i,j) contendrá la correlación entre modo i y modo j
    MAC_matrix = zeros(nModos_ref, nModos_test);
    
    % Calcular MAC para cada par de modos (i de referencia, j de prueba)
    for i = 1:nModos_ref
        % Extraer el i-ésimo modo de referencia (vector columna)
        phi_i = phi_ref(:, i);
        
        for j = 1:nModos_test
            % Extraer el j-ésimo modo de prueba (vector columna)
            phi_j = phi_test(:, j);
            
            % Calcular el numerador: producto escalar al cuadrado
            % Este término mide cuánto se "parecen" los dos modos
            numerador = (phi_i' * phi_j)^2;
            
            % Calcular el denominador: producto de las normas al cuadrado
            % Esto normaliza el MAC para que esté en el rango [0, 1]
            denominador = (phi_i' * phi_i) * (phi_j' * phi_j);
            
            % Calcular MAC(i,j)
            % Nota: el denominador nunca debería ser cero para modos bien formados
            if denominador < eps
                % Caso extremo: modo con norma cero (no debería ocurrir)
                MAC_matrix(i, j) = 0;
            else
                MAC_matrix(i, j) = numerador / denominador;
            end
        end
    end
    
    % Nota sobre interpretación de la matriz MAC resultante:
    % - Diagonal alta (MAC(i,i) ≈ 1): los modos mantienen su orden
    % - Valores altos fuera de diagonal: hubo cruces modales (mode veering)
    % 
    % Ejemplo de matriz MAC con cruce modal:
    %         Dañado_1  Dañado_2  Dañado_3  Dañado_4
    % Intacto_1   0.98      0.05      0.03      0.01
    % Intacto_2   0.06      0.15      0.92      0.02  ← Modo 2 se correlaciona con 3!
    % Intacto_3   0.04      0.88      0.12      0.03  ← Modo 3 se correlaciona con 2!
    % Intacto_4   0.02      0.03      0.04      0.96
    %
    % En este ejemplo, los modos 2 y 3 intercambiaron posiciones en el sistema dañado

end
