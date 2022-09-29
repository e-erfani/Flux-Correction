function [OHT,lat]=get_zonalmean_OHT(infile)


ncid = netcdf.open(infile,'nowrite');
varid = netcdf.inqVarID(ncid,'N_HEAT');
missing_value = netcdf.getAtt(ncid,varid,'missing_value','double');
OHT1=netcdf.getVar(ncid,varid,'double');

% N_HEAT:coordinates = "lat_aux_grid transport_components transport_regions time"      
% transport_components =
%  "Total",
%  "Eulerian-Mean Advection",
%  "Eddy-Induced Advection (bolus) + Diffusion",
%  "Eddy-Induced (bolus) Advection",
%  "Submeso Advection" ;

% transport_regions =
%  "Global Ocean - Marginal Seas",
%  "Atlantic Ocean + Mediterranean Sea + Labrador Sea + GIN Sea + Arctic Ocean + Hudson Bay" ;


lat=ncread(infile,'lat_aux_grid');

I=find(OHT1==missing_value);
OHT1(I)=NaN;
clear ncid varid missing_value 

OHT=squeeze(OHT1(:,1,1));
%OHT=squeeze(OHT1(:,2,1))+squeeze(OHT1(:,3,1))+squeeze(OHT1(:,5,1));

lat=ncread(infile,'lat_aux_grid');











