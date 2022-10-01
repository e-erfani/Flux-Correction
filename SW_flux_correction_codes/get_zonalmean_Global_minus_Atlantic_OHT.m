function [OHT,lat]=get_zonalmean_Atlantic_OHT(infile)


ncid = netcdf.open(infile,'nowrite');
varid = netcdf.inqVarID(ncid,'N_HEAT');
missing_value = netcdf.getAtt(ncid,varid,'missing_value','double');
OHT1=netcdf.getVar(ncid,varid,'double');

I=find(OHT1==missing_value);
OHT1(I)=NaN;
clear ncid varid missing_value 

lat=ncread(infile,'lat_aux_grid');


% transport_components =
%  "Total",                   !! Valid for Global but NaN for Atlantic
%  "Eulerian-Mean Advection",
%  "Eddy-Induced Advection (bolus) + Diffusion", !! Valid for Global but NaN for Atlantic
%  "Eddy-Induced (bolus) Advection",
%  "Submeso Advection" ;

% Global
%plot(OHT1(:,1,1),'m') % = plot(OHT1(:,2,1)+OHT1(:,3,1),'r')
%hold on;
%plot(OHT1(:,2,1)+OHT1(:,3,1),'r')
%plot(OHT1(:,2,1)+OHT1(:,4,1)+OHT1(:,5,1),'k')
%plot(OHT1(:,2,1)+OHT1(:,4,1),'b')
%plot(OHT1(:,2,1),'g')

% Atlantic
%plot(OHT1(:,1,2),'m') % = plot(OHT1(:,2,2)+OHT1(:,3,1),'r')
%hold on;
%plot(OHT1(:,2,2)+OHT1(:,3,2),'r')
%plot(OHT1(:,2,2)+OHT1(:,4,2)+OHT1(:,5,1),'k')
%plot(OHT1(:,2,2)+OHT1(:,4,2),'b')
%plot(OHT1(:,2,2),'g')

% Not 100% correct missing Diffusion, !! Valid for Global but NaN for Atlantic
OHT_Atlantic=squeeze(OHT1(:,2,2)+OHT1(:,4,2));

  III=find(isnan(OHT_Atlantic)==1);
  OHT_Atlantic(III)=0;

OHT_Global=squeeze(OHT1(:,1,1));
OHT=OHT_Global-OHT_Atlantic;













