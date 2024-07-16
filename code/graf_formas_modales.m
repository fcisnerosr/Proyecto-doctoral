function graf_formas_modales(modos_cond, nodes)
    % Generar 3 txt para tener las lineas a graficar 
    % Ruta del directorio donde se guardarán los archivos
    % directory = 'E:\Archivos_Jaret\Proyecto-doctoral\code\graficas_líneas_formas_modales'; % Cambia esta ruta según tu necesidad
    
    % Crear y escribir en 3 archivos de texto diferentes (conectividad)
    % conectividad = matriz de 3 filas, primera es de no. de elemento tubular (línea) y las otras dos son entre qué nodos están. (puntos a graficar)
    % Modelo: plot3([X(2), X(4)], [Y(2), Y(4)], [Z(2), Z(4)], 'b-', 'LineWidth', 3); % 'g-' dibuja una línea azul
    % for i = 1:3
    %     % Definir el nombre del archivo
    %     filename = fullfile(directory, ['archivo_' num2str(i) '.txt']);
    % 
    %     % Abrir el archivo para escritura
    %     fid = fopen(filename, 'w');
    %     if fid == -1
    %         error('No se pudo abrir el archivo: %s', filename);
    %     end
    % 
    %     % Escribir contenido en el archivo
    %     fprintf(fid, 'Este es el archivo número %d\n', i);
    %     fprintf(fid, 'Aquí puedes añadir cualquier contenido que desees.\n');
    % 
    %     % Cerrar el archivo
    %     fclose(fid);
    % end
    
    close all
    figure
    
    for modo = 1:3
    % for modo = 1
        factor_amplificacion = 1000000;         % Factor de amplificación a fin de poder apreciar la forma modal
        % factor_amplificacion = 1;         % Factor de amplificación a fin de poder apreciar la forma modal
        X = nodes(:, 2);                        % nodos en X de la matriz de nodes inicial
        Y = nodes(:, 3);
        Z = nodes(:, 4);
        nodos_graf          = nodes;    
        nodos_graf(:,1)     = [];
        nodos_graf          = nodos_graf(5:end, :);
        modo_n              = reshape(modos_cond(:,modo),3,[])';
        modo_amplificado    = modo_n*factor_amplificacion;
        modo_mas_origin     = nodos_graf + modo_amplificado;


        subplot(1,3,modo);
        hold on;
        % Plot de nodos del modelo intacto
        plot3(X,Y,Z, 'bs', 'LineWidth', 1.5, 'MarkerSize', 4);
        
        % text(X(1), Y(1), Z(1), num2str(1), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(2), Y(2), Z(2), num2str(2), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(3), Y(3), Z(3), num2str(3), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(4), Y(4), Z(4), num2str(4), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(5), Y(5), Z(5), num2str(5), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(6), Y(6), Z(6), num2str(6), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(7), Y(7), Z(7), num2str(7), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(8), Y(8), Z(8), num2str(8), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(9), Y(9), Z(9), num2str(9), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(10), Y(10), Z(10), num2str(10), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(11), Y(11), Z(11), num2str(11), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(12), Y(12), Z(12), num2str(12), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(13), Y(13), Z(13), num2str(13), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(14), Y(14), Z(14), num2str(14), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(15), Y(15), Z(15), num2str(15), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(16), Y(16), Z(16), num2str(16), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(17), Y(17), Z(17), num2str(17), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(18), Y(18), Z(18), num2str(18), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(19), Y(19), Z(19), num2str(19), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(20), Y(20), Z(20), num2str(20), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(21), Y(21), Z(21), num2str(21), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(22), Y(22), Z(22), num2str(22), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(23), Y(23), Z(23), num2str(23), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(24), Y(24), Z(24), num2str(24), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(25), Y(25), Z(25), num2str(25), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(26), Y(26), Z(26), num2str(26), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(27), Y(27), Z(27), num2str(27), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(28), Y(28), Z(28), num2str(28), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(29), Y(29), Z(29), num2str(29), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(30), Y(30), Z(30), num2str(30), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(31), Y(31), Z(31), num2str(31), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(32), Y(32), Z(32), num2str(32), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(33), Y(33), Z(33), num2str(33), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(34), Y(34), Z(34), num2str(34), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(35), Y(35), Z(35), num2str(35), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(36), Y(36), Z(36), num2str(36), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(37), Y(37), Z(37), num2str(37), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(38), Y(38), Z(38), num2str(38), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(39), Y(39), Z(39), num2str(39), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(40), Y(40), Z(40), num2str(40), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(41), Y(41), Z(41), num2str(41), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(42), Y(42), Z(42), num2str(42), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(43), Y(43), Z(43), num2str(43), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(44), Y(44), Z(44), num2str(44), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(45), Y(45), Z(45), num2str(45), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(46), Y(46), Z(46), num2str(46), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(47), Y(47), Z(47), num2str(47), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(48), Y(48), Z(48), num2str(48), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(49), Y(49), Z(49), num2str(49), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(50), Y(50), Z(50), num2str(50), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(51), Y(51), Z(51), num2str(51), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(52), Y(52), Z(52), num2str(52), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(53), Y(53), Z(53), num2str(53), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(54), Y(54), Z(54), num2str(54), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(55), Y(55), Z(55), num2str(55), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(56), Y(56), Z(56), num2str(56), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(57), Y(57), Z(57), num2str(57), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(58), Y(58), Z(58), num2str(58), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(59), Y(59), Z(59), num2str(59), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(60), Y(60), Z(60), num2str(60), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(61), Y(61), Z(61), num2str(61), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(62), Y(62), Z(62), num2str(62), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(63), Y(63), Z(63), num2str(63), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(64), Y(64), Z(64), num2str(64), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(65), Y(65), Z(65), num2str(65), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(66), Y(66), Z(66), num2str(66), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(67), Y(67), Z(67), num2str(67), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(68), Y(68), Z(68), num2str(68), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(69), Y(69), Z(69), num2str(69), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(70), Y(70), Z(70), num2str(70), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(71), Y(71), Z(71), num2str(71), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(72), Y(72), Z(72), num2str(72), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(73), Y(73), Z(73), num2str(73), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(74), Y(74), Z(74), num2str(74), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(75), Y(75), Z(75), num2str(75), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
        % text(X(76), Y(76), Z(76), num2str(76), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

        % Líneas para dibujar la plataforma inicial
        plot3([X(04), X(08)], [Y(04), Y(08)], [Z(04), Z(08)], 'b-', 'LineWidth', 3);
        plot3([X(01), X(08)], [Y(01), Y(08)], [Z(01), Z(08)], 'b-', 'LineWidth', 3);
        plot3([X(12), X(08)], [Y(12), Y(08)], [Z(12), Z(08)], 'b-', 'LineWidth', 3);
        plot3([X(09), X(08)], [Y(09), Y(08)], [Z(09), Z(08)], 'b-', 'LineWidth', 3);
        plot3([X(09), X(01)], [Y(09), Y(01)], [Z(09), Z(01)], 'b-', 'LineWidth', 3);
        plot3([X(04), X(12)], [Y(04), Y(12)], [Z(04), Z(12)], 'b-', 'LineWidth', 3);
        plot3([X(01), X(05)], [Y(01), Y(05)], [Z(01), Z(05)], 'b-', 'LineWidth', 3);
        plot3([X(05), X(10)], [Y(05), Y(10)], [Z(05), Z(10)], 'b-', 'LineWidth', 3);
        plot3([X(02), X(09)], [Y(02), Y(09)], [Z(02), Z(09)], 'b-', 'LineWidth', 3);
        plot3([X(04), X(44)], [Y(04), Y(44)], [Z(04), Z(44)], 'b-', 'LineWidth', 3);
        plot3([X(01), X(41)], [Y(01), Y(41)], [Z(01), Z(41)], 'b-', 'LineWidth', 3);
        plot3([X(02), X(42)], [Y(02), Y(42)], [Z(02), Z(42)], 'b-', 'LineWidth', 3);
        plot3([X(03), X(43)], [Y(03), Y(43)], [Z(03), Z(43)], 'b-', 'LineWidth', 3);
        plot3([X(10), X(17)], [Y(10), Y(17)], [Z(10), Z(17)], 'b-', 'LineWidth', 3);
        plot3([X(11), X(18)], [Y(11), Y(18)], [Z(11), Z(18)], 'b-', 'LineWidth', 3);
        plot3([X(10), X(19)], [Y(10), Y(19)], [Z(10), Z(19)], 'b-', 'LineWidth', 3);
        plot3([X(11), X(20)], [Y(11), Y(20)], [Z(11), Z(20)], 'b-', 'LineWidth', 3);
        plot3([X(12), X(19)], [Y(12), Y(19)], [Z(12), Z(19)], 'b-', 'LineWidth', 3);
        plot3([X(12), X(17)], [Y(12), Y(17)], [Z(12), Z(17)], 'b-', 'LineWidth', 3);
        plot3([X(09), X(20)], [Y(09), Y(20)], [Z(09), Z(20)], 'b-', 'LineWidth', 3);
        plot3([X(09), X(18)], [Y(09), Y(18)], [Z(09), Z(18)], 'b-', 'LineWidth', 3);
        plot3([X(10), X(17)], [Y(10), Y(17)], [Z(10), Z(17)], 'b-', 'LineWidth', 3);
        plot3([X(10), X(01)], [Y(10), Y(01)], [Z(10), Z(01)], 'b-', 'LineWidth', 3);
        plot3([X(02), X(11)], [Y(02), Y(11)], [Z(02), Z(11)], 'b-', 'LineWidth', 3);
        plot3([X(03), X(10)], [Y(03), Y(10)], [Z(03), Z(10)], 'b-', 'LineWidth', 3);
        plot3([X(03), X(12)], [Y(03), Y(12)], [Z(03), Z(12)], 'b-', 'LineWidth', 3);
        plot3([X(04), X(11)], [Y(04), Y(11)], [Z(04), Z(11)], 'b-', 'LineWidth', 3);
        plot3([X(18), X(27)], [Y(18), Y(27)], [Z(18), Z(28)], 'b-', 'LineWidth', 3);
        plot3([X(19), X(26)], [Y(19), Y(26)], [Z(19), Z(26)], 'b-', 'LineWidth', 3);
        plot3([X(19), X(28)], [Y(19), Y(28)], [Z(19), Z(28)], 'b-', 'LineWidth', 3);
        plot3([X(20), X(27)], [Y(20), Y(27)], [Z(20), Z(27)], 'b-', 'LineWidth', 3);
        plot3([X(20), X(25)], [Y(20), Y(25)], [Z(20), Z(25)], 'b-', 'LineWidth', 3);
        plot3([X(17), X(28)], [Y(17), Y(28)], [Z(17), Z(28)], 'b-', 'LineWidth', 3);
        plot3([X(17), X(26)], [Y(17), Y(26)], [Z(17), Z(26)], 'b-', 'LineWidth', 3);
        plot3([X(18), X(25)], [Y(18), Y(25)], [Z(18), Z(25)], 'b-', 'LineWidth', 3);
        plot3([X(26), X(35)], [Y(26), Y(35)], [Z(26), Z(35)], 'b-', 'LineWidth', 3);
        plot3([X(27), X(34)], [Y(27), Y(34)], [Z(27), Z(34)], 'b-', 'LineWidth', 3);
        plot3([X(27), X(36)], [Y(27), Y(36)], [Z(27), Z(36)], 'b-', 'LineWidth', 3);
        plot3([X(28), X(35)], [Y(28), Y(35)], [Z(28), Z(35)], 'b-', 'LineWidth', 3);
        plot3([X(28), X(33)], [Y(28), Y(33)], [Z(28), Z(33)], 'b-', 'LineWidth', 3);
        plot3([X(25), X(36)], [Y(25), Y(36)], [Z(25), Z(36)], 'b-', 'LineWidth', 3);
        plot3([X(25), X(34)], [Y(25), Y(34)], [Z(25), Z(34)], 'b-', 'LineWidth', 3);
        plot3([X(26), X(33)], [Y(26), Y(33)], [Z(26), Z(33)], 'b-', 'LineWidth', 3);
        plot3([X(26), X(35)], [Y(26), Y(35)], [Z(26), Z(35)], 'b-', 'LineWidth', 3);
        plot3([X(27), X(34)], [Y(27), Y(34)], [Z(27), Z(34)], 'b-', 'LineWidth', 3);
        plot3([X(27), X(36)], [Y(27), Y(36)], [Z(27), Z(36)], 'b-', 'LineWidth', 3);
        plot3([X(28), X(35)], [Y(28), Y(35)], [Z(28), Z(35)], 'b-', 'LineWidth', 3);
        plot3([X(28), X(33)], [Y(28), Y(33)], [Z(28), Z(33)], 'b-', 'LineWidth', 3);
        plot3([X(25), X(36)], [Y(25), Y(36)], [Z(25), Z(36)], 'b-', 'LineWidth', 3);
        plot3([X(36), X(41)], [Y(36), Y(41)], [Z(36), Z(41)], 'b-', 'LineWidth', 3);
        plot3([X(33), X(44)], [Y(33), Y(44)], [Z(33), Z(44)], 'b-', 'LineWidth', 3);
        plot3([X(33), X(42)], [Y(33), Y(42)], [Z(33), Z(42)], 'b-', 'LineWidth', 3);
        plot3([X(34), X(41)], [Y(34), Y(41)], [Z(34), Z(41)], 'b-', 'LineWidth', 3);
        plot3([X(34), X(43)], [Y(34), Y(43)], [Z(34), Z(43)], 'b-', 'LineWidth', 3);
        plot3([X(35), X(42)], [Y(35), Y(42)], [Z(35), Z(42)], 'b-', 'LineWidth', 3);
        plot3([X(35), X(44)], [Y(35), Y(44)], [Z(35), Z(44)], 'b-', 'LineWidth', 3);
        plot3([X(36), X(43)], [Y(36), Y(43)], [Z(36), Z(43)], 'b-', 'LineWidth', 3);
    
        plot3([X(41), X(70)], [Y(41), Y(70)], [Z(41), Z(70)], 'b-', 'LineWidth', 3);
        plot3([X(42), X(71)], [Y(42), Y(71)], [Z(42), Z(71)], 'b-', 'LineWidth', 3);
        plot3([X(43), X(67)], [Y(43), Y(67)], [Z(43), Z(67)], 'b-', 'LineWidth', 3);
        plot3([X(44), X(66)], [Y(44), Y(66)], [Z(44), Z(66)], 'b-', 'LineWidth', 3);
        plot3([X(57), X(45)], [Y(57), Y(45)], [Z(57), Z(45)], 'b-', 'LineWidth', 3);
        plot3([X(57), X(60)], [Y(57), Y(60)], [Z(57), Z(60)], 'b-', 'LineWidth', 3);
        plot3([X(48), X(60)], [Y(48), Y(60)], [Z(48), Z(60)], 'b-', 'LineWidth', 3);
        plot3([X(48), X(45)], [Y(48), Y(45)], [Z(48), Z(45)], 'b-', 'LineWidth', 3);
        plot3([X(73), X(61)], [Y(73), Y(61)], [Z(73), Z(61)], 'b-', 'LineWidth', 3);
        plot3([X(64), X(61)], [Y(64), Y(61)], [Z(64), Z(61)], 'b-', 'LineWidth', 3);
        plot3([X(64), X(76)], [Y(64), Y(76)], [Z(64), Z(76)], 'b-', 'LineWidth', 3);
        plot3([X(73), X(76)], [Y(73), Y(76)], [Z(73), Z(76)], 'b-', 'LineWidth', 3);
        plot3([X(65), X(68)], [Y(65), Y(68)], [Z(65), Z(68)], 'b-', 'LineWidth', 3);
        plot3([X(69), X(72)], [Y(69), Y(72)], [Z(69), Z(72)], 'b-', 'LineWidth', 3);
        plot3([X(74), X(62)], [Y(74), Y(62)], [Z(74), Z(62)], 'b-', 'LineWidth', 3);
        plot3([X(75), X(63)], [Y(75), Y(63)], [Z(75), Z(63)], 'b-', 'LineWidth', 3);
        plot3([X(53), X(56)], [Y(53), Y(56)], [Z(53), Z(56)], 'b-', 'LineWidth', 3);
        plot3([X(49), X(52)], [Y(49), Y(52)], [Z(49), Z(52)], 'b-', 'LineWidth', 3);
        plot3([X(58), X(46)], [Y(58), Y(46)], [Z(58), Z(46)], 'b-', 'LineWidth', 3);
        p1 = plot3([X(59), X(47)], [Y(59), Y(47)], [Z(59), Z(47)], 'b-', 'LineWidth', 3);

        % % Plot de los puntos de las forma modal n
        plot3(modo_mas_origin(:,1), modo_mas_origin(:,2), modo_mas_origin(:,3), 'rd', 'LineWidth', 1.5, 'MarkerSize', 4);

        % Numeros en las formas modales
        % text(modo_mas_origin(1,1), modo_mas_origin(1,2), modo_mas_origin(1,3), sprintf('%d', 1), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(2,1), modo_mas_origin(2,2), modo_mas_origin(2,3), sprintf('%d', 2), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(3,1), modo_mas_origin(3,2), modo_mas_origin(3,3), sprintf('%d', 3), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(4,1), modo_mas_origin(4,2), modo_mas_origin(4,3), sprintf('%d', 4), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(5,1), modo_mas_origin(5,2), modo_mas_origin(5,3), sprintf('%d', 5), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(6,1), modo_mas_origin(6,2), modo_mas_origin(6,3), sprintf('%d', 6), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(7,1), modo_mas_origin(7,2), modo_mas_origin(7,3), sprintf('%d', 7), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(8,1), modo_mas_origin(8,2), modo_mas_origin(8,3), sprintf('%d', 8), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(9,1), modo_mas_origin(9,2), modo_mas_origin(9,3), sprintf('%d', 9), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(10,1), modo_mas_origin(10,2), modo_mas_origin(10,3), sprintf('%d', 10), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(11,1), modo_mas_origin(11,2), modo_mas_origin(11,3), sprintf('%d', 11), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(12,1), modo_mas_origin(12,2), modo_mas_origin(12,3), sprintf('%d', 12), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(13,1), modo_mas_origin(13,2), modo_mas_origin(13,3), sprintf('%d', 13), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(14,1), modo_mas_origin(14,2), modo_mas_origin(14,3), sprintf('%d', 14), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(15,1), modo_mas_origin(15,2), modo_mas_origin(15,3), sprintf('%d', 15), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(16,1), modo_mas_origin(16,2), modo_mas_origin(16,3), sprintf('%d', 16), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(17,1), modo_mas_origin(17,2), modo_mas_origin(17,3), sprintf('%d', 17), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(18,1), modo_mas_origin(18,2), modo_mas_origin(18,3), sprintf('%d', 18), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(19,1), modo_mas_origin(19,2), modo_mas_origin(19,3), sprintf('%d', 19), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(20,1), modo_mas_origin(20,2), modo_mas_origin(20,3), sprintf('%d', 20), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(21,1), modo_mas_origin(21,2), modo_mas_origin(21,3), sprintf('%d', 21), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(22,1), modo_mas_origin(22,2), modo_mas_origin(22,3), sprintf('%d', 22), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(23,1), modo_mas_origin(23,2), modo_mas_origin(23,3), sprintf('%d', 23), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(24,1), modo_mas_origin(24,2), modo_mas_origin(24,3), sprintf('%d', 24), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(25,1), modo_mas_origin(25,2), modo_mas_origin(25,3), sprintf('%d', 25), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(26,1), modo_mas_origin(26,2), modo_mas_origin(26,3), sprintf('%d', 26), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(27,1), modo_mas_origin(27,2), modo_mas_origin(27,3), sprintf('%d', 27), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(28,1), modo_mas_origin(28,2), modo_mas_origin(28,3), sprintf('%d', 28), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(29,1), modo_mas_origin(29,2), modo_mas_origin(29,3), sprintf('%d', 29), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(30,1), modo_mas_origin(30,2), modo_mas_origin(30,3), sprintf('%d', 30), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(31,1), modo_mas_origin(31,2), modo_mas_origin(31,3), sprintf('%d', 31), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(32,1), modo_mas_origin(32,2), modo_mas_origin(32,3), sprintf('%d', 32), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(33,1), modo_mas_origin(33,2), modo_mas_origin(33,3), sprintf('%d', 33), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(34,1), modo_mas_origin(34,2), modo_mas_origin(34,3), sprintf('%d', 34), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(35,1), modo_mas_origin(35,2), modo_mas_origin(35,3), sprintf('%d', 35), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(36,1), modo_mas_origin(36,2), modo_mas_origin(36,3), sprintf('%d', 36), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(37,1), modo_mas_origin(37,2), modo_mas_origin(37,3), sprintf('%d', 37), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(38,1), modo_mas_origin(38,2), modo_mas_origin(38,3), sprintf('%d', 38), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(39,1), modo_mas_origin(39,2), modo_mas_origin(39,3), sprintf('%d', 39), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(40,1), modo_mas_origin(40,2), modo_mas_origin(40,3), sprintf('%d', 40), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(41,1), modo_mas_origin(41,2), modo_mas_origin(41,3), sprintf('%d', 41), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(42,1), modo_mas_origin(42,2), modo_mas_origin(42,3), sprintf('%d', 42), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(43,1), modo_mas_origin(43,2), modo_mas_origin(43,3), sprintf('%d', 43), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(44,1), modo_mas_origin(44,2), modo_mas_origin(44,3), sprintf('%d', 44), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(45,1), modo_mas_origin(45,2), modo_mas_origin(45,3), sprintf('%d', 45), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(46,1), modo_mas_origin(46,2), modo_mas_origin(46,3), sprintf('%d', 46), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(47,1), modo_mas_origin(47,2), modo_mas_origin(47,3), sprintf('%d', 47), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(48,1), modo_mas_origin(48,2), modo_mas_origin(48,3), sprintf('%d', 48), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(49,1), modo_mas_origin(49,2), modo_mas_origin(49,3), sprintf('%d', 49), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(50,1), modo_mas_origin(50,2), modo_mas_origin(50,3), sprintf('%d', 50), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(51,1), modo_mas_origin(51,2), modo_mas_origin(51,3), sprintf('%d', 51), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(52,1), modo_mas_origin(52,2), modo_mas_origin(52,3), sprintf('%d', 52), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(53,1), modo_mas_origin(53,2), modo_mas_origin(53,3), sprintf('%d', 53), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(54,1), modo_mas_origin(54,2), modo_mas_origin(54,3), sprintf('%d', 54), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(55,1), modo_mas_origin(55,2), modo_mas_origin(55,3), sprintf('%d', 55), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(56,1), modo_mas_origin(56,2), modo_mas_origin(56,3), sprintf('%d', 56), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(57,1), modo_mas_origin(57,2), modo_mas_origin(57,3), sprintf('%d', 57), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(58,1), modo_mas_origin(58,2), modo_mas_origin(58,3), sprintf('%d', 58), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(59,1), modo_mas_origin(59,2), modo_mas_origin(59,3), sprintf('%d', 59), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(60,1), modo_mas_origin(60,2), modo_mas_origin(60,3), sprintf('%d', 60), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(61,1), modo_mas_origin(61,2), modo_mas_origin(61,3), sprintf('%d', 61), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(62,1), modo_mas_origin(62,2), modo_mas_origin(62,3), sprintf('%d', 62), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(63,1), modo_mas_origin(63,2), modo_mas_origin(63,3), sprintf('%d', 63), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(64,1), modo_mas_origin(64,2), modo_mas_origin(64,3), sprintf('%d', 64), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(65,1), modo_mas_origin(65,2), modo_mas_origin(65,3), sprintf('%d', 65), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(66,1), modo_mas_origin(66,2), modo_mas_origin(66,3), sprintf('%d', 66), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(67,1), modo_mas_origin(67,2), modo_mas_origin(67,3), sprintf('%d', 67), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(68,1), modo_mas_origin(68,2), modo_mas_origin(68,3), sprintf('%d', 68), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(69,1), modo_mas_origin(69,2), modo_mas_origin(69,3), sprintf('%d', 69), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(70,1), modo_mas_origin(70,2), modo_mas_origin(70,3), sprintf('%d', 70), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(71,1), modo_mas_origin(71,2), modo_mas_origin(71,3), sprintf('%d', 71), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
        % text(modo_mas_origin(72,1), modo_mas_origin(72,2), modo_mas_origin(72,3), sprintf('%d', 72), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

        % Lineas de las formas modales
        m1 = modo_mas_origin(:,1);   % mm matriz de modos
        m2 = modo_mas_origin(:,2);   % mm matriz de modos
        m3 = modo_mas_origin(:,3);   % mm matriz de modos
        plot3([m1(05), m1(04)], [m2(05), m2(04)], [m3(05), m3(04)], 'r-', 'LineWidth', 3);
        plot3([m1(08), m1(04)], [m2(08), m2(04)], [m3(08), m3(04)], 'r-', 'LineWidth', 3);
        plot3([m1(08), m1(16)], [m2(08), m2(16)], [m3(08), m3(16)], 'r-', 'LineWidth', 3);
        plot3([m1(08), m1(12)], [m2(08), m2(12)], [m3(08), m3(12)], 'r-', 'LineWidth', 3);
        plot3([m1(08), m1(05)], [m2(08), m2(05)], [m3(08), m3(05)], 'r-', 'LineWidth', 3);
        plot3([m1(12), m1(05)], [m2(12), m2(05)], [m3(12), m3(05)], 'r-', 'LineWidth', 3);
        plot3([m1(12), m1(13)], [m2(12), m2(13)], [m3(12), m3(13)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(13)], [m2(16), m2(13)], [m3(16), m3(13)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(12)], [m2(16), m2(12)], [m3(16), m3(12)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(20)], [m2(16), m2(20)], [m3(16), m3(20)], 'r-', 'LineWidth', 3);
        plot3([m1(13), m1(20)], [m2(13), m2(20)], [m3(13), m3(20)], 'r-', 'LineWidth', 3);
        plot3([m1(13), m1(21)], [m2(13), m2(21)], [m3(13), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(28), m1(21)], [m2(28), m2(21)], [m3(28), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(28), m1(24)], [m2(28), m2(24)], [m3(28), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(24)], [m2(29), m2(24)], [m3(29), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(21)], [m2(29), m2(21)], [m3(29), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(20), m1(21)], [m2(20), m2(21)], [m3(20), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(20), m1(24)], [m2(20), m2(24)], [m3(20), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(24)], [m2(16), m2(24)], [m3(16), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(05), m1(13)], [m2(05), m2(13)], [m3(05), m3(13)], 'r-', 'LineWidth', 3);
        plot3([m1(28), m1(32)], [m2(28), m2(32)], [m3(28), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(24), m1(32)], [m2(24), m2(32)], [m3(24), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(32)], [m2(29), m2(32)], [m3(29), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(40), m1(32)], [m2(40), m2(32)], [m3(40), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(36)], [m2(29), m2(36)], [m3(29), m3(36)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(37)], [m2(29), m2(37)], [m3(29), m3(37)], 'r-', 'LineWidth', 3);
        plot3([m1(36), m1(40)], [m2(36), m2(40)], [m3(36), m3(40)], 'r-', 'LineWidth', 3);
        plot3([m1(36), m1(37)], [m2(36), m2(37)], [m3(36), m3(37)], 'r-', 'LineWidth', 3);
        plot3([m1(36), m1(32)], [m2(36), m2(32)], [m3(36), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(40), m1(37)], [m2(40), m2(37)], [m3(40), m3(37)], 'r-', 'LineWidth', 3);

        plot3([m1(01), m1(05)], [m2(01), m2(05)], [m3(01), m3(05)], 'r-', 'LineWidth', 3);
        plot3([m1(06), m1(05)], [m2(06), m2(05)], [m3(06), m3(05)], 'r-', 'LineWidth', 3);
        plot3([m1(06), m1(01)], [m2(06), m2(01)], [m3(06), m3(01)], 'r-', 'LineWidth', 3);
        plot3([m1(06), m1(09)], [m2(06), m2(09)], [m3(06), m3(09)], 'r-', 'LineWidth', 3);
        plot3([m1(05), m1(09)], [m2(05), m2(09)], [m3(05), m3(09)], 'r-', 'LineWidth', 3);
        plot3([m1(13), m1(09)], [m2(13), m2(09)], [m3(13), m3(09)], 'r-', 'LineWidth', 3);
        plot3([m1(14), m1(09)], [m2(14), m2(09)], [m3(14), m3(09)], 'r-', 'LineWidth', 3);
        plot3([m1(17), m1(13)], [m2(17), m2(13)], [m3(17), m3(13)], 'r-', 'LineWidth', 3);
        plot3([m1(17), m1(14)], [m2(17), m2(14)], [m3(17), m3(14)], 'r-', 'LineWidth', 3);
        plot3([m1(17), m1(22)], [m2(17), m2(22)], [m3(17), m3(22)], 'r-', 'LineWidth', 3);
        plot3([m1(17), m1(21)], [m2(17), m2(21)], [m3(17), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(25), m1(21)], [m2(25), m2(21)], [m3(25), m3(21)], 'r-', 'LineWidth', 3);
        plot3([m1(25), m1(22)], [m2(25), m2(22)], [m3(25), m3(22)], 'r-', 'LineWidth', 3);
        plot3([m1(25), m1(29)], [m2(25), m2(29)], [m3(25), m3(29)], 'r-', 'LineWidth', 3);
        plot3([m1(25), m1(30)], [m2(25), m2(30)], [m3(25), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(33), m1(29)], [m2(33), m2(29)], [m3(33), m3(29)], 'r-', 'LineWidth', 3);
        plot3([m1(33), m1(30)], [m2(33), m2(30)], [m3(33), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(33), m1(37)], [m2(33), m2(37)], [m3(33), m3(37)], 'r-', 'LineWidth', 3);
        plot3([m1(33), m1(38)], [m2(33), m2(38)], [m3(33), m3(38)], 'r-', 'LineWidth', 3);
        plot3([m1(37), m1(38)], [m2(37), m2(38)], [m3(37), m3(38)], 'r-', 'LineWidth', 3);
        plot3([m1(29), m1(30)], [m2(29), m2(30)], [m3(29), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(21), m1(22)], [m2(21), m2(22)], [m3(21), m3(22)], 'r-', 'LineWidth', 3);
        plot3([m1(13), m1(14)], [m2(13), m2(14)], [m3(13), m3(14)], 'r-', 'LineWidth', 3);
        plot3([m1(38), m1(30)], [m2(38), m2(30)], [m3(38), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(22), m1(30)], [m2(22), m2(30)], [m3(22), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(22), m1(14)], [m2(22), m2(14)], [m3(22), m3(14)], 'r-', 'LineWidth', 3);
        plot3([m1(06), m1(14)], [m2(06), m2(14)], [m3(06), m3(14)], 'r-', 'LineWidth', 3);

        plot3([m1(06), m1(02)], [m2(06), m2(02)], [m3(06), m3(02)], 'r-', 'LineWidth', 3);
        plot3([m1(07), m1(02)], [m2(07), m2(02)], [m3(07), m3(02)], 'r-', 'LineWidth', 3);
        plot3([m1(07), m1(06)], [m2(07), m2(06)], [m3(07), m3(06)], 'r-', 'LineWidth', 3);
        plot3([m1(10), m1(06)], [m2(10), m2(06)], [m3(10), m3(06)], 'r-', 'LineWidth', 3);
        plot3([m1(10), m1(07)], [m2(10), m2(07)], [m3(10), m3(07)], 'r-', 'LineWidth', 3);
        plot3([m1(10), m1(15)], [m2(10), m2(15)], [m3(10), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(10), m1(14)], [m2(10), m2(14)], [m3(10), m3(14)], 'r-', 'LineWidth', 3);
        plot3([m1(14), m1(15)], [m2(14), m2(15)], [m3(14), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(18), m1(15)], [m2(18), m2(15)], [m3(18), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(18), m1(14)], [m2(18), m2(14)], [m3(18), m3(14)], 'r-', 'LineWidth', 3);
        plot3([m1(18), m1(22)], [m2(18), m2(22)], [m3(18), m3(22)], 'r-', 'LineWidth', 3);
        plot3([m1(18), m1(23)], [m2(18), m2(23)], [m3(18), m3(23)], 'r-', 'LineWidth', 3);
        plot3([m1(22), m1(23)], [m2(22), m2(23)], [m3(22), m3(23)], 'r-', 'LineWidth', 3);
        plot3([m1(26), m1(23)], [m2(26), m2(23)], [m3(26), m3(23)], 'r-', 'LineWidth', 3);
        plot3([m1(26), m1(22)], [m2(26), m2(22)], [m3(26), m3(22)], 'r-', 'LineWidth', 3);
        plot3([m1(26), m1(30)], [m2(26), m2(30)], [m3(26), m3(30)], 'r-', 'LineWidth', 3);
        plot3([m1(26), m1(31)], [m2(26), m2(31)], [m3(26), m3(31)], 'r-', 'LineWidth', 3);
        plot3([m1(30), m1(31)], [m2(30), m2(31)], [m3(30), m3(31)], 'r-', 'LineWidth', 3);
        plot3([m1(31), m1(34)], [m2(31), m2(34)], [m3(31), m3(34)], 'r-', 'LineWidth', 3);
        plot3([m1(30), m1(34)], [m2(30), m2(34)], [m3(30), m3(34)], 'r-', 'LineWidth', 3);
        plot3([m1(38), m1(34)], [m2(38), m2(34)], [m3(38), m3(34)], 'r-', 'LineWidth', 3);
        plot3([m1(39), m1(34)], [m2(39), m2(34)], [m3(39), m3(34)], 'r-', 'LineWidth', 3);
        plot3([m1(39), m1(38)], [m2(39), m2(38)], [m3(39), m3(38)], 'r-', 'LineWidth', 3);
        plot3([m1(07), m1(15)], [m2(07), m2(15)], [m3(07), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(23), m1(15)], [m2(23), m2(15)], [m3(23), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(23), m1(31)], [m2(23), m2(31)], [m3(23), m3(31)], 'r-', 'LineWidth', 3);

        plot3([m1(03), m1(07)], [m2(03), m2(07)], [m3(03), m3(07)], 'r-', 'LineWidth', 3);
        plot3([m1(03), m1(08)], [m2(03), m2(08)], [m3(03), m3(08)], 'r-', 'LineWidth', 3);
        plot3([m1(07), m1(08)], [m2(07), m2(08)], [m3(07), m3(08)], 'r-', 'LineWidth', 3);
        plot3([m1(07), m1(11)], [m2(07), m2(11)], [m3(07), m3(11)], 'r-', 'LineWidth', 3);
        plot3([m1(08), m1(11)], [m2(08), m2(11)], [m3(08), m3(11)], 'r-', 'LineWidth', 3);
        plot3([m1(15), m1(11)], [m2(15), m2(11)], [m3(15), m3(11)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(11)], [m2(16), m2(11)], [m3(16), m3(11)], 'r-', 'LineWidth', 3);
        plot3([m1(16), m1(15)], [m2(16), m2(15)], [m3(16), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(19), m1(15)], [m2(19), m2(15)], [m3(19), m3(15)], 'r-', 'LineWidth', 3);
        plot3([m1(19), m1(16)], [m2(19), m2(16)], [m3(19), m3(16)], 'r-', 'LineWidth', 3);
        plot3([m1(19), m1(23)], [m2(19), m2(23)], [m3(19), m3(23)], 'r-', 'LineWidth', 3);
        plot3([m1(19), m1(24)], [m2(19), m2(24)], [m3(19), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(27), m1(24)], [m2(27), m2(24)], [m3(27), m3(24)], 'r-', 'LineWidth', 3);
        plot3([m1(27), m1(31)], [m2(27), m2(31)], [m3(27), m3(31)], 'r-', 'LineWidth', 3);
        plot3([m1(27), m1(32)], [m2(27), m2(32)], [m3(27), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(31), m1(32)], [m2(31), m2(32)], [m3(31), m3(32)], 'r-', 'LineWidth', 3);
        plot3([m1(31), m1(35)], [m2(31), m2(35)], [m3(31), m3(35)], 'r-', 'LineWidth', 3);
        plot3([m1(39), m1(35)], [m2(39), m2(35)], [m3(39), m3(35)], 'r-', 'LineWidth', 3);
        plot3([m1(40), m1(35)], [m2(40), m2(35)], [m3(40), m3(35)], 'r-', 'LineWidth', 3);
        plot3([m1(40), m1(39)], [m2(40), m2(39)], [m3(40), m3(39)], 'r-', 'LineWidth', 3);
        plot3([m1(31), m1(39)], [m2(31), m2(39)], [m3(31), m3(39)], 'r-', 'LineWidth', 3);
        
        % Superestructura
        plot3([m1(37), m1(50)], [m2(37), m2(50)], [m3(37), m3(50)], 'r-', 'LineWidth', 3);
        plot3([m1(40), m1(46)], [m2(40), m2(46)], [m3(40), m3(46)], 'r-', 'LineWidth', 3);
        plot3([m1(38), m1(51)], [m2(38), m2(51)], [m3(38), m3(51)], 'r-', 'LineWidth', 3);
        plot3([m1(39), m1(47)], [m2(39), m2(47)], [m3(39), m3(47)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(51)], [m2(50), m2(51)], [m3(50), m3(51)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(46)], [m2(50), m2(46)], [m3(50), m3(46)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(51)], [m2(50), m2(51)], [m3(50), m3(51)], 'r-', 'LineWidth', 3);
        plot3([m1(47), m1(51)], [m2(47), m2(51)], [m3(47), m3(51)], 'r-', 'LineWidth', 3);
        plot3([m1(47), m1(46)], [m2(47), m2(46)], [m3(47), m3(46)], 'r-', 'LineWidth', 3);
        plot3([m1(53), m1(49)], [m2(53), m2(49)], [m3(53), m3(49)], 'r-', 'LineWidth', 3);
        plot3([m1(53), m1(54)], [m2(53), m2(54)], [m3(53), m3(54)], 'r-', 'LineWidth', 3);
        plot3([m1(55), m1(54)], [m2(55), m2(54)], [m3(55), m3(54)], 'r-', 'LineWidth', 3);
        plot3([m1(55), m1(56)], [m2(55), m2(56)], [m3(55), m3(56)], 'r-', 'LineWidth', 3);
        plot3([m1(52), m1(56)], [m2(52), m2(56)], [m3(52), m3(56)], 'r-', 'LineWidth', 3);
        plot3([m1(49), m1(45)], [m2(49), m2(45)], [m3(49), m3(45)], 'r-', 'LineWidth', 3);
        plot3([m1(41), m1(45)], [m2(41), m2(45)], [m3(41), m3(45)], 'r-', 'LineWidth', 3);
        plot3([m1(41), m1(42)], [m2(41), m2(42)], [m3(41), m3(42)], 'r-', 'LineWidth', 3);
        plot3([m1(43), m1(42)], [m2(43), m2(42)], [m3(43), m3(42)], 'r-', 'LineWidth', 3);
        plot3([m1(43), m1(44)], [m2(43), m2(44)], [m3(43), m3(44)], 'r-', 'LineWidth', 3);
        plot3([m1(48), m1(44)], [m2(48), m2(44)], [m3(48), m3(44)], 'r-', 'LineWidth', 3);
        plot3([m1(48), m1(52)], [m2(48), m2(52)], [m3(48), m3(52)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(49)], [m2(50), m2(49)], [m3(50), m3(49)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(54)], [m2(50), m2(54)], [m3(50), m3(54)], 'r-', 'LineWidth', 3);
        plot3([m1(46), m1(42)], [m2(46), m2(42)], [m3(46), m3(42)], 'r-', 'LineWidth', 3);
        plot3([m1(46), m1(45)], [m2(46), m2(45)], [m3(46), m3(45)], 'r-', 'LineWidth', 3);
        plot3([m1(47), m1(43)], [m2(47), m2(43)], [m3(47), m3(43)], 'r-', 'LineWidth', 3);
        plot3([m1(47), m1(48)], [m2(47), m2(48)], [m3(47), m3(48)], 'r-', 'LineWidth', 3);
        plot3([m1(51), m1(52)], [m2(51), m2(52)], [m3(51), m3(52)], 'r-', 'LineWidth', 3);
        plot3([m1(51), m1(55)], [m2(51), m2(55)], [m3(51), m3(55)], 'r-', 'LineWidth', 3);
        plot3([m1(50), m1(66)], [m2(50), m2(66)], [m3(50), m3(66)], 'r-', 'LineWidth', 3);
        plot3([m1(51), m1(67)], [m2(51), m2(67)], [m3(51), m3(67)], 'r-', 'LineWidth', 3);
        plot3([m1(47), m1(63)], [m2(47), m2(63)], [m3(47), m3(63)], 'r-', 'LineWidth', 3);
        plot3([m1(66), m1(62)], [m2(66), m2(62)], [m3(66), m3(62)], 'r-', 'LineWidth', 3);
        plot3([m1(66), m1(67)], [m2(66), m2(67)], [m3(66), m3(67)], 'r-', 'LineWidth', 3);
        plot3([m1(68), m1(67)], [m2(68), m2(67)], [m3(68), m3(67)], 'r-', 'LineWidth', 3);
        plot3([m1(63), m1(67)], [m2(63), m2(67)], [m3(63), m3(67)], 'r-', 'LineWidth', 3);
        plot3([m1(63), m1(62)], [m2(63), m2(62)], [m3(63), m3(62)], 'r-', 'LineWidth', 3);
        plot3([m1(66), m1(65)], [m2(66), m2(65)], [m3(66), m3(65)], 'r-', 'LineWidth', 3);
        plot3([m1(61), m1(62)], [m2(61), m2(62)], [m3(61), m3(62)], 'r-', 'LineWidth', 3);
        plot3([m1(57), m1(61)], [m2(57), m2(61)], [m3(57), m3(61)], 'r-', 'LineWidth', 3);
        plot3([m1(61), m1(65)], [m2(61), m2(65)], [m3(61), m3(65)], 'r-', 'LineWidth', 3);
        plot3([m1(69), m1(65)], [m2(69), m2(65)], [m3(69), m3(65)], 'r-', 'LineWidth', 3);
        plot3([m1(69), m1(70)], [m2(69), m2(70)], [m3(69), m3(70)], 'r-', 'LineWidth', 3);
        plot3([m1(71), m1(70)], [m2(71), m2(70)], [m3(71), m3(70)], 'r-', 'LineWidth', 3);
        plot3([m1(71), m1(72)], [m2(71), m2(72)], [m3(71), m3(72)], 'r-', 'LineWidth', 3);
        plot3([m1(68), m1(72)], [m2(68), m2(72)], [m3(68), m3(72)], 'r-', 'LineWidth', 3);
        plot3([m1(68), m1(64)], [m2(68), m2(64)], [m3(68), m3(64)], 'r-', 'LineWidth', 3);
        plot3([m1(60), m1(64)], [m2(60), m2(64)], [m3(60), m3(64)], 'r-', 'LineWidth', 3);
        plot3([m1(59), m1(60)], [m2(59), m2(60)], [m3(59), m3(60)], 'r-', 'LineWidth', 3);
        plot3([m1(59), m1(58)], [m2(59), m2(58)], [m3(59), m3(58)], 'r-', 'LineWidth', 3);
        plot3([m1(57), m1(58)], [m2(57), m2(58)], [m3(57), m3(58)], 'r-', 'LineWidth', 3);
        plot3([m1(62), m1(58)], [m2(62), m2(58)], [m3(62), m3(58)], 'r-', 'LineWidth', 3);
        plot3([m1(63), m1(59)], [m2(63), m2(59)], [m3(63), m3(59)], 'r-', 'LineWidth', 3);
        plot3([m1(63), m1(64)], [m2(63), m2(64)], [m3(63), m3(64)], 'r-', 'LineWidth', 3);
        plot3([m1(71), m1(67)], [m2(71), m2(67)], [m3(71), m3(67)], 'r-', 'LineWidth', 3);
        plot3([m1(70), m1(66)], [m2(70), m2(66)], [m3(70), m3(66)], 'r-', 'LineWidth', 3);
        p2 = plot3([m1(46), m1(62)], [m2(46), m2(62)], [m3(46), m3(62)], 'r-', 'LineWidth', 3);

        % Configuración de la gráfica
        grid on;
        xlabel('Eje X en mm');
        ylabel('Eje Y en mm');
        zlabel('Eje Z en mm');
        title(sprintf('Modo %d', modo));

        % Leyenda
        legend([p1 p2], 'Plataforma inicial', sprintf('Modo %d', modo));
        view(3);  % Vista en 3D
    end

    %% Asignar números a cada punto
    % Ejemplo de como programar la líneas
    % for i = 1:size(modo_mas_origin, 1)
    %     fprintf("text(modo_mas_origin(%d,1), modo_mas_origin(%d,2), modo_mas_origin(%d,3), sprintf('%%d', %d), 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');\n", i, i, i, i);
    % end
end
