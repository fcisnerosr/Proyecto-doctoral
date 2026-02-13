% Transformation matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function LT=TransfM(theta)

gamma=[cos(theta) sin(theta) 0;
       -sin(theta) cos(theta) 0;
       0            0           1];
   
   
   LT=[gamma zeros(3,3);
       zeros(3,3) gamma];