% Transformation matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function LT=TransfM3Dframe(CX,CY,CZ,CXY,cosalpha,sinalpha)

   
gammavertical=[  0           0           CZ; 
            CZ*sinalpha   cosalpha          0;
           -CZ*cosalpha   sinalpha          0];

gammaotro=[CX                                          CY                                   CZ;
       -CX*CZ*sinalpha/CXY-CY*cosalpha/CXY    -CY*CZ*sinalpha/CXY+CX*cosalpha/CXY   CXY*sinalpha;
        CY*sinalpha/CXY-CX*CZ*cosalpha/CXY    -CX*sinalpha/CXY-CY*CZ*cosalpha/CXY   CXY*cosalpha];
        

if CXY<=1e-3
   gamma=gammavertical;
else
    gamma=gammaotro;
    
end

LT=[    gamma zeros(3,9);
        zeros(3,3) gamma zeros(3,6);
        zeros(3,6) gamma zeros(3,3)
        zeros(3,9) gamma];
end
