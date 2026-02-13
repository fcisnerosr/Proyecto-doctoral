% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 17th December 2020

function me=localmeframe3D(A,L,rho)

me=zeros(12,12);

ml=rho*A;

me(1,1)=ml*L/3; 
me(2,2)=13/35*ml*L;
me(3,3)=13/35*ml*L;
me(4,4)=10^(-8);
me(5,5)=ml*L^3/105;
me(6,6)=ml*L^3/105;
me(7,7)=ml*L/3; 
me(8,8)=13/35*ml*L;
me(9,9)=13/35*ml*L;
me(10,10)=10^(-8);
me(11,11)=ml*L^3/105;
me(12,12)=ml*L^3/105;

me(7,1)=ml*L/6;
me(6,2)=0;
me(8,2)=0;
me(12,2)=0;
me(5,3)=0;
me(9,3)=0;
me(11,3)=0;
me(10,4)=0;
me(9,5)=0;
me(11,5)=0;
me(8,6)=0;
me(12,6)=0;
me(12,8)=0;
me(11,9)=0;


meT=me';
mediag=diag(diag(me));

me=me+meT-mediag;

end



