%% ============================================= %%
%%%%%%%%%%%%%% F  U  N  C  I  Ó  N %%%%%%%%%%%%%%%%
%% ============================================= %%

function [ke_d] = funcion_abulladura_longitudinal_210623(ed, porcent, Long, D, t, L_D);
    format short G
    %% COMENTAR desde AQUí %%%%
    clc; clear all; close all %%% Cuidado con correr el código principal y que esta línea esté descomentada
    %% Datos del elemento a dañar
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ed = 5; % ed = elemento a dañar                                     %
        porcent = 44; % Porcen_de_prof_de_abolld_con_respecto_al_diam;      %
        % Unidades en milímetros                                            %
        % Longitud_total_del_elemento_en_mm;                                %
            switch ed                                                       %
                case {5,6,9,7}                                              %
                    Long = 5000;                                            %
                case {1,3}                                                  %
                    Long = 4000;                                            %
                case {2, 4}                                                 %
                    Long = 3000;                                            %
            end                                                             %                  
        D       = 600;      % Diametro_de_elemento_tubular_en_mm;           %
        t       = 25.4;     % Espesor_en_mm;                                %
        L_D     = Long;     % longitud dañada_en_mm;                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% COMENTAR hasta ACÁ %%%%
    L = Long;
    Ubicacion_de_abolladura_en_m  = Long*0.5;
    z_s     = porcent * D / 100;

    fprintf('Propiedades del elemento tubular \n\n')
    fprintf('Longitud del elemento = %7.0f  mm \n',Long)
    fprintf('Diámetro              = %7.0f  mm \n',D)
    fprintf('Espesor               = %7.0f  mm \n',t)
    fprintf('Ubicación del daño    = %7.0f  mm \n',Ubicacion_de_abolladura_en_m)
    fprintf('Longitud de daño      = %7.0f  mm \n',L_D)
    
    % División de segmentos transversales
    Nseg = 1000;                      % Mil segmentos
    lim  = 0.003;
    
    fprintf('Abolladura máxima     = %7.0f  mm\n',z_s) % Se le suma el t para considerar la abolladura total, desde la cara exterior del elemento
    fprintf('Elemento dañado       = %7.0f  \n',ed) % Se le suma el t para considerar la abolladura total, desde la cara exterior del elemento

    R = 0.5*D;       % Radio
    R = R-0.5*t;     % Radio sin la mitad del espesor
    
    % Área intacta. En el caso del daño de la abolladura el área es la misma intacta y después del daño
    A1 = pi * D^2 * 0.25;
    D_interior = D-t;
    A2 = pi * D_interior^2 * 0.25;
    A = A1 - A2; % en mm^2
    
    % Módulos
    E = 1.999477869*1E+05;          % Elasticidad (MPa)
    mu = 0.28;                      % relación de Poisson (promedio para el acero)
    G = E/(2*(1+mu));               % Cortante (MPa)
    J = pi/4 * ((0.5*D)^4 - (R)^4); % Polar de inercia en mm^4
    
    %% Criterio de que detener el programa si la abolladura rebasa el 50%
    if (z_s*100)/(R*2) > 50
        fprintf('\n********************************************************** \n')
        fprintf('***La abolladura no puede ser más del 50%% del diámetro**** \n')
        fprintf('********************************************************** \n\n')
    end
    
    % Ciclo para plasmar los puntos sobre la función sinusoidal a los largo longitudal (eje x) 
    Slong = 5;                     % División de segmentos longitudinales
    x = 0;
    for i = 1 : Slong
	    x = x + L_D/Slong;
	    V(i) = x/L_D;
	    Vz_s(i) = z_s * sin(pi*V(i)); %único valor util en este ciclo
    end
    
    Vz_s = Vz_s(1:end-1);
    
    %% Ciclo para el cálculo de cada momento de inercia en cada sección de abolladura
    for p = 1:length(Vz_s)
    % for p = 1
	    % Datos de abolladura
	    P = 2*pi*R;                     % Perímetro del círculo sin daño
	    z_i = R-Vz_s(p);                    % Distancia entre el centro del círculo sin daño y la profundidad de la abolladura
	    z_dent = z_i+R;                 % Distancia desde el punto más bajo hasta la ubicación de la abolladura. (Ver Fig)
	    theta = acosd(z_i/R);           % Ángulo entre radio y centro de círculo sin daño
	    theta = 2*theta;                % Ángulo completo
	    cuerda = ( R^2 - z_i^2 )^0.5;   % MITAD de distancia horizontal abollada
	    cuerda = 2*cuerda;              % Distancia total horizontal abollada
	    L1 = theta * pi/180 * R;        % Longitud del arco superior
	    L2 = L1;                        % Igualación del arco seccionado con la ditancia horizontal abollada
	    delta = L2-cuerda;              % Ensanchamiento total
	    delta = 0.5*delta;              % Ensanchamiento en cada lado
    
	    %% Gráfica de sección abollada y sin daño
	    Circ = zeros(Nseg,2,2);         % Matriz de ceros donde ir incluyendo los valores del círculo
	    Lseg = P/Nseg;                  % Longitud (perímetro) discretizado
	    Alpha = 0: 360/Nseg :360;       % Diferentes valores de PI discretizados
    
	    %% Cálculo de curva Z del círculo dañado
	    for i = 1 : Nseg+1          % Se le suma +1, para que se cierre la figura
	    % 	%% Círculo sin daño
		    Yi = R*cosd(Alpha(i));    % Altura de circunferencia
		    Zi = R*sind(Alpha(i));    % Anchura de circunferencia
		    Circ(i,1,1) = Yi;                       % Almacenamiento de valores de la altura de circunferencia
		    Circ(i,1,2) = Zi;                       % Almacenamiento de valores de la anchura de circunferencia
		    
		    %% Círculo con daño
	       if Alpha(i)>90 && Alpha(i)<270       % Operador para ir distribuyendo en los cuadrantes negativos al rededor de la circunferencia        
		       Sig = -1;
	       else
		       Sig = 1;
	       end    
	       if Zi>z_i	% Condicional que indica que cuando Zi sobrepase a z_i, 
	       % entonces se irá moviendo por la parte achatada. z_i = parte achatada
			    Circ(i,2,1) = Circ(i-1,2,1)-Lseg; % Lseg = Longitud (perímetro) discretizado
			    Circ(i,2,2) = z_i;
	       else
		       Yi = R*cosd(Alpha(i));    % Altura de circunferencia sin daño (solo para traer el dato)
		       Zi = R*sind(Alpha(i));    % Anchura de circunferencia sin daño (solo para traer el dato)
		       Circ(i,2,1) = Yi+delta*sin(((pi/2)/(z_dent))*(Zi+R))*Sig; %
		       Circ(i,2,2) = Zi;
	       end
	    end
    
    
	    %% Cálculo de la longitud de la curva inferior
		    % Mitad de curva izquierda, desde la cuerda hasta R
			    % Tratamiento de vector en Y y Z
			    for i = 1:Nseg
				    if Circ(i,2,2) < z_i && Circ(i,2,1) < 0
					    V_z(i) = horzcat(Circ(i,2,2));
					    V_y(i) = horzcat(Circ(i,2,1));
				    end
			    end
		    
			    % Longitud
			    for i = 1: length(V_z)-1
				    if V_y(i) ~= 0
					    Li  = (((V_y(i+1)) - V_y(i))^2 + ((V_z(i+1)) - V_z(i))^2 )^0.5;
					    L_c(i) = horzcat(Li);
				    end
			    end
			    L_c = sum(L_c);         % Suma de las longitudes
    
		    % Longitud inferior completa
			    L_c = 2*L_c;
    
	    % Cálculo correcto de delta
		    % delta = ensachamiento de cada lado
		    % fórmula a iterar:
			    %%% ec = L_c + cuerda + 2*delta = P;
			    ec = L_c + cuerda + 2*delta;
			    error = abs(P-ec);
                kj = 1;
                kx = 5;
    
			    while error > lim
				    delta = delta - lim;
				    ec = L_c + cuerda + 2*delta;
				    error = abs(P-ec);
                    V_error(kj) = error;
                    kj = kj+1;
                    if kj > kx && V_error(2) > V_error(1)
                        while error > lim
                            delta = delta + lim;
                            ec = L_c + cuerda + 2*delta;
                            error = abs(P-ec);
                            V_error(kj) = error;
                            kj = kj+1;
                        end
                    end
			    end
    
    % 	fprintf('Ensanch_de_cada_lado = %5.2f cm\n',delta) 
    
	    Circ = zeros(Nseg,2,2);         % Matriz de ceros donde ir incluyendo los valores del círculo
	    Lseg = P/Nseg;                  % Longitud (perímetro) discretizado
	    Alpha = 0: 360/Nseg :360;       % Diferentes valores de PI discretizados
    
	    %% Gráficas finales
	    for i = 1 : Nseg+1          % Se le suma +1, para que se cierre la figura
		    %% Círculo sin daño
		    Yi = R*cosd(Alpha(i));    % Altura de circunferencia
		    Zi = R*sind(Alpha(i));    % Anchura de circunferencia
		    Circ(i,1,1) = Yi;                       % Almacenamiento de valores de la altura de circunferencia
		    Circ(i,1,2) = Zi;                       % Almacenamiento de valores de la anchura de circunferencia
		    
		    %% Círculo con daño
	       if Alpha(i)>90 && Alpha(i)<270       % Operador para ir distribuyendo en los cuadrantes negativos al rededor de la circunferencia        
		       Sig = -1;
	       else
		       Sig = 1;
	       end    
	       if Zi > z_i	% Condicional que indica que cuando Zi sobrepase a z_i, 
	       % entonces se irá moviendo por la parte achatada. z_i = parte achatada
			    Circ(i,2,1) = Circ(i,2,1) - Lseg; % Lseg = Longitud (perímetro) discretizado
			    Circ(i,2,2) = z_i;
	       else
		       Yi = R*cosd(Alpha(i));    % Altura de circunferencia sin daño (solo para traer el dato)
		       Zi = R*sind(Alpha(i));    % Anchura de circunferencia sin daño (solo para traer el dato)
		       Circ(i,2,1) = Yi + delta*sin(((pi/2)/(z_dent))*(Zi+R))*Sig;
		       Circ(i,2,2) = Zi;
	       end
	    end
    
    
	    % Cálculo de centroide
		    % Promedio de todas las alturas en ambas direcciones.
		    c_y = mean(Circ(:,2,1));
		    c_y = 0;
		    c_z = mean(Circ(:,2,2));
