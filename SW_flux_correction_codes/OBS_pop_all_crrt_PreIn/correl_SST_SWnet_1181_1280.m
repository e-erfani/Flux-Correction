    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 
address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
cd (address)

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
    SW_N=ncread(filename1,'SHF_QSW'); 
    SW_N_all(:,:,nn) = SW_N;          
end
sst_mean = nanmean(sst_all,3) ;
SW_N_mean = nanmean(SW_N_all,3);    
TAREA2 = TAREA ;
II = find(isnan(sst_mean) == 1) ;
TAREA2(II) = NaN;
var_glb = nansum(nansum(sst_mean .* TAREA2 ,1),2) ./ nansum(nansum(TAREA2 ,1),2) 

%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr

    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SW_N=ncread(filename1,'SHF_QSW'); 
    SW_N_all_ctrl(:,:,nn) = SW_N; 
    sst=ncread(filename1,'TEMP'); 
    sst_all_ctrl(:,:,nn) = sst(:,:,1);          
end

diff_SST = sst_mean - sst_all_ctrl;
diff_SW = SW_N_mean - SW_N_all_ctrl;
kk = find (sst_mean > -1000);
[correl, P] = corrcoef(diff_SST(kk),diff_SW(kk)) ;

dbstop

glb_correl = nansum(nansum(correl .* TAREA2 ,1),2)...
               ./ nansum(nansum(TAREA2 ,1),2)

%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(correl) ;
lat_T31(:,:,1)  = lat_pop ;
lon_T31(:,:,1)  = lon_pop ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('correlation_SST_SWnet_1181_1280');%,num2str(tt));
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
    Title_1 = strcat('Correlation b/w SST and SWnet, POP, Annual Mean=',num2str(glb_correl));    
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-1, 1])
cd (address)
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
          