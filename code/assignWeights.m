function [W1, W2, W3, W4, W5, W6, W7] = assignWeights(optimal_alpha)
% assignWeights Asigna cada elemento de optimal_alpha a W1, W2 y W3.
%
% Sintaxis:
%   [W1, W2, W3] = assignWeights(optimal_alpha)
%
% Entradas:
%   optimal_alpha - Vector de 3 elementos.
%
% Salidas:
%   W1, W2, W3   - Escalares correspondientes a cada elemento.
%
% Ejemplo:
%   optimal_alpha = [0.10922, 2.8805e-05, 6.5801e-05];
%   [W1, W2, W3] = assignWeights(optimal_alpha);

    if numel(optimal_alpha) ~= 7
        error('El vector optimal_alpha debe tener exactamente 7 elementos.');
    end

    % Asignación mediante un loop y switch-case:
    for i = 1:7
        switch i
            case 1
                W1 = optimal_alpha(i);
            case 2
                W2 = optimal_alpha(i);
            case 3
                W3 = optimal_alpha(i);
            case 4
                W4 = optimal_alpha(i);
            case 5
                W5 = optimal_alpha(i);
            case 6
                W6 = optimal_alpha(i);
            case 7
                W7 = optimal_alpha(i);
        end
    end
end
