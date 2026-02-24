function pathfile = obtenerRutaMarco3Ddam0()
    % Función para obtener la ruta completa del archivo marco3Ddam0.xlsx
    %
    % Salida:
    %   pathfile: Ruta completa del archivo

    % Obtener ruta del script actual
    scriptPath = fileparts(mfilename('fullpath'));
    
    % Subir hasta la raíz del proyecto (3 niveles arriba)
    rootPath = fullfile(scriptPath, '..', '..', '..');
    rootPath = char(java.io.File(rootPath).getCanonicalPath());
    
    % Intentar varios paths posibles
    posibles_rutas = {
        fullfile(rootPath, 'data', 'excels_de_ing_Jaret', 'Jaret3erPlataforma-09-02-2022c2.xlsx');
        fullfile(rootPath, 'pruebas_excel', 'marco3Ddam0.xlsx');
        fullfile(rootPath, 'data', 'marco3Ddam0.xlsx');
    };
    
    for i = 1:length(posibles_rutas)
        if exist(posibles_rutas{i}, 'file')
            pathfile = posibles_rutas{i};
            return;
        end
    end
    
    % Si no se encuentra ninguno, usar el primero (para diagnóstico)
    pathfile = posibles_rutas{1};
end
