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

    T=ncread(filename1,'TS'); % Temp (K)
    T_sfrc = T ;

T_sfc_glb_mean(1) = nansum(nansum(GW .* T_sfrc .* sea_frc,1),2) ./ nansum(nansum(GW .* sea_frc,1),2) 


%%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(T_sfrc) ;
lat_T31(:,:,1)  = lat_fn_msh ;
lon_T31(:,:,1)  = lon_fn_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('TS','_climo');
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
    Title_1 = strcat('Surface temperature (K)', ', Annual Mean');
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
    T=ncread(filename1,'TS'); % Temp (K)
    T_sfrc = T ;
T_sfc_glb_mean(i+1) = nansum(nansum(GW .* T_sfrc .* sea_frc,1),2) ./ nansum(nansum(GW .* sea_frc,1),2) ;


%%%%%%
% cellsize = 0.5; 
% SST_T31(:,:,1)  = double(T_sfrc) ;
% lat_T31(:,:,1)  = lat_fn_msh ;
% lon_T31(:,:,1)  = lon_fn_msh ; 
% [Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
%  latlim = [-75 75];
%  lonlim = [1 360]; 
%  
%        fig_name = strcat('TS','_climo_',num2str(i));
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
%     Title_1 = strcat('surface temperature (K), ', month(i), 'Mean');
%     title(Title_1,'fontsize',23,'fontweight','bold');
%     cc = colorbar('peer',gca);
%     set(gca,'Fontsize',20)
%     m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
%     caxis([220, 300])
% cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
%   eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
end


        fig_name = strcat('TS_ocean');
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,10,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(T_sfc_glb_mean(2:end),'b','linewidth',2)
    xlabel('Time (month)','fontsize',23,'fontweight','bold');
    ylabel('Ocean surface Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
    ylim([287.8 289])
  box on  
 cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);
