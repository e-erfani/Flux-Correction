    clc
    clear
path(path,'/homes/eerfani/Bias/m_map')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
address = '/shared/SWFluxCorr/CESM/PreInd_chey_contr';
cd (address)

cd /homes/eerfani/Bias
cd CERES
load('lat_fine.mat')
load('lon_fine.mat')
cd fields_NEW
load ('SW_S_d_mo_mean')
load ('SW_S_u_mo_mean')
SW_S_N_mo_mean = SW_S_d_mo_mean - SW_S_u_mo_mean ;
[lat_msh_obs,lon_msh_obs] = meshgrid(lat_fine,lon_fine);

%%%%%
cd (address)
    aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.0471-0570._*_climo.nc');
    tt=1;  filename=aa(tt,1).name;
    lat_msh_p =ncread(filename,'TLAT'); lon_msh_p =ncread(filename,'TLONG');
TAREA=ncread(filename,'TAREA'); % surface net Shortwave Radiation (W/m2)

nn = 0 ;
for tt=1:12%length(aa1)
    nn = nn + 1 ;
    filename=aa(tt,1).name;
    SW_S_N_pop=double(ncread(filename,'SHF_QSW')); % solar flux at surface (W/m2)
    SW_S_N_pop_all(:,:,nn) = SW_S_N_pop;  
    clear SW_S_N_pop  
end
SW_S_N_pop_mean = nanmean(SW_S_N_pop_all,3);
%%%%
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7_*_climo.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  gw=ncread(filename1,'gw'); % surface net Shortwave Radiation (W/m2)
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lat_msh_cam,lon_msh_cam] = meshgrid(latitude,longitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
md = [15 46 74 105	135	166	196	227	258	288	319	349] ;

nn = 0 ;
for tt1=1:12%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SW_S_N_c=double(ncread(filename1,'FSNS')); % solar flux at surface (W/m2)
    SW_S_N_c_all(:,:,nn) = SW_S_N_c;      
    tmp2 = griddata(lon_msh_cam,lat_msh_cam,SW_S_N_c,lon_msh_p,lat_msh_p,'natural');
    SW_S_N_c_all_POPgrid_all(:,:,nn) = tmp2 ;
    clear SW_S_N_c tmp2
end
for i = 1:12
    for kk = 1:size(SW_S_N_c_all_POPgrid_all,2)
      if (isnan(SW_S_N_c_all_POPgrid_all(11,kk,i)) == 1)
          SW_S_N_c_all_POPgrid_all(11,kk,i) = (SW_S_N_c_all_POPgrid_all(10,kk,i) + SW_S_N_c_all_POPgrid_all(12,kk,i)) ./ 2 ;
      end     
    end
end
SW_S_N_c_all_POPgrid_mean = nanmean(SW_S_N_c_all_POPgrid_all,3);
%%%%

diff_POP_CAM = SW_S_N_pop_all - SW_S_N_c_all_POPgrid_all;
diff_POP_CAM_mean = nanmean(diff_POP_CAM,3) ;
%%%%%
  cellsize = 0.5; 
SST_T31  = double(diff_POP_CAM_mean) ;
lat_T31  = lat_msh_p ;
lon_T31  = lon_msh_p ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('diff_POP_CAM_SW_S_N_POPgrid');%,num2str(tt));
        fig_dum = figure(1);
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
    Title_1 = 'SWnet, POP - CAM, Annual, POP grid';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(30,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
set(cc,'YTick',[-50:10:50])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
 
%%%%%%
II = find(lat_msh_p > - 40 & lat_msh_p < 40);
for i = 1:12
    temp = diff_POP_CAM(:,:,i);
    temp(II) = NaN;
    diff_POP_CAM_2(:,:,i) = temp;
    clear temp
end
diff_POP_CAM_2_mean = nanmean(diff_POP_CAM_2,3);
%%%%
for tt = 1:12
    tmp = double(SW_S_N_mo_mean(:,:,tt)) ;
    tmp2 = griddata(lon_msh_obs,lat_msh_obs,tmp,lon_msh_p,lat_msh_p,'natural');
    SW_S_N_obs_POPgrid(:,:,tt) = tmp2 ;
    clear tmp2 tmp
end
diff_POP_CAM_2(isnan(diff_POP_CAM_2)==1) = 0 ;
SW_S_N_obs_POPgrid_diff_added_poles = SW_S_N_obs_POPgrid + diff_POP_CAM_2 ;
SW_S_N_obs_POPgrid_diff_added_poles_mean = nanmean(SW_S_N_obs_POPgrid_diff_added_poles,3);
%%%%
  cellsize = 0.5; 
SST_T31  = double(SW_S_N_obs_POPgrid_diff_added_poles_mean) ;
lat_T31  = lat_msh_p ;
lon_T31  = lon_msh_p ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_N_CERES_POPgrid_diff_added_to_poles');%,num2str(tt));
        fig_dum = figure(2);
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
    Title_1 = 'SWnet, CERES, POP grid, Annual';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(40,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 300])
