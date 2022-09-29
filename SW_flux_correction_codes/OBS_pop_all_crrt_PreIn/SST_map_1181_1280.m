    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)
cd /homes/eerfani/Bias
load ('SST_Hadley.mat')
load('lat_HadI') ; load('lon_HadI')
load('lat_pop') ; load('lon_pop');
 SST_mean_interp_HADI = griddata(double(lon_HadI),double(lat_HadI),SST_Hadley,lon_pop,lat_pop,'natural');

%%%%
cd /shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn

    aa1=dir('tavg.1181-1280.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); % surface net Shortwave Radiation (W/m2)

nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    sst=ncread(filename1,'TEMP'); 
    sst_all(:,:,nn) = sst(:,:,1);      
end
    sst_mean = nanmean(sst_all,3) ;
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

%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(sst_mean - SST_mean_interp_HADI) ;
lat_T31(:,:,1)  = lat_pop ;
lon_T31(:,:,1)  = lon_pop ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SST_bias_annual_1181_1280');%,num2str(tt));
        fig_dum = figure(145);
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
    Title_1 = strcat('SST, CESM - obs, Global Mean=',num2str(var_glb),', RMSE=',num2str(var_rmse_glb),' \circC');    
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
        colormap(brewermap(32,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-8, 8])
      set(cc,'YTick',-8:2:8)
    eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      
%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    sst=ncread(filename1,'TEMP'); 
    sst_all_ctrl(:,:,nn) = sst(:,:,1);      
end
    
TAREA2 = TAREA ;
II = find(isnan(sst_all_ctrl) == 1) ;
TAREA2(II) = NaN;
var_glb_diff = nansum(nansum((sst_mean-sst_all_ctrl) .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2) 

var_bias_glb_ctrl = nansum(nansum((sst_all_ctrl - SST_mean_interp_HADI) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2) 
%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(sst_mean - sst_all_ctrl) ;
lat_T31(:,:,1)  = lat_pop ;
lon_T31(:,:,1)  = lon_pop ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SST_diff_annual_1181_1280');%,num2str(tt));
        fig_dum = figure(144);
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
    Title_1 = strcat('flx corr - ctrl, SST, POP, Annual Mean=',num2str(var_glb_diff),' \circC');    
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
        colormap(brewermap(24,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-3, 3])
cd (address)
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
          
