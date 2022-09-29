clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

%%%%
cd /shared/SWFluxCorr/OA_Flux
load ('lat_msh_OAFlux.mat')
load ('lon_msh_OAFlux.mat')
load ('Qnet_average_OA.mat')
lat_msh_OAFlux = double(lat_msh_OAFlux) ;
lon_msh_OAFlux = double(lon_msh_OAFlux) ;
    
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.*.anmn.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
      latitude =ncread(filename1,'TLAT');
    longitude =ncread(filename1,'TLONG');

nn = 0 ;
%for tt1=length(aa1) - 100 + 1:length(aa1)
for tt1=1:length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SHF=ncread(filename1,'SHF'); % net heat flux at surface (W/m2)
    SHF_all(:,:,nn) = SHF;      
end
Qnet_model = nanmean(SHF_all,3);

    Qnet_average_intrp = griddata(lon_msh_OAFlux,lat_msh_OAFlux,Qnet_average',longitude,latitude,'natural');

    %%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(Qnet_model) ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Qnet_surf_POPgrid','_annual_last100');
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
    Title_1 = strcat('Net Surface Heat Flux  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-180, 180])
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr        
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);       
     
 %%%%%%     
      cellsize = 0.5; 
SST_T31(:,:,1)  = double(Qnet_model - Qnet_average_intrp) ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('bias_Qnet_surf_POPgrid','_annual_last100');
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
    Title_1 = strcat('CESM - OAFlux, Net Surface Heat Flux  (W m^-^2)', ', Annual Mean');
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-150, 150])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
       