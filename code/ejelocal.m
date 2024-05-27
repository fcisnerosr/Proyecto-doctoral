% local axes orientation
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 30th October 2020

function [cosalpha,sinalpha] = ejelocal(CX,CY,CZ,CXY,vxzuser)

% default orientation
if CXY < 1e-3
    vxzdef = [-1,0,0];
else
    vxzdef = [0,0,1];
end

vxl     = [CX,CY,CZ];
vydef1  = cross(vxzdef,vxl);
vydef   = vydef1/norm(vydef1);
vzdef1  = cross(vxl,vydef);
vzdef   = vzdef1/norm(vzdef1);
%user orientation
vyuser1 = cross(vxzuser,vxl);
vyuser  = vyuser1/norm(vyuser1);

vzuser1 = cross(vxl,vyuser);
vzuser  = vzuser1/norm(vzuser1);

cosalpha = round(dot(vyuser,vydef),5);
alpha    = acos(cosalpha);
if cosalpha == 0
    sinalpha = sum(cross(vyuser,vydef));
else
   sinalpha = sin(alpha);
end

end

    