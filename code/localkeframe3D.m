% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estradalocalkeframe3D
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function ke = localkeframe3D(A,Iy,Iz,J,E,G,L)
    % dano = 'corrosion'
    % switch dano
    %     case 'corrosion'
    % 
    % end
    
    ke = zeros(12,12);
    
    ke(1,1)     = (E*A)/L; 
    ke(2,2)     = (12*E*Iz)/L^3;
    ke(3,3)     = (12*E*Iy)/L^3;
    ke(4,4)     = (G*J)/L;
    ke(5,5)     = (4*E*Iy)/L;
    ke(6,6)     = (4*E*Iz)/L;
    ke(7,7)     = (E*A)/L;
    ke(8,8)     = (12*E*Iz)/L^3;
    ke(9,9)     = (12*E*Iy)/L^3;
    ke(10,10)   = (G*J)/L;
    ke(11,11)   = (4*E*Iy)/L;
    ke(12,12)   = (4*E*Iz)/L;
    
    ke(7,1)     = -ke(1,1);
    ke(6,2)     = (6*E*Iz)/L^2;
    ke(8,2)     = (-12*E*Iz)/L^3;
    ke(12,2)    = (6*E*Iz)/L^2;
    ke(5,3)     = -(6*E*Iy)/L^2;
    ke(9,3)     = (-12*E*Iy)/L^3;
    ke(11,3)    = (-6*E*Iy)/L^2;
    ke(10,4)    = (-G*J)/L;
    ke(9,5)     = (6*E*Iy)/L^2;
    ke(11,5)    = 2*E*Iy/L;
    ke(8,6)     = (-6*E*Iz)/L^2;
    ke(12,6)    = (2*E*Iz)/L;
    ke(12,8)    = (-6*E*Iz)/L^2;
    ke(11,9)    = (6*E*Iy)/L^2;
    
    
    keT = ke';
    kediag = diag(diag(ke));
    
    ke = ke + keT - kediag;

end



