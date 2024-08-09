% Determine the mode shapes and frequencies
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 5th November 2020

function [x1,f]=modes(KG,Mass,modespar,ID)
    % determining active and non-active dynamic degrees of freedom		
		k = 0;
		l = 0;
		% Ciclo para definir que grados de libertad están activos y no activos
		for i = 1:length(modespar)-1
			if modespar(i+1)==1
				k = k+1;
				indxa = find(ID(i,:)>0);
				active1 = ID(i,indxa);
				if k==1
					active = active1;
				else
					active = [active,active1];
				end
			else
				l = l+1;
				indxna = find(ID(i,:)>0);
				nactive1 = ID(i,indxna);
				if l==1
					nactive = nactive1;
				else
					nactive = [nactive,nactive1];
				end
			end
			
		end
		active  = sort(active);
		nactive = sort(nactive);
    
    % Realización de la condensación estática
		% active  = grados activos
		% nactive = grados no activos
		Kaa = KG(active,active);
		Kac = KG(active,nactive);
		Kca = KG(nactive,active);
		Kcc = KG(nactive,nactive);
		Ma  = Mass(active,active);
		
		Ka = Kaa-Kac*inv(Kcc)*Kca; % Matriz condesada
    
    % Cálculo de las formas modales y las frecuencias naturales
		numodes = modespar(1,1);
		% formas modales con la matriz de rigidez completa
		[phi,omega2] = eigs(KG,Mass,numodes,'SM');
		[omega,indxom] = sort(sqrt(diag(omega2)));
		phi = phi(:,indxom);
		
		% formas modales con la matriz de rigidez condensada
		% proceso de volver a unir las matrices
		[x,lambda]    = eigs(Ka,Ma,numodes,'SM');	% Matriz de formas modales
		lambdaf       = sqrt(lambda);
		[f,u]         = sort(diag(lambdaf));
		x             = x(:,u);
		xf            = -inv(Kcc)*Kca*x;
		IDmax         = max(max(ID));
		x1            = zeros(IDmax,numodes);
		% Matriz de formas modales con grados activos y no activos
		x1(active,:)  = x;
		x1(nactive,:) = xf;
    
    % mass normalization
		Fmass1 = sqrt(1./diag(phi'*Mass*phi));		% Masa normalizada con la matriz de rigidez completa
		Fmass2 = sqrt(1./diag(x1'*Mass*x1));		% Masa normalizada con la matriz condensada
			  
		for i=1:numodes
		  phi(:,i)=phi(:,i)*Fmass1(i);
		  x1(:,i)=x1(:,i)*Fmass2(i);
		end
     
end

