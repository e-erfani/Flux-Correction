    clc
    clear
%path(path,'/homes/eerfani/Bias/m_map')
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
%path(path,'/homes/eerfani/altmany-export_fig-9676767')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn';
cd (address)
cd /homes/eerfani/Bias
load ('SST_Hadley.mat')
load('lat_HadI') ; load('lon_HadI')
lon_HadI = double(lon_HadI); lat_HadI = double(lat_HadI);
%%%%
cd (address)

    aa1=dir('tavg*.nc');
    tt1=1; 
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); 
  lat_pop=ncread(filename1,'TLAT'); 
 lon_pop=ncread(filename1,'TLONG');

  SST_mean_interp_HADI = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop,lat_pop,'natural');

    filename1=aa1(tt1,1).name;
    sst=ncread(filename1,'TEMP'); 
    sst_mean = sst(:,:,1) ;
      
TAREA2 = TAREA ;
II = find(isnan(sst_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(sst_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2) 

 TAREA3 = TAREA ;
JJ = find(isnan(SST_mean_interp_HADI) == 1) ;
TAREA3(JJ) = NaN;          

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_rmse_glb = sqrt(nansum(nansum((sst_mean - SST_mean_interp_HADI) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)) 
var_bias_glb = nansum(nansum((sst_mean - SST_mean_interp_HADI) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2) 
obs_glb = nansum(nansum(SST_mean_interp_HADI .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)

%%%%%%

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lon_c_m, lat_c_m] = meshgrid(lon_c, lat_c);

 SST_mean_interp_HADI_c = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_c_m,lat_c_m,'natural');
 SST_mean_interp_c      = griddata(lon_pop,lat_pop,sst_mean,lon_c_m,lat_c_m,'natural');

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%

address2 = '/shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn';
cd (address2)

    aa1=dir('tavg*.nc');
    tt1=1;
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA');
  lat_pop2=ncread(filename1,'TLAT');
 lon_pop2=ncread(filename1,'TLONG');

  SST_mean_interp_HADI = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop2,lat_pop2,'natural');


    filename1=aa1(tt1,1).name;
    sst=ncread(filename1,'TEMP');
    sst_mean = sst(:,:,1) ;
TAREA2 = TAREA ;
II = find(isnan(sst_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(sst_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)

 TAREA3 = TAREA ;
JJ = find(isnan(SST_mean_interp_HADI) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_rmse_glb = sqrt(nansum(nansum((sst_mean - SST_mean_interp_HADI) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb = nansum(nansum((sst_mean - SST_mean_interp_HADI) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)

%%%%%%

bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c2 = ncread(fname,'lat');
lon_c2 = ncread(fname,'lon');
[lon_c_m2, lat_c_m2] = meshgrid(lon_c2, lat_c2);

 SST_mean_interp_HADI_c2 = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_c_m2,lat_c_m2,'natural');
 SST_mean_interp_c2      = griddata(lon_pop2,lat_pop2,sst_mean,lon_c_m2,lat_c_m2,'natural');


%%%%%
 cd (address)
      fig_name = strcat('SST_bias_annual_NEW_panel');
        fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,13.5,4]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
[ha, pos] = tight_subplot(1,2,[.00 .01],[.01 .01],[.05 .06]) ;

axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SST_mean_interp_c - SST_mean_interp_HADI_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-4, 4])

axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SST_mean_interp_c2 - SST_mean_interp_HADI_c2),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'GC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-4, 4])

h = colorbar('location','Manual', 'position', [0.95 0.109 0.013 0.785]);
set(h, 'ylim', [-4 4])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)

