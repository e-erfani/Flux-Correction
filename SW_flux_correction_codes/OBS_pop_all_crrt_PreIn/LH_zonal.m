    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;

cd /shared/SWFluxCorr/OA_Flux
load('lat_msh_OAFlux.mat')
load('lon_msh_OAFlux.mat')
load('LH_S_average_OA.mat')
lat_fn_msh = double(lat_msh_OAFlux') ; lon_fn_msh = double(lon_msh_OAFlux') ;
SW_S_N_mo_mean = - LH_S_average_OA ;

%%%%%%
cd (address)
  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  TAREA = ncread(filename1,'TAREA');
  lat_pop = ncread(filename1,'TLAT');
  lon_pop = ncread(filename1,'TLONG');
  var_mean = ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');

SW_mean_intrp = griddata(lon_fn_msh,lat_fn_msh,SW_S_N_mo_mean,lon_pop,lat_pop,'natural');
idx = find(isnan(var_mean) == 1);
SW_mean_intrp(idx) = NaN;
    
%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    var_mean_ctrl = ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
    
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  TAREA = ncread(filename1,'TAREA');
  lat_pop2 = ncread(filename1,'TLAT');
  lon_pop2 = ncread(filename1,'TLONG');
  var_mean2 = ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
var_mean2_intrp  = griddata(lon_pop2,lat_pop2,var_mean2 ,lon_pop,lat_pop,'natural');


SW_mean_intrp2 = griddata(lon_fn_msh,lat_fn_msh,SW_S_N_mo_mean,lon_pop2,lat_pop2,'natural');
idx2 = find(isnan(var_mean2) == 1);
SW_mean_intrp2(idx2) = NaN;

%%%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    var_mean_ctrl2 = ncread(filename1,'latent_heat_vapor') .* ncread(filename1,'EVAP_F');
var_mean_ctrl2_intrp  = griddata(lon_pop2,lat_pop2,var_mean_ctrl2 ,lon_pop,lat_pop,'natural');
   
SW_interp_zon = squeeze(nanmean(SW_mean_intrp,1));
SW_interp_zon2 = squeeze(nanmean(SW_mean_intrp2,1));
var_zonal       = squeeze(nanmean(var_mean,1));
var_zonal_ctrl  = squeeze(nanmean(var_mean_ctrl,1));
var_zonal2      = squeeze(nanmean(var_mean2,1));
var_zonal_ctrl2 = squeeze(nanmean(var_mean_ctrl2,1));
lat_pop_zon     = nanmean(lat_pop,1);
lat_pop_zon2    = nanmean(lat_pop2,1);
SW_obs_zon      = squeeze(nanmean(SW_S_N_mo_mean,1));
lat_obs_zon     = nanmean(lat_fn_msh,1);
var_zonal2_intrp = squeeze(nanmean(var_mean2_intrp,1));
var_zonal_ctrl2_intrp = squeeze(nanmean(var_mean_ctrl2_intrp,1));
%lat_1_zon     = nanmean(lat_1,1);

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%
      fig_name = strcat('LH_zonal_NEW');
      fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
y = lat_pop_zon;
y(:) = 0;
 plot(lat_pop_zon, y, 'k--');
hold on
 h10 = plot(lat_pop_zon,SW_interp_zon,'k','linewidth',2) ;
% h10 = plot(lat_obs_zon,SW_obs_zon,'k','linewidth',2) ;
 
hold on
 h1 = plot(lat_pop_zon,var_zonal_ctrl,'r--','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon,var_zonal,'r','linewidth',2) ;
hold on
%h3 = plot(lat_pop_zon2,var_zonal_ctrl2,'b--','linewidth',2) ;
h3 = plot(lat_pop_zon,var_zonal_ctrl2_intrp,'b--','linewidth',2) ;
hold on
%h4 = plot(lat_pop_zon2,var_zonal2,'b','linewidth',2) ;
h4 = plot(lat_pop_zon,var_zonal2_intrp,'b','linewidth',2) ;

    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('LHF (Wm^-^2)','fontsize',20,'fontweight','bold');
xlim([-74 74])
%ylim([-4.5 1.7])
   hleg1 = legend([h1 h2 h3 h4 h10],'ctrl-T31','GC-T31','ctrl-f19','GC-f19','obs');
    set(hleg1,'Location','SouthWest','Fontsize',14)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
%print ('-depsc','-tiff','-r600','-painters', fig_name)
print ('-dpdf','-r600','-painters', fig_name)


%%%%%%%%%%%%%%
      fig_name = strcat('LH_bias_zonal');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
y = lat_pop_zon;
y(:) = 0;
 plot(lat_pop_zon, y, 'k--');
hold on
 h1 = plot(lat_pop_zon,var_zonal_ctrl - SW_interp_zon,'r--','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon,var_zonal - SW_interp_zon,'r','linewidth',2) ;
hold on
%h3 = plot(lat_pop_zon2,var_zonal_ctrl2 - SW_interp_zon2,'b--','linewidth',2) ;
h3 = plot(lat_pop_zon,var_zonal_ctrl2_intrp - SW_interp_zon,'b--','linewidth',2) ;
hold on
%h4 = plot(lat_pop_zon2,var_zonal2 - SW_interp_zon2,'b','linewidth',2) i;
h4 = plot(lat_pop_zon,var_zonal2_intrp - SW_interp_zon,'b','linewidth',2) ;

    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('LHF bias (Wm^-^2)','fontsize',20,'fontweight','bold');
xlim([-74 74])
ylim([-30 30])
   hleg1 = legend([h1 h2 h3 h4],'ctrl-T31 - obs','GC-T31 - obs','ctrl-f19 - obs','GC-f19 - obs');
    set(hleg1,'Location','NorthWest','Fontsize',14)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-dpdf','-r600','-painters', fig_name)


dbstop

%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
      fig_name = strcat('LW_anomaly_zonal');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_pop_zon, var_zonal - var_zonal_ctrl,'r','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon2, var_zonal2 - var_zonal_ctrl2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Net LW anomaly (Wm^-^2)','fontsize',20,'fontweight','bold');
xlim([-75 75])
%ylim([-2.5 3.1])
   hleg1 = legend([h1 h2],'GC-T31 - ctrl-T31','GC-f19 - ctrl-f19');
    set(hleg1,'Location','NorthEast','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

