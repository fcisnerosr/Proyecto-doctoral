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
  % Offset = cuantos nodos empotrados no están en P_scaled
  offset = 4;

  % 1) Índice interno de P_scaled con mayor valor
  [~, domIdx] = max(P_scaled);

  % 2) Lo convierto a número de nodo real
  nodoDetectado = domIdx + offset;

  % 3) Extraigo los nodos que componen ese elemento
  fila      = (conectividad(:,1)==elemento);
  elemNodos = conectividad(fila,2:3);  % [nodo1 nodo2]

  % 4) Compruebo si el nodoDetectado está en esos dos
  ok = any(nodoDetectado == elemNodos);
end
