% config.m (función)
function config = config()
  config.tipo        = "simple";
  % config.tipo_dano   = 'corrosion'; 
  config.tipo_dano   = 'abolladura'; 
  config.ab          = struct('Nseg', 1000, 'Slong', 5, 'lim', 3e-3);
  % config.rangoElem   = 5:6; 
  % config.porcentajes = 5:5:10;   % [5,10,15,…,90]
  % config.rangoElem   = 1:120; 
  config.rangoElem   = 71; 
  config.porcentajes = 49;   % [5,10,15,…,90]
  config.outputFolder = fullfile(pwd, "resultados_AG");
end