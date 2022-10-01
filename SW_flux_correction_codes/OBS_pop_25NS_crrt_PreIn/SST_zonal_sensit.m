    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_25NS_crrt_PreIn' ;
%%%%
cd /homes/eerfani/Bias
load ('SST_Hadley.mat')
load('lat_HadI') ; load('lon_HadI')
lon_HadI = double(lon_HadI); lat_HadI = double(lat_HadI);
%%%%
cd (address)

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  TAREA = ncread(filename1,'TAREA');
  lat_pop = ncread(filename1,'TLAT');
  lon_pop = ncread(filename1,'TLONG');

  SST_mean_interp_HADI = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop,lat_pop,'natural');

  sst = ncread(filename1,'TEMP');
  var_mean_TC_LR = sst(:,:,1) ;
    
%%%%%%
cd /shared/SWFluxCorr/CESM/OBS_pop_35-90NS_crrt_PreIn
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    sst = ncread(filename1,'TEMP');
    var_mean_EC_LR = sst(:,:,1) ;
    
%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    sst = ncread(filename1,'TEMP');
    var_mean_ctrl = sst(:,:,1) ;    
    
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_25NS_crrt_PreIn

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  TAREA = ncread(filename1,'TAREA');
  lat_pop2 = ncread(filename1,'TLAT');
  lon_pop2 = ncread(filename1,'TLONG');

  SST_mean_interp_HADI_HR = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop2,lat_pop2,'natural');

  sst = ncread(filename1,'TEMP');
  var_mean_TC_HR = sst(:,:,1) ;
    
%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_35-90NS_crrt_PreIn

    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    sst = ncread(filename1,'TEMP');
    var_mean_EC_HR = sst(:,:,1) ;
    
%%%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    sst = ncread(filename1,'TEMP');
    var_mean_ctrl_HR = sst(:,:,1) ;
    
%%%%%%    
SST_interp_HADI_zon    = squeeze(nanmean(SST_mean_interp_HADI,1));
SST_interp_HADI_zon_HR = squeeze(nanmean(SST_mean_interp_HADI_HR,1));
var_zonal_ctrl         = squeeze(nanmean(var_mean_ctrl,1));
var_zonal_TC_LR        = squeeze(nanmean(var_mean_TC_LR,1));
var_zonal_EC_LR        = squeeze(nanmean(var_mean_EC_LR,1));
var_zonal_ctrl_HR      = squeeze(nanmean(var_mean_ctrl_HR,1));
var_zonal_TC_HR        = squeeze(nanmean(var_mean_TC_HR,1));
var_zonal_EC_HR        = squeeze(nanmean(var_mean_EC_HR,1));
lat_pop_zon            = nanmean(lat_pop,1);
lat_pop_zon2           = nanmean(lat_pop2,1);

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
      fig_name = strcat('SST_bias_zonal_sensit_NEW');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
y = lat_pop_zon;
y(:) = 0;
 plot(lat_pop_zon, y, 'k--');
hold on 
 h1 = plot(lat_pop_zon,var_zonal_ctrl - SST_interp_HADI_zon,'r--','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon,var_zonal_TC_LR - SST_interp_HADI_zon,'r','linewidth',2) ;
hold on
h3 = plot(lat_pop_zon,var_zonal_EC_LR - SST_interp_HADI_zon,'m','linewidth',2) ;
hold on
h4 = plot(lat_pop_zon2,var_zonal_ctrl_HR - SST_interp_HADI_zon_HR,'b--','linewidth',2) ;
hold on
h5 = plot(lat_pop_zon2,var_zonal_TC_HR - SST_interp_HADI_zon_HR,'b','linewidth',2) ;
hold on
h6 = plot(lat_pop_zon2,var_zonal_EC_HR - SST_interp_HADI_zon_HR,'c','linewidth',2) ;
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('SST bias (\circC)','fontsize',20,'fontweight','bold');
xlim([-74 74])
ylim([-4.5 2.2])
hleg1 = legend([h1 h2 h3 h4 h5 h6],'ctrl-T31 - obs','TC-T31 - obs','EC-T31 - obs',...
       'ctrl-f19 - obs','TC-f19 - obs','EC-f19 - obs');
    set(hleg1,'Location','SouthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

% %%%%%%%%%%%%%%
%       fig_name = strcat('SST_anomaly_zonal_sensit');
%       fig_dum = figure(1);
%       set(fig_dum, 'name', fig_name,'numbertitle','on');
%       set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
%       set(fig_dum,'paperpositionmode','auto');
% h1 = plot(lat_pop_zon, var_zonal_TC_LR - var_zonal_ctrl,'r','linewidth',2) ;
% hold on
% h2 = plot(lat_pop_zon2, var_zonal_TC_HR - var_zonal_ctrl_HR,'b','linewidth',2) ;
% hold on
%     xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
%     ylabel('SST anomaly (\circC)','fontsize',20,'fontweight','bold');
% xlim([-80 80])
% %ylim([-2.5 3.1])
%    hleg1 = legend([h1 h2],'GC-T31 - ctrl-T31','GC-f19 - ctrl-f19');
%     set(hleg1,'Location','NorthEast','Fontsize',16)
%     set(hleg1,'Interpreter','none')
% set(gca,'Fontsize',16,'linewidth',1.5)
% box on
% set(gcf,'color','w');
% set(gcf, 'PaperPositionMode', 'auto')
% set(gcf,'renderer','Painters')
% cd (address)
% print ('-depsc','-tiff','-r600','-painters', fig_name)
