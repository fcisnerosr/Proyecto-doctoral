%{
    m = [1 12;...
    2 200;...
    3 1234]
%}

A =diag([ 12;...
    200;...
   1234]) 

% Define el vector de índices
indices = [1 2 3 4 5 6 7 8 9 10 11 12 13 15 16]

% Obtener el tamaño de la matriz
n = size(A, 1);


% Calcular la longitud del vector de salida
longitudVector = length(indices);

% Crear un vector vacío
y = zeros(1, longitudVector);

% Recorrer los índices y extraer los elementos diagonales
for i = 1:longitudVector
    y(i) = A(indices(i), indices(i));
end
y = diag(y)