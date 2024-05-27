% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 30th October 2020
% 2nd version 11 December 2020
% 3rd version 30 June 2021
 

function SAPkbothmass

% reading data files
[file,path] = uigetfile(('*.xlsx'), 'Choose a File');
pathfile = strcat(path,file);


% reading input data
nodes = xlsread(pathfile,'nudos');
elements = xlsread(pathfile,'conectividad');
[propgeom,txtpg] = xlsread(pathfile,'prop geom');
fixnodes= xlsread(pathfile,'fix nodes');
nodeforces=xlsread(pathfile,'node forces');
uniformload=xlsread(pathfile,'uniform load');
pload=xlsread(pathfile,'puntual load');
vxz=xlsread(pathfile,'vxz');
masses=xlsread(pathfile,'masses');
modespar=xlsread(pathfile,'modes');
dynload=xlsread(pathfile,'dynload');
damage=xlsread(pathfile,'damage');
propdent=xlsread(pathfile,'prop dent');
kspring=xlsread(pathfile,'spring');


% eliminating node numbers
fixn=fixnodes(:,2:end)';
massn=masses(:,2:end)';

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

if isempty(masses)==0
% adding non fix nodes
for l=1:length(masses(:,1))
indxfix=find(masses(l,1)==nodes(:,1));
indxfixo=find(indxfix==masses(:,1));
massest(indxfix,:)=massn(:,indxfixo)';
end
massn=massest';
else
    massn=zeros(nnodes,6)';
end



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
tipo=txtpg(3:end,8);
water=txtpg(3:end,9);
radio=zeros(size(propgeom(:,10)));
b=zeros(size(propgeom(:,10)));
h=zeros(size(propgeom(:,10)));
trec=zeros(size(propgeom(:,10)));
for i=1:length(propgeom(:,10))
if strcmp(tipo(i),'circular')
    radio(i)=propgeom(i,10);
elseif strcmp(tipo(i),'rectangular')
    b(i)=propgeom(i,10);
    h(i)=propgeom(i,11);
    trec(i)=propgeom(i,12);
end
end
gammae=propgeom(:,13);
betam=propgeom(:,14);


% dent properties
if isempty(propdent)==1
eledent=[];
Adent=[];
Iydent=[];
Izdent=[];
Jdent=[];
x1dentr=[];
x2dentr=[];
else
eledent=propdent(:,1);
Adent=propdent(:,2);
Iydent=propdent(:,3);
Izdent=propdent(:,4);
Jdent=propdent(:,5);
x1dentr=propdent(:,6);
x2dentr=propdent(:,7);
end

% damage properties
if isempty(damage)==1
damele=[];
xdcr=[];
depthr=[];
else
damele=damage(:,1);
xdcr=damage(:,2);
depthr=damage(:,3);
end

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
 
 locdam=find(damele==i,1);
 locdent=find(eledent==i, 1);
 if isempty(locdam) && isempty(locdent)
 % local stiffness matrix of the elements
        ke(:,:,i)=localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
 elseif isempty(locdent)
     xdc=xdcr(locdam)*L(i);
     
     if strcmp(tipo(i),'circular')
     depthr1=depthr(locdam)*radio(i);
     ke(:,:,i)=ZhengcircT8(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),betam(i));
     elseif  strcmp(tipo(i),'rectangular')
     depthr1=depthr(locdam)*h(i);
     ke(:,:,i)=Zhengrectub(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),h(i),b(i),trec(i));  
     end
     
 elseif isempty(locdam)
     ident=eledent(locdent);
     x1dent=x1dentr*L(ident);
     x2dent=x2dentr*L(ident);
     ke(:,:,i)=FEMdent(L(ident),Adent(locdent),Izdent(locdent),...
         Iydent(locdent),Jdent(locdent),A(ident),Iz(ident),Iy(ident),...
         J(ident),x1dent,x2dent,E(ident),G(ident));
         
 end
 
 
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

% springs
if isempty(kspring)==0
    nnodej=1;
for j=1:length(kspring(:,1))
    nnodej=(kspring(j,1)-1)*6+nnodej;
    Lnodej(:,j)=[ID(:,kspring(j,1))];
   for k=1:6 
    if Lnodej(k,j)>0
    KG(Lnodej(k,j),Lnodej(k,j))=KG(Lnodej(k,j),Lnodej(k,j))+kspring(j,k+1);
    end
end
end
end

Pnodes=zeros(IDmax,1);

% assamblage of node forces
if isempty(nodeforces)==0
for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];

Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
end
end


masses1= masselement(nodes,elements,L,A,tipo,water,radio,b,h,gammae);
masses=zeros(size(masses1));
masses(:,1)=masses1(:,1);
massn=massn+masses1(:,2:end)';
masses(:,2:end)=massn';
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
FEMGup=zeros(1,NEn);
if isempty(uniformload)==0
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
    
FEMgw(:,i)=LT(:,:,IN(uniformload(i,1)))'*FEMew(:,i);

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
end

% Concentrated load between nodes
if isempty(pload)==0
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
end

%net global external force
NForce=Pnodes-FEMG';


% global displacements structure
DeltaG=(KG^(-1))*NForce;


% global reactions
React=KGtu'*DeltaG+FEMGu';

% Element internal forces
Deltag=zeros(12,NE);
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
fn=1./Tn;
numodes=modespar(1,1);
phio=zeros(IDmin,numodes);
phio(indxdp,:)=phi;

% modal participation factor

[Mefx,Mefy,Mefz]=MPf(phi,Mass,ID);

%draw mode shapes
drawmodes(nodes,elements,phio,Tn)


%dynamic response
fi=dynload(1,1);
dt=dynload(2,1);
TDuration=dynload(end,1);
forcet=dynload(5:end,2:end);
fdir=dynload(1,2:end);
fnodes=dynload(2,2:end);
u0i=dynload(3,2:end);
v0i=dynload(4,2:end);
[Ntime,Ntr]=size(forcet);
force=zeros(Ntime,IDmax);
force(:,diag(ID(fdir,fnodes)))=forcet;
u0=zeros(1,IDmax);
v0=zeros(1,IDmax);
u0(1,diag(ID(fdir,fnodes)))=u0i;
v0(1,diag(ID(fdir,fnodes)))=v0i;

[u,v,ac]=Wilson1(dt,TDuration,Mass,phi,fi,force,omega,u0,v0);


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
outfile=strcat(outfile,'damresults');

% variables to be saved
results='DeltaG DeltaGo Fi React KG ke kg Mefx Mefy Mefz Pnodes Mass fn LT ID L CX CY CZ FEMG NForce phi phio Tn u v ac ;';

%saving main results to output file
eval(['save ' outfile '  ' results ]);

end

