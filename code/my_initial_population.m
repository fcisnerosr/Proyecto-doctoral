function Pop = my_initial_population(N, num_variables)
    Pop = rand(N, num_variables) * 0.30; % Generar valores entre 0 y 30%
    for i = 1:N
        Pop(i, 1:10) = 0.30; % Forzar que los primeros 10 elementos tengan daño del 30%
    end
end
