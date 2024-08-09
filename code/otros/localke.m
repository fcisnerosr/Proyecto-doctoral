% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function ke=localke(A,I,E,L)

ke=zeros(6,6);


ke(1,1)=E*A/L;
ke(2,2)=12*E*I/L^3;
ke(3,3)=4*E*I/L;
ke(4,4)=ke(1,1);
ke(5,5)=ke(2,2);
ke(6,6)=ke(3,3);
ke(4,1)=-ke(1,1);
ke(3,2)=6*E*I/L^2;
ke(5,2)=-ke(2,2);
ke(6,2)=ke(3,2);
ke(5,3)=-ke(3,2);
ke(6,3)=2*E*I/L;
ke(6,5)=-ke(3,2);

keT=ke';
kediag=diag(diag(ke));

ke=ke+keT-kediag;

end



