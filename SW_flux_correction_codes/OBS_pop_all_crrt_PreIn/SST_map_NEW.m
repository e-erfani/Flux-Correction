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

%%%%%
 cd (address)

      fig_name = strcat('SST_bias_annual_NEW');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])
      [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SST_mean_interp_c - SST_mean_interp_HADI_c),32);
       set(h,'LineColor','none')
  m_coast('linewidth',1,'color','black');
    Title_1  = '(Global Correction, Low Resolution) - (Observation)';
%    Title_1  =strcat('Global Mean=',num2str(var_glb),' ,bias=',nuim2str(var_bias_glb),' , RMSE=',num2str(var_rmse_glb),' C');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
     colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',16)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',16);
    caxis([-4, 4])
    set(gcf,'color','w');
     set(gcf, 'PaperPositionMode', 'auto')
     set(gcf,'renderer','Painters')     
 print ('-depsc','-tiff','-r600','-painters', fig_name)
%  export_fig(fig_name,'-eps') 

