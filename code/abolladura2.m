function [D, L_D, z_s, t, R, A1, D_interior, A2, A_d, j] = area_y_momento_polar_con_dano(i, num_de_ele_long, prop_geom, no_elemento_a_danar, dano_porcentaje)
  % tengo el siguiente código y necesito hacerlo funcion, necesito que que identifices cuales son mis variables de entrada y salida a fin de convertirla en funcion. La funcion se llamará area_y_momento_polar_con_dano
  %% SECCION: Cálculo del area con dano y momento polar con dano (A_d y j)
  %% BLOQUE: Datos para el cálculo del área
  % Tabla de propiedades geometricas
  index 		= find(num_de_ele_long(:,1) == i);
  long_elem_a_danar 	= num_de_ele_long(index,2);
  prop_geom_mat 	= cell2mat(prop_geom); espesor_elem_a_danar = prop_geom_mat(no_elemento_a_danar(i),10);
  % Diametro sin dano, longitud con dano profundidad de abolladura
  D(i) 			= prop_geom_mat(no_elemento_a_danar(i),8);
  L_D(i) 		= long_elem_a_danar;
  z_s(i) 		= dano_porcentaje(i) * D(i) / 100;
  Nseg 			= 1000;
  lim 			= 0.003;
  % Calculo del area y momento polar con dano
  t(i) 			= espesor_elem_a_danar;
  R(i) 			= 0.5 * D(i) - (0.5*t(i));
  A1(i) 		= pi * D(i)^2 * 0.25;
  D_interior(i) 	= D(i) - (t(i)*2);
  A2(i) 		= pi * D_interior(i)^2 * 0.25;
  A_d(i) 		= A1(i) - A2(i); % Área con daño
  j(i) = 		prop_geom_mat(no_elemento_a_danar(i),5);
  % Advertencia de que el porcentaje de dano de la abolladura no debe rebasar el 50%
  if dano_porcentaje(i) > 50
    fprintf('\n********************************************************** \n')
    fprintf('***La abolladura no puede ser más del 50%% del diámetro**** \n')
    fprintf('********************************************************** \n\n')
    error('La abolladura excede el 50%% del diámetro. La ejecución se detiene.')
  end
end

