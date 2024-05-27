% program for combining modal responses 
% using complete quadrature combination method
% donde by Rolando Salgado Estrada
% assistant professor at Faculty of Engineering of Construction
% and the Habitat, Campus Veracruz, Universidad Veracruzana
% first version
% 6th October 2021

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rf=CQC(damping,ro,omegan)

[rs,cs]=size(ro);

rp=zeros(rs,1);

for i=1:cs
    for n=1:cs
        beta(i,n)=omegan(i)/omegan(n);
        
        rho(i,n)=(8*sqrt(damping(i)*damping(n))*(damping(i)+beta(i,n)*damping(n))...
            *beta(i,n)^(3/2))/((1-beta(i,n)^2)^2+4*damping(i)*damping(n)...
            *beta(i,n)*(1+beta(i,n)^2)+4*(damping(i)^2+damping(n)^2)*beta(i,n)^2);
        
        rp=rho(i,n)*ro(:,i).*ro(:,n)+rp;
        
    end
end

    
    rf=sqrt(rp);
        
        
        
            

