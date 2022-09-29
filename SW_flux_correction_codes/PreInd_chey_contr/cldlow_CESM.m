clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr  
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.cam.h0.0*.anmn.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  gw=ncread(filename1,'gw'); % surface net Shortwave Radiation (W/m2)
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lat_msh,lon_msh] = meshgrid(latitude,longitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
nn = 0 ;
for tt1=401:500%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
     cldlow=ncread(filename1,'CLDLOW'); % Net solar flux at surface (W/m2)
    cldlow_all(:,:,nn) = cldlow ;      
end
cldlow_all = cldlow_all .* 100 ;
cldlow_average = nanmean(cldlow_all,3);
save cldlow_average
%dbstop
%%%%
cd /shared/SWFluxCorr/CLOUDSAT
    filename10='CLOUDSAT_ANN_climo.nc';
  cldlow_obs=ncread(filename10,'CLDLOW'); % surface net Shortwave Radiation (W/m2)    
  lat_obs=ncread(filename10,'lat'); % surface net Shortwave Radiation (W/m2)
  lon_obs=ncread(filename10,'lon'); % surface net Shortwave Radiation (W/m2)
[lat_obs_msh,lon_obs_msh] = meshgrid(lat_obs,lon_obs);
    
    cldlow_obs_intrp_CAMgrid = griddata(double(lat_obs_msh),double(lon_obs_msh),cldlow_obs,lat_msh,lon_msh,'natural');

 II=find(isnan(cldlow_average)==1);
 JJ=find(isnan(cldlow_obs_intrp_CAMgrid)==1);
GW2 = GW ; GW3 = GW; GW4 = GW ;
GW2(II)=nan; GW3(JJ)=nan; GW4(II)=nan; GW4(JJ)=nan; 
cldlow_obs_average_glb =  nansum(nansum(GW3 .* cldlow_obs_intrp_CAMgrid,1),2) ./ nansum(nansum(GW3,1),2) 
cldlow_model_average_glb =  nansum(nansum(GW2 .* cldlow_average,1),2) ./ nansum(nansum(GW2,1),2) 
cldlow_rmse =  sqrt(nansum(nansum(GW4 .* (cldlow_average - cldlow_obs_intrp_CAMgrid) .^ 2,1),2) ...
    ./ nansum(nansum(GW4,1),2)) 
 
%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(cldlow_average) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('cloud_low_flx_ajd_CAM_CAMgrid','_annual');
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = strcat('CAM (flx adj), Low Cloud Amount  (%)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 100])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
      
%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(cldlow_average - cldlow_obs_intrp_CAMgrid) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Bias_cloud_low_flx_ajd_CAM_CAMgrid','_annual');
        fig_dum = figure(4);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = strcat('Bias, CAM (flx adj) - CLOUDSAT, low cloud amount  (%)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-49, 49])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       

% %%%%%
% cellsize = 0.5; 
% SST_T31(:,:,1)  = double(cldlow_obs_intrp_CAMgrid) ;
% lat_T31(:,:,1)  = lat_msh ;
% lon_T31(:,:,1)  = lon_msh ; 
% [Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
%  latlim = [-75 75];
%  lonlim = [1 360]; 
%  
%        fig_name = strcat('cloud_low_obs_CAM_CAMgrid','_annual');
%         fig_dum = figure(5);
%       set(fig_dum, 'name', fig_name,'numbertitle','on');
%       set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
%       set(fig_dum,'paperpositionmode','auto');
%        m_proj('miller','long',[0 358],'lat',[-75 75])       
%     axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
%    'Frame','off','Grid','off')
% AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
%     set(AA,'FaceColor','flat','Linestyle','-'); 
%     setm(gca,'frame','on');
%     setm(gca,'fontsize',12);
%     setm(gca,'FEdgeColor',[1 1 1]);
%   m_coast('linewidth',2,'color','black');
%     Title_1 = strcat('obs, Low Cloud Amount  (%)', ', Annual Mean');
%     title(Title_1,'fontsize',23,'fontweight','bold');
%     cc = colorbar('peer',gca);
%     set(gca,'Fontsize',20)
%     m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
%     caxis([0, 100])
% cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
%       eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
%       