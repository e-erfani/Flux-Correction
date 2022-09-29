clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.*anmn.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
    TAREA = ncread(filename1,'TAREA');
    latitude=ncread(filename1,'TLAT'); % lat
    longitude=ncread(filename1,'TLONG'); % lon 
    
for tt1=1:length(aa1)    
    filename1=aa1(tt1,1).name;
    SST=ncread(filename1,'TEMP'); % surface net Shortwave Radiation (W/m2)
    SST(SST > 1E4) = NaN ;  
    SST_POP_adj(:,:,tt1) = SST(:,:,1) ;    
end


for i = 1:size(SST_POP_adj,3)
    II=find(isnan(SST_POP_adj(:,:,i))==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;    
    SST_Tseries(i) = nansum(nansum(TAREA2 .* SST_POP_adj(:,:,i),1),2) ./ nansum(nansum(TAREA2,1),2) ; 
end
SST_average = nanmean(SST_POP_adj,3);

%%%%%%
time = 401:500 ;
       fig_name = strcat('SST_ctrl_TIME_SERIES_GLOBAL');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time,squeeze(SST_Tseries+273.15),'k','linewidth',2)
hold on
% plot(time2,squeeze(SST_ajd_annual_m_10),'k','linewidth',3)
   % setm(gca,'fontsize',12);
 %   Title_1 = 'Time Series of Sea Surface Temperature  (deg C)';
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Global SST (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
    ylim([289.6 289.9])
  box on
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);    
  
  %%%%%%%
idx = find(latitude(65,:) >= -2 & latitude(65,:) <= 2) ;
idy = find(longitude(:,50) >= 150 & longitude(:,50) <= 260) ;
SST_POP_adj_trim = SST_POP_adj(idy,idx,:) ;
SST_POP_adj_trim_mean = nanmean(SST_POP_adj_trim,3) ;
TAREA_trim = TAREA(idy,idx) ;

for i = 1:length(SST_POP_adj_trim)
    II=find(isnan(SST_POP_adj_trim(:,:,i))==1);
    TAREA_trim2 = TAREA_trim ;
    TAREA_trim2(II)=nan;        
    SST_ajd_trim_mean(i) = nansum(nansum(TAREA_trim2 .* SST_POP_adj_trim(:,:,i),1),2) ./ nansum(nansum(TAREA_trim2,1),2) ;  
end


       fig_name = strcat('SST_ctrl_TIME_SERIES_TROPIC');%,num2str(tt));
        fig_dum = figure(30);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time,squeeze(SST_ajd_trim_mean+273.15),'k','linewidth',2)
hold on
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Tropical SST (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
  box on
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);    
  