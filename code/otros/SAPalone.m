% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 23rd October 2020


function SAPMIAdynw

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
modespar=xlsread(pathfile,'modes');

% eliminating node numbers
fixn=fixnodes(:,2:end)';

% total number of nodes
nnodes=length(nodes(:,1));

fixt=zeros(nnodes,3);
% adding non fix nodes
for l=1:length(fixnodes(:,1))
indxfix=find(fixnodes(l,1)==nodes(:,1));
indxfixo=find(indxfix==fixnodes(:,1));
fixt(indxfix,:)=fixn(:,indxfixo)';
end

fixn=fixt';

drawstr2D(nodes,elements,nodeforces,fixn')

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
I=propgeom(:,3);
E=propgeom(:,4);
gammae=propgeom(:,5);

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
     (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2);
 % angle of the element to the x global axis
 theta(i)=atan((nodes(elements(i,3),3)-nodes(elements(i,2),3))/...
     (nodes(elements(i,3),2)-nodes(elements(i,2),2)));
 
 % local stiffness matrix of the elements
 ke(:,:,i)=localke(A(i),I(i),E(i),L(i));
 
 % Transformation matrix 2D
  LT(:,:,i)=TransfM(theta(i));
 
  
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
% assamblage of node forces
if isempty(nodeforces)==0
for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];


Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
end
end

% perfectly clamped forces
% uniform distributed load
FEMG=zeros(1,IDmax);
FEMGu=zeros(1,NEn);
if isempty(uniformload)==0
for i=1:length(uniformload(:,1))
    FEMGf=zeros(1,IDmax);
    FEMGuf=zeros(1,NEn);
    Li=L(IN(uniformload(i,1)));
   Fex=uniformload(i,2)*Li/2;
   Fey=uniformload(i,3)*Li/2;
   Me=uniformload(i,3)*Li^2/12;

FEMew(:,i)=[Fex,-Fey,-Me,Fex,-Fey,Me];
    
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
    FEMGup=zeros(1,NEn);
    Li=L(IN(pload(i,1)));
    a=pload(i,3)*Li;
    b=Li-a;
    
   Peiy=pload(i,2)*b^2/Li^2*(3-2*b/Li);
   Pejy=pload(i,2)*a^2/Li^2*(3-2*a/Li);
   Mei=pload(i,2)*a*b^2/Li^2;
   Mej=pload(i,2)*b*a^2/Li^2;
% local FEM element
%FEMep(:,i)=[0,-Peiy,-Mei,0,-Pejy,Mej];
FEMep=[0,-Peiy,-Mei,0,-Pejy,Mej];
% global FEM element    
FEMgp=LT(:,:,IN(pload(i,1)))'*FEMep';
% global FEM structure
LVF=LV(:,IN(pload(i,1)));
indxLVF=find(LVF>0);
indxLVn=find(LVF<0);
FEMGp(LVF(indxLVF))=FEMgp(indxLVF,1); 
if isempty(indxLVn)==1
   FEMGup=zeros(1,NEn);
else
FEMGup(LVF(indxLVn)*(-1)-IDmax)=FEMgp(indxLVn,1);
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
Deltag=zeros(6,NE);
for i=1:NE
   
    indxLV=find(LV(:,i)>0);
    Deltag(indxLV,i)=DeltaG(LV(indxLV,i));
    Fi(:,i)=ke(:,:,elements(i,1))*LT(:,:,i)*Deltag(:,i);
end

% located global displacements
DeltaGo=zeros(IDmin,1);
DeltaGo(indxdp,1)=DeltaG;


% mass matrix
masses= massele2D(nodes,elements,L,A,gammae);

Mass=zeros(IDmax,IDmax);
for j=1:length(masses(:,1))
    indxLV=find(ID(:,j)>0);
    LVnodes=[ID(indxLV,masses(j,1))];
    if isempty(LVnodes)==0
    Mass(LVnodes,LVnodes)=diag(masses(j,indxLV+1)); 
    end
end

% determination of mode shapes and circular frecuencies
[phi,omega]=modes(KG,Mass,modespar,ID);
Tn=2*pi./omega;
fn=1./Tn;
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
results='DeltaG DeltaGo Fi React KG ke Pnodes LT ID L theta Mass Tn  phi phio;';

dispinfo=['Program has finished correctly. Check results in ', outfile, '.mat'];

disp(dispinfo);

%saving main results to output file
eval(['save ' outfile '  ' results ]);

















