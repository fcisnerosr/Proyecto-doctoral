% Ritz vector procedure to determine frequencies and mode shapes
% Done by Rolando Salgado Estrada
% Assistant professor at Faculty of Engineering of Construction and
% the Habitat, Universidad Veracruzana
% first version 5th October 2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%function [mode,freq]=Ritz(mass,Kg,Nm)

%load marco2D3pisosMAresults
load Marco1pisoAMEresults.mat
Spectra = importdata('BOCARIONRF.txt');


% approximations of mode shapes
 
An = interp1(Spectra(:,1),Spectra(:,2),Tn,'linear');

omegan=2*pi./Tn;
Dn=An./(omegan).^2;

[Mefx,Mefy, MPx,MPy,phix,phiy,mx,my]=MPf2D(phi,Mass,ID);

[rs,cs]=size(phi);
[rn,cn]=size(nodes);

    indxa=find(ID(1,:)>0);
    indya=find(ID(2,:)>0);
   % indma=find(ID(3,:)>0);
    nodex=nodes(indxa,1);
    nodey=nodes(indya,1);
   % nodem=nodes(indma,1);

    %nodetotal=[nodex; nodey; nodem];

    sm=zeros(rn,cs);
    snx=zeros(rn,cn);
    sny=zeros(rn,cn);
    
    filename='D:\OneDrive - Universidad Veracruzana\clases\AEA MIA\Matlab\marco2D3pisosMA.xlsx';
    sheet='node forces';
    nodelRange='A3';
    xlRange='B3';
    ylRange='C3';
    mlRange='B3';
    %xlswrite(filename,nodes(:,1),sheet,nodelRange);
    xlswrite(filename,nodes(:,1),sheet,nodelRange)
    xlswrite(filename,sm,sheet,xlRange);
    
% modal forces
for i=1:cs
snx(indxa,i)=MPx(i)*diag(mx).*phix(:,i);
xlswrite(filename,snx(:,i),sheet,xlRange);
[Rxm(:,i), uxm(:,i),Fxm(:,:,i)]=SAPSMA(filename);
xlswrite(filename,sm,sheet,mlRange);
sny(indya,i)=MPy(i)*diag(my).*phiy(:,i);
xlswrite(filename,sny(:,i),sheet,ylRange);
[Rym(:,i), uym(:,i),Fym(:,:,i)]=SAPSMA(filename);
end


%modal displacements
for i=1:cs
uxn(:,i)=MPx(i)*phix(:,i)*Dn(i);
uyn(:,i)=MPy(i)*phiy(:,i)*Dn(i);
end

puxn=uxm.*An;
puyn=uym.*An;



critdamping=0.05;

damping=ones(1,cs)*0.05;

uxc=CQC(damping,uxn,omegan);














