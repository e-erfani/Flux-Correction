    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')
purple = [.61 .51 .74] ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)

%%%% OA Flux
cd /shared/SWFluxCorr/OA_Flux
load('lat_msh_OAFlux.mat')
load('lon_msh_OAFlux.mat')
load('Qnet_average_OA.mat')
Qnet_average = Qnet_average ;%  - 28.14 ;
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
    var_mean  = ncread(filename1,'SHF');

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

obs_glb = nansum(nansum(var_mean_obs_intrp .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)
var_mean_obs_intrp = var_mean_obs_intrp - obs_glb ;

var_zonal = squeeze(var_mean(:,1,1));
var_zonal_OA = squeeze(var_mean_obs_intrp(:,1,1));
lat_zonal = squeeze(var_mean_obs_intrp(:,1,1));

%var_zonal    = squeeze(nanmean(var_mean,1));
%var_zonal_OA = squeeze(nanmean(var_mean_obs_intrp,1));
var_zonal    = squeeze(nansum(var_mean .* TAREA2,1) ./ nansum(TAREA2,1) ) ;
var_zonal_OA = squeeze(nansum(var_mean_obs_intrp .* TAREA3,1) ./ nansum(TAREA3,1) ) ;

lat_zonal    = squeeze(nanmean(latitude,1));


%%%%%%%%%% SODA3
cd /shared/SWFluxCorr/SODA3_NHF/
fname = 'SODA3_net_hf_07-14_0.5x0.5.nc' ;
lon_SODA = ncread(fname,'lon');
lat_SODA = ncread(fname,'lat');
Qnet_average = ncread(fname,'hflx');
var_mean_obs = Qnet_average;
lat_SODA = double(lat_SODA) ; lon_SODA = double(lon_SODA) ;
[lat_fn_msh,lon_fn_msh] = meshgrid(lat_SODA, lon_SODA) ;
var_mean_obs_intrp = griddata(lon_fn_msh,lat_fn_msh,Qnet_average,longitude,latitude,'natural');

obs_glb = nansum(nansum(var_mean_obs_intrp .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)
var_mean_obs_intrp = var_mean_obs_intrp - obs_glb ;

var_zonal_SODA = squeeze(nanmean(var_mean_obs_intrp,1));

var_zonal_SODA2 = squeeze(nanmean(Qnet_average,1)) - 2.1332 ;
lat_zonal_SODA  = squeeze(nanmean(lat_fn_msh,1));

%%%%%
clear SW_N LW_N SH LH
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
    var_mean_ctrl  = ncread(filename1,'SHF');    

%var_zonal_ctrl = squeeze(nanmean(var_mean_ctrl,1));
var_zonal_ctrl  = squeeze(nansum(var_mean_ctrl .* TAREA2,1) ./ nansum(TAREA2,1) ) ;

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

 var_mean_obs_intrp2 = griddata(lon_fn_msh,lat_fn_msh,var_mean_obs,longitude2,latitude2,'natural');

 var_mean  = ncread(filename1,'SHF');
 var_mean_intrp = griddata(longitude2,latitude2,var_mean,longitude,latitude,'natural');
TAREA2 = TAREA ;
II = find(isnan(var_mean) == 1) ;
TAREA2(II) = NaN;

 TAREA3 = TAREA ;
JJ = find(isnan(var_mean_obs_intrp2) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

obs_glb2 = nansum(nansum(var_mean_obs_intrp2 .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)
var_mean_obs_intrp2 = var_mean_obs_intrp2 - obs_glb2 ;

%var_zonal2 = squeeze(nanmean(var_mean,1));
lat_zonal2 = squeeze(nanmean(latitude2,1));

var_zonal2 = squeeze(nansum(var_mean .* TAREA2,1) ./ nansum(TAREA2,1) ) ;
var_zonal2_intrp = squeeze(nanmean(var_mean_intrp,1));
%%%%%
clear SW_N LW_N SH LH
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1=dir('tavg*.nc');
    filename1=aa1(1,1).name;
    var_mean_ctrl  = ncread(filename1,'SHF');
    var_mean_ctrl_intrp = griddata(longitude2,latitude2,var_mean_ctrl,longitude,latitude,'natural');
    %    var_zonal_ctrl2 = squeeze(nanmean(var_mean_ctrl,1));
    var_zonal_ctrl2 = squeeze(nansum(var_mean_ctrl .* TAREA2,1) ./ nansum(TAREA2,1) ) ;
    var_zonal_ctrl2_intrp = squeeze(nanmean(var_mean_ctrl_intrp,1));


%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
 cd (address)

      fig_name = strcat('NHF_zonal_OA_SODA_NEWEST');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h10 = plot(lat_zonal,var_zonal_OA,'k','linewidth',2) ;
hold on
h20 = plot(lat_zonal(lat_zonal > -72),var_zonal_SODA(lat_zonal > -72),'color',purple,'linewidth',3) ;
%h20 = plot(lat_zonal_SODA,var_zonal_SODA2,'color',purple,'linewidth',3) ;
hold on
h1 = plot(lat_zonal,var_zonal_ctrl,'r--','linewidth',2) ;
hold on
h2 = plot(lat_zonal,var_zonal,'r','linewidth',2) ;
hold on
h3 = plot(lat_zonal,var_zonal_ctrl2_intrp,'b--','linewidth',2) ;
hold on
h4 = plot(lat_zonal,var_zonal2_intrp,'b','linewidth',2) ;
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('NHF (Wm^-^2)','fontsize',20,'fontweight','bold');
xlim([-74 74])
%ylim([NEW_NHF_POP_zonal.m-1.5 2.2])
   hleg1 = legend([h1 h2 h3 h4 h10 h20],'ctrl-T31','GC-T31','ctrl-f19','GC-f19','OA-Flux','SODA3');
%   hleg1 = legend([h1 h2 h3 h4 h10],'ctrl-T31','GC-T31','ctrl-f19','GC-f19', 'SODA3');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
%print ('-depsc','-tiff','-r600','-painters', fig_name)
print ('-dpdf','-r600','-painters', fig_name)


%%%%%%%%%%%%%%%%%%%%
      fig_name = strcat('NHF_bias_zonal_OA');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
y = lat_zonal;
y(:) = 0;
plot(lat_zonal, y, 'k--');
hold on
h1 = plot(lat_zonal,var_zonal_ctrl - var_zonal_OA,'r--','linewidth',2) ;
hold on
h2 = plot(lat_zonal,var_zonal - var_zonal_OA,'r','linewidth',2) ;
hold on
h3 = plot(lat_zonal,var_zonal_ctrl2_intrp - var_zonal_OA,'b--','linewidth',2) ;
hold on
h4 = plot(lat_zonal,var_zonal2_intrp - var_zonal_OA,'b','linewidth',2) ;
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('NHF bias (Wm^-^2)','fontsize',20,'fontweight','bold');
xlim([-74 74])
%ylim([NEW_NHF_POP_zonal.m-1.5 2.2])
   hleg1 = legend([h1 h2 h3 h4],'ctrl-T31','GC-T31','ctrl-f19','GC-f19');
%   hleg1 = legend([h1 h2 h3 h4 h10],'ctrl-T31','GC-T31','ctrl-f19','GC-f19', 'SODA3');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-dpdf','-r600','-painters', fig_name)

