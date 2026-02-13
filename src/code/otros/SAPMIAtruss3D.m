% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 23rd October 2020


function SAPMIAtruss3D

% reading data files
[file,path] = uigetfile(('*.xlsx'), 'Choose a File');
pathfile = strcat(path,file);

% reading input data
nodes = xlsread(pathfile,'nudos');
elements = xlsread(pathfile,'conectividad');
propgeom = xlsread(pathfile,'prop geom');
fixnodes= xlsread(pathfile,'fix nodes');
nodeforces=xlsread(pathfile,'node forces');

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
E=propgeom(:,3);

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
 hipo(i)=sqrt((nodes(elements(i,3),3)-nodes(elements(i,2),3))^2+...
 (nodes(elements(i,3),2)-nodes(elements(i,2),2))^2);
 
 
 % local stiffness matrix of the elements
 ke(:,:,i)=localke3Dtruss(A(i),E(i),L(i));
 
 % Transformation matrix 3D
  LT(:,:,i)=TransfM3Dtruss(CX(i),CY(i),CZ(i),hipo(i));
 
  
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


% global displacements structure
DeltaG=(KG^(-1))*Pnodes;


% global reactions
React=KGtu'*DeltaG;

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
results='DeltaG DeltaGo Fi React KG ke Pnodes LT ID L CX CY CZ hipo;';

%saving main results to output file
eval(['save ' outfile '  ' results ]);

end

