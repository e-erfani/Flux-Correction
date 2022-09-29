    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h*.anmn.nc');

    tt=1; % ncdisp(aa(tt,1).name)    
nn = 0 ;
for tt=401:500%length(aa1)
    nn = nn + 1 ;
    filename=aa(tt,1).name;
    SST=ncread(filename,'TEMP'); % surface net Shortwave Radiation (W/m2)
    SST(SST > 1E4) = NaN ;  
    latitude=ncread(filename,'TLAT'); % lat
    longitude=ncread(filename,'TLONG'); % lon 
    SST_POP_adj(:,:,nn) = SST(:,:,1) ;    
 end
 save SST_POP_adj
 SST_ajd_mean = nanmean(SST_POP_adj,3) ; 
  
  cellsize = 0.5; 
SST_T31(:,:,1)  = SST_ajd_mean ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
 latlim = [-75 75];
 lonlim = [1 360];
 
[Z(:,:,1),refvec(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);

       fig_name = strcat('SST_pop_flx_adj','_');%,num2str(tt));
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z(:,:,1)), squeeze(refvec(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = 'flx adj, Sea Surface Temperature  (deg C), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([0, 30])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

 %%%%%%%%%%%%%%5 
cd /shared/SWFluxCorr/CESM/flux_corr_pop
load ('SST_POP')
load('lat_fine')
load('lon_fine')

 SST_ajd_mean = nanmean(SST_POP_adj,3) ; 
 SST_mean = nanmean(SST_POP,3) ; 
SST_adjust_model = SST_ajd_mean - SST_mean ;
  
  cellsize = 0.5; 
SST_T31(:,:,1)  = SST_adjust_model ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);
 
       fig_name = strcat('Adjustment_SST_pop_flx_adj');%,'_',num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = 'CESM - CESM(ctrl), Sea Surface Temperature  (deg C), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([-1, 1])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
 
%%%%%%%%%%%%
cd /homes/eerfani/Bias
load ('SST_Hadley_interp.mat')
cd CERES
load('latitude_pop')
load('longitude_pop')
  
SST_Bias_model = SST_ajd_mean - SST_mean_interp ;
  
 cellsize = 0.5; 
SST_T31(:,:,1)  = SST_Bias_model ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
[Z_Bias(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);
 
fig_name = strcat('Bias_SST_POPgrid_flx_adj');%,'_',num2str(tt));
        fig_dum = figure(4);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_Bias(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CESM - Hadley, Sea Surface Temperature (deg C), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([-8, 8])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     


  %%%%%%%%%%%%  
SST_Bias_ctrl_model = SST_mean - SST_mean_interp ;
  
 cellsize = 0.5; 
SST_T31(:,:,1)  = SST_Bias_ctrl_model ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
[Z_Bias(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);
 
       fig_name = strcat('Bias_SST_POPgrid_ctrl');
        fig_dum = figure(5);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_Bias(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CESM(ctrl) - Hadley, Sea Surface Temperature (deg C), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([-8, 8])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     

  %%%%%%%%%%%%  
 cellsize = 0.5; 
SST_T31(:,:,1)  = SST_Bias_model - SST_Bias_ctrl_model ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
[Z_Bias(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);
 
       fig_name = strcat('Diff_Bias_SST_POPgrid');
        fig_dum = figure(6);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_Bias(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = '[CESM(flx adj) - Hadley] - [CESM(ctrl) - Hadley], SST (deg C), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([-2, 2])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
  