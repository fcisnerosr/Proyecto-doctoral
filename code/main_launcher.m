% main_launcher.m
clc; clear; close all;
% 1) Carga configuración
config = config();      % o: run config.m si es script
% 2) Crea carpeta de resultados
if ~exist(config.outputFolder, 'dir')
  mkdir(config.outputFolder);
end
% 3) Lanza el barrido completo
tablaResultados = runExperimentos(config);
