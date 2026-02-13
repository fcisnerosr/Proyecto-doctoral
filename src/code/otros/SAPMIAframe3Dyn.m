% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 30th October 2020


function SAPMIAframe3Dyn

% reading data files
[file,path] = uigetfile(('*.xlsx'), 'Choose a File');
pathfile = strcat(path,file);

% reading input data
nodes = xlsread(pathfile,'nudos');
elements = xlsread(pathfile,'conectividad');
propgeom = xlsread(pathfile,'prop geom');
fixnodes= xlsread(pathfile,'fix nodes');
nodeforces=xlsread(pathfile,'node forces');
uniformload=xlsread(pathfile,'uniform load');
pload=xlsread(pathfile,'puntual load');
vxz=xlsread(pathfile,'vxz');
masses=xlsread(pathfile,'masses');
modespar=xlsread(pathfile,'modes');


% eliminating node numbers
fixn=fixnodes(:,2:end)';

% total number of nodes
nnodes=length(nodes(:,1));


fixt=zeros(nnodes,6);
% adding non fix nodes
for l=1:length(fixnodes(:,1))
indxfix=find(fixnodes(l,1)==nodes(:,1));
indxfixo=find(indxfix==fixnodes(:,1));
fixt(indxfix,:)=fixn(:,indxfixo)';
end

fixn=fixt';
% indexes of non fix and fix nodes
indx0=find(fixn==0);
indx1=find(fixn==1);

k=0;
[m,n]=size(fixn);
ID=zeros(m,n);

%sorting element numbers
[B,IN]=sort(elements(:,1));


% creating ID matrix
for i=1:length(indx0)
    
    ID(indx0(i))=k+1;
    k=k+1;
    
end


for i=1:length(indx1)
    
    ID(indx1(i))=(k+1)*(-1);
    k=k+1;
    
end

% geometrical properties
NE=length(elements(:,1));
A=propgeom(:,2);
Iy=propgeom(:,3);
Iz=propgeom(:,4);
J=propgeom(:,5);
E=propgeom(:,6);
G=propgeom(:,7);

IDmax=max(max(ID));
IDmin=abs(min(min(ID)));
indxdp=find(ID>0);
indxdn=find(ID<0);

NEn=length(find(ID<0));

KG=zeros(IDmax,IDmax);
KGtu=zeros(IDmax,NEn);

for i=1:NE
    KGf=zeros(IDmax,IDmax);
    KGtuf=zeros(IDmax,NEn);
    % Length of the elements
 L(i)=sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2+...
     (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2+...
     (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);
 
 CZ(i)=(nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
 CY(i)=(nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
 CX(i)=(nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
 CXY(i)=sqrt(CX(i)^2+CY(i)^2);
 
 
 % local stiffness matrix of the elements
 ke(:,:,i)=localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
 
 vxzl(:,i)=vxz(i,2:end);
 
 
 [cosalpha,sinalpha]=ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));
 
 %alpha=pi/4;
 
 % Transformation matrix 3D
  LT(:,:,i)=TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha);
 
  
 % global stiffnes matrix of the elements  
 kg(:,:,i)=LT(:,:,i)'*ke(:,:,i)*LT(:,:,i);
 
 LV(:,i)=[ID(:,elements(i,2)); ID(:,elements(i,3))];
 
 indxLV=find(LV(:,i)>0);
 indxLVn=find(LV(:,i)<0);
 
 % assamblage general stiffness matrix
 KGf(LV(indxLV,i),LV(indxLV,i))=kg(indxLV,indxLV,i); 
 KGtuf(LV(indxLV,i),LV(indxLVn,i)*(-1)-IDmax)=kg(indxLV,indxLVn,i);
 KG=KGf+KG;
 % stiffness matrix for reactions
 KGtu=KGtuf+KGtu;
 clear KGf;
 clear KGtuf;
end

Pnodes=zeros(IDmax,1);

% assamblage of node forces
for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];

Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
end

% mass matrix
Mass=zeros(IDmax,IDmax);
for j=1:length(masses(:,1))
    indxLV=find(ID(:,j)>0);
    LVnodes=[ID(indxLV,masses(j,1))];
    if isempty(LVnodes)==0
    Mass(LVnodes,LVnodes)=diag(masses(j,indxLV+1)); 
    end
end

