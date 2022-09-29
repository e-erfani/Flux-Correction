    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;

%%%%
cd /homes/eerfani/Bias/CERES
load('lat_fine.mat')
load('lon_fine.mat')
load('latitude_pop.mat')
load('longitude_pop.mat')

load ('SW_T_mo_mean')
load('SW_T_u_mo_mean2')
load('SW_T_d_mo_mean2')
load ('LW_T_u_mo_mean')
var_obs = nanmean(SW_T_d_mo_mean - SW_T_u_mo_mean - LW_T_u_mo_mean,3) ;
[lat_obs_m,lon_obs_m] = meshgrid(lat_fine,lon_fine);


%%%%
cd (address)
bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lat_c_m, lon_c_m] = meshgrid(lat_c, lon_c);
gw = ncread(fname,'gw');
I = length(lon_c);
TAREA = repmat(gw,[1 I])';

fsnt =ncread(fname,'FSNT');
flnt =ncread(fname,'FLNT');
var_mean = fsnt - flnt ;

var_obs_interp = griddata(lon_obs_m,lat_obs_m,var_obs,lon_c_m,lat_c_m,'natural');

TAREA2 = TAREA ;
II = find(isnan(var_mean) == 1) ;
TAREA2(II) = NaN;

obs_glb = nansum(nansum(var_obs_interp .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

var_glb = nansum(nansum(var_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
%var_bias = nansum(nansum((var_mean - var_obs_interp) .* TAREA2)) ./ nansum(nansum(TAREA2))
%var_RMSE = sqrt (nansum(nansum((var_mean - var_obs_interp) .^ 2 .* TAREA2)) ./ nansum(nansum(TAREA2)) )
%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
fsnt =ncread(fname,'FSNT');
flnt =ncread(fname,'FLNT');
var_mean_ctrl = fsnt - flnt ;

TAREA2 = TAREA ;
II = find(isnan(var_mean_ctrl) == 1) ;
TAREA2(II) = NaN;

var_glb_ctrl = nansum(nansum(var_mean_ctrl .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
address2 = '/shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn' ;
cd (address2)

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lat_c_m2, lon_c_m2] = meshgrid(lat_c, lon_c);
gw = ncread(fname,'gw');
I = length(lon_c);
TAREA_2 = repmat(gw,[1 I])';
fsnt =ncread(fname,'FSNT');
flnt =ncread(fname,'FLNT');
var_mean2 = fsnt - flnt ;

TAREA2_2 = TAREA_2 ;
II = find(isnan(var_mean2) == 1) ;
TAREA2_2(II) = NaN;

var_glb2 = nansum(nansum(var_mean2 .* TAREA2_2 ,1),2) ./ nansum(nansum(TAREA2_2 ,1),2)


%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

bb = dir('*.cam.h0.*_climo.nc');
for i = 1:length(bb)
    fname = bb(i,1).name;
    fsnt =ncread(fname,'FSNT');
    flnt =ncread(fname,'FLNT');
    varr(:,:,i) = fsnt - flnt;
end

var_mean_ctrl2 = nanmean(varr,3) ;

TAREA2_2 = TAREA_2 ;
II = find(isnan(var_mean_ctrl2) == 1) ;
TAREA2_2(II) = NaN;

var_glb2_ctrl = nansum(nansum(var_mean_ctrl2 .* TAREA2_2 ,1),2) ./ nansum(nansum(TAREA2_2 ,1),2)

 cd (address)


dbstop



%%%%%%%%%%%%%%%%
 cd (address)
      fig_name = strcat('precip_bias_panel');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,14,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.00 .01],[.01 .01],[.05 .06]) ;           
      
axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean_ctrl - var_obs_interp),30);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'ctrl-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-6, 6])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean_ctrl2 - var_obs_interp2),30);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'ctrl-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-6, 6])

axes(ha(3))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean - var_obs_interp),30);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-6, 6])
    
axes(ha(4))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean2 - var_obs_interp2),30);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-6, 6])    
    
    
h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(h, 'ylim', [-6 6])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)

%%%%%
      fig_name = strcat('precip_diff_panel');
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,13.5,4]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
[ha, pos] = tight_subplot(1,2,[.00 .01],[.01 .01],[.05 .06]) ;

axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean - var_mean_ctrl),12);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(12,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-6, 6])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(var_mean2 - var_mean_ctrl2),36);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(36,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-6, 6])

h = colorbar('location','Manual', 'position', [0.95 0.109 0.013 0.785]);
set(h, 'ylim', [-6 6])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)