%     % % % 		fprintf('Centroides \n')	
%     % % % 		fprintf('	y = %3.2f cm \n',c_y)
%     % % % 		fprintf('	z = %1.2f cm \n',c_z)
% 		    
%     % % % 		fprintf('Centroide en eje y   =  %3.2f cm \n',c_y)
%     % % % 		fprintf('Centroide en eje z   = %3.2f cm \n',c_z)
%     
%     	    hold on
%     	    title(['Comparación de sección abollada VS sin daño.'])
%     	    ax = gca;
%     	    ax.Subtitle.String = ['Diámetro de ' num2str(D) ' mm y ', 'abolladura de ' num2str(z_s) ' mm.', ' Porcentaje de abolladura del ' num2str(porcent) '%'];
%     % 	    ax.Subtitle.String = ['Porcentaje de abolladura de ' num2str(porcent) '%'];
%     	    ax.Subtitle.FontAngle = 'italic';
%     	    Y(:,1)=Circ(:,1,1);
%     	    Z(:,1)=Circ(:,1,2);
%     	    plot(Y,Z,'color','blue','LineWidth', 1)   % Círculo dañado
%     	    Y(:,1) = Circ(:,2,1);
%     	    Z(:,1) = Circ(:,2,2);
%     	    plot(Y,Z,'color','red','LineWidth', 3)   % Círculo dañado
%         
%     	    legend({'Sección intacta','Sección abollada'},'Location','southeast')
%     	    xlabel({'Diámetro en y','(en milímetros)'})
%     	    ylabel({'Diámetro en z','(en milímetros)'})
%     	    plot(c_y,c_z,"x", 'DisplayName','Centroide de sección abollada')
%     	    % plot(0,0,".")
%     	    plot(0,0,"x", 'DisplayName','Centroide de sección intacta')
%     	    hold off
%     	    grid on
    
	    %% Cálculo de momentos de inercia
	    % Cálculo de ángulo de cada elemento diferencial
			    % Cuadrante I
			    j = 1;
			    for i = 1 : Nseg + 1
				    Vy_I(j) = Circ(j,2,1);
				    Vz_I(j) = Circ(j,2,2);        
				    j = j+1;            
				    if Circ(j,2,2) == z_i
					    break
				    end
			    end
			    Vz_Ic = Vz_I;
			    Vy_Ic = Vy_I;
				    % Ciclo para: 
					    % realizar un vector con las longitudes de cada vector
					    % calcular ángulos y almacenarlos en en el vector V_ang_I y el vector de distancias al centroide global de la sección transversal
					    k = 1;
					    for i = 1 : length(Vz_Ic)-1					
						    % Distancia de cada elemento diferencial
						    L_I(i) = (((Vz_Ic(i+1)) - Vz_Ic(i))^2 + ((Vy_Ic(i+1)) - Vy_Ic(i))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
						    % Distancias necesarias para el cálculo del ángulo
						    V_longy_I(i) = Vy_Ic(k) - Vy_Ic(k+1);
						    % Cálculo del ángulo de cada elemento diferencial
						    V_ang_I(i) = acosd(V_longy_I(i)/L_I(i));
						    k = k+1;
						    % Cálculo de las distancias de los centroides de cada elemento diferencial al centroide global de la sección
						    % dy_I = distancia paralela a Y del centroide global al centroide local de cada elemento diferencial
						    % dz_I = distancia paralela a Z del centroide global al centroide local de cada elemento diferencial
						    if i == 1
							    dy_I(i) = (L_I(i)*sind(V_ang_I(i)) * 0.5) + (c_z*-1);
							    % L_I(i)*sind(V_ang_I(i)) es la proyección vertical de cada elemento diferencial, es la distancia vertical de cada elemento diferencial, ésta no es pequeña ni despreciable
							    dz_I(i) = Circ(i,2,1) - (L_I(i)*cosd(V_ang_I(i)) * 0.5);
							    % L_I(i)*cosd(V_ang_I(i)) es la proyección horizontal de cada elemento diferencia, ésta sí tiene valores muy pequeños
						    else
							    dy_I(i) = Circ(i,2,2) + (L_I(i)*sind(V_ang_I(i)) * 0.5 + (c_z*-1));
							    dz_I(i) = Circ(i,2,1) - (L_I(i)*cosd(V_ang_I(i)) * 0.5);
						    end
						    
					    end
					    
				    %% Cálculo del momento de inercia local
					    for i = 1:length(V_ang_I)
						    % Momento en y
						    Iy_I(i) = 1/12 * L_I(i) * t^3;					
						    % Momento en Z
						    Iz_I(i) = 1/12 * L_I(i)^3 * t;					
						    % Momento inclinado
						    Iy_prima_I(i) = ((Iy_I(i) + Iz_I(i)) * 0.5) + (((Iy_I(i) - Iz_I(i))* 0.5) * cosd(2*V_ang_I(i)));
						    Iz_prima_I(i) = ((Iy_I(i) + Iz_I(i)) * 0.5) - (((Iy_I(i) - Iz_I(i))* 0.5) * cosd(2*V_ang_I(i)));
						    A_I(i) = L_I(i) * t;	% Área de cada elemento diferencial 
					    end
			    
    
			    % Cuadrante II
			    Alpha = 0: 2*pi/Nseg : 2*pi;       % Diferentes valores de PI discretizados
			    j = 1;
			    for i = 1 : Nseg
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante II mediante un
				    % círculo unitario
				    j = j+1;
				    % Condicional excluye a:
					    % 1.- Valores de coseno positivos
					    % 2.- Valores de seno vayores a 1
					    % 3.- Valores de seno Circ(:,2,2) mayores a z_i
				    if sign(y_uni(j)) == -1 && z_uni(j) < 1 && Circ(j,2,2) < z_i
					    Vy_II(j) = Circ(j,2,1);     % Vector que guarda los elementos del II cuadrante sin considerar la parte achatada
					    Vz_II(j) = Circ(j,2,2);     % Vector que guarda los elementos del II cuadrante sin considerar la parte achatada
				    end
				    if Circ(j,2,2) < 0
					    break
				    end
			    end
				    Vz_II(:,length(Vz_II)) = [];    % Retira el último elemento porque es menor a cero y pertenece al cuadrante III
				    j = 1;
				    r = 1;
				    for i = 1:length(Vz_II)
					    if Vz_II(i) ~= 0 & Vy_II(i) ~= 0 % condicional que elimina todos los ceros de la matriz
						    Vz_IIc(j) = horzcat(Vz_II(i)); %_c es de corregido, debido a que el anterior vector tenía valores de ceros inservibles
						    Vy_IIc(j) = horzcat(Vy_II(i)); %_c es de corregido, debido a que el anterior vector tenía valores de ceros inservibles
						    j = j+1;					
					    else
						    r = r + 1;	% número para llegar al siguiente valor en el vector Circ, para el cálculo de la distancia d del teorema de ejes paralelos
					    end
				    end
				    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
				    k = 1;
				    for i = 1 : (length(Vz_IIc)-1)
					    L_II(i) = (((Vz_IIc(i+1)) - Vz_IIc(i))^2 + ((Vy_IIc(i+1)) - Vy_IIc(i))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
					    V_longy_II(i) = Vy_IIc(k+1) - Vy_IIc(k); % V_longy_II vector con distancias de proyección horizontal de cada elemento diferencial
					    V_ang_II(i) = acosd(-V_longy_II(i)/L_II(i));
					    k = k+1;
					    % Distancias de los centroides de cada elemento diferencial al centroide global en cada eje
					    dy_II(i) = Circ(r,2,2) - L_II(i)*sind(V_ang_II(i)) * 0.5 + (c_z*-1);
					    dz_II(i) = Circ(r,2,1) - L_II(i)*cosd(V_ang_II(i)) * 0.5;
					    r = r+1;
				    end
				    
			    % Cálculo del momento de inercia local
					    for i = 1:length(V_ang_II)
						    % Momento en y
						    Iy_II(i) = 1/12 * L_II(i) * t^3;					
						    % Momento en Z
						    Iz_II(i) = 1/12 * L_II(i)^3 * t;					
						    % Momento inclinado
						    Iy_prima_II(i) = ((Iy_II(i) + Iz_II(i)) * 0.5) + (((Iy_II(i) - Iz_II(i))* 0.5) * cosd(2*V_ang_II(i)));
						    Iz_prima_II(i) = ((Iy_II(i) + Iz_II(i)) * 0.5) - (((Iy_II(i) - Iz_II(i))* 0.5) * cosd(2*V_ang_II(i)));
						    A_II(i) = L_II(i) * t;	% Área de cada elemento diferencial 
					    end
			    
			    % Cuadrante III
			    j = 1;
			    for i = 1 : Nseg
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante III mediante un círculo unitario
				    j = j+1;
				    if sign(y_uni(j)) == -1 && sign(z_uni(j)) == -1
					    Vy_III(j) = Circ(j,2,1);
					    Vz_III(j) = Circ(j,2,2);
				    end
				    if sign(y_uni(j)) == 0
					    break
				    end
			    end
			    j = 1;
			    for i = 1:length(Vz_III)
				    if Vz_III(i) ~= 0
					    Vy_IIIc(j) = horzcat(Vy_III(i));
					    Vz_IIIc(j) = horzcat(Vz_III(i));
					    j = j+1;
				    end
			    end
			    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
			    k = 1;
			    % Dist_emerg = (Circ(r,2,2)) - ((L_II(length(V_ang_II)) * sind(180 - V_ang_II(length(V_ang_II))))*-1);  % Esta distancia es el restante de la última pieza del cuadrante II que pasa a los números negativos. Solo se realiza una y su solución es general al no. de Nseg que se manejen.
			    r = r+1;
			    for i = 1 : (length(Vz_IIIc)-1)
				    L_III(i) = (((Vz_IIIc(i+1)) - Vz_IIIc(i))^2 + ((Vy_IIIc(i+1)) - Vy_IIIc(i))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    V_longy_III(i) = Vy_IIIc(k+1) - Vy_IIIc(k);
				    V_ang_III(i) = 180 - acosd(-V_longy_III(i)/L_III(i));
				    k = k+1;
				    % Cálculo de las distancias de los centroides de cada elemento diferencial al centroide global en cada eje
				    dy_III(i) = Circ(r,2,2) - (L_III(i)*sind(V_ang_III(i)) * 0.5) - c_z;
				    dz_III(i) = Circ(r,2,1) + (L_III(i)*cosd(V_ang_III(i)) * 0.5);
				    r = r+1;
			    end
			    % Cálculo del momento de inercia local
				    for i = 1:length(V_ang_III)
					    % Momento en y
					    Iy_III(i) = 1/12 * L_III(i) * t^3;					
					    % Momento en Z
					    Iz_III(i) = 1/12 * L_III(i)^3 * t;					
					    % Momento inclinado
					    Iy_prima_III(i) = ((Iy_III(i) + Iz_III(i)) * 0.5) + ((Iy_III(i) - (Iz_III(i))* 0.5) * cosd(2*V_ang_III(i)));
					    Iz_prima_III(i) = ((Iy_III(i) + Iz_III(i)) * 0.5) - ((Iy_III(i) - (Iz_III(i))* 0.5) * cosd(2*V_ang_III(i)));
					    A_III(i) = L_III(i) * t;	% Área de cada elemento diferencial 
				    end
    
			    % Cuadrante IV
			    for i = 1 : Nseg+1
				    y_uni = cos(Alpha);
				    z_uni = sin(Alpha);
				    % Ambos elementos son para discriminar el cuadrante II mediante un círculo unitario
				    if sign(y_uni(i)) == 1 && sign(z_uni(i)) == -1
					    Vy_IV(i) = Circ(i,2,1);     % Vector que guarda los elementos del IV cuadrante sin considerar la parte achatada
					    Vz_IV(i) = Circ(i,2,2);     % Vector que guarda los elementos del IV cuadrante sin considerar la parte achatada
				    end
			    end
			    j = 1;
			    for i = 1:length(Vz_IV)
				    if Vz_IV(i) ~= 0
					    Vy_IVc(j) = horzcat(Vy_IV(i));
					    Vz_IVc(j) = horzcat(Vz_IV(i));
					    j = j+1;
				    end
			    end
			    Vy_IVc(:,length(Vy_IVc)+1) = [delta + R];   % Añade un delta + R al final.
			    Vz_IVc(:,length(Vz_IVc)+1) = [0];			% Añade un cero al final.
			    % Ciclo para calcular distancia de cada elemento diferencial y los ángulos de cada elemento diferencial
			    k = 1;
			    r = r+1;
			    for i = 1 : (length(Vz_IVc)-1)
				    L_IV(i) = (((Vz_IVc(i+1)) - Vz_IVc(i))^2 + ((Vy_IVc(i+1)) - Vy_IVc(i))^2 )^0.5; % Cálculo de longitud de cada elemento diferencial
				    V_longy_IV(i) = Vy_IVc(k+1) - Vy_IVc(k);
				    V_ang_IV(i) = 180 - acosd(-V_longy_IV(i)/L_IV(i));
				    k = k+1;
				    dy_IV(i) = Circ(r,2,2) + (L_IV(i)*sind(V_ang_IV(i)) * 0.5) - c_z;
				    dz_IV(i) = Circ(r,2,1) + (L_IV(i)*cosd(V_ang_IV(i)) * 0.5);
				    r = r+1;
			    end
			    
			    % Cálculo del momento de inercia local
				    for i = 1:length(V_ang_IV)
					    % Momento en y
					    Iy_IV(i) = 1/12 * L_IV(i) * t^3;					
					    % Momento en Z
					    Iz_IV(i) = 1/12 * L_IV(i)^3 * t;					
					    % Momento inclinado
					    Iy_prima_IV(i) = ((Iy_IV(i) + Iz_IV(i)) * 0.5) + (((Iy_IV(i) - Iz_IV(i))* 0.5) * cosd(2*V_ang_IV(i)));
					    Iz_prima_IV(i) = ((Iy_IV(i) + Iz_IV(i)) * 0.5) - (((Iy_IV(i) - Iz_IV(i))* 0.5) * cosd(2*V_ang_IV(i)));
					    A_IV(i) = L_IV(i) * t;	% Área de cada elemento diferencial 
				    end
				    
				    
		    %%% Cálculo del momento de inercia total
		    %% Iy_t = Iy_prima + A*d^2; 
			    %% Iy_t = Momento de inercia total,
			    %% Iy_prima = Momento de inercia local inclinado
		    dy = horzcat(dy_I, dy_II, dy_III, dy_IV); 	% dy es la distancia paralela al eje y de cada elemento diferencial
		    dz = horzcat(dz_I, dz_II, dz_III, dz_IV);	% dz es la distancia paralela al eje z de cada elemento diferencial
		    Iy_prima = horzcat(Iy_prima_I, Iy_prima_II, Iy_prima_III, Iy_prima_IV); % Momento de inercia inclinado de cada elemento diferencial paralelo al eje y
		    Iz_prima = horzcat(Iz_prima_I, Iz_prima_II, Iz_prima_III, Iz_prima_IV);	% Momento de inercia inclinado de cada elemento diferencial paralelo al eje z
		    VA = horzcat(A_I, A_II, A_III, A_IV);		% Área de todos los elementos diferenciales
		    for i = 1 : length(dy)-1
			    Iy_t = Iy_prima(i) + (VA(i) * dy.^2);
			    Iz_t = Iz_prima(i) + (VA(i) * dz.^2);
		    end
			    
		    % Parte achatada
			    L_ach = cuerda + 2*delta;	% Longitud de parte achatada
			    Iy_ach= 1/12 * L_ach * t^3;	% Momento de inercia paralelo al eje y
			    Iz_ach= 1/12 * L_ach^3 * t;	% Momento de inercia paralelo al eje z
			    A_ach = L_ach*t;			% Área parte achatada
			    d_acha = z_i + (c_z*-1);
			    Iy_achatada_centro = Iy_ach + (A_ach * d_acha^2);
			    Iz_achatada_centro = Iz_ach;
		    
		    % Momento de inercia dañado
		    Iy_t_damaged = sum(Iy_t) + Iy_achatada_centro; 	% prefijo _t es de total
		    Iz_t_damaged = sum(Iz_t) + Iz_achatada_centro;
		    
		    % Momento de inercia sin daño
		    R_ext = 0.5*D;
		    I_ext = pi/4 * R_ext^4;
		    R_int = (0.5*D) - t;
		    I_int = pi/4 * R_int^4;
		    I_undamaged = I_ext - I_int;
		    % I_undamaged es igual en el sentido Y y Z
		    % Diferencias y porcentajes de reducción en Y
		    Dif_y = (Iy_t_damaged - I_undamaged);
		    Porcentaje_reduccion_y = Dif_y*100 / I_undamaged;
		    % % Diferencias y porcentajes de reducción en Z
		    Dif_z = (Iz_t_damaged - I_undamaged);
		    Porcentaje_reduccion_z = Dif_z*100 / I_undamaged;
    
%     		% Propiedades del momento de inercia
%     		fprintf(' \n')
%     		fprintf('** Momentos de inercia ** \n')	
%     		fprintf('	** Paralelo al eje Y ** \n')	
%     		fprintf('	Iy_intacta = %1.2f cm^4 \n',I_undamaged)
%     		fprintf('	Iy_dañada  = %1.2f cm^4 \n',Iy_t_damaged)
%     		fprintf('	Reducción  = %1.2f%% \n\n',abs(Porcentaje_reduccion_y))
%     		fprintf('	** Paralelo al eje Z ** \n')
%     		fprintf('	Iz_intacta = %1.2f cm^4 \n',I_undamaged)
%     		fprintf('	Iz_dañada  = %1.2f cm^4 \n',Iz_t_damaged)
%     		if Iz_t_damaged > I_undamaged
%     			fprintf('	Aumento  = %1.2f%% \n',abs(Porcentaje_reduccion_z))
%     		else
%     			fprintf('	Reducción  = %1.2f%% \n',abs(Porcentaje_reduccion_z))
%     		end
    
        VIy(p) = Iy_t_damaged;
	    VIz(p) = Iz_t_damaged;

        %%%% R E C O R D A T O R I O %%%%
        % En SAP2000, 
            % El eje y es el 3, mientras que...
            % El eje z es el 2.

    
        % El código arrastra algunos valores en cada ciclo y tenía errores en los cálculos de los momentos de inercia,
        % fue necesario borrar todas las variables en cada ciclo con excepción de las siguientes variables:
        clearvars -except Diametro_de_elemento_tubular_en_cm Espesor_en_mm Longitud_danada_en_cm Longitud_total_del_elemento_en_cm Ubicacion_de_abolladura_en_cm...
            Long D t L_D x R A G J E z_s Lseg Nseg x V Vz_s...
            P p pi R z_i Vz_s z_dent theta cuerda L1 L2 delta...
            Circ Yi Zi Alpha Sig z_i...
            lim VIy VIz...
            I_undamaged Slong porcent...
            ed
    end
    
    %% Polinomio del momento de inercia de la sección
    VIy = horzcat(I_undamaged,VIy,I_undamaged); % en mm^4
    VIz = horzcat(I_undamaged,VIz,I_undamaged); % en mm^4
    x_f = 0 : L_D/Slong : L_D;          % Distancia longitudinal acumulada de L_D
    
    % Momento de inercia en Y    
        % Ajuste de curva para la sección abollada
        grado = 4;
        poly_y = polyfit(x_f, VIy, grado);      % Ajusta a la función sin a un conjunto de datos mediante mínimos cuadrados % poly = polyfit(x, y, grado) % polyfit arroja los polinomios
%         % Gráfica del polinomio                                       
%             y_fit = polyval(poly_y, x_f);       % polyval evalua los puntos x_f en poly
%             V_undamaged = [I_undamaged I_undamaged];
%             x_undamaged = [0 Long];       
%             green_dark = [0, 0.5, 0];
%             subplot(1,2,1);
%             plot(x_f,VIy,'ro',x_f,y_fit,'b','LineWidth', 2);       % Gráfica de la aproximación del polimonio
%             hold on
%             plot(x_undamaged,V_undamaged,'color',green_dark,'LineWidth', 3);       % Gráfica de la aproximación del polimonio
%             title('Variación del momento de inercia en el eje Y a lo largo de la longitud') 
%             xlabel('Longitud en mm') 
%             ylabel('Momento de inercia en \it{Y} en mm^4') 
%             legend('puntos calculados', 'polinomio de 4° grado','Inercia intacta','Location', 'southeast')
        % Interacción del cortante Vz,Vz en A y B, usado en f_33
            ec_y_03_03 = @(x) x.^2 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción del momento My,My en A y B, usado en f_22
            ec_y_05_05 = @(x) 1 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
    
    % Momento de inercia en Z    
        % Ajuste de curva para la sección abollada
        grado = 4;
        poly_z = polyfit(x_f, VIz, grado);  
%         % Gráfica del polinomio
%             y_fit = polyval(poly_z, x_f);    % polyval evalua los puntos x_f en poly
%             subplot(1,2,2);
%             plot(x_f,VIz,'ro',x_f,y_fit,'b','LineWidth', 2)     % Gráfica de la aproximación del polimonio
%             hold on
%             plot(x_undamaged,V_undamaged,'color',green_dark,'LineWidth', 2)     % Gráfica de la aproximación del polimonio
%             hold on
%             title('Variación del momento de inercia en el eje Z a lo largo de la longitud')
%             xlabel('Longitud en mm') 
%             ylabel('Momento de inercia en \it{Z} en mm^4')
%             legend('puntos calculados', 'polinomio de 4° grado','Inercia intacta','Location', 'southeast')
        % Interacción del cortante Vy,Vy en A y B, usado en f_22
            % cuarto grado % 
            ec_z_02_02 = @(x) x.^2 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            % quinto grado  % ec_z_22 = @(x) x.^2 ./ ((E)*(poly_z(1)* x .^5 + poly_z(2)* x .^4 + poly_z(3)* x .^3 + poly_z(4)* x .^2 + + poly_z(5)* x .^1 + poly_z(6)));
            % sexto grado   % ec_z_22 = @(x) x.^2 ./ ((E)*(poly_z(1)* x .^6 + poly_z(2)* x .^5 + poly_z(3)* x .^4 + poly_z(4)* x .^3 + + poly_z(5)* x .^2 + poly_z(6)* x .^1 + poly_z(7)));
            % séptimo grado % ec_z_22 = @(x) x.^2 ./ ((E)*(poly_z(1)* x .^7 + poly_z(2)* x .^6 + poly_z(3)* x .^5 + poly_z(4)* x .^4 + + poly_z(5)* x .^3 + poly_z(6)* x .^2 + poly_z(7)* x .^1 + poly_z(8)));
        % Interacción del momento Mz,Mz en A y B, usado en f_66
            ec_z_06_06 = @(x) 1 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
    
        % en A,A y B,B
        % Interacción del momento My,Vz en A, usado en f_05_03 y en f_03_05
            ec_y_03_05 = @(x) -x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
            ec_y_05_03 = @(x) -x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción del momento My,Vz en A, usado en f_02_06 y en f_06_02
            ec_y_02_06 = @(x) x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
            ec_y_06_02 = @(x) x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
%     
    % Efectos combinados
        % en A,B
        % Interación de Mz,Mz en A y B, usado en f_06_12 y f_12_06
            ec_z_06_12 = @(x) -1 ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interación de Mz,Vy en A y B, usado en f_06_08 y f_08_06
            ec_z_06_08 = @(x) (1-x) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interación de Vz,Vz en A y B, usado en f_03_09 y f_09_03
            ec_y_03_09 = @(x) (x-x.^2) ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de My,My en A y B, usado en f_05_11 y en f_11_05
            ec_y_05_11 = @(x) -1 ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de My,Vz en A y B, usado en f_05_09 y en f_09_05
            ec_y_05_09 = @(x) (-1+x) ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de Mz,Vy en A y B, usado en f_06_08 y en f_08_06
            ec_z_06_08 = @(x) (1-x) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interacción de Vz,My en A y B, usado en f_03_11 y en f_11_03
            ec_y_03_11 = @(x) x ./ ((E)*(poly_y(1)* x .^4 + poly_y(2)* x .^3 + poly_y(3)* x .^2 + poly_y(4)* x .^1 + + poly_y(5)));
        % Interacción de Vz,Mz en A y B, usado en f_02_12 y en f_12_02
            ec_z_02_12 = @(x) -x ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
        % Interacción de Vy,Vy en A y B, usado en f_02_08 y en f_08_02
            ec_z_02_08 = @(x) (x-x.^2) ./ ((E)*(poly_z(1)* x .^4 + poly_z(2)* x .^3 + poly_z(3)* x .^2 + poly_z(4)* x .^1 + + poly_z(5)));
    
    
    %% Matriz de flexibilidades general de un elemento de sección variable en 3D
    % % Cálculo de cada coeficiente que se ve afectado
        % Diagonal principal
            f_02_02 = integral(ec_z_02_02, 0, Long);
            f_03_03 = integral(ec_y_03_03, 0, Long);
            f_05_05 = integral(ec_y_05_05, 0, Long);
            f_06_06 = integral(ec_z_06_06, 0, Long);
        % Efectos combinados de V y M pero en A,A y en B,B
            f_02_06 = integral(ec_y_02_06, 0, Long);
            f_06_02 = integral(ec_y_06_02, 0, Long);
            f_03_05 = integral(ec_y_03_05, 0, Long);        
            f_05_03 = integral(ec_y_05_03, 0, Long);
        % Efectos combinados de A,B y B,A
          % Mz,Mz  en A,B
            f_02_08 = integral(ec_z_02_08, 0, Long);
            f_03_09 = integral(ec_y_03_09, 0, Long);
            f_05_11 = integral(ec_y_05_11, 0, Long);
            f_06_12 = integral(ec_z_06_12, 0, Long);
            f_06_08 = integral(ec_z_06_08, 0, Long);
            f_05_09 = integral(ec_y_05_09, 0, Long);
            f_03_11 = integral(ec_y_03_11, 0, Long);
            f_02_12 = integral(ec_z_02_12, 0, Long);
    
    f_AA = [Long/(E*A)  0          0           0            0           0;...
            0           f_02_02    0           0            0           f_06_02;...
            0           0          f_03_03     0            f_05_03     0;...
            0           0          0           Long/(G*J)   0           0;...
            0           0          f_03_05     0            f_05_05     0;...
            0           f_02_06    0           0            0           f_06_06];
    
    % Matriz de transformación para evitar invertir la matriz de flexibilidades
    T   = [-1    0      0       0   0   0
            0    -1     0       0   0   0 
            0    0      -1      0   0   0
            0    0      0       -1  0   0
            0    0      Long    0  -1   0
            0   -Long   0       0   0  -1
            1    0      0       0   0   0
            0    1      0       0   0   0
            0    0      1       0   0   0
            0    0      0       1   0   0
            0    0      0       0   1   0
            0    0      0       0   0   1];
    
    ke_d = T * f_AA^(-1) * T';
    
    %% Comprobación de resultados
    % % f_BB = f_AA;
    % % f_AB = [-Long/(E*A)  0          0           0            0           0;...
    % %         0         f_02_08    0           0            0           f_06_08;...
    % %         0         0          f_03_09     0            f_05_09     0;...
    % %         0         0          0           -Long/(G*J)     0           0;...
    % %         0         0          f_03_11     0            f_05_11     0;...
    % %         0         f_02_12    0           0            0           f_06_12];
    % % f_BA = f_AB;
    % % f_damage = [f_AA f_AB;...
    % %             f_BA f_BB]  
    % 
    % %% Cálculo de la matriz sin ningún daño (solo para comparar)
    % I = I_undamaged;
    % 
    % % Ecuaciones a integrar
    %     % Efectos en A,A y B,B
    %         ec_u_02_02 = @(x) x.^2 / (E*I);
    %         ec_u_03_03 = @(x) x.^2 / (E*I);
    %         ec_u_05_05 = Long/(E*I);
    %         ec_u_06_06 = Long/(E*I);
    %         ec_u_02_06 = @(x) x / (E*I);
    %         ec_u_03_05 = @(x) -x / (E*I);
    %         ec_u_05_03 = ec_u_03_05;
    %         ec_u_06_02 = ec_u_02_06;
    %     % Efectos combinados entre A y B
    %         ec_u_02_08 = @(x) (x - x.^2) / (E*I);
    %         ec_u_03_09 = @(x) (x - x.^2) / (E*I);
    %         ec_u_05_11 = - Long / (E*I);
    %         ec_u_06_12 = - Long / (E*I);
    %         ec_u_06_08 = @(x) (1-x) / (E*I);
    %         ec_u_05_09 = @(x) (-1+x) / (E*I);
    %         ec_u_03_11 = @(x) x / (E*I);
    %         ec_u_02_12 = @(x) -x / (E*I);
    % % Integrales
    %     % Efectos en A,A y B,B
    %         fu_02_02 = integral(ec_u_02_02, 0 , Long);
    %         fu_03_03 = integral(ec_u_03_03, 0 , Long);
    %         fu_05_05 = ec_u_05_05;
    %         fu_06_06 = ec_u_06_06;
    %         fu_02_06 = integral(ec_u_02_06, 0 , Long);
    %         fu_03_05 = integral(ec_u_03_05, 0 , Long);
    %         fu_05_03 = integral(ec_u_05_03, 0 , Long);
    %         fu_06_02 = integral(ec_u_06_02, 0 , Long);       
    %     % Efectos combinados entre A y B
    %         fu_02_08 = integral(ec_u_02_08, 0, Long);
    %         fu_03_09 = integral(ec_u_03_09, 0, Long);
    %         fu_05_11 = ec_u_05_11;
    %         fu_06_12 = ec_u_06_12;
    %         fu_06_08 = integral(ec_u_06_08, 0 , Long);
    %         fu_05_09 = integral(ec_u_05_09, 0, Long);
    %         fu_03_11 = integral(ec_u_03_11, 0, Long);
    %         fu_02_12 = integral(ec_u_02_12, 0, Long);
    % 
    % f_AA_u = [Long/(E*A)    0               0           0           0          0;...
    %          0           fu_02_02        0           0           0          fu_06_02;...
    %          0           0               fu_03_03    0           fu_05_03   0;...
    %          0           0               0           Long/(G*J)     0          0;...
    %          0           0               fu_03_05    0           fu_05_05   0;...
    %          0           fu_02_06        0           0           0          fu_06_06];
    % 
    % ke_u = T * f_AA_u^(-1) * T';
    
    % f_BB_u = f_AA_u;
    % 
    % f_AB_u = [-Long/(E*A)   0               0           0           0          0;...
    %          0           fu_02_08        0           0           0          fu_06_08;...
    %          0           0               fu_03_09    0           fu_05_09   0;...
    %          0           0               0           -Long/(G*J)    0          0;...
    %          0           0               fu_03_11    0           fu_05_11   0;...
    %          0           fu_02_12        0           0           0          fu_06_12];
    % 
    % f_BA_u = f_AB_u;
    % f_undamage = [f_AA_u f_AB_u;...
    %               f_BA_u f_BB_u]
    % 
    % format short
    
%     %% Expansión de la matriz local
%             % Tamaño de la matriz expandida_g = global
%             GDL = 24;
%         
%             % Crear matriz expandida con ceros
%             K_dg = zeros(GDL);
%             
%             % Coordenadas del primer elemento de la matriz original en la matriz expandida
%                 % coord_x = coordenada x en la matriz expandida
%                 % coord_y = coordenada y en la matriz expandida
% 
%             switch ed
%                 case {1,5}
%                     coord_x = 1;
%                     coord_y = 1;
%                 case {2,6}
%                     coord_x = 7;
%                     coord_y = 7;
%                 case {3,7,8}
%                     coord_x = 13;
%                     coord_y = 13;                    
%                 otherwise
%                     ke_d = [ke_d(1:6, 1:6)          zeros(6,6)  zeros(6,6)  ke_d(end-5:end, end-5:end);...
%                             zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                             zeros(6,6)              zeros(6,6)  zeros(6,6)  zeros(6,6);...
%                             ke_d(end-5:end, 1:6)    zeros(6,6)  zeros(6,6)  ke_d(end-5:end, end-5:end)];
%             end
% 
%             if ed ~= 4
%                 % Copiar el primer elemento de la matriz original en la matriz expandida
%                 K_dg(coord_y, coord_x) = ke_d(1, 1);
%                 
%                 % Expandir los elementos restantes
%                 for i = 1:size(ke_d, 1)
%                     for j = 1:size(ke_d, 2)
%                         K_dg(coord_y + i - 1, coord_x + j - 1) = ke_d(i, j);
%                     end
%                 end
%                 K_dg;
%             else
%                 K_dg = ke_d;
%             end
    
    %% Ejercicios para comprobar los resultados obtenidos
%     fprintf('\nViga en cantiliver en 2D \n')
%     fprintf('Vector P en Newtons \n')
%     P   = [0; 0; -980.665; 0]
%     fprintf('\n')
%     fprintf('Sin daño \n')
%         ke_u_AA = [ke_u(3,3) ke_u(5,3); ke_u(3,5) ke_u(5,5)];
%         ke_u_AB = [0 0; 0 0];
%         ke_u_g  = [ke_u_AA ke_u_AB;ke_u_AB ke_u_AA]
%         fprintf('\n')
%         d_u     = ke_u_g^-1*P
%     fprintf('\n')
%     fprintf('Con daño \n')
%         ke_d_AA = [ke_d(3,3) ke_d(5,3); ke_d(3,5) ke_d(5,5)];
%         ke_d_AB = [0 0; 0 0];
%         ke_d_g  = [ke_d_AA ke_d_AB;ke_d_AB ke_d_AA]
%         d_d     = ke_d_g^-1*P        
% fprintf('\nViga en cantiliver en 3D \n')
% fprintf('Vector P en Newtons \n')
% P   =  [0;  0;  0;  0 ; -2941.995;  -980.665;   0;  0]
%     %   Fy  Fz  My  Mz  Fy          Fz          My  Mz
% fprintf('\n')
% fprintf('Sin daño \n')    
%     ke_u_AA =  [ke_u(2,2)   0           0           ke_u(2,6);...
%                 0           ke_u(3,3)   ke_u(5,3)   0;...
%                 0           ke_u(3,5)   ke_u(5,5)   0; 
%                 ke_u(6,2)   0           0           ke_u(6,6) ];
% 
%     ke_u_AB = zeros(4,4);
%     ke_u_g  = [ke_u_AA ke_u_AB;ke_u_AB ke_u_AA]
%     d_u     = ke_u_g^(-1)*P
% fprintf('\n')
%     fprintf('Con daño \n')
%         ke_d_AA =  [ke_d(2,2)   0           0           ke_d(2,6);...
%                     0           ke_d(3,3)   ke_d(5,3)   0;...
%                     0           ke_d(3,5)   ke_d(5,5)   0; 
%                     ke_d(6,2)   0           0           ke_d(6,6) ];
%         ke_d_AB = zeros(4,4);
%         ke_d_g  = [ke_d_AA ke_d_AB;ke_d_AB ke_d_AA]
%         d_d     = ke_d_g^(-1)*P


    
    % % Elementos
    % % Columna
    %     % Sin daño
    %         f_AA_u = [Long/(E*A)   0               0           0           0           0;...
    %              0           fu_02_02        0           0           0          fu_06_02;...
    %              0           0               fu_03_03    0           fu_05_03   0;...
    %              0           0               0           Long/(G*J)     0          0;...
    %              0           0               fu_03_05    0           fu_05_05   0;...
    %              0           fu_02_06        0           0           0          fu_06_06];
    %         f_BB_u = f_AA_u;
    %         f_AB_u = zeros(6,6);
    %         f_u    = [f_AA_u f_AB_u; f_AB_u f_BB_u] 
    %         K_u    = f_u^-1
    %     
    %         % Tamaño de la matriz expandida_g = global
    %         GDL = 24;
    %     
    %         % Crear matriz expandida con ceros
    %         K_ug = zeros(GDL);
    %         
    %         % Coordenadas del primer elemento de la matriz original en la matriz expandida
    %         coord_x = 1; % Coordenada x en la matriz expandida
    %         coord_y = 1; % Coordenada y en la matriz expandida
    %         
    %         % Copiar el primer elemento de la matriz original en la matriz expandida
    %         K_ug(coord_y, coord_x) = K_u(1, 1);
    %         
    %         % Expandir los elementos restantes
    %         for i = 1:size(K_u, 1)
    %             for j = 1:size(K_u, 2)
    %                 K_ug(coord_y + i - 1, coord_x + j - 1) = K_u(i, j);
    %             end
    %         end
    %         
    %         K_ug
end
