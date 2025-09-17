function addedPaths = setupProjectPath(projRoot, subdirs, doClean)
% SETUPPROJECTPATH  Añade al PATH todas las carpetas del proyecto (recursivo).
% Uso típico (en la PRIMERA línea de main_launcher.m):
%   setupProjectPath(fileparts(mfilename('fullpath')));
%
% Uso avanzado:
%   setupProjectPath(projRoot, {'000_framework','003_calcular_DIs'}, true)
%
% Entradas:
%   projRoot : char/string  Carpeta raíz del proyecto (donde está main).
%   subdirs  : cellstr      Ramas top-level a incluir (recursivo). Opcional.
%   doClean  : logical      true → limpia el path antes de añadir. Opcional.
%
% Salida:
%   addedPaths : cellstr    Rutas efectivamente añadidas (opcional).
%
% Notas:
%  - No mueve archivos; solo gestiona PATH.
%  - Usa addpath(...,'-begin') para priorizar el proyecto.
%  - Filtra carpetas ocultas típicas (p.ej., .git).

    % -------- Defaults robustos --------
    if nargin < 1 || isempty(projRoot)
        st = dbstack('-completenames');
        if numel(st) >= 2
            projRoot = fileparts(st(2).file);  % archivo que llamó a esta func.
        else
            projRoot = pwd;                    % fallback: carpeta actual
        end
    end
    if nargin < 2 || isempty(subdirs)
        subdirs = {'000_framework','001_run_experimentos', ...
                   '002_ensamblaje_matriz_rigidez_global_sin_dano', ...
                   '003_calcular_DIs','004_runExperimentos'};
    end
    if nargin < 3 || isempty(doClean), doClean = false; end

    if doClean
        restoredefaultpath; rehash toolboxcache
    end

    added = {};

    % -------- Raíz del proyecto --------
    if exist(projRoot,'dir')
        addpath(projRoot,'-begin');
        added{end+1} = projRoot; %#ok<AGROW>
    else
        error('setupProjectPath:RootNotFound','No existe projRoot: %s',projRoot);
    end

    % -------- Subcarpetas (recursivo) --------
    for k = 1:numel(subdirs)
        p = fullfile(projRoot, subdirs{k});
        if exist(p,'dir')
            gp = genpath(p);                                % p + sub/subsub
            toks = strsplit(gp, pathsep);                  % celda de rutas
            toks = toks(~cellfun('isempty', toks));        % limpia vacíos
            % filtra carpetas ocultas/comunes que no deben entrar
            m = contains(toks, [filesep '.git']) | startsWith(toks, '.');
            toks = toks(~m);
            for j = 1:numel(toks)
                if exist(toks{j},'dir')
                    addpath(toks{j},'-begin');
                    added{end+1} = toks{j}; %#ok<AGROW>
                end
            end
        else
            warning('setupProjectPath:MissingDir','Subcarpeta no encontrada: %s', p);
        end
    end

    if nargout, addedPaths = unique(added,'stable'); end
end
