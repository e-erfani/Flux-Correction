    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
aa=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h*.anmn.nc');

    tt=1; % ncdisp(aa(tt,1).name)    
nn = 0 ;
for tt=1:length(aa)
    nn = nn + 1 ;
    filename=aa(tt,1).name;
    SW_N=ncread(filename,'SHF_QSW'); % surface net Shortwave Radiation (W/m2)
    SW_N(SW_N > 1.5E3) = NaN ;  
    latitude=ncread(filename,'TLAT'); % lat
    longitude=ncread(filename,'TLONG'); % lon 
    SW_N_all(:,:,nn) = SW_N(:,:,1) ;    
 end
 SW_N_mean = nanmean(SW_N_all,3) ; 
%%%%%  
  cellsize = 0.5; 
SST_T31(:,:,1)  = SW_N_mean ;
lat_T31(:,:,1)  = latitude ;
lon_T31(:,:,1)  = longitude ;
 latlim = [-75 75];
 lonlim = [1 360];
 
[Z(:,:,1),refvec(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);

       fig_name = strcat('SW_N_POP');%,num2str(tt));
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 360],'lat',[-75 75]) 
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z(:,:,1)), squeeze(refvec(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
   set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
    m_coast('linewidth',2,'color','black');
    Title_1 = 'SW Net Flux  (W/m^2), Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
  set(gca,'Visible','off')     
    caxis([0, 300])
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);     
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
  