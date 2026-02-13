% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function ke=localke3Dtruss(A,E,L)

ke=zeros(2,2);

ke(1,1)=E*A/L;
ke(2,2)=ke(1,1);
ke(2,1)=-ke(1,1);
ke(1,2)=-ke(1,1);

end



