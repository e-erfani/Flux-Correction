    clc
    clear
path(path,'/homes/eerfani/Bias/m_map')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.0471-0570._*_climo.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
    lat_msh =ncread(filename1,'TLAT');
    lon_msh =ncread(filename1,'TLONG');

TAREA=ncread(filename1,'TAREA'); % surface net Shortwave Radiation (W/m2)

nn = 0 ;
for tt1=1:12%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    temp=ncread(filename1,'TEMP'); 
    temp(temp > 100) = NaN ;
    temp(temp < -200) = NaN ;
    sst_all(:,:,nn) = temp(:,:,1);      
end
sst_mean = nanmean(sst_all,3) ;
sst_zonal = nanmean(sst_mean,1);
    
       fig_name = strcat('Line_SST');%,num2str(tt));
        fig_dum = figure(3100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_msh(50,:),sst_zonal','k','linewidth',2) ;
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Downward SW bias coefficient','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
   % ylim([0.75 1.2001])
    xlim([-90 90])
  box on
eval(['print -r600 -djpeg ', fig_name,'.jpg']);  

%%%%%%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = sst_mean;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SST_annual_Chey_ctrl_FILE_POP_NEW');%,num2str(tt));
        fig_dum = figure(100);
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
    Title_1 = 'SST, CESM (ctrl), \circC, Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
                    colormap(brewermap(30,'*RdBu'))    
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0, 30])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      
%%%%
TAREA2 = TAREA ;
II = find(isnan(sst_mean)== 1) ;
TAREA2(II) = NaN ;
sst_glb_mean = nansum(nansum(TAREA2 .* sst_mean,1),2) ./ nansum(nansum(TAREA2,1),2)

%%%%%
dbstop   
 nccreate('sst_POP_Chey_ctrl.nc','sst_mean','Dimensions',{'lon',100,'lat',116},'Format','classic');
 nccreate('sst_POP_Chey_ctrl.nc','lat','Dimensions',{'lon',100,'lat',116},'Format','classic');
 nccreate('sst_POP_Chey_ctrl.nc','lon','Dimensions',{'lon',100,'lat',116},'Format','classic'); 
 ncwrite('sst_POP_Chey_ctrl.nc','sst_mean',sst_mean);
 ncwrite('sst_POP_Chey_ctrl.nc','lat',lat_msh);
 ncwrite('sst_POP_Chey_ctrl.nc','lon',lon_msh);
    
Test_sst = ncread('sst_POP_Chey_ctrl.nc','sst_mean') ;
Test_lat = ncread('sst_POP_Chey_ctrl.nc','lat') ;
Test_lon = ncread('sst_POP_Chey_ctrl.nc','lon') ;

clear SST_T31; clear lat_T31; clear lon_T31
  cellsize = 0.5;
SST_T31(:,:,1)  = double(nanmean(Test_sst,3)) ;
lat_T31(:,:,1)  = Test_lat ;
lon_T31(:,:,1)  = Test_lon ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('sst_annual_fromFILE_POP_NEW');%,num2str(tt));
        fig_dum = figure(120);
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
    Title_1 = 'SST, CESM(ctrl), \circC, Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0 30])
