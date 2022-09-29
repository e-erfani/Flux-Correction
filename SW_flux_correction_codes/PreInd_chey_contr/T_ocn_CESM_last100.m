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
 
 %%%%
        fig_name = strcat('cross_Tocn_CESM');%,num2str(tt));
        fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_zonal,z_t,T_ocn_adj_zonal',40,'edgecolor','none');
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

[z_t_msh,latitude_msh] = meshgrid(double(z_t),double(lat_zonal));
[depth_msh,lat_msh] = meshgrid(double(depth),double(lat));

Tocn_zonal_obs_intrp = griddata(lat_msh,depth_msh,T_zonal,latitude_msh,z_t_msh);
T_ocn_adj_zonal_intrp = griddata(latitude_msh,z_t_msh,T_ocn_adj_zonal,lat_msh,depth_msh);

  %%%%
        fig_name = strcat('bias_cross_Tocn');%,num2str(tt));
        fig_dum = figure(20);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_zonal,z_t,T_ocn_adj_zonal' - Tocn_zonal_obs_intrp',40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([-4.99 4.99])
  cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   

  %%%%
        fig_name = strcat('bias_cross_Tocn_WOAgrid');%,num2str(tt));
        fig_dum = figure(200);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat,depth,T_ocn_adj_zonal_intrp' - T_zonal',40,'edgecolor','none');
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
        fig_name = strcat('bias_cross_Tocn_WOAgrid_whole_ocn');%,num2str(tt));
        fig_dum = figure(201);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat,depth,T_ocn_adj_zonal_intrp' - T_zonal',40,'edgecolor','none');
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
dbstop  
%%%%% 

lon_zonal = nanmean(longitude,2);
[z_t_msh,latitude_msh,longitude_msh] = meshgrid(double(z_t),double(lat_zonal),double(lon_zonal));
[depth_msh,lat_msh,lon_msh] = meshgrid(double(depth),double(lat),double(lon));

Tocn_obs_intrp = griddata(lon_msh,lat_msh,depth_msh,T,...
    longitude_msh,latitude_msh,z_t_msh,'natural');
% T_ocn_adj_zonal_intrp = griddata(longitude_msh,latitude_msh,z_t_msh,...
%     T_ocn_adj,lon_mch,lat_msh,depth_msh);
 T_ocn_adj_zonal_intrp = griddata(longitude_msh,latitude_msh,z_t_msh,...
    T_ocn_adj,lon_msh,lat_msh,depth_msh);
 
 T_ocn_rmse =  sqrt(nansum((T_ocn_adj - permute(Tocn_obs_intrp,[3 1 2])) .^ 2,1) ./ 100);
 T_ocn_rmse_WOAgrid =  sqrt(nansum((permute(T_ocn_adj_zonal_intrp,[3 1 2]) - T ) .^ 2,1) ./ 360);

         fig_name = strcat('RMSE_cross_Tocn');%,num2str(tt));
        fig_dum = figure(37);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat_zonal,z_t,permute(T_ocn_rmse,[3 2 1]),40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([0 4.99])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   

%%%%%
         fig_name = strcat('RMSE_cross_Tocn_WOAgrid');%,num2str(tt));
        fig_dum = figure(38);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
contourf(lat,depth,permute(T_ocn_rmse_WOAgrid,[3 2 1]),40,'edgecolor','none');
set(gca,'Ydir','reverse')
ylim([0 500])
xlim([-70 70])
cc = colorbar('peer',gca);
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Depth (m)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
  box on
  caxis([0 7])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   

 