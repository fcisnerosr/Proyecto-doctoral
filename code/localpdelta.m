% local stiffness matrix for 2D elements
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 16th February 2022

function kg=localpdelta(L,T)

kg=zeros(12,12);

kg(1,1)=0; 
kg(2,2)=(6*T)/(5*L);
kg(3,3)=(6*T)/(5*L);
kg(4,4)=0;                    % no influence of the torsional stiffness
kg(5,5)=(2*T*L)/15;
kg(6,6)=(2*T*L)/15;
kg(7,7)=0;
kg(8,8)=(6*T)/(5*L);
kg(9,9)=(6*T)/(5*L);
kg(10,10)=0;
kg(11,11)=(2*T*L)/15;
kg(12,12)=(2*T*L)/15;

kg(6,2)=T/10;
kg(8,2)=-(6*T)/(5*L);
kg(12,2)=T/10;
kg(5,3)=-T/10;
kg(9,3)=-(6*T)/(5*L);
kg(11,3)=-T/10;
kg(9,5)=T/10;
kg(11,5)=-(T*L)/30;
kg(8,6)=-T/10;
kg(12,6)=-(T*L)/30;
kg(12,8)=-T/10;
kg(11,9)=T/10;


kgT=kg';
kgdiag=diag(diag(kg));

kg=kg+kgT-kgdiag;

end



