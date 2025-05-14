function ok = esDeteccionCorrecta(conectividad, elemento, P_scaled)
% esDeteccionCorrecta  Comprueba si el nodo con máxima detección
%                      pertenece al elemento dañado.
%
%   ok = esDeteccionCorrecta(conectividad, elemento, P_scaled)
%
%   - conectividad:  N×3, columnas [ID_elem nodo1 nodo2]
%   - elemento:      escalar, ID del elemento dañado
%   - P_scaled:      vector (nodos×1) de valores normalizados
%
%   ok: lógico, true si domIdx ∈ {nodo1,nodo2}

  % Nodo con mayor valor
  [~, domIdx] = max(P_scaled);

  % Extrae los dos nodos del elemento dado
  fila      = conectividad(:,1)==elemento;
  elemNodos = conectividad(fila,2:3);

  % Devuelve true si domIdx coincide con alguno
  ok = any(domIdx == elemNodos);
end
