    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
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
 filename1=aa1(1,1).name;
 TAREA=ncread(filename1,'TAREA'); 
 lat_pop=ncread(filename1,'TLAT'); 
 lon_pop=ncread(filename1,'TLONG');
 sst=ncread(filename1,'TEMP'); 
 sst_mean = sst(:,:,1) ;
 SST_mean_interp_HADI = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop,lat_pop,'natural');

%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

  aa1=dir('tavg*.nc');
  filename1=aa1(1,1).name;
  sst=ncread(filename1,'TEMP');
  sst_mean_ctrl = sst(:,:,1) ;

%%%%%%
bb = dir('*._ANN_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lon_c_m, lat_c_m] = meshgrid(lon_c, lat_c);


 SST_mean_interp_HADI_c = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_c_m,lat_c_m,'natural');
 SST_mean_interp_c      = griddata(lon_pop,lat_pop,sst_mean,lon_c_m,lat_c_m,'natural');
 SST_mean_ctrl_interp_c = griddata(lon_pop,lat_pop,sst_mean_ctrl,lon_c_m,lat_c_m,'natural');
 
 ratio = 1./ (abs(SST_mean_interp_c - SST_mean_interp_HADI_c) ./ abs(SST_mean_ctrl_interp_c - SST_mean_interp_HADI_c));
 ratio (ratio > 1000) = 1000 ;
 ratio (ratio < 0.001) = 0.001 ;
 ratio_zonal = nanmean(ratio,2);
  lat_zon = nanmean(lat_c_m,2);

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%

address2 = '/shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn';
cd (address2)

  aa1=dir('tavg*.nc');
  filename1=aa1(1,1).name;
  TAREA=ncread(filename1,'TAREA');
  lat_pop2=ncread(filename1,'TLAT');
  lon_pop2=ncread(filename1,'TLONG');
  sst=ncread(filename1,'TEMP');
  sst_mean2 = sst(:,:,1) ;
  SST_mean_interp_HADI2 = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_pop2,lat_pop2,'natural');

%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

  aa1=dir('tavg*.nc');
  filename1=aa1(1,1).name;
  sst=ncread(filename1,'TEMP');
  sst_mean_ctrl2 = sst(:,:,1) ;

%%%%%%
bb = dir('*.cam.h0.*_01_climo.nc');
fname = bb(1,1).name;
lat_c2 = ncread(fname,'lat');
lon_c2 = ncread(fname,'lon');
[lon_c_m2, lat_c_m2] = meshgrid(lon_c2, lat_c2);

 SST_mean_interp_HADI_c2 = griddata(lon_HadI,lat_HadI,SST_Hadley,lon_c_m2,lat_c_m2,'natural');
 SST_mean_interp_c2      = griddata(lon_pop2,lat_pop2,sst_mean2,lon_c_m2,lat_c_m2,'natural');
 SST_mean_ctrl_interp_c2 = griddata(lon_pop2,lat_pop2,sst_mean_ctrl2,lon_c_m2,lat_c_m2,'natural');
 
 ratio2 = 1./( abs(SST_mean_interp_c2 - SST_mean_interp_HADI_c2) ./ abs(SST_mean_ctrl_interp_c2 - SST_mean_interp_HADI_c2));
 ratio2 (ratio2 > 1000) = 1000 ;
 ratio2 (ratio2 < 0.001) = 0.001 ;
 ratio2_zonal = nanmean(ratio2,2);
 lat_zon2 = nanmean(lat_c_m2,2);

  ratio2 (ratio2 > 1000) = 1000 ;
 ratio2 (ratio2 < 0.001) = 0.001 ;
 %%%%%%%%%%%%%
      fig_name = strcat('ratio_SST_bias_zonal_panel');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_zon,ratio_zonal,'k','linewidth',2) ;
hold on
h2 = plot(lat_zon2,ratio2_zonal,'b','linewidth',2) ;
hold on
set(gca, 'YScale', 'log')
y = lat_zon;
y(:) = 1;
 plot(lat_zon, y, 'r--');
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Ratio of SST bias','fontsize',20,'fontweight','bold');
xlim([-80 80])
ylim([0.7 30])
   hleg1 = legend([h1 h2],'T31','f19');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)
