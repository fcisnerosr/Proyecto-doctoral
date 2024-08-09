function [prop_geom, num_de_ele_long, L_d] = calculo_longitudes_elementos(prop_geom, archivo_excel, no_elemento_a_danar)
      prop_geom(:,8:9)    = []; % eliminacion de 'circular' y 'wo', si no se eliminan la conversion a matriz numerica no es posible
      % Tabla con no. de elemento y longitud de orden descendente
      hoja_excel = 'Beam Object Connectivity';
      vigas_long = xlsread (archivo_excel, hoja_excel, '');
      vigas_long(:,2:5) = [];
      % Extracción de datos de las columas (tanto en la subestructura como en al superestructura)
      hoja_excel = 'Brace Object Connectivity'; % pestaña con elementos diagonales (ubicados en la subestructura)
      brac_long = xlsread (archivo_excel, hoja_excel, '');
      brac_long(:,2:5) = [];
      hoja_excel = 'Column Object Connectivity'; % pestaña con columnas rectas (generalmente ubicados en la superestructura)
      col_long = xlsread (archivo_excel, hoja_excel, '');
      col_long(:,2:5) = [];
      % no_ele_long = sort(vertcat(vigas_long,brac_long,col_long),1)
      num_de_ele_long = sortrows(vertcat(vigas_long,brac_long,col_long),1);    
      % SECCION: Longitudes de elementos a danar (long_elem_con_dano)
      hoja_excel              = 'Frame Assigns - Summary';
      datos_para_long         = xlsread(archivo_excel, hoja_excel, 'C:E');
      datos_para_long(:,2)    = [];
      elementos_y_long        = sortrows(datos_para_long, 1);
      for i = 1:length(no_elemento_a_danar)
	      long_elem_con_dano(i)  = elementos_y_long(no_elemento_a_danar(i),2);
      end
      L_d = long_elem_con_dano;
end
