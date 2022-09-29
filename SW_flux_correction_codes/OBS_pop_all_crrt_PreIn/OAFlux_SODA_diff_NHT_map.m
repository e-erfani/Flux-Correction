    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)

%%%% SODA3
cd /shared/SWFluxCorr/SODA3_NHF/
fname = 'SODA3_net_hf_07-14_0.5x0.5.nc' ;
lon_SODA = ncread(fname,'lon');
lat_SODA = ncread(fname,'lat');
Qnet_average_S = ncread(fname,'hflx');
Qnet_average_S = Qnet_average_S - 2.2947 ;
lat_SODA = double(lat_SODA) ; lon_SODA = double(lon_SODA) ;
[lat_S_msh,lon_S_msh] = meshgrid(lat_SODA, lon_SODA) ;

%%%%%% OAFlux
cd /shared/SWFluxCorr/OA_Flux
load('lat_msh_OAFlux.mat')
load('lon_msh_OAFlux.mat')
load('Qnet_average_OA.mat')
Qnet_average_OA = Qnet_average - 28.14 ;
lat_fn_msh = double(lat_msh_OAFlux') ; lon_fn_msh = double(lon_msh_OAFlux') ;

Qnet_average_S_intrp = griddata(lon_S_msh,lat_S_msh,Qnet_average_S,lon_fn_msh,lat_fn_msh,'natural');



%%%%%%
cd (address)

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lon_c_m, lat_c_m] = meshgrid(lon_c, lat_c);

 var_mean_interp_OAFlux  = griddata(lon_fn_msh,lat_fn_msh,Qnet_average_OA,lon_c_m,lat_c_m,'natural');
 var_mean_interp_SODA    = griddata(lon_S_msh, lat_S_msh, Qnet_average_S, lon_c_m,lat_c_m,'natural');


%%%%%
 cd (address)
      fig_name = strcat('DIFF_SODA_OAFlux_net_heat_bias');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,14,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
%      [ha, pos] = tight_subplot(2,2,[.00 .01],[.01 .01],[.05 .06]) ;           
      
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(var_mean_interp_SODA - var_mean_interp_OAFlux),100);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'SODA3 - OAFlux';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(100,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-50, 50])
h = colorbar    
%h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
%set(h, 'ylim', [-50 50])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)


