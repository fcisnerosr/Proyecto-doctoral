function [order1, order2] = reorganizar_vector(vector)
    % Calcula la longitud del vector
    n = length(vector);

    % Calcula la cantidad de grupos de 6
    num_grupos = n / 6;

    % Inicializa los vectores order1 y order2
    order1 = [];
    order2 = [];

    % Recorre cada grupo de 6 elementos
    for i = 1:num_grupos
        % Agrega el primer, segundo, y tercer valor del grupo a order1
        order1 = [order1, vector((i-1)*6+1), vector((i-1)*6+2), vector((i-1)*6+3)];
        
        % Agrega los valores restantes del grupo a order2
        for j = 4:6
            order2 = [order2, vector((i-1)*6+j)];
        end
    end

    % Ordena los valores en order2 de menor a mayor
    order2 = sort(order2);
end
