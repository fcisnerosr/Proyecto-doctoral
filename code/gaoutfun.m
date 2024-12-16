function state = gaoutfun(options,state,flag)
    switch flag
        case 'init'
            % Inicializa tu gráfica aquí
            fig_handle = figure;
            set(fig_handle, 'Name', 'Diferencias COMAC', 'NumberTitle', 'off');
        case 'iter'
            % Actualiza tu gráfica aquí
            comac_diff = calcularDiferencias(state.Best); % Asumiendo que tienes una función que calcula las diferencias
            figure(fig_handle);
            clf; % Limpia la figura actual
            imagesc(comac_diff); % Grafica la matriz de diferencias
            colorbar;
            title('Diferencias nodo a nodo en la matriz COMAC');
            xlabel('Modos de vibrar');
            ylabel('Nodos');
        case 'done'
            % Limpieza final si es necesario
    end
end
