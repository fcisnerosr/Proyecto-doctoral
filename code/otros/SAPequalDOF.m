% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 23rd October 2020


function SAPequalDOF

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
eDOF=xlsread(pathfile,'equalDOF');


% eliminating node numbers
fixn=fixnodes(:,2:end)';


indx0=find(fixn==0);
indx1=find(fixn==1);

k=0;
[m,n]=size(fixn);
[mdof,ndof]=size(eDOF);

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

% Equal DOF
kd=0;
for i=1:mdof
    con=find(eDOF(i,3:end));
    for j=con
        kd=kd+1;
        const(kd)=ID(j,eDOF(1,2));
        slave(kd)=ID(j,eDOF(1,1));
        ID(j,eDOF(1,2))=ID(j,eDOF(1,1)); 
    end
end

% geometrical properties
NE=length(elements(:,1));
A=propgeom(:,2);
I=propgeom(:,3);
E=propgeom(:,4);

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
for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];


Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
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
   Me=uniformload(i,3)*Li^2/12;

FEMew(:,i)=[Fex,-Fey,-Me,Fex,-Fey,Me];
    
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
    a=pload(:,3)*Li;
    b=Li-a;
    
   Peiy=pload(i,2)*b(i)^2/Li^2*(3-2*b(i)/Li);
   Pejy=pload(i,2)*a(i)^2/Li^2*(3-2*a(i)/Li);
   Mei=pload(i,2)*a(i)*b(i)^2/Li^2;
   Mej=pload(i,2)*b(i)*a(i)^2/Li^2;
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

%net global external force
NForce=Pnodes-FEMG';

KG(const,:)=[];
KG(:,const)=[];
NForce(const)=[];
KGtu(const,:)=[];


% global displacements structure
DeltaG=(KG^(-1))*NForce;



% global reactions
React=KGtu'*DeltaG+FEMGu';

delta0=0;
for kd=1:length(const)
DeltaG = [DeltaG(1:length(DeltaG) < const(kd)); delta0; DeltaG(1:length(DeltaG) >= const(kd))];
end

for kd=1:length(const)
DeltaG(const)=DeltaG(slave(kd));
end

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
results='DeltaG DeltaGo Fi React KG ke Pnodes LT ID L theta;';

%saving main results to output file
eval(['save ' outfile '  ' results ]);

















