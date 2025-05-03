function resultsTable = runExperimentos(config)
  ID = 1;
  results = [];
  % -- simple vs combinado según config.tipo
  % -- dentro de cada bucle: res = unaCorridaAG(...);
  % -- results = [results; res];
  % Al final:
  resultsTable = struct2table(results);
  writetable(resultsTable, fullfile(config.outputFolder, "todos_los_resultados.xlsx"));
end
