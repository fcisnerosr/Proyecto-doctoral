function [optimal_alpha, fval] = GA(DI, T, threshold, ID_Ejecucion, outputFolder)
% GA  Ejecuta el algoritmo genético “en segundo plano” y guarda la figura.
%
%   [optimal_alpha, fval] = GA(DI, T, threshold, ID_Ejecucion, outputFolder)
%
%   - DI, T, threshold: como antes
%   - ID_Ejecucion     : entero (para nombrar ID_0001.png, etc.)
%   - outputFolder     : carpeta base “Resultados”
%
%   Guarda la figura oculta en: outputFolder/figuras/ID_0001.png, …

    nVars = 8;
    lb    = zeros(1,nVars);
    ub    = ones(1,nVars);
    
    fig = figure('Visible','off');

    
    % 1) Opciones del GA
    options = optimoptions('ga', ...
        'Display',       'iter', ...
        'PopulationSize',300, ...
        'Generations',   500, ...
        'StallGenLimit', 200, ...
        'PlotFcn', {@gaplotbestf, @gaplotbestindiv, @gaplotdistance, @gaplotrange, @gaplotstopping} ...
    );

    % 2) Definir función objetivo y ejecutar GA
    objFun = @(alpha) objective_function(alpha, DI, T, threshold);
    [optimal_alpha, fval] = ga(objFun, nVars, [],[],[],[], lb, ub, [], options);

    % 3) Asegurar existencia de carpeta "figuras”
    figDir = fullfile(outputFolder, 'figuras');
    if ~exist(figDir,'dir')
        mkdir(figDir);
    end

    % 4) Guardar la figura con nombre ID_0001.png, etc.
    figFile = fullfile(figDir, sprintf('ID_%04d.png', ID_Ejecucion));
    saveas(fig, figFile);  % guarda la figura en ese archivo

    % (5) Cerrar la figura si ya no la necesitas
    close(fig);

end
