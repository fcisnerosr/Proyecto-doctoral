function Resultado_final = createNodeTable(P_values, DI1_COMAC)
% createNodeTable Crea una tabla con nodos, valores de daño ponderado y etiquetas.
%
% Sintaxis:
%   Resultado_final = createNodeTable(P_values, DI1_COMAC)
%
% Entradas:
%   P_values  - Vector numérico (n x 1) con los valores combinados P.
%   DI1_COMAC - Vector de referencia para determinar el número de nodos.
%               Se usará length(DI1_COMAC) para definir la cantidad.
%
% Salida:
%   Resultado_final - Tabla con tres columnas:
%                     'Número de nodo', 'Valor de daño ponderado' y 'Estado',
%                     donde se etiqueta el nodo como "nodo con daño" si el
%                     valor es mayor a 50, o "nodo sin daño" en caso contrario.
%
% Ejemplo:
%   P_values = [0.64533; 0.13173; ...]; % n elementos
%   DI1_COMAC = [0.15; 0.20; ...];        % n elementos
%   Resultado_final = createNodeTable(P_values, DI1_COMAC);
%   disp(Resultado_final);

    nNodes = length(DI1_COMAC);
    
    if numel(P_values) ~= nNodes
        error('P_values debe tener exactamente %d elementos (la longitud de DI1_COMAC).', nNodes);
    end

    % Generar el vector de nodos: desde 5 hasta (5 + nNodes - 1)
    nodes = (5:(4+nNodes))';
    
    % Multiplicar P_values por 100 para expresar el "valor de daño ponderado"
    % (como en tu código original)
    dano_valor = P_values * 100;

    Pmax = max(P_values);        % Valor máximo en P
    P_scaled = (P_values / Pmax) * 100;
    
    % Crear etiquetas para cada nodo según el criterio: valor mayor a 50 => "nodo con daño"
    Estado = cell(nNodes,1);
    for i = 1:nNodes
        if P_scaled(i) > 50
            Estado{i} = 'Daño';
        else
            Estado{i} = ' - ';
        end
    end
    
    % Crear la tabla final
    Resultado_final = table(nodes, P_scaled, Estado, ...
        'VariableNames', {'Número_de_nodo', 'Valor_de_daño_normalizado', 'Estado'});
    
    % Mostrar la tabla
    disp(Resultado_final);
end
