function [OHT,lat,heat_storage]=get_zonalmean_OHT_implied(infile)

%
% 
% adapted from plot_oaht.ncl & functions_transport.ncl -  calculate the ocean heat transport for models
% function oht_model (gwi[*]:numeric,oroi[*][*]:numeric,fsnsi[*][*]:numeric, \
%                   flnsi[*][*]:numeric,shfli[*][*]:numeric,lhfli[*][*]:numeric)
%
% gw  : gaussian weights (lat)
% oro : orography data array (lat,lon)
% requires the lat and lon are attached coordinates of oro 
% and that oro and the following variables are 2D arrays (lat,lon).
% fsns: net shortwave solar flux at surface
% flns: net longwave solar flux at surface
% shfl: sensible heat flux at surface 
% lhfl: latent heat flux at surface 
%
%	float OCNFRAC(time, lat, lon) ;
%		OCNFRAC:units = "fraction" ;
%		OCNFRAC:long_name = "Fraction of sfc area covered by ocean" ;
%		OCNFRAC:cell_methods = "time: mean" ;
%
%
      ncid = netcdf.open(infile,'NOWRITE');

      varid = netcdf.inqVarID(ncid,'FSNS'); % 
      fsns = netcdf.getVar(ncid,varid,'double'); clear  varid 

      varid = netcdf.inqVarID(ncid,'FLNS'); % 
      flns = netcdf.getVar(ncid,varid,'double'); clear  varid 

      varid = netcdf.inqVarID(ncid,'SHFLX'); % 
      shfl = netcdf.getVar(ncid,varid,'double'); clear  varid 

      varid = netcdf.inqVarID(ncid,'LHFLX'); % 
      lhfl= netcdf.getVar(ncid,varid,'double'); clear  varid 


% constants
  pi = 3.14159265
  re = 6.371e6            % radius of earth
  coef = (re.^2)./1.e15   % scaled for PW 

     
      lon=ncread(infile,'lon');
      lat=ncread(infile,'lat');

      %[lat_rho,lon_rho]=meshgrid(lat1,lon1); clear lon1 lat1

      gw=ncread(infile,'gw');
      I=length(lon);
      GW=repmat(gw,[1 I])';

      nlat = length(lat);
      nlon = length(lon);

      dlon = 2.*pi./nlon;       % dlon in radians

% get OCNFRAC:long_name = "Fraction of sfc area covered by ocean" ;
% 1 all ocean to 0 all land
      varid = netcdf.inqVarID(ncid,'OCNFRAC'); % 
      oro_field = netcdf.getVar(ncid,varid,'double'); clear  varid 
      netcdf.close(ncid);
% compute net surface energy flux scale by ocean fraction
 netflux = zeros(nlon,nlat);
 netflux = (fsns-flns-shfl-lhfl); % This provides a better approx of the pop N_HEAT based OHT than if scaled by ocean fraction
 %netflux = (fsns-flns-shfl-lhfl).*oro_field;
 %GW = GW.*oro_field;

% W/m^2 adjustment for ocean heat storage
heat_storage = sum(sum((netflux).*GW))./sum(sum(GW)); 

netflux = netflux-heat_storage;  

% sum flux over the longitudes 
 heatflux = zeros(nlat);
 heatflux = nansum(squeeze(netflux));

% compute implied heat transport in each basin

 heatflux_flipped=flipdim(heatflux,2);
 
 lat2=flipdim(lat,1);
 lat2_flux1=(lat2(1:end-1)+lat2(2:end))./2;
 lat2_flux=cat(1,lat2_flux1,-90);

   for j=1:nlat  %start sum at most northern point 
     oht(j) = -coef*dlon*sum(heatflux_flipped(1:j)*gw(1:j));
   end 

  OHT = flipdim(oht,2)';
  lat = flipdim(lat2_flux,1);
  

















