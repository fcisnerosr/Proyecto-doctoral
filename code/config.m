% config.m (función)
function config = config()
  config.tipo        = "simple";
  config.tipo_dano   = 'corrosion'; 
  config.rangoElem   = 1:120; 
  config.porcentajes = 5:5:90;   % [5,10,15,…,90]
  config.outputFolder = fullfile(pwd, "resultados_AG");
end
