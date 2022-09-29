clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
   % cd /project/airsea/SWflux/PreInd_T31_gx3v7/DIAGS_401_900
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7_ANN_climo.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa(tt1,1).name;
  gw=ncread(filename1,'gw');
    land_frc=ncread(filename1,'LANDFRAC'); % Temp (K)
    sea_frc = 1 - land_frc ;
  lev=ncread(filename1,'lev'); 
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lon_fn_msh,lat_fn_msh] = meshgrid(longitude,latitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';

    T=ncread(filename1,'T'); % Temp (K)
    T_sfc = T(:,:,end) ;

T_sfc_ocn_mean(1) = nansum(nansum(GW .* T_sfc .* sea_frc,1),2) ./ nansum(nansum(GW .* sea_frc,1),2) 

%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(T_sfc) ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('T_sfc','_climo');
        fig_dum = figure(300);
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
    Title_1 = strcat('Air temperature at surface  (K)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([220, 300])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       

%%%%%%%      
%monthly mean
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7_*_climo*');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa(tt1,1).name;
  gw=ncread(filename1,'gw');
  lev=ncread(filename1,'lev'); 
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lon_fn_msh,lat_fn_msh] = meshgrid(longitude,latitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
for i  = 1: 12
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    filename1 = aa(i,1).name;
    T=ncread(filename1,'T'); % Temp (K)
    T_sfc = T(:,:,end) ;
T_sfc_ocn_mean(i+1) = nansum(nansum(GW .* T_sfc .* sea_frc,1),2) ./ nansum(nansum(GW .* sea_frc,1),2) ;
T_sfc_glb_mean(i+1) = nansum(nansum(GW .* T_sfc,1),2) ./ nansum(nansum(GW,1),2) ;


%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(T_sfc) ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
%        fig_name = strcat('T_sfc','_climo_',num2str(i));
%         fig_dum = figure(i);
%       set(fig_dum, 'name', fig_name,'numbertitle','on');
%       set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
%       set(fig_dum,'paperpositionmode','auto');
%        m_proj('miller','long',[0 358],'lat',[-75 75])       
%     axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
%    'Frame','off','Grid','off')
% AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
%     set(AA,'FaceColor','flat','Linestyle','-'); 
%     setm(gca,'frame','on');
%     setm(gca,'fontsize',12);
%     setm(gca,'FEdgeColor',[1 1 1]);
%   m_coast('linewidth',2,'color','black');
%     Title_1 = strcat('Air temperature at surface  (K), ', month(i), 'Mean');
%     title(Title_1,'fontsize',23,'fontweight','bold');
%     cc = colorbar('peer',gca);
%     set(gca,'Fontsize',20)
%     m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
%     caxis([220, 300])
% cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
%   eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
end

time = 0.5:11.5 ;
        fig_name = strcat('T_lowest_air_ocean');
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,10,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time,T_sfc_ocn_mean(2:end),'b','linewidth',4)
    xlabel('Time (month)','fontsize',23,'fontweight','bold');
    ylabel('Ocean lowest level air Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
    ylim([285.8 287])
  box on  
 cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);

%%%%%%  
time = 0.5:11.5 ;
        fig_name = strcat('T_lowest_air_global');
        fig_dum = figure(1007);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,10,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time, T_sfc_glb_mean(2:end),'b','linewidth',4)
    xlabel('Time (month)','fontsize',23,'fontweight','bold');
    ylabel('Global lowest level air Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
    ylim([282 288])
  box on  
 cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);
      

dbstop

 nccreate('Land_Frac_T31_gx3v7.nc','LANDFRAC','Dimensions',{'lon',96,'lat',48},'Format','classic');
 nccreate('Land_Frac_T31_gx3v7.nc','lat','Dimensions',{'lon',96,'lat',48},'Format','classic');
 nccreate('Land_Frac_T31_gx3v7.nc','lon','Dimensions',{'lon',96,'lat',48},'Format','classic'); 
 ncwrite('Land_Frac_T31_gx3v7.nc','LANDFRAC',double(land_frc));
 ncwrite('Land_Frac_T31_gx3v7.nc','lat',lat_fn_msh');
 ncwrite('Land_Frac_T31_gx3v7.nc','lon',lon_fn_msh');

%%%%%%
land_frc = ncread('Land_Frac_T31_gx3v7.nc','LANDFRAC');
    lat_fn_msh =ncread('Land_Frac_T31_gx3v7.nc','lat');
    lon_fn_msh =ncread('Land_Frac_T31_gx3v7.nc','lon');
cellsize = 0.5; 
SST_T31(:,:,1)  = land_frc;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];  
        fig_name = strcat('land_fraction');
        fig_dum = figure(317);
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
    Title_1 = strcat('Land Fraction', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 1.001])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);
 