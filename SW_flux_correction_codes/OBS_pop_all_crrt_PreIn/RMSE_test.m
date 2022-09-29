    clc
    clear
path(path,'/homes/eerfani/Bias/m_map')
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
 
 ratio = abs(SST_mean_ctrl_interp_c - SST_mean_interp_HADI_c) ./ abs(SST_mean_interp_c - SST_mean_interp_HADI_c);
 ratio (ratio > 1000) = 1000 ;
 ratio (ratio < 0.001) = 0.001 ;

 bias = abs(sst_mean - SST_mean_interp_HADI);
 bias_ctrl = abs(sst_mean_ctrl - SST_mean_interp_HADI) ;
 ratio2 = bias_ctrl ./ bias;
 ratio2 (ratio2 > 1000) = 1000 ;
 ratio2 (ratio2 < 0.001) = 0.001 ;

%%%%%%%%%
 cd (address)
        fig_name = strcat('ratio_RMSE_panel');
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,8.5,4]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
   cint = [0.05 0.06667 0.1 0.1333 0.2 0.2857 0.5 0.66667 1 1.5 2 3.5 5 7.5 10 15 20];
   m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, log(ratio), log(cint));%,[0.05:0.1:2 3:10 11:5:50]);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = '|ctrl-T31 bias| / |GC-T31 bias|';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(length(cint),'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
  hC = colorbar;
   c_thick = [0.05 0.1 0.2 0.5 1 2 5 10 20];
  set(hC,'YTick',log(c_thick),'YTickLabel',c_thick);
%set(hc, 'ylim', [log(0.1) log(20)])
set(gca,'Fontsize',11)
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)

dbsotp
       
    %%%%%%
clear SST_T31; clear lat_T31; clear lon_T31
  cellsize = 0.5;
SST_T31  = double(ratio2) ;
lat_T31  = lat_pop ;
lon_T31  = lon_pop ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_N_annual_fromFILE_CERES_POPgrid');%,num2str(tt));
        fig_dum = figure(101);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust), squeeze(refvec_bias), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = 'CERES, Net SW Flux, Annual, POP grid';
    title(Title_1,'fontsize',23,'fontweight','bold');

 c_thick = [0.05 0.1 0.2 0.5 1 2 5];
 hC = colorbar;
  set(hC,'YTick',log(c_thick),'YTickLabel',c_thick);
      colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
 %   caxis([0 20])
 print ('-depsc','-tiff','-r600','-painters', fig_name)
dbstop
    
d = log10(ratio2);
mn = nanmin(nanmin(d(:)));
rng = nanmax(nanmax(d(:)))-mn;
d = 1+63*(d-mn) ./ rng; % Self scale data

c_thick = [0.1 0.2 0.5 1 2 5 10 20 40];
% Choose appropriate
% or somehow auto generate colorbar labels
l = 1+63*(log10(c_thick)-mn)/rng; % Tick mark positions
set(hC,'Ytick',l,'YTicklabel',c_thick);


    
    
    %cc = colorbar('peer',gca);
      colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
 %   caxis([0 20])
 print ('-depsc','-tiff','-r600','-painters', fig_name)

 dbstop
 
 
%%%%%
