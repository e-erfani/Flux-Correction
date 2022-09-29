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
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.cam.h0.*.anmn.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  gw=ncread(filename1,'gw'); % surface net Shortwave Radiation (W/m2)
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lon_msh,lat_msh] = meshgrid(longitude,latitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';
nn = 0 ;
for tt1=length(aa1) - 100 + 1:length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    LH_S=ncread(filename1,'LHFLX'); % Latent heat flux at surface (W/m2)
    SH_S=ncread(filename1,'SHFLX'); % Sensible heat flux at surface (W/m2)
    LW_N=ncread(filename1,'FLNS'); % Net LW flux at surface (W/m2)
    LH_S_all(:,:,nn) = LH_S;      
    SH_S_all(:,:,nn) = SH_S; 
    LW_N_all(:,:,nn) = LW_N;     
end
LH_S_average = nanmean(LH_S_all,3);
SH_S_average = nanmean(SH_S_all,3);
LW_N_average = nanmean(LW_N_all,3);
LW_LH_LS = double(LH_S_average + SH_S_average + LW_N_average) ;

%%%
load SW_N_mean_POP.mat
load latitude_POP.mat 
load longitude_POP.mat
%%%%

    Qnet_average_intrp = griddata(lon_msh_OAFlux,lat_msh_OAFlux,Qnet_average',lon_msh,lat_msh,'natural');
    SW_N_mean_intrp = griddata(longitude,latitude,SW_N_mean,lon_msh,lat_msh,'natural');
Qnet_model = SW_N_mean_intrp' - LW_LH_LS ;    

 II=find(isnan(Qnet_average_intrp')==1);
GW2 = GW ;
GW2(II)=nan; Qnet_model(II) = NaN; 
Qnet_glb =  nansum(nansum(GW2 .* Qnet_model,1),2) ./ nansum(nansum(GW2,1),2) 
Qnet_rmse =  sqrt(nansum(nansum(GW2 .* (Qnet_model - Qnet_average_intrp') .^ 2,1),2) ./ nansum(nansum(GW2,1),2)) 

%%%%%
cellsize = 0.5; 
SST_T31(:,:,1)  = double(Qnet_model) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('Qnet_surf_CESM_CAMgrid','_annual_last100');
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
SST_T31(:,:,1)  = double(Qnet_model - Qnet_average_intrp') ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)'), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360]; 
 
       fig_name = strcat('bias_Qnet_surf_CESM_CAMgrid','_annual_last100');
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
       