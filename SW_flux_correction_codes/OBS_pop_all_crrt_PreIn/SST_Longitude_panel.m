    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
purple = [0.5 0 0.5] ;
lat_thr = 2 ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ; 
cd (address)
    aa1=dir('tavg.*.nc');
    filename1=aa1(1,1).name;
    TAREA=ncread(filename1,'TAREA');
    lat =ncread(filename1,'TLAT');
    lon =ncread(filename1,'TLONG');    
    sst=ncread(filename1,'TEMP'); 
    sst_mean = sst(:,:,1);      

    II=find(isnan(sst_mean)==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    
idx = find(lat(65,:) >= -lat_thr & lat(65,:) <= lat_thr) ;
TAREA_trim = TAREA2(:,idx) ;
SST_ajd_trim_mean = nansum(TAREA2(:,idx) .* sst_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ;

%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1=dir('tavg.*.nc');
    filename1=aa1(1,1).name;
    sst = ncread(filename1,'TEMP'); 
    sst_ctrl_mean = sst(:,:,1); 
SST_ctrl_trim_mean = nansum(TAREA2(:,idx) .* sst_ctrl_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 

long = nansum(TAREA(:,idx) .* lon(:,idx),2) ./ nansum(TAREA(:,idx),2) ;
idy = find(long > 130 & long < 280);

%%%%%
cd /homes/eerfani/Bias
load ('SST_Hadley.mat')
load ('lat_HadI.mat')
load ('lon_HadI.mat')

lon_HadI_2 = lon_HadI ;
SST_Hadley_2 = SST_Hadley ;
lon_HadI_2(181:360,:) = lon_HadI(1:180,:) ;
lon_HadI_2(1:180,:)   = lon_HadI(181:360,:) ;
SST_Hadley_2(181:360,:) = SST_Hadley(1:180,:) ;
SST_Hadley_2(1:180,:)   = SST_Hadley(181:360,:) ;

SST_Hadley_interp = griddata(double(lon_HadI_2),double(lat_HadI),SST_Hadley_2,lon,lat,'natural');
SST_hadley_intrp_trim = nansum(TAREA2(:,idx) .* SST_Hadley_interp(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 
SST_hadley_trim_mean = nanmean(SST_hadley_intrp_trim,2) ;

%%%%%%%%
%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn
    aa1=dir('tavg.*.nc');
    filename1=aa1(1,1).name;
    TAREA=ncread(filename1,'TAREA');
    lat_hr =ncread(filename1,'TLAT');
    lon_hr =ncread(filename1,'TLONG');    
    sst=ncread(filename1,'TEMP'); 
    sst_mean = sst(:,:,1);      

    II=find(isnan(sst_mean)==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    
idx = find(lat_hr(65,:) >= -lat_thr & lat_hr(65,:) <= lat_thr) ;
TAREA_trim = TAREA2(:,idx) ;
SST_ajd_trim_mean_hr = nansum(TAREA2(:,idx) .* sst_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ;

long_hr = nansum(TAREA(:,idx) .* lon_hr(:,idx),2) ./ nansum(TAREA(:,idx),2) ;
idy_hr = find(long_hr > 130 & long_hr < 280);

%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16
    aa1=dir('tavg.*.nc');
    filename1=aa1(1,1).name;
    sst = ncread(filename1,'TEMP'); 
    sst_ctrl_mean = sst(:,:,1); 
SST_ctrl_trim_mean_hr = nansum(TAREA2(:,idx) .* sst_ctrl_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 

%%%%%%%%%%%%%
      fig_name = strcat('SST_Longitude_all');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(long(idy),SST_ajd_trim_mean(idy),'r','linewidth',2) ;
hold on
h2 = plot(long(idy),SST_ctrl_trim_mean(idy),'r--','linewidth',2) ;
hold on
h3 = plot(long(idy),SST_hadley_intrp_trim(idy),'k','linewidth',2) ;
hold on
h4 = plot(long_hr(idy_hr),SST_ajd_trim_mean_hr(idy_hr),'b','linewidth',2) ;
hold on
h5 = plot(long_hr(idy_hr),SST_ctrl_trim_mean_hr(idy_hr),'b--','linewidth',2) ;

    xlabel('Longitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('SST (\circC)','fontsize',20,'fontweight','bold');
xlim([130 280])
ylim([21.5 30])
   hleg1 = legend([h2 h1 h5 h4 h3 ],'ctrl-T31','GC-T31','ctrl-f19','GC-f19','obs.');
    set(hleg1,'Location','NorthEast','Fontsize',16)%h_legend-4)
    set(hleg1,'Interpreter','none')%,'box','Off')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)
