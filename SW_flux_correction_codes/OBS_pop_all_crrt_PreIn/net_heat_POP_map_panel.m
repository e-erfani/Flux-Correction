    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)

cd /shared/SWFluxCorr/OA_Flux
load('lat_msh_OAFlux.mat')
load('lon_msh_OAFlux.mat')
load('Qnet_average_OA.mat')
Qnet_average = Qnet_average - 28.14 ;
lat_fn_msh = double(lat_msh_OAFlux') ; lon_fn_msh = double(lon_msh_OAFlux') ;

cd /homes/eerfani/Bias/CERES
load('latitude_pop.mat')
load('longitude_pop.mat')
    var_mean_obs_intrp = griddata(lon_fn_msh,lat_fn_msh,Qnet_average,longitude,latitude,'natural');
    var_mean_obs = Qnet_average;

%%%%
cd (address)
    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
    TAREA = ncread(filename1,'TAREA'); 
    SW_N  = ncread(filename1,'SHF_QSW');
    LW_N  = - ncread(filename1,'LWUP_F') - ncread(filename1,'LWDN_F') ;    
    SH    = - ncread(filename1,'SENH_F');
    LH    = - ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
    var_mean = SW_N - LW_N - SH - LH ;

TAREA2 = TAREA ;
II = find(isnan(var_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(var_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

 TAREA3 = TAREA ;
JJ = find(isnan(var_mean_obs_intrp) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_rmse_glb = sqrt(nansum(nansum((var_mean - var_mean_obs_intrp) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb = nansum(nansum((var_mean - var_mean_obs_intrp) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
obs_glb = nansum(nansum(var_mean_obs_intrp .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
clear SW_N LW_N SH LH
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
    SW_N  = ncread(filename1,'SHF_QSW');
    LW_N  = - ncread(filename1,'LWUP_F') - ncread(filename1,'LWDN_F') ;    
    SH    = - ncread(filename1,'SENH_F');
    LH    = - ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
    var_mean_ctrl = SW_N - LW_N - SH - LH ;

TAREA2 = TAREA ;
II = find(isnan(var_mean_ctrl) == 1) ;
TAREA2(II) = NaN;

var_glb_diff = nansum(nansum((var_mean-var_mean_ctrl) .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

var_glb_ctrl = nansum(nansum(var_mean_ctrl .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

var_rmse_glb_ctrl = sqrt(nansum(nansum((var_mean_ctrl - var_mean_obs_intrp) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))

%%%%%%

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lon_c_m, lat_c_m] = meshgrid(lon_c, lat_c);

 var_mean_interp_obs_c  = griddata(lon_fn_msh,lat_fn_msh,var_mean_obs,lon_c_m,lat_c_m,'natural');
 var_mean_interp_c      = griddata(longitude,latitude,var_mean,lon_c_m,lat_c_m,'natural');
 var_mean_ctrl_interp_c = griddata(longitude,latitude,var_mean_ctrl,lon_c_m,lat_c_m,'natural');

 ratio = abs(var_mean_interp_c - var_mean_interp_obs_c) ./ abs(var_mean_ctrl_interp_c - var_mean_interp_obs_c) ;
 
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
clear SW_N_all SW_N SW_N_all_ctrl SW_N LW_N SH LH
address2 = '/shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn' ;
cd (address2)
    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
 TAREA=ncread(filename1,'TAREA'); 
 latitude2=ncread(filename1,'TLAT'); 
 longitude2=ncread(filename1,'TLONG'); 

 var_mean_obs_ntrp2 = griddata(lon_fn_msh,lat_fn_msh,var_mean_obs,longitude2,latitude2,'natural');

    SW_N  = ncread(filename1,'SHF_QSW');
    LW_N  = - ncread(filename1,'LWUP_F') - ncread(filename1,'LWDN_F') ;    
    SH    = - ncread(filename1,'SENH_F');
    LH    = - ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
    var_mean = SW_N - LW_N - SH - LH ;
 
TAREA2 = TAREA ;
II = find(isnan(var_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(var_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

 TAREA3 = TAREA ;
JJ = find(isnan(var_mean_obs_ntrp2) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_rmse_glb = sqrt(nansum(nansum((var_mean - var_mean_obs_ntrp2) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb = nansum(nansum((var_mean - var_mean_obs_ntrp2) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
obs_glb = nansum(nansum(var_mean_obs_ntrp2 .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
clear SW_N LW_N SH LH
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
    SW_N  = ncread(filename1,'SHF_QSW');
    LW_N  = - ncread(filename1,'LWUP_F') - ncread(filename1,'LWDN_F') ;    
    SH    = - ncread(filename1,'SENH_F');
    LH    = - ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
    var_mean_ctrl = SW_N - LW_N - SH - LH ;

TAREA2 = TAREA ;
II = find(isnan(var_mean_ctrl) == 1) ;
TAREA2(II) = NaN;

var_glb_diff = nansum(nansum((var_mean-var_mean_ctrl) .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

var_glb_ctrl = nansum(nansum(var_mean_ctrl .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

var_rmse_glb_ctrl = sqrt(nansum(nansum((var_mean_ctrl - var_mean_obs_ntrp2) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
           
%%%%%%

bb = dir('*.cam.h0.*_01_climo.nc');
fname = bb(1,1).name;
lat_c2 = ncread(fname,'lat');
lon_c2 = ncread(fname,'lon');
[lon_c_m2, lat_c_m2] = meshgrid(lon_c2, lat_c2);

 var_mean_interp_obs_c2  = griddata(lon_fn_msh,lat_fn_msh,var_mean_obs,lon_c_m2,lat_c_m2,'natural');
 var_mean_interp_c2      = griddata(longitude2,latitude2, var_mean, lon_c_m2,lat_c_m2,'natural');
 var_mean_ctrl_interp_c2 = griddata(longitude2,latitude2,var_mean_ctrl,lon_c_m2,lat_c_m2,'natural');

 ratio2 = abs(var_mean_interp_c2 - var_mean_interp_obs_c2) ./ abs(var_mean_ctrl_interp_c2 - var_mean_interp_obs_c2) ;

%%%%%
 cd (address)
      fig_name = strcat('net_heat_bias_POP_panel');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,14,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.00 .01],[.01 .01],[.05 .06]) ;           
      
axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean_ctrl_interp_c - var_mean_interp_obs_c),50);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'ctrl-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(50,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-50, 50])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean_ctrl_interp_c2 - var_mean_interp_obs_c2),50);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'ctrl-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(50,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-50, 50])

axes(ha(3))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean_interp_c - var_mean_interp_obs_c),50);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(50,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-50, 50])
    
axes(ha(4))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean_interp_c2 - var_mean_interp_obs_c2),50);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(50,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-50, 50])    
    
    
h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(h, 'ylim', [-50 50])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)


%%%%%%%%%%%%%%%%
      fig_name = strcat('net_heat_diff_POP_panel');
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,13.5,4]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
[ha, pos] = tight_subplot(1,2,[.00 .01],[.01 .01],[.05 .06]) ;

axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean_interp_c - var_mean_ctrl_interp_c),60);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(60,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-20, 20])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean_interp_c2 - var_mean_ctrl_interp_c2),40);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(40,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-20, 20])

h = colorbar('location','Manual', 'position', [0.95 0.109 0.013 0.785]);
set(h, 'ylim', [-20 20])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)

%%%%%
      fig_name = strcat('ratio_bias_NHF_map_panel');
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,13.5,4]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
[ha, pos] = tight_subplot(1,2,[.00 .01],[.01 .01],[.05 .06]) ;
   cint = [0.05 0.06667 0.1 0.1333 0.2 0.2857 0.5 0.66667 1 1.5 2 3.5 5 7.5 10 15 20];
   color_num = 2 .* (length(cint)) ;
axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, log(ratio), color_num);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = '(GC-T31 bias) / (ctrl-T31 bias)';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(color_num,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([log(cint(1)), log(cint(end))])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, log(ratio2), color_num);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = '(GC-f19 bias) / (ctrl-f19 bias)';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(color_num,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([log(cint(1)), log(cint(end))])

  hc = colorbar('location','Manual', 'position', [0.95 0.109 0.013 0.785]);
  c_thick = cint(1:2:end);
  set(hc,'YTick',log(c_thick),'YTickLabel',c_thick);
  set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)
