% config.m (función)
function config = config()
  config.tipo        = "simple";
  config.rangoElem   = 1:120;
  config.porcentajes = [5,10,15];
  config.outputFolder = fullfile(pwd, "resultados_AG");
end
