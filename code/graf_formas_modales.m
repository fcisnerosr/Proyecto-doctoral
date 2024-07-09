function graf_formas_modales(modos_cond, nodes)
    close all
    figure
    % for modo = 1:3
    for modo = 1
        factor_amplificacion = 1000000;         % Factor de amplificación a fin de poder apreciar la forma modal
        X = nodes(:, 2);                        % nodos en X de la matriz de nodes inicial
        Y = nodes(:, 3);
        Z = nodes(:, 4);
        nodos_graf          = nodes;    
        nodos_graf(:,1)     = [];
        nodos_graf          = nodos_graf(5:end, :);
        modo_n              = reshape(modos_cond(:,modo),3,[])';
        modo_amplificado    = modo_n*factor_amplificacion;
        modo_mas_origin     = nodos_graf + modo_amplificado;
        
        % Graficar ambas matrices en una sola figura
        % figure;
        
        subplot(1,3,modo);
        hold on;
        % Plot de nodos del modelo intacto
        plot3(X,Y,Z, 'bs', 'LineWidth', 1.5, 'MarkerSize', 4);
        
        % Plot de la forma modal n
        plot3(modo_mas_origin(:,1), modo_mas_origin(:,2), modo_mas_origin(:,3), 'rd', 'LineWidth', 1.5, 'MarkerSize', 4);
        
        plot3()
        % Configuración de la gráfica
        grid on;
        xlabel('Eje X en mm');
        ylabel('Eje Y en mm');
        zlabel('Eje Z en mm');
        title(sprintf('Modo %d', modo));
        
        % Leyenda
        legend('Nodos', sprintf('Modo %d', modo));        
        % Opcional: Cambiar la vista de la gráfica para mejor visualización
        view(3);  % Vista en 3D
    end
end
