    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h*.anmn.nc');


    tt=1; % ncdisp(aa(tt,1).name)    
nn = 0 ;
for tt=400:500%length(aa) - 100 + 1:length(aa)
    nn = nn + 1 ;
    filename=aa(tt,1).name;
    T_ocn=ncread(filename,'TEMP'); % surface net Shortwave Radiation (W/m2)
    T_ocn(T_ocn > 1E4) = NaN ;   
    T_ocn_adj_all(:,:,:,nn) = T_ocn ;    
end
T_ocn_adj = nanmean(T_ocn_adj_all,4) ; 
     latitude=ncread(filename,'TLAT'); % lat
    longitude=ncread(filename,'TLONG'); % lon
    z_t=ncread(filename,'z_t') ./ 100; % lon
 save T_ocn_adj
 T_ocn_adj_zonal = permute(nanmean(T_ocn_adj,1),[2 3 1]) ; 
 lat_zonal = permute(nanmean(latitude,1),[2 1]);
 
 lon_meridional = permute(nanmean(longitude,2),[1 2]);
 jj = find(lon_meridional >= 190 & lon_meridional <= 270) ;
lat_mdl_trm = latitude(jj,:) ;
lat_mdl_zonal_trm = permute(nanmean(lat_mdl_trm,1),[2 1]);
T_ocn_adj_trm = T_ocn_adj(jj,:,:);
T_ocn_adj_trm_zonal = permute(nanmean(T_ocn_adj_trm,1),[2,3,1]) ;

 %%%%
        fig_name = strcat('cross_Tocn_CESM_Pacific');%,num2str(tt));
        fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_mdl_zonal_trm,z_t,T_ocn_adj_trm_zonal',40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-2 28])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']); 
 
%%%%%%%%%%%%
cd /shared/SWFluxCorr/WOA13
fname_obs = 'woa13_5564_t00_01v2.nc' ;
T = ncread(fname_obs,'t_an') ;
lon = ncread(fname_obs,'lon') ;
lat = ncread(fname_obs,'lat') ;
depth = ncread(fname_obs,'depth') ;
T_zonal = permute(nanmean(T,1),[2,3,1]) ;

ii = find(lon >= -170 & lon <= -90) ;
lon_trm = lon(ii) ;
T_trm = T(ii,:,:);
T_trm_zonal = permute(nanmean(T_trm,1),[2,3,1]) ;

[z_t_msh,latitude_msh] = meshgrid(double(z_t),double(lat_mdl_zonal_trm));
[depth_msh,lat_msh] = meshgrid(double(depth),double(lat));

Tocn_trm_zonal_obs_intrp = griddata(lat_msh,depth_msh,T_trm_zonal,latitude_msh,z_t_msh);
Tocn_trm_zonal_mdl_intrp = griddata(latitude_msh,z_t_msh,T_ocn_adj_trm_zonal,lat_msh,depth_msh);

%%%%
        fig_name = strcat('cross_Tocn_WOA13_Pacific');%,num2str(tt));
        fig_dum = figure(13);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat,depth,T_trm_zonal',40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-60 60])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-2 28])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   

  %%%%
          fig_name = strcat('cross_Tocn_WOA13_Pacific_intrp');%,num2str(tt));
        fig_dum = figure(14);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_mdl_zonal_trm,z_t,Tocn_trm_zonal_obs_intrp',40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-60 60])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-2 28])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   

 %%%%
        fig_name = strcat('bias_cross_Tocn_CESM_Pacific');%,num2str(tt));
        fig_dum = figure(117);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_mdl_zonal_trm,z_t,T_ocn_adj_trm_zonal' - Tocn_trm_zonal_obs_intrp',40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-4.99 4.99])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']); 
  
  %%%%
          fig_name = strcat('bias_cross_Tocn_CESM_Pacific_WOAgrid');%,num2str(tt));
        fig_dum = figure(118);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_mdl_zonal_trm,z_t,T_ocn_adj_trm_zonal' - Tocn_trm_zonal_obs_intrp',40,'edgecolor','none');
contourf(lat,depth,Tocn_trm_zonal_mdl_intrp' - T_trm_zonal',40,'edgecolor','none');

set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-4.99 4.99])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']); 

   %%%%
        fig_name = strcat('bias_cross_Tocn_CESM_Pacific_whole_ocn');%,num2str(tt));
        fig_dum = figure(120);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_mdl_zonal_trm,z_t,T_ocn_adj_trm_zonal' - Tocn_trm_zonal_obs_intrp',40,'edgecolor','none');
set(gca,'Ydir','reverse')
%ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-4.99 4.99])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']); 