% perfectly clamped forces
% uniform distributed load
FEMG=zeros(1,IDmax);
FEMGu=zeros(1,NEn);
for i=1:length(uniformload(:,1))
    FEMGf=zeros(1,IDmax);
    FEMGuf=zeros(1,NEn);
    Li=L(IN(uniformload(i,1)));
   Fex=uniformload(i,2)*Li/2;
   Fey=uniformload(i,3)*Li/2;
   Fez=uniformload(i,4)*Li/2;
   Mez=uniformload(i,3)*Li^2/12;
   Mey=uniformload(i,4)*Li^2/12;

FEMew(:,i)=[-Fex,-Fey,-Fez,0,Mey,-Mez,-Fex,-Fey,-Fez,0,-Mey,Mez];
    
FEMgw(:,i)=LT(:,:,IN(uniformload(i,1)))'*FEMew;

LVF=LV(:,IN(uniformload(i,1)));
indxLVF=find(LVF>0);
indxLVn=find(LVF<0);
FEMGf(LVF(indxLVF))=FEMgw(indxLVF,i); 
FEMGuf(LVF(indxLVn)*(-1)-IDmax)=FEMgw(indxLVn,i);
 FEMG=FEMGf+FEMG;
 FEMGu=FEMGuf+FEMGu;
 clear FEMGf;
 clear FEMGuf;

end

% Concentrated load between nodes
for i=1:length(pload(:,1))
    FEMGp=zeros(1,IDmax);
    Li=L(IN(pload(i,1)));
    ay=pload(i,4)*Li;
    az=pload(i,5)*Li;
    by=Li-ay;
    bz=Li-az;
   
   Peiy=pload(i,2)*by^2/Li^2*(3-2*by/Li);
   Pejy=pload(i,2)*ay^2/Li^2*(3-2*ay/Li);
   Meiz=pload(i,2)*ay*by^2/Li^2;
   Mejz=pload(i,2)*by*ay^2/Li^2;
   
   Peiz=pload(i,3)*bz^2/Li^2*(3-2*bz/Li);
   Pejz=pload(i,3)*az^2/Li^2*(3-2*az/Li);
   Meiy=pload(i,3)*az*bz^2/Li^2;
   Mejy=pload(i,3)*bz*az^2/Li^2;
   
% local FEM element
FEMep(:,i)=[0,-Peiy,-Peiz,0,Meiy,-Meiz,0,-Pejy,-Pejz,0,-Mejy,Mejz];
% global FEM element    
FEMgp(:,i)=LT(:,:,IN(pload(i,1)))'*FEMep(:,i);
% global FEM structure
LVF=LV(:,IN(pload(i,1)));
indxLVF=find(LVF>0);
indxLVn=find(LVF<0);
FEMGp(LVF(indxLVF))=FEMgp(indxLVF,i); 
if isempty(indxLVn)==1
   FEMGup=zeros(1,NEn);
else
FEMGup(LVF(indxLVn)*(-1)-IDmax)=FEMgp(indxLVn,i);
end
FEMG=FEMGp+FEMG;
FEMGu=FEMGup+FEMGu;
 clear FEMGp;
 clear FEMGup;
end

%net global external force
NForce=Pnodes-FEMG';


% global displacements structure
DeltaG=(KG^(-1))*NForce;


% global reactions
React=KGtu'*DeltaG+FEMGu';

% Element internal forces
Deltag=zeros(6,NE);
for i=1:NE
   
    indxLV=find(LV(:,i)>0);
    Deltag(indxLV,i)=DeltaG(LV(indxLV,i));
    Fi(:,i)=ke(:,:,elements(i,1))*LT(:,:,i)*Deltag(:,i);
end

% locate global displacements
DeltaGo=zeros(IDmin,1);
DeltaGo(indxdp,1)=DeltaG;



% determination of mode shapes and circular frecuencies
[phi,omega]=modes(KG,Mass,modespar,ID);
Tn=2*pi./omega;
fn=1/Tn;
numodes=modespar(1,1);
phio=zeros(IDmin,numodes);
phio(indxdp,:)=phi;


%eliminating file extension
dotLocations = find(file == '.');
if isempty(dotLocations)
	% No dots at all found so just take entire name.
	outfile = file;
else
	% Take up to , but not including, the first dot.
	outfile = file(1:dotLocations(1)-1);
end

% creating output file
outfile=strcat(outfile,'results');

% variables to be saved
results='DeltaG DeltaGo Fi React KG ke kg Pnodes Mass fn LT ID L CX CY CZ FEMG NForce phi phio Tn ;';

%saving main results to output file
eval(['save ' outfile '  ' results ]);

end

