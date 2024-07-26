% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020

function ke=localkeframe3DT(A,Iy,Iz,J,E,G,L,Asy,Asz)


if Asy<=0.0001
SHIy=0;
else
SHIy=12*E*Iy/(G*Asy*L^2);
end

if Asz<=0.0001
SHIz=0;
else
SHIz=12*E*Iz/(G*Asz*L^2);
end


SHIzt=1/(1+SHIz);
SHIyt=1/(1+SHIy);

ke=zeros(12,12);

ke(1,1)=(E*A)/L; 
ke(2,2)=(12*E*Iz*SHIzt)/L^3;
ke(3,3)=(12*E*Iy*SHIyt)/L^3;
ke(4,4)=(G*J)/L;
ke(5,5)=(E*Iy*(4+SHIy)*SHIyt)/L;
ke(6,6)=(E*Iz*(4+SHIz)*SHIzt)/L;
ke(7,7)=(E*A)/L;
ke(8,8)=(12*E*Iz*SHIzt)/L^3;
ke(9,9)=(12*E*Iy*SHIyt)/L^3;
ke(10,10)=(G*J)/L;
ke(11,11)=(E*Iy*(4+SHIy)*SHIyt)/L;
ke(12,12)=(E*Iz*(4+SHIz)*SHIzt)/L;

ke(7,1)=-ke(1,1);
ke(6,2)=(6*E*Iz*SHIzt)/L^2;
ke(8,2)=(-12*E*Iz*SHIzt)/L^3;
ke(12,2)=(6*E*Iz*SHIzt)/L^2;
ke(5,3)=-(6*E*Iy*SHIyt)/L^2;
ke(9,3)=(-12*E*Iy*SHIyt)/L^3;
ke(11,3)=(-6*E*Iy*SHIyt)/L^2;
ke(10,4)=(-G*J)/L;
ke(9,5)=(6*E*Iy*SHIyt)/L^2;
ke(11,5)=E*Iy*(2-SHIy)*SHIyt/L;
ke(8,6)=(-6*E*Iz*SHIzt)/L^2;
ke(12,6)=(E*Iz*(2-SHIz)*SHIzt)/L;
ke(12,8)=(-6*E*Iz*SHIzt)/L^2;
ke(11,9)=(6*E*Iy*SHIyt)/L^2;


keT=ke';
kediag=diag(diag(ke));

ke=ke+keT-kediag;

end



