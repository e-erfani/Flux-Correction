    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')
purple = [.61 .51 .74] ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
%%%%
cd (address)

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  lat_pop_zon = ncread(filename1,'lat_aux_grid');
  var = ncread(filename1,'N_HEAT');
  var_zonal = squeeze(var(:,1,1));


%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
  var = ncread(filename1,'N_HEAT');
  var_zonal_ctrl = squeeze(var(:,1,1));    

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  SW_N  = ncread(filename1,'SHF_QSW');    
  latitude  = ncread(filename1,'TLAT');    
  longitude  = ncread(filename1,'TLONG');    
  lat_pop_zon2 = ncread(filename1,'lat_aux_grid');
  var = ncread(filename1,'N_HEAT');
  var_zonal2 = squeeze(var(:,1,1));    
    
%%%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    var = ncread(filename1,'N_HEAT');
    var_zonal_ctrl2 = squeeze(var(:,1,1));    
    
%%%%%%%%%%
%%%%%%%%%% Observations
cd /shared/SWFluxCorr/SODA3_NHF/
fname = 'SODA3_net_hf_07-14_0.5x0.5.nc' ;
lon_SODA = ncread(fname,'lon');
lat_SODA = ncread(fname,'lat');
Qnet_average = ncread(fname,'hflx');
var_mean_obs = Qnet_average;
lat_SODA = double(lat_SODA) ; lon_SODA = double(lon_SODA) ;
[lat_fn_msh,lon_fn_msh] = meshgrid(lat_SODA, lon_SODA) ;


cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn
bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lat_c_m, lon_c_m] = meshgrid(lat_c, lon_c);
var_mean_obs_intrp = griddata(lon_fn_msh,lat_fn_msh,var_mean_obs,lon_c_m,lat_c_m,'natural');

gw = ncread(fname, 'gw');
I = length(lon_c);
GW = repmat(gw, [1 I])';
GW2 = GW ;
II = find(isnan(var_mean_obs_intrp) == 1) ;
GW2(II) = NaN ;

% constants
pi   = 3.14159265 ;
re   = 6.371e6 ;            % radius of earth
coef = (re .^ 2) ./ 1.e15 ; % scaled for PW    
nlat = length(lat_c);
nlon = length(lon_c);
dlon = 2 .*pi ./ nlon;         % dlon in radians

% compute net surface energy flux scale by ocean fraction
 %netflux = zeros(nlon,nlat) ;
netflux = var_mean_obs_intrp ; % This provides a better approx of the pop N_HEAT based OHT than if scaled by ocean fraction
netflux(II) = NaN ; 
% W/m^2 adjustment for ocean heat storage
heat_storage = nansum(nansum(netflux .* GW2)) ./ nansum(nansum(GW2)) ; 
netflux = netflux - heat_storage;  

% sum flux over the longitudes 
 heatflux = zeros(nlat);
 heatflux = nansum(squeeze(netflux));

% compute implied heat transport in each basin
 heatflux_flipped = flipdim(heatflux,2);
 lat2 = flipdim(lat_c,1);
 lat2_flux1 = (lat2(1:end-1) + lat2(2:end)) ./ 2;
 lat2_flux = cat(1, lat2_flux1, -90);

   for j=1:nlat  %start sum at most northern point 
     oht(j) = -coef .* dlon .* nansum(heatflux_flipped(1:j)' .* gw(1:j));
   end 

  OHT = flipdim(oht,2)';
  lat = flipdim(lat2_flux,1);

cd (address)  
load OHT_OA

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
      fig_name = strcat('ocean_heat_transport_zonal_OA_SODA_NEW');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h10 = plot(lat,OHT_OA,'k','linewidth',2) ;      
hold on
h20 = plot(lat,OHT,'color',purple,'linewidth',3) ;
h1 = plot(lat_pop_zon,var_zonal_ctrl,'r--','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon,var_zonal,'r','linewidth',2) ;
hold on
h3 = plot(lat_pop_zon2,var_zonal_ctrl2,'b--','linewidth',2) ;
hold on
h4 = plot(lat_pop_zon2,var_zonal2,'b','linewidth',2) ;
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Ocean heat transport (PW)','fontsize',20,'fontweight','bold');
xlim([-78 78])
ylim([-1.5 2.2])
   hleg1 = legend([h1 h2 h3 h4 h10 h20],'ctrl-T31','GC-T31','ctrl-f19','GC-f19','OA-Flux','SODA3');
%   hleg1 = legend([h1 h2 h3 h4 h10],'ctrl-T31','GC-T31','ctrl-f19','GC-f19', 'SODA3');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
print ('-depsc','-tiff','-r600','-painters', fig_name)
dbstop

%%%%%%%%%%%%%%
      fig_name = strcat('ocean_heat_transport_anomaly_zonal_NEW');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_pop_zon, var_zonal - var_zonal_ctrl,'r','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon2, var_zonal2 - var_zonal_ctrl2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Ocean heat transport anomaly (PW)','fontsize',20,'fontweight','bold');
xlim([-80 80])
ylim([-0.6 0.15])
   hleg1 = legend([h1 h2],'GC-T31 - ctrl-T31','GC-f19 - ctrl-f19');
    set(hleg1,'Location','SouthEast','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)
