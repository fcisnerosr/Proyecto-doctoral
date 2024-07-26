% Drawing mode shapes
% program donde by 
% Dr. Rolando Salgado Estrada
% Full-time Professor at 
% Faculty of Engineering of the Construction and the Habitat
% Universidad Veracruzana
% 1st version 
% 10th November 2020

function drawmodes(nodes,elem,phio,Tn)

[DOF,Nmodes]=size(phio);
[Nele,jele]=size(elem);
%[Nnodes,jnodes]=size(nodes);
ltele='b.-';
for j=1:Nmodes
  h=figure(j); 

  for i=1:Nele
     
       nloc2=find(nodes(:,1)==elem(i,2));
       nloc3=find(nodes(:,1)==elem(i,3));
       
      L(i)=sqrt((nodes(nloc2,2)-nodes(nloc3,2))^2+...
     (nodes(nloc2,3)-nodes(nloc3,3))^2+...
     (nodes(nloc2,4)-nodes(nloc3,4))^2);
      
  end
  
  Lmax=max(L);
  gx=1:6:length(phio(:,1));
  gy=2:6:length(phio(:,1));
  gz=3:6:length(phio(:,1));
  
  phioxmax=max(abs(phio(gx,j)));
  phioymax=max(abs(phio(gy,j)));
  phiozmax=max(abs(phio(gz,j)));
  phiogmax=max(sqrt(phio(gx,j).^2+phio(gy,j).^2+phio(gz,j).^2));
  
  
  if phioxmax<=5e-4
      phioxmax=1;
  end
  
  if phioymax<=5e-4
      phioymax=1;
  end
  
  if phiozmax<=5e-4
      phiozmax=1;
  end
  
  if phiogmax<=5e-4
      phiogmax=1;
  end
  
  Fx=Lmax/phioxmax*1;
  Fy=Lmax/phioymax*1;
  Fz=Lmax/phiozmax*1;
  Fg=Lmax/phiogmax*1;
  
for i=1:Nele
        
       nloc2=find(nodes(:,1)==elem(i,2));
       nloc3=find(nodes(:,1)==elem(i,3));
       
      
    x1=[nodes(nloc2,2)+phio(6*(nloc2-1)+1,j)*Fg nodes(nloc3,2)+phio(6*(nloc3-1)+1,j)*Fg];
    y1=[nodes(nloc2,3)+phio(6*(nloc2-1)+2,j)*Fg nodes(nloc3,3)+phio(6*(nloc3-1)+2,j)*Fg];
    z1=[nodes(nloc2,4)+phio(6*(nloc2-1)+3,j)*Fg nodes(nloc3,4)+phio(6*(nloc3-1)+3,j)*Fg];
    x2=[nodes(nloc2,2) nodes(nloc3,2)];
    y2=[nodes(nloc2,3) nodes(nloc3,3)];
    z2=[nodes(nloc2,4) nodes(nloc3,4)];

   plot3(real(x1),real(y1),real(z1),ltele,'LineWidth',3.5);
   hold on
   plot3(x2,y2,z2,'y-','LineWidth',1,'color',[0.5,0.5,0.5]);
end
%zoom(1.20);
    xyz=[1 1 1];
    daspect(xyz);
    freq1=num2str(round(Tn(j),3));
    nmode=num2str(j);
    tit=strcat('T_{',nmode,'}=',freq1,' sec');
    filename=strcat('mode',nmode);
    set(gca,'FontSize',18)
    title(tit);
    axis off;
    %print(h,'-dsvg', filename, '-r100');
    savefig(h,filename);
    pause(2);
    close(h);
end