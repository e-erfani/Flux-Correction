    clc
    clear
path(path,'/homes/eerfani/Bias/m_map')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)
cd /homes/eerfani/Bias
cd CERES
load('lat_fine.mat')
load('lon_fine.mat')
load('latitude_pop.mat')
load('longitude_pop.mat')
cd fields_NEW
load ('LW_S_d_mo_mean')
load ('LW_S_u_mo_mean')
SW_S_N_mo_mean = nanmean(LW_S_u_mo_mean - LW_S_d_mo_mean,3) ;
[lat_fn_msh,lon_fn_msh] = meshgrid(lat_fine,lon_fine);

    SW_S_N_mo_mean_intrp_CAMgrid = griddata(lon_fn_msh,lat_fn_msh,SW_S_N_mo_mean,longitude,latitude,'natural');
 
%%%%
cd (address)
    aa1=dir('tavg.1181-1280.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); % surface net Shortwave Radiation (W/m2)

nn = 0 ;
for tt1=1:length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    LW_U = ncread(filename1,'LWUP_F');
    LW_D = ncread(filename1,'LWDN_F'); 
    LW_N = -LW_U - LW_D ;
    SW_N_all(:,:,nn) = LW_N;      
end
SW_N_mean = nanmean(SW_N_all,3);
TAREA2 = TAREA ;
II = find(isnan(SW_N_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(SW_N_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2) 

 TAREA3 = TAREA ;
JJ = find(isnan(SW_S_N_mo_mean_intrp_CAMgrid) == 1) ;
TAREA3(JJ) = NaN;          

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_rmse_glb = sqrt(nansum(nansum((SW_N_mean - SW_S_N_mo_mean_intrp_CAMgrid) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)) 
var_bias_glb = nansum(nansum((SW_N_mean - SW_S_N_mo_mean_intrp_CAMgrid) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
obs_glb = nansum(nansum(SW_S_N_mo_mean_intrp_CAMgrid .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2) 

%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    LW_U = ncread(filename1,'LWUP_F');
    LW_D = ncread(filename1,'LWDN_F');
    LW_N = - LW_U - LW_D ;
    SW_N_all_ctrl(:,:,nn) = LW_N;      
end
    
TAREA2 = TAREA ;
II = find(isnan(SW_N_all_ctrl) == 1) ;
TAREA2(II) = NaN;

var_glb_ctrl = nansum(nansum(SW_N_all_ctrl .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_glb_diff = nansum(nansum((SW_N_mean-SW_N_all_ctrl) .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2) 
var_bias_glb_ctrl = nansum(nansum((SW_N_all_ctrl - SW_S_N_mo_mean_intrp_CAMgrid) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
var_rmse_glb_ctrl = sqrt(nansum(nansum((SW_N_all_ctrl - SW_S_N_mo_mean_intrp_CAMgrid) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))

%%%    
SW_N_all_intrp = griddata(longitude,latitude,SW_N_mean,lon_fn_msh,lat_fn_msh,'natural');
SW_N_all_ctrl_intrp = griddata(longitude,latitude,SW_N_all_ctrl,lon_fn_msh,lat_fn_msh,'natural');
    
%%%%%
clear SST_T31 lat_T31 lon_T31 Z_adjust refvec_bias
cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_N_all_intrp - SW_S_N_mo_mean') ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('LW_N_bias_POP_CERESgrid_1181_1280');%,num2str(tt));
        fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = strcat('Global Mean=',num2str(var_glb),',bias=',num2str(var_bias_glb),', RMSE=',num2str(var_rmse_glb),' Wm^-^2');    
    title(Title_1,'fontsize',23,'fontweight','bold');    
    cc = colorbar('peer',gca);
        colormap(brewermap(30,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
  %  set(cc,'YTick',[-50:10:50])
 cd (address)
     eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
     
%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(SW_N_all_intrp - SW_N_all_ctrl_intrp) ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('LW_N_intrp_diff_1181_1280');%,num2str(tt));
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = strcat('Global Mean=',num2str(var_glb),',bias=',num2str(var_bias_glb),', RMSE=',num2str(var_rmse_glb),' Wm^-^2');   
    Title_1 = strcat('flx corr - ctrl, Net SW, POP, Annual Mean=',num2str(var_glb_diff),' Wm^-^2');    
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
        colormap(brewermap(30,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-30, 30])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  

%%%%%
clear SST_T31 lat_T31 lon_T31 Z_adjust refvec_bias
cellsize = 0.5;
SST_T31(:,:,1)  = double(SW_N_all_ctrl_intrp - SW_S_N_mo_mean') ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ;
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);
 latlim = [-75 75];
 lonlim = [1 360];

        fig_name = strcat('LW_N_bias_POP_CERESgrid_1181_1280_CTRL');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-');
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = strcat('Global Mean=',num2str(var_glb_ctrl),',bias=',num2str(var_bias_glb_ctrl),', RMSE=',num2str(var_rmse_glb_ctrl),' Wm^-^2');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
        colormap(brewermap(30,'*RdBu'))
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
  %  set(cc,'YTick',[-50:10:50])
 cd (address)
     eval(['print -r600 -djpeg ', fig_name,'.jpg']);      