%set(cc,'YTick',[-50:10:50])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      
%%%%
bias_SW  = double(SW_S_N_pop_mean - SW_S_N_obs_POPgrid_diff_added_poles_mean);
II = find (isnan(bias_SW) == 1);
TAREA2 = TAREA ;
TAREA2(II) = NaN;
bias_glb = nansum(nansum(TAREA2 .* bias_SW,1),2) ./ nansum(nansum(TAREA2,1),2)
III = find (isnan(SW_S_N_pop_mean) == 1);
TAREA10 = TAREA ;
TAREA10(III) = NaN;
SWnet_ctrl_glb = nansum(nansum(TAREA10 .* SW_S_N_pop_mean,1),2) ./ nansum(nansum(TAREA10,1),2)
RMSE_glb = sqrt(nansum(nansum(TAREA2 .* bias_SW .^ 2,1),2) ./ nansum(nansum(TAREA2,1),2))
clear II TAREA2

cellsize = 0.5; 
SST_T31  =  bias_SW;
lat_T31  = lat_msh_p ;
lon_T31  = lon_msh_p ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('bias_SW_S_N_POP_CERES_POPgrid_diff_added_to_poles');%,num2str(tt));
        fig_dum = figure(3);
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
    Title_1 = strcat('SWnet, POP - CERES, POP grid, Mean=',num2str(bias_glb),', RMSE=',num2str(RMSE_glb),' Wm^-^2');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(30,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
%set(cc,'YTick',[-50:10:50])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
%%%%%%%%
SW_S_N_obs_POPgrid_mean = nanmean(SW_S_N_obs_POPgrid,3);
  cellsize = 0.5; 
SST_T31  = double(SW_S_N_obs_POPgrid_mean) ;
lat_T31  = lat_msh_p ;
lon_T31  = lon_msh_p ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_N_CERES_POPgrid');%,num2str(tt));
        fig_dum = figure(23);
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
    Title_1 = 'SWnet, CERES, POP grid, Annual';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(40,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 300])
%set(cc,'YTick',[-50:10:50])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  

%%%%%% interpolate to daily resolution %%%%%%
%SW_S_N_obs_POPgrid(isnan(SW_S_N_obs_POPgrid) == 1) = 0;
for t1 = 1:365
    for m = 1:11
        if ( t1 >= md(m) && t1 < md(m+1) )
            for i = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,1)
            for j = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,2)
                SW_S_N_dail_mea(i,j,t1) = (t1 - md(m)) .* (SW_S_N_obs_POPgrid_diff_added_poles(i,j,m+1) - SW_S_N_obs_POPgrid_diff_added_poles(i,j,m))...
                                           ./ (md(m+1) - md(m)) + SW_S_N_obs_POPgrid_diff_added_poles(i,j,m)  ;                                        
            end
            end            
        end
    
    end
        if ( t1 < md(1) ) 
            for i = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,1)
            for j = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,2)
                 SW_S_N_dail_mea(i,j,t1) = (t1 - (-15)) .* (SW_S_N_obs_POPgrid_diff_added_poles(i,j,1) - SW_S_N_obs_POPgrid_diff_added_poles(i,j,12))...
                                           ./ (md(1) - (-15)) + SW_S_N_obs_POPgrid_diff_added_poles(i,j,12)  ; 
            end
            end
        end
        
        if ( t1 >= md(12) )
            for i = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,1)
            for j = 1:size(SW_S_N_obs_POPgrid_diff_added_poles,2)
                SW_S_N_dail_mea(i,j,t1) = (t1 - md(12)) .* (SW_S_N_obs_POPgrid_diff_added_poles(i,j,1) - SW_S_N_obs_POPgrid_diff_added_poles(i,j,12))...
                                           ./ (365+15 - md(12)) + SW_S_N_obs_POPgrid_diff_added_poles(i,j,12)  ; 
            end
            end
        end            
end

% for i = 1:365
%    JJ = find (isnan(SW_S_N_pop_mean) == 1) ;
%    ttmp = SW_S_N_dail_mea(:,:,i) ;
%    ttmp(JJ) = NaN ;
%    SW_S_N_dail_mea(:,:,i) = ttmp ;
%    clear JJ ttmp
% end

% for i = 1:12
%    JJ = find (isnan(SW_S_N_pop_mean) == 1) ;
%    ttmp = SW_S_N_obs_POPgrid_diff_added_poles(:,:,i) ;
%    ttmp(JJ) = NaN ;
%    SW_S_N_obs_POPgrid_diff_added_poles(:,:,i) = ttmp ;
%    clear JJ ttmp
% end

    SW_S_N_mea = nanmean(nanmean(SW_S_N_dail_mea,1),2) ;
    day = 1:365 ;
    figure(17)
     plot(day,permute(SW_S_N_mea,[3 1 2]),'k')
    SW_S_N_month_mean = nanmean(nanmean(SW_S_N_obs_POPgrid_diff_added_poles,1),2) ;
    hold on
    plot(md,permute(SW_S_N_month_mean,[3 1 2]),'ok')      
%SW_S_N_dail_mea(isnan(SW_S_N_dail_mea)==1) = 0.0 ;   
%%%
SW_S_N_CERES_intrp = nanmean(SW_S_N_obs_POPgrid_diff_added_poles,3) ;
II = find(isnan(SW_S_N_CERES_intrp == 1));
TAREA2 = TAREA;
TAREA2(II) = NaN;
var_CERES_glb_12 = nansum(nansum(TAREA2 .* SW_S_N_CERES_intrp,1),2) ./ nansum(nansum(TAREA2,1),2)
clear II TAREA2
SW_S_N_CERES_daily = nanmean(SW_S_N_dail_mea,3) ;
II = find(isnan(SW_S_N_CERES_daily == 1));
TAREA2 = TAREA;
TAREA2(II) = NaN;
var_CERES_glb_365 = nansum(nansum(TAREA2 .* SW_S_N_CERES_daily,1),2) ./ nansum(nansum(TAREA2,1),2)
clear II TAREA2
%%%%%%%%%%
cd (address)
cellsize = 0.5; 
SST_T31  = double(nanmean(SW_S_N_dail_mea,3)) ;
lat_T31  = lat_msh_p ;
lon_T31  = lon_msh_p ; 
[Z_adjust,refvec_bias] = geoloc2grid(squeeze(lat_T31),squeeze(lon_T31),squeeze(SST_T31), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_N_FILE_CERES_POPgrid');
        fig_dum = figure(100);
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
    Title_1 = strcat('SWnet, CERES, POP grid, Mean=',num2str(var_CERES_glb_365),'Wm^-^2');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(40,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 300])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
dbstop 
%%%%%

 nccreate('S_N_CERES_POPgrid.nc','S_N_daily','Dimensions',{'lon',100,'lat',116,'day',365},'Format','classic');
 nccreate('S_N_CERES_POPgrid.nc','lat','Dimensions',{'lon',100,'lat',116},'Format','classic');
 nccreate('S_N_CERES_POPgrid.nc','lon','Dimensions',{'lon',100,'lat',116},'Format','classic'); 
 ncwrite('S_N_CERES_POPgrid.nc','S_N_daily',SW_S_N_dail_mea);
 ncwrite('S_N_CERES_POPgrid.nc','lat',lat_msh_p);
 ncwrite('S_N_CERES_POPgrid.nc','lon',lon_msh_p);
    
Test_SW = ncread('S_N_CERES_POPgrid.nc','S_N_daily') ;
Test_lat = ncread('S_N_CERES_POPgrid.nc','lat') ;
Test_lon = ncread('S_N_CERES_POPgrid.nc','lon') ;

clear SST_T31; clear lat_T31; clear lon_T31
  cellsize = 0.5;
SST_T31  = double(nanmean(Test_SW,3)) ;
lat_T31  = Test_lat ;
lon_T31  = Test_lon ; 
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
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0 300])
