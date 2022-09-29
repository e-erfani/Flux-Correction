    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;

%%%%
cd /shared/SWFluxCorr/GPCP
aa = dir('GPCP_ANN_climo.nc');
filename = aa(1,1).name;
lat_obs = double(ncread(filename,'lat'));
lon_obs = double(ncread(filename,'lon'));
[lat_obs_m, lon_obs_m] = meshgrid(lat_obs, lon_obs);

var_obs = ncread(filename,'PRECT');
var_obs_zon = nanmean(var_obs,1);
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
precc = ncread(fname,'PRECC');
precl = ncread(fname,'PRECL');
var_mean =  (precc + precl) .* 1000 .* 60 .* 60 .* 24 ;
var_zonal = squeeze(nanmean(var_mean,1));

var_obs_interp = griddata(lon_obs_m,lat_obs_m,var_obs,lon_c_m,lat_c_m,'natural');
var_obs_zon_interp = nanmean(var_obs_interp,1);
%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
precc = ncread(fname,'PRECC');
precl = ncread(fname,'PRECL');
var_mean_ctrl =  (precc + precl) .* 1000 .* 60 .* 60 .* 24 ;
var_zonal_ctrl = squeeze(nanmean(var_mean_ctrl,1));

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
precc = ncread(fname,'PRECC');
precl = ncread(fname,'PRECL');
var_mean2 =  (precc + precl) .* 1000 .* 60 .* 60 .* 24 ;
var_zonal2 = squeeze(nanmean(var_mean2,1));

%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

bb = dir('*.cam.h0.*_climo.nc');
for i = 1:length(bb)
    fname = bb(i,1).name;
    precc = ncread(fname,'PRECC');
    precl = ncread(fname,'PRECL');
    var_mean_ctrl2_all(:,:,i) =  (precc + precl) .* 1000 .* 60 .* 60 .* 24 ;
end

var_mean_ctrl2  = nanmean(var_mean_ctrl2_all,3) ;
var_zonal_ctrl2 = squeeze(nanmean(var_mean_ctrl2,1));

var_obs_interp2 = griddata(lon_obs_m,lat_obs_m,var_obs,lon_c_m2,lat_c_m2,'natural');
var_obs_zon_interp2 = nanmean(var_obs_interp2,1);

%%%%%%%%%%%%%%
      fig_name = strcat('precip_zonal_anomaly_NEW');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_c_m(1,:),var_zonal - var_zonal_ctrl,'r','linewidth',2) ;
hold on
h2 = plot(lat_c_m2(1,:),var_zonal2 - var_zonal_ctrl2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Precipitation anomaly (mm day^-^1)','fontsize',20,'fontweight','bold');
xlim([-90 90])
ylim([-1.5 2])
   hleg1 = legend([h1 h2],'GC-T31 - ctrl-T31','GC-f19 - ctrl-f19');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

%%%%%%%%%%%%%%
      fig_name = strcat('precip_zonal_NEW');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h10 = plot(lat_obs,var_obs_zon,'k','linewidth',2) ;
hold on
h1 = plot(lat_c_m(1,:),var_zonal_ctrl,'r--','linewidth',2) ;
hold on
h2 = plot(lat_c_m(1,:),var_zonal,'r','linewidth',2) ;
hold on
h3 = plot(lat_c_m2(1,:),var_zonal_ctrl2,'b--','linewidth',2) ;
hold on
h4 = plot(lat_c_m2(1,:),var_zonal2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Precipitation (mm day^-^1)','fontsize',20,'fontweight','bold');
xlim([-90 90])
ylim([0 7])
   hleg1 = legend([h1 h2 h3 h4 h10],'ctrl-T31','GC-T31','ctrl-f19','GC-f19','obs.');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

%%%%%%%%%%%%%%
      fig_name = strcat('precip_zonal_bias_NEW');
      fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
y = lat_c_m;
y(:) = 0;
 plot(lat_c_m(1,:), y, 'k--','linewidth',1);
hold on 
h1 = plot(lat_c_m(1,:),var_zonal_ctrl - var_obs_zon_interp,'r--','linewidth',2) ;
hold on
h2 = plot(lat_c_m(1,:),var_zonal - var_obs_zon_interp,'r','linewidth',2) ;
hold on
h3 = plot(lat_c_m2(1,:),var_zonal_ctrl2 - var_obs_zon_interp2,'b--','linewidth',2) ;
hold on
h4 = plot(lat_c_m2(1,:),var_zonal2 - var_obs_zon_interp2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Precipitation bias (mm day^-^1)','fontsize',20,'fontweight','bold');
xlim([-90 90])
ylim([-1.5 3])
   hleg1 = legend([h1 h2 h3 h4],'ctrl-T31','GC-T31','ctrl-f19','GC-f19');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

