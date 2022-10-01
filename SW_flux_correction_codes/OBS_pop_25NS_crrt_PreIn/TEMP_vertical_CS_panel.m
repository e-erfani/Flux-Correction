    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_25NS_crrt_PreIn' ;

%%%%%%
cd /shared/SWFluxCorr/WOA13
fname_obs = 'woa13_5564_t00_01v2.nc' ;
T = ncread(fname_obs,'t_an') ;
lon = ncread(fname_obs,'lon') ;
lat = ncread(fname_obs,'lat') ;
depth = ncread(fname_obs,'depth') ;
T_zonal = permute(nanmean(T,1),[2,3,1]) ;
[lat_msh, depth_msh] = meshgrid(double(lat), double(depth)) ;

%%%%
cd (address)
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    longitude = ncread(filename1,'TLONG'); % lon
    latitude = ncread(filename1,'TLAT'); % lat
    lat_zonal = permute(nanmean(latitude,1),[2 3 1]);    
    z_t = ncread(filename1,'z_t') ./ 100; % lev
    [z_t_msh, latitude_msh] = meshgrid(double(z_t), double(lat_zonal));
    T_ocn = ncread(filename1,'TEMP');
    T_ocn(T_ocn > 1E4) = NaN ;
    T_ocn_zonal_TC = permute(nanmean(T_ocn,1),[2 3 1]) ;

Tocn_zonal_obs_intrp = griddata(lat_msh,depth_msh,T_zonal',latitude_msh,z_t_msh);
T_ocn_zonal_TC_intrp = griddata(latitude_msh,z_t_msh,T_ocn_zonal_TC,lat_msh,depth_msh);

%%%%%
cd /shared/SWFluxCorr/CESM/OBS_pop_35-90NS_crrt_PreIn
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    T_ocn_EC = ncread(filename1,'TEMP');
    T_ocn_EC(T_ocn_EC > 1E4) = NaN ;
    T_ocn_zonal_EC = permute(nanmean(T_ocn_EC,1),[2 3 1]) ;
    
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
address2 = '/shared/SWFluxCorr/high_res/OBS_pop_25NS_crrt_PreIn' ;
cd (address2)
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    longitude2 = ncread(filename1,'TLONG'); % lon
    latitude2 = ncread(filename1,'TLAT'); % lat
    lat_zonal2 = permute(nanmean(latitude2,1),[2 3 1]);    
    z_t2 = ncread(filename1,'z_t') ./ 100; % lev
    [z_t_msh2, latitude_msh2] = meshgrid(double(z_t2), double(lat_zonal2));
    T_ocn_TC_HR = ncread(filename1,'TEMP');
    T_ocn_TC_HR(T_ocn_TC_HR > 1E4) = NaN ;
    T_ocn_zonal_TC_HR = permute(nanmean(T_ocn_TC_HR,1),[2 3 1]) ;

Tocn_zonal_obs_intrp2  = griddata(lat_msh,depth_msh,T_zonal',latitude_msh2,z_t_msh2);
T_ocn_TC_HR_zonal_intrp = griddata(latitude_msh2,z_t_msh2,T_ocn_zonal_TC_HR,lat_msh,depth_msh);

%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_35-90NS_crrt_PreIn
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    T_ocn_EC_HR = ncread(filename1,'TEMP');
    T_ocn_EC_HR(T_ocn_EC_HR > 1E4) = NaN ;
    T_ocn_zonal_EC_HR = permute(nanmean(T_ocn_EC_HR,1),[2 3 1]) ;

%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    T_ocn_ctrl = ncread(filename1,'TEMP');
    T_ocn_ctrl(T_ocn_ctrl > 1E4) = NaN ;
    T_ocn_zonal_ctrl = permute(nanmean(T_ocn_ctrl,1),[2 3 1]) ;
    
%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16
    aa1=dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    T_ocn_ctrl2 = ncread(filename1,'TEMP');
    T_ocn_ctrl2(T_ocn_ctrl2 > 1E4) = NaN ;
    T_ocn_zonal_ctrl2 = permute(nanmean(T_ocn_ctrl2,1),[2 3 1]) ;

idx = find(lat_zonal > -70 & lat_zonal < 70) ;    
idx2 = find(lat_zonal2 > -70 & lat_zonal2 < 70) ;


%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
 cd (address)
      fig_name = strcat('TEMP_vertical_sensit_diff_panel_NEW');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,11,8]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.06 .01],[.065 .065],[.09 .06]) ;

