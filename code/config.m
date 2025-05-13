% config.m (función)
function config = config()
  config.tipo        = "simple";
  config.tipo_dano = 'corrosion'; 
  % config.rangoElem   = 1:120;
  config.rangoElem   = 8;
  config.porcentajes = [30];
  config.outputFolder = fullfile(pwd, "resultados_AG");
end
