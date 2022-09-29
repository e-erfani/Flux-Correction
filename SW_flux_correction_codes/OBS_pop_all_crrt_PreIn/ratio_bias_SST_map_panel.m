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
 
 ratio = abs(SST_mean_interp_c - SST_mean_interp_HADI_c) ./ abs(SST_mean_ctrl_interp_c - SST_mean_interp_HADI_c) ;
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
 
 ratio2 = abs(SST_mean_interp_c2 - SST_mean_interp_HADI_c2) ./ abs(SST_mean_ctrl_interp_c2 - SST_mean_interp_HADI_c2) ;
 
%%%%%
 cd (address)
      fig_name = strcat('ratio_bias_SST_map_panel');
        fig_dum = figure(1);
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