axes(ha(3))
    contourf(lat_zonal(idx),z_t,T_ocn_zonal_EC(idx,:)' - T_ocn_zonal_ctrl(idx,:)',32,'edgecolor','none');
    hold on
    contour(lat_zonal(idx),z_t,T_ocn_zonal_EC(idx,:)' - T_ocn_zonal_ctrl(idx,:)',[0,0],'k');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'EC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');
    ylim([0 500])
    xlim([-70 70])
    ylabel('Depth (m)','fontsize',15,'fontweight','bold');
    xlabel('latitude','fontsize',15,'fontweight','bold');
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-2 2])

axes(ha(4))
    contourf(lat_zonal2(idx2),z_t2,T_ocn_zonal_EC_HR(idx2,:)' - T_ocn_zonal_ctrl2(idx2,:)',32,'edgecolor','none');
    hold on
    contour(lat_zonal2(idx2),z_t2,T_ocn_zonal_EC_HR(idx2,:)' - T_ocn_zonal_ctrl2(idx2,:)',[0,0],'k');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'EC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');
   set(gca,'yticklabel',[])
   xlabel('latitude','fontsize',15,'fontweight','bold');
    ylim([0 500])
    xlim([-70 70])
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-2 2])

axes(ha(1))
    contourf(lat_zonal(idx),z_t,T_ocn_zonal_TC(idx,:)' - T_ocn_zonal_ctrl(idx,:)',32,'edgecolor','none');
    hold on
    contour(lat_zonal(idx),z_t,T_ocn_zonal_TC(idx,:)' - T_ocn_zonal_ctrl(idx,:)',[0,0],'k');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'TC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');
    ylim([0 500])
    xlim([-70 70])
    set(gca,'xticklabel',[])
    ylabel('Depth (m)','fontsize',15,'fontweight','bold');
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-2 2])

axes(ha(2))
    contourf(lat_zonal2(idx2),z_t2,T_ocn_zonal_TC_HR(idx2,:)' - T_ocn_zonal_ctrl2(idx2,:)',32,'edgecolor','none');
    hold on
    contour(lat_zonal2(idx2),z_t2,T_ocn_zonal_TC_HR(idx2,:)' - T_ocn_zonal_ctrl2(idx2,:)',[0,0],'k');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'TC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');
    ylim([0 500])
    xlim([-70 70])
   set(gca,'xticklabel',[],'yticklabel',[])
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-2 2])

h = colorbar('location','Manual', 'position', [0.95 0.063 0.025 0.88]);
set(h, 'ylim', [-2 2])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)


dbstop

%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%
 cd (address)
      fig_name = strcat('TEMP_vertical_sensit_bias_panel');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,11,8]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.06 .01],[.065 .065],[.09 .06]) ;           
      
axes(ha(3))
    contourf(lat_zonal,z_t,T_ocn_zonal_EC' - Tocn_zonal_obs_intrp',32,'edgecolor','none');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'EC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    ylim([0 500])
    xlim([-70 70])
    ylabel('Depth (m)','fontsize',15,'fontweight','bold');
    xlabel('latitude (\circ)','fontsize',15,'fontweight','bold');    
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-4 4])
  
axes(ha(4))
    contourf(lat_zonal2,z_t2,T_ocn_zonal_EC_HR' - Tocn_zonal_obs_intrp2',32,'edgecolor','none');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'EC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
   set(gca,'yticklabel',[])        
   xlabel('latitude (\circ)','fontsize',15,'fontweight','bold');   
    ylim([0 500])
    xlim([-70 70])
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-4 4])

axes(ha(1))
    contourf(lat_zonal,z_t,T_ocn_zonal_TC' - Tocn_zonal_obs_intrp',32,'edgecolor','none');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'TC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    ylim([0 500])
    xlim([-70 70])
    set(gca,'xticklabel',[])    
    ylabel('Depth (m)','fontsize',15,'fontweight','bold');
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-4 4])
  
axes(ha(2))
    contourf(lat_zonal2,z_t2,T_ocn_zonal_TC_HR' - Tocn_zonal_obs_intrp2',32,'edgecolor','none');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Ydir','reverse')
    Title_1  = 'TC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    ylim([0 500])
    xlim([-70 70])
   set(gca,'xticklabel',[],'yticklabel',[])
    set(gca,'Fontsize',11,'linewidth',1)
    caxis([-4 4])
   
h = colorbar('location','Manual', 'position', [0.95 0.063 0.025 0.88]);
set(h, 'ylim', [-4 4])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)

