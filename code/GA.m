function [optimal_alpha, fval] = GA(DI, T, threshold)
% optimizarAlphaGA Ejecuta el algoritmo genético para encontrar los pesos óptimos alpha.
%
% Entradas:
%   DI        - Matriz o estructura de índices de daño (8 columnas para cada DI).
%   T         - Vector objetivo (target) para comparación.
%   threshold - Umbral usado dentro de la función objetivo.
%
% Salidas:
%   optimal_alpha - Vector de pesos alpha óptimos (1x8).
%   fval          - Valor de la función objetivo correspondiente a optimal_alpha.

    nVars = 8;                            % Número de pesos alpha
    lb = zeros(1, nVars);                % Límite inferior: 0
    ub = ones(1, nVars);                 % Límite superior: 1

    % Configuración del algoritmo genético
    options = optimoptions('ga', ...
        'Display', 'iter', ...
        'PopulationSize', 300, ...
        'Generations', 500, ...
        'StallGenLimit', 200, ...
        'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping});

    % Definición de la función objetivo
    objFun = @(alpha) objective_function(alpha, DI, T, threshold);

    % Ejecutar GA
    [optimal_alpha, fval] = ga(objFun, nVars, [], [], [], [], lb, ub, [], options);

    % Mostrar resultados
    disp('Pesos óptimos (alpha):');
    disp(optimal_alpha);
    disp('Valor de la función objetivo:');
    disp(fval);
end
