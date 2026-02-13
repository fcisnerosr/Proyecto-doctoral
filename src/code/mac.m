clc
clear all
close all

% Ejemplo de formas modales para una estructura intacta
phi_intacta = [
    0.7071,  0.5,  0.2;
    0.7071, -0.5,  0.3;
    0,       0.7071,  0.4;
    0.1,     0.2,  0.5;
    0.2,     0.3,  0.6;
    0.3,     0.4,  0.7;
    0.4,     0.5,  0.8;
    0.5,     0.6,  0.9;
    0.6,     0.7,  1.0;
    0.7,     0.8,  1.1
];

% Ejemplo de formas modales para la misma estructura, pero con daño
phi_danada = [
    0.1,    0.7,  0.6;
    0.2,   -0.6,  0.5;
    0.3,    0.6,  0.4;
    0.4,    0.5,  0.3;
    0.5,    0.4,  0.2;
    0.6,    0.3,  0.1;
    0.7,    0.2,  0.7;
    0.8,    0.1,  0.8;
    0.9,    0.9,  0.9;
    1.0,    1.0,  1.0
];

% Ejemplo de matriz de masa (M)
M = diag([2, 1.5, 1, 1, 1, 1, 1, 1, 1, 1]);  % Una matriz de masa simple y diagonal para el ejemplo

% Ejecutar el cálculo de MACN
MACN(phi_intacta, phi_danada, M);

function macn = MACN(phi_intacta, phi_danada, M)
    % Esta función calcula el MAC Normalizado (MACN) entre las formas modales intactas y dañadas
    % phi_intacta: Formas modales de la estructura intacta
    % phi_danada: Formas modales de la estructura dañada
    % M: Matriz de masa
    % macn: Valor promedio del MACN entre las formas modales intactas y dañadas

    % Inicializar suma de MACN
    sum_macn = 0;
    num_modos = size(phi_intacta, 2);

    for i = 1:num_modos
        % Calcular MAC para cada par de modos
        num = (phi_intacta(:,i)' * M * phi_danada(:,i))^2;
        den = (phi_intacta(:,i)' * M * phi_intacta(:,i)) * (phi_danada(:,i)' * M * phi_danada(:,i));
        macn_value = num / den;

        % Sumar el valor de MACN
        sum_macn = sum_macn + macn_value;
    end

    % Calcular el valor promedio de MACN
    macn = sum_macn / num_modos;

    % Mostrar el resultado
    fprintf('Valor promedio de MACN entre formas modales intactas y dañadas: %.6f\n', macn);
end

% function macn = MACN(phi1, phi2, M)
%     % Esta función calcula y grafica la matriz MACN entre dos conjuntos de formas modales
%     % phi1: matriz de las formas modales intactas
%     % phi2: matriz de las formas modales con daño
%     % M: matriz de masa asociada a las formas modales
%     % macn: matriz MACN entre phi1 y phi2
% 
%     % Asegurarse de que phi1 y phi2 tengan el mismo número de modos
%     if size(phi1, 2) ~= size(phi2, 2)
%         error('Las matrices de formas modales deben tener el mismo número de modos.');
%     end
% 
%     % Calcular la matriz MACN
%     macn = zeros(size(phi1, 2), size(phi2, 2));
%     for I = 1:size(phi1, 2)
%         for J = 1:size(phi2, 2)
%             macn(I, J) = MacN(phi1(:, I), phi2(:, J), M);
%         end
%     end
% 
%     % Graficar la matriz MACN
%     figure
%     bar3(macn)
%     title('MACN entre formas modales intactas y dañadas')
%     xlabel('Modos en la estructura con daño')
%     ylabel('Modos en la estructura intacta')
% end
% 
% function mAcN = MacN(Phi1, Phi2, M)
%     % Esta función calcula el valor MACN entre dos formas modales
%     % utilizando la matriz de masa para normalizar la energía modal
%     mAcN = (abs(Phi1' * M * Phi2))^2 / ((Phi1' * M * Phi1) * (Phi2' * M * Phi2));
% end


% function mac = MAC(phi1, phi2)
%     % Esta función calcula y grafica la matriz de MAC entre dos conjuntos de formas modales
%     % phi1: matriz de las formas modales intactas
%     % phi2: matriz de las formas modales con daño
%     % mac: matriz MAC entre phi1 y phi2
% 
%     % Asegurarse de que phi1 y phi2 tengan el mismo número de modos
%     if size(phi1, 2) ~= size(phi2, 2)
%         error('Las matrices de formas modales deben tener el mismo número de modos.');
%     end
% 
%     % Calcular la matriz MAC
%     mac = zeros(size(phi1, 2), size(phi2, 2));
%     for I = 1:size(phi1, 2)
%         for J = 1:size(phi2, 2)
%             mac(I, J) = Mac(phi1(:, I), phi2(:, J));
%         end
%     end
% 
%     % Graficar la matriz MAC
%     figure
%     bar3(mac)
%     title('MAC entre formas modales intactas y dañadas')
%     xlabel('Modos en la estructura con daño')
%     ylabel('Modos en la estructura intacta')
% end
% 
% function mAc = Mac(Phi1, Phi2)
%     % Esta función calcula el valor MAC entre dos formas modales
%     mAc = (abs(Phi1' * Phi2))^2 / ((Phi1' * Phi1) * (Phi2' * Phi2));
% end
