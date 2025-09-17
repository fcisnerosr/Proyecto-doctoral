function [optimal_alpha, fval] = optimizarAlphaGA(DI, T, threshold, ...
    popSize, nGenerations, stallLimit, mutationFcn, crossoverFraction)
%%%% Ejemplos de uso:
% [alpha, val] = optimizarAlphaGA(DI, T, threshold);  % usa todos los valores por defecto
% [alpha, val] = optimizarAlphaGA(DI, T, threshold, 400, 800, 300, {@mutationuniform}, 0.7);

% optimizarAlphaGA Ejecuta un algoritmo genético para encontrar los pesos alpha óptimos.
%
% Entradas:
%   DI               - Matriz con los índices de daño (cada columna un DI).
%   T                - Vector objetivo (target) que indica la ubicación del daño.
%   threshold        - Umbral de tolerancia usado en la función objetivo.
%   popSize          - (Opcional) Tamaño de la población [default: 300].
%   nGenerations     - (Opcional) Número de generaciones [default: 500].
%   stallLimit       - (Opcional) Límite de generaciones sin mejora [default: 200].
%   mutationFcn      - (Opcional) Función de mutación [default: {@mutationgaussian, 0.2, 0.5}].
%   crossoverFraction- (Opcional) Fracción de cruzamiento [default: 0.6].
%
% Salidas:
%   optimal_alpha    - Vector óptimo de pesos alpha (1x8).
%   fval             - Valor final de la función objetivo.

    % Valores por defecto si no se especifican
    if nargin < 4 || isempty(popSize), popSize = 300; end
    if nargin < 5 || isempty(nGenerations), nGenerations = 500; end
    if nargin < 6 || isempty(stallLimit), stallLimit = 200; end
    if nargin < 7 || isempty(mutationFcn), mutationFcn = {@mutationgaussian, 0.2, 0.5}; end
    if nargin < 8 || isempty(crossoverFraction), crossoverFraction = 0.6; end

    nVars = 8;
    lb = zeros(1, nVars);
    ub = ones(1, nVars);

    % Configurar opciones del algoritmo genético
    options = optimoptions('ga', ...
        'Display', 'iter', ...
        'PopulationSize', popSize, ...
        'Generations', nGenerations, ...
        'StallGenLimit', stallLimit, ...
        'CrossoverFraction', crossoverFraction, ...
        'MutationFcn', mutationFcn, ...
        'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping});

    % Definición de función objetivo
    objFun = @(alpha) objective_function(alpha, DI, T, threshold);

    % Ejecutar algoritmo genético
    [optimal_alpha, fval] = ga(objFun, nVars, [], [], [], [], lb, ub, [], options);

    % Mostrar resultados
    disp('Pesos óptimos (alpha):');
    disp(optimal_alpha);
    disp('Valor de la función objetivo:');
    disp(fval);
end
