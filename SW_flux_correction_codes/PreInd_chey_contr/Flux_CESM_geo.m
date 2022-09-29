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
[lon_msh,lat_msh] = meshgrid(longitude,latitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
nn = 0 ;
for tt1=401:500%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
     SW_N_S=ncread(filename1,'FSNS'); % Net solar flux at surface (W/m2)
    SW_d_S=ncread(filename1,'FSDS'); % Downwelling solar flux at surface (W/m2)
    SW_N_S_all(:,:,nn) = SW_N_S;      
    SW_d_S_all(:,:,nn) = SW_d_S;      
end
SW_N_S_average = nanmean(SW_N_S_all,3);
SW_d_S_average = nanmean(SW_d_S_all,3);
%save SW_d_S_average
%dbstop
%%%%
cd /homes/eerfani/Bias
cd CERES
load ('lat_fine.mat')
load ('lon_fine.mat')
cd fields_NEW
load ('SW_S_d_mo_mean.mat')
load ('SW_S_u_mo_mean.mat')
SW_S_N_CERES = SW_S_d_mo_mean -SW_S_u_mo_mean ;

[lon_fn_msh,lat_fn_msh] = meshgrid(lon_fine,lat_fine);
    
for tt = 1:12
    tmp = double(SW_S_d_mo_mean(:,:,tt)') ;
    tmp2 = griddata(lon_fn_msh,lat_fn_msh,tmp,lon_msh,lat_msh,'natural');
    SW_S_d_mo_mean_intrp_CAMgrid(:,:,tt) = tmp2' ; 
    tmp = double(SW_S_N_CERES(:,:,tt)') ;
    tmp2 = griddata(lon_fn_msh,lat_fn_msh,tmp,lon_msh,lat_msh,'natural');
    SW_S_N_mo_mean_intrp_CAMgrid(:,:,tt) = tmp2' ; 
end
 II=find(isnan(SW_d_S_average)==1);
GW2 = GW ;
GW2(II)=nan;
abc=nanmean(SW_S_d_mo_mean_intrp_CAMgrid,3);
SW_d_S_average_glb =  nansum(nansum(GW2 .* abc,1),2) ./ nansum(nansum(GW2,1),2) 
SW_d_S_rmse =  sqrt(nansum(nansum(GW2 .* (SW_d_S_average - abc) .^ 2,1),2) ./ nansum(nansum(GW2,1),2)) 
 
%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_N_S_average) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('SW_N_surf_CESM_flx_ajd_CAM_CAMgrid','_annual');
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
    Title_1 = strcat('CAM (flx adj), Net SW Flux at surface  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 300])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
      
%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_d_S_average) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('SW_down_surf_CESM_flx_ajd_CAM_CAMgrid','_annual');
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
    Title_1 = strcat('CAM (flx adj), Downward SW Flux at surface  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 300])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       

%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_N_S_average - nanmean(SW_S_N_mo_mean_intrp_CAMgrid,3)) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Bias_SW_N_surf_CESM_flx_ajd_CAM_CAMgrid','_annual');
        fig_dum = figure(5);
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
    Title_1 = strcat('Bias, CAM (flx adj) - CERES, Net SW Flux at surface  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr      
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
      
%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_d_S_average - nanmean(SW_S_d_mo_mean_intrp_CAMgrid,3)) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Bias_SW_down_surf_CESM_flx_ajd_CAM_CAMgrid','_annual');
        fig_dum = figure(6);
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
    Title_1 = strcat('Bias, CAM (flx adj) - CERES, Downward SW Flux at surface  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);     

      
%%%%%%
cd /homes/eerfani/Bias

load ('SW_S_d_CESM')
load ('SW_S_u_CESM')

SW_S_N_all = SW_S_d_all - SW_S_u_all ;

SW_S_N_average_burls = nanmean(SW_S_N_all,3);
SW_S_d_average_burls = nanmean(SW_S_d_all,3);


%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_d_S_average - SW_S_d_average_burls) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Diff_SW_d_S_CESM_flx_ajd_CTRL_CAM','_annual');
        fig_dum = figure(40);
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
    Title_1 = strcat('CAM (flx adj) - CAM(ctrl), Annual Sfc Down SW Flux (W m^-^2)');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-15, 15])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr       
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       

%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_N_S_average - SW_S_N_average_burls) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Diff_SW_N_S_CESM_flx_ajd_CTRL_CAM','_annual');
        fig_dum = figure(50);
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
    Title_1 = strcat('CAM (flx adj) - CAM(ctrl), Annual Sfc Net SW Flux (W m^-^2)');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-15, 15])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr      
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
      