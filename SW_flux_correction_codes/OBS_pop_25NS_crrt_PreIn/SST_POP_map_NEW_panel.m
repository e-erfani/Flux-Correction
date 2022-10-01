    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_25NS_crrt_PreIn' ;
cd (address)
bb = dir('*.cam.h0.*_climo.nc');
fname = bb(1,1).name;
lat_c = ncread(fname,'lat');
lon_c = ncread(fname,'lon');
[lon_c_m, lat_c_m] = meshgrid(lon_c, lat_c);

%%%%%%%
cd /homes/eerfani/Bias
load ('SST_Hadley.mat')
load('lat_HadI') ; load('lon_HadI')
lon_fn_msh = double(lon_HadI); lat_fn_msh = double(lat_HadI);

%%%%
cd (address)
    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); 
  latitude=ncread(filename1,'TLAT'); 
  longitude=ncread(filename1,'TLONG'); 
  
 SW_S_N_mo_mean_intrp_CAMgrid = griddata(lon_fn_msh,lat_fn_msh,SST_Hadley,longitude,latitude,'natural');

nn = 0 ;
for tt1=1:length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    var_all(:,:,nn) = var(:,:,1);
end
SW_N_mean_trop_LR = nanmean(var_all,3);
TAREA2 = TAREA ;
II = find(isnan(SW_N_mean_trop_LR) == 1) ;
TAREA2(II) = NaN;

TAREA3 = TAREA ;
JJ = find(isnan(SW_S_N_mo_mean_intrp_CAMgrid) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_glb_trop_LR = nansum(nansum(SW_N_mean_trop_LR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_trop_LR = sqrt(nansum(nansum((SW_N_mean_trop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_trop_LR = nansum(nansum((SW_N_mean_trop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
obs_glb = nansum(nansum(SW_S_N_mo_mean_intrp_CAMgrid .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
cd /shared/SWFluxCorr/CESM/OBS_pop_35-90NS_crrt_PreIn
    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    SW_N_mean_extratrop_LR(:,:,nn) = var(:,:,1);
end

var_glb_extratrop_LR = nansum(nansum(SW_N_mean_extratrop_LR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_extratrop_LR = sqrt(nansum(nansum((SW_N_mean_extratrop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_extratrop_LR = nansum(nansum((SW_N_mean_extratrop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
cd /shared/SWFluxCorr/CESM/OBS_pop_15-40NS_crrt_PreIn

    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    SW_N_mean_subtrop_LR(:,:,nn) = var(:,:,1);
end

var_glb_subtrop_LR = nansum(nansum(SW_N_mean_subtrop_LR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_subtrop_LR = sqrt(nansum(nansum((SW_N_mean_subtrop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_subtrop_LR = nansum(nansum((SW_N_mean_subtrop_LR - SW_S_N_mo_mean_intrp_CAMgrid) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)

%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;   
    sst = ncread(filename1,'TEMP');
    SW_N_mean_ctrl_LR = sst(:,:,1) ;   
    
%%%%%%
 SW_mean_interp_obs_c          = griddata(lon_fn_msh,lat_fn_msh,SST_Hadley,lon_c_m,lat_c_m,'natural');
 SW_mean_interp_trop_LR_c      = griddata(longitude,latitude, SW_N_mean_trop_LR, lon_c_m,lat_c_m,'natural');
 SW_mean_interp_subtrop_LR_c   = griddata(longitude,latitude,SW_N_mean_subtrop_LR,lon_c_m,lat_c_m,'natural');
 SW_mean_interp_extratrop_LR_c = griddata(longitude,latitude,SW_N_mean_extratrop_LR,lon_c_m,lat_c_m,'natural');
 SW_mean_interp_ctrl_LR_c      = griddata(longitude,latitude, SW_N_mean_ctrl_LR, lon_c_m,lat_c_m,'natural');
 %SW_mean_interp_extratrop_LR_c(abs(lat_c_m) > 65) = NaN ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn
clear var var_all
bb = dir('*.cam.h0.*_climo.nc');
fname = bb(1,1).name;
lat_c2 = ncread(fname,'lat');
lon_c2 = ncread(fname,'lon');
[lon_c_m2, lat_c_m2] = meshgrid(lon_c2, lat_c2);

cd /shared/SWFluxCorr/high_res/OBS_pop_25NS_crrt_PreIn

    aa1=dir('tavg*.nc');
    tt1=1;
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); 
  latitude2=ncread(filename1,'TLAT'); 
  longitude2=ncread(filename1,'TLONG'); 

SW_S_N_mo_mean_intrp_CAMgrid2 = griddata(lon_fn_msh,lat_fn_msh,SST_Hadley,longitude2,latitude2,'natural');  
  
nn = 0 ;
for tt1=1:length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    var_all(:,:,nn) = var(:,:,1);
end
SW_N_mean_trop_HR = nanmean(var_all,3);
TAREA2 = TAREA ;
II = find(isnan(SW_N_mean_trop_HR) == 1) ;
TAREA2(II) = NaN;

TAREA3 = TAREA ;
JJ = find(isnan(SW_S_N_mo_mean_intrp_CAMgrid2) == 1) ;
TAREA3(JJ) = NaN;

TAREA4 = TAREA ;
TAREA4(II) = NaN;
TAREA4(JJ) = NaN;

var_glb_trop_HR = nansum(nansum(SW_N_mean_trop_HR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_trop_HR = sqrt(nansum(nansum((SW_N_mean_trop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_trop_HR = nansum(nansum((SW_N_mean_trop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
obs_glb = nansum(nansum(SW_S_N_mo_mean_intrp_CAMgrid2 .* TAREA4 ,1),2) ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_35-90NS_crrt_PreIn
    aa1=dir('tavg*.nc');
    tt1=1; 
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    SW_N_mean_extratrop_HR(:,:,nn) = var(:,:,1);
end

var_glb_extratrop_HR = nansum(nansum(SW_N_mean_extratrop_HR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_extratrop_HR = sqrt(nansum(nansum((SW_N_mean_extratrop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_extratrop_HR = nansum(nansum((SW_N_mean_extratrop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)

%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_15-40NS_crrt_PreIn

    aa1=dir('tavg*.nc');
    tt1=1; 
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    var=ncread(filename1,'TEMP');
    SW_N_mean_subtrop_HR(:,:,nn) = var(:,:,1);
end

var_glb_subtrop_HR = nansum(nansum(SW_N_mean_subtrop_HR .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2)
var_rmse_glb_subtrop_HR = sqrt(nansum(nansum((SW_N_mean_subtrop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .^2 .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2))
var_bias_glb_subtrop_HR = nansum(nansum((SW_N_mean_subtrop_HR - SW_S_N_mo_mean_intrp_CAMgrid2) .* TAREA4 ,1),2)...
               ./ nansum(nansum(TAREA4 ,1),2)
            
%%%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;   
    sst = ncread(filename1,'TEMP');
    SW_N_mean_ctrl_HR = sst(:,:,1) ;     
                     
%%%%%%

 SW_mean_interp_obs_c2         = griddata(lon_fn_msh,lat_fn_msh,SST_Hadley,lon_c_m2,lat_c_m2,'natural');
 SW_mean_interp_trop_HR_c      = griddata(longitude2,latitude2, SW_N_mean_trop_HR, lon_c_m2,lat_c_m2,'natural');
 SW_mean_interp_subtrop_HR_c   = griddata(longitude2,latitude2,SW_N_mean_subtrop_HR,lon_c_m2,lat_c_m2,'natural');
 SW_mean_interp_extratrop_HR_c = griddata(longitude2,latitude2,SW_N_mean_extratrop_HR,lon_c_m2,lat_c_m2,'natural');
 SW_mean_interp_ctrl_HR_c      = griddata(longitude2,latitude2, SW_N_mean_ctrl_HR, lon_c_m2,lat_c_m2,'natural');
 %SW_mean_interp_extratrop_HR_c(abs(lat_c_m2) > 65) = NaN ;
%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%
 cd (address)
 color_num = 32 ;
      fig_name = strcat('SST_bias_POP_SENSIT_panel');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,14,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.00 .01],[.01 .01],[.05 .06]) ;           

      
axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_trop_LR_c - SW_mean_interp_obs_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'TC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','xticklabels',[],'tickdir','in','fontsize',11);
    caxis([-4, 4])

axes(ha(3))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_extratrop_LR_c - SW_mean_interp_obs_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'EC-T31 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-4, 4])
      
axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_trop_HR_c - SW_mean_interp_obs_c2),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'TC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','xticklabels',[],'yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-4, 4])

axes(ha(4))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_extratrop_HR_c - SW_mean_interp_obs_c2),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'EC-f19 - obs.';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-4, 4])
    
    
h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(h, 'ylim', [-4 4])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)
 
%%%%%%%%%%%%%%%%%%
 cd (address)
 color_num = 32 ;
      fig_name = strcat('SST_diff_POP_SENSIT_panel');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,14,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
      [ha, pos] = tight_subplot(2,2,[.00 .01],[.01 .01],[.05 .06]) ;           

      
axes(ha(1))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_trop_LR_c - SW_mean_interp_ctrl_LR_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'TC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','xticklabels',[],'tickdir','in','fontsize',11);
    caxis([-2, 2])

axes(ha(3))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_extratrop_LR_c - SW_mean_interp_ctrl_LR_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'EC-T31 - ctrl-T31';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','tickdir','in','fontsize',11);
    caxis([-2, 2])
      
axes(ha(2))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_trop_HR_c - SW_mean_interp_ctrl_HR_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'TC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','xticklabels',[],'yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-2, 2])

axes(ha(4))
    m_proj('miller','long',[0 358],'lat',[-75 75])
    [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_extratrop_HR_c - SW_mean_interp_ctrl_HR_c),32);
    set(h,'LineColor','none')
    m_coast('linewidth',1,'color','black');
    Title_1  = 'EC-f19 - ctrl-f19';
    title(Title_1,'fontsize',15,'fontweight','bold');    
    colormap(brewermap(32,'*RdBu'))
    set(gca,'Fontsize',11)
    m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',11);
    caxis([-2, 2])
    
    
h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
set(h, 'ylim', [-2, 2])
set(gca,'Fontsize',11)

set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')     
print ('-depsc','-tiff','-r600','-painters', fig_name)
 
% %%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%
%  cd (address)
%  color_num = 32 ;
%       fig_name = strcat('SST_bias_POP_SENSIT_panel');
%       fig_dum = figure(1);
%       set(fig_dum, 'name', fig_name,'numbertitle','on');
%       set(fig_dum,'units','inches','position',[0.3,0.3,9,7.5]);%,'PaperOrientation','landscape');
%       set(fig_dum,'paperpositionmode','auto');
%       [ha, pos] = tight_subplot(3,2,[.00 .01],[.01 .01],[.05 .06]) ;           
%       
% axes(ha(1))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_trop_LR_c - SW_mean_interp_obs_c),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'TC-T31 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');    
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','xticklabels',[],'tickdir','in','fontsize',8);
%     caxis([-4, 4])
% 
% axes(ha(3))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_subtrop_LR_c - SW_mean_interp_obs_c),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'SC-T31 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','xticklabels',[],'tickdir','in','fontsize',8);
%     caxis([-4, 4])
% 
% axes(ha(5))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m, lat_c_m, double(SW_mean_interp_extratrop_LR_c - SW_mean_interp_obs_c),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'EC-T31 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');    
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','tickdir','in','fontsize',8);
%     caxis([-4, 4])
%       
% axes(ha(2))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_trop_HR_c - SW_mean_interp_obs_c2),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'TC-f19 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');    
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','xticklabels',[],'yticklabels',[],'tickdir','in','fontsize',8);
%     caxis([-4, 4])
% 
% axes(ha(4))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_subtrop_HR_c - SW_mean_interp_obs_c2),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'SC-f19 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','xticklabels',[],'yticklabels',[],'tickdir','in','fontsize',8);
%     caxis([-4, 4])
% 
% axes(ha(6))
%     m_proj('miller','long',[0 358],'lat',[-75 75])
%     [C, h] =  m_contourf(lon_c_m2, lat_c_m2, double(SW_mean_interp_extratrop_HR_c - SW_mean_interp_obs_c2),32);
%     set(h,'LineColor','none')
%     m_coast('linewidth',1,'color','black');
%     Title_1  = 'EC-f19 - obs.';
%     title(Title_1,'fontsize',12,'fontweight','bold');    
%     colormap(brewermap(32,'*RdBu'))
%     set(gca,'Fontsize',8)
%     m_grid('linewi',1,'linest','none','yticklabels',[],'tickdir','in','fontsize',8);
%     caxis([-4, 4])
%     
%     
% h = colorbar('location','Manual', 'position', [0.95 0.049 0.02 0.905]);
% set(h, 'ylim', [-4 4],'Fontsize',10)
% set(gca,'Fontsize',8)
% 
% set(gcf,'color','w');
% set(gcf, 'PaperPositionMode', 'auto')
% set(gcf,'renderer','Painters')     
% print ('-depsc','-tiff','-r600','-painters', fig_name)
