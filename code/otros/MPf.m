% Determine the modal participation factor 
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 17th November 2020

function [Mefx,Mefy,Mefz]=MPf(phi,Mass,ID)

indxx=find(ID(1,:)>0);
indxy=find(ID(2,:)>0);
indxz=find(ID(3,:)>0);
rx=ones(length(indxx),1);
ry=ones(length(indxy),1);
rz=ones(length(indxz),1);
phix=phi(ID(1,indxx),:);
phiy=phi(ID(2,indxy),:);
phiz=phi(ID(3,indxz),:);

% mass in each direction
mx=Mass(ID(1,indxx),ID(1,indxx));
my=Mass(ID(2,indxy),ID(2,indxy));
mz=Mass(ID(3,indxz),ID(3,indxz));

mgx=phix'*mx*phix;
mgy=phiy'*my*phiy;
mgz=phiz'*mz*phiz;

Lx=phix'*mx*rx;
Ly=phiy'*my*ry;
Lz=phiz'*mz*rz;

MPx=Lx./diag(mgx+mgy+mgz);
MPy=Ly./diag(mgx+mgy+mgz);
MPz=Lz./diag(mgx+mgy+mgz);

Mastx=MPx.*Lx;
Masty=MPy.*Ly;
Mastz=MPz.*Lz;

masstotalx=sum(diag(Mass(ID(1,indxx),ID(1,indxx))));
masstotaly=sum(diag(Mass(ID(1,indxy),ID(1,indxy))));
masstotalz=sum(diag(Mass(ID(1,indxz),ID(1,indxz))));

Mefx=Mastx/masstotalx;
Mefy=Masty/masstotaly;
Mefz=Mastz/masstotalz;

end


