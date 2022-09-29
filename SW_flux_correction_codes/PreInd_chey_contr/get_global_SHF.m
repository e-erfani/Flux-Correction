function global_SHF=get_global_SHF(infile)
%
% Adapted from popdiag_rel_20110902/idl_lib/SHF_eq_pac_seasonal_cycle_diff.run
% 
% Creates an area weighted average of SHF "Total Surface Heat flux" in W/m^2 
%
%

lon=ncread(infile,'TLONG');
lat=ncread(infile,'TLAT');
area=ncread(infile,'TAREA');

ncid = netcdf.open(infile,'nowrite');
varid = netcdf.inqVarID(ncid,'SHF');
missing_value = netcdf.getAtt(ncid,varid,'missing_value','double');
SHF1=netcdf.getVar(ncid,varid,'double');

I=find(SHF1==missing_value);
SHF1(I)=NaN;
area(I)=NaN;
clear ncid varid missing_value I

SHF=squeeze(SHF1(:,:,1));

B=find(isnan(SHF)==0);

global_SHF=nansum(SHF(B).*area(B))./nansum(area(B));


