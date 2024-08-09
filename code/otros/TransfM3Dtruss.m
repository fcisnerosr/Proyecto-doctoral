% Transformation matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function LT=TransfM(CX,CY,CZ,hipo)

   
   
   LT=[CX  CY CZ  0   0  0;
       0   0   0  CX  CY CZ];
   
end
