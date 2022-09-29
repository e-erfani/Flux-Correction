clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
cd monthly_data
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.04*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
    TAREA = ncread(filename1,'TAREA');
    latitude=ncread(filename1,'TLAT'); % lat
    longitude=ncread(filename1,'TLONG'); % lon 

nn = 0 ;    
for tt1=1:length(aa1)/12 %years    
  for tt2=1:12 %months  
    nn = nn + 1 ;   
    filename1=aa1(nn,1).name;
    SST=ncread(filename1,'TEMP'); % surface net Shortwave Radiation (W/m2)
    SST(SST > 1E4) = NaN ;  
    SST_POP_adj(:,:,tt2,tt1) = SST(:,:,1) ; 
  end
end

% II=find(isnan(SST(:,:,1))==1);
% TAREA2 = TAREA ;
% TAREA2(II)=nan;
% test_SST = 273.15 + nansum(nansum(TAREA2 .* SST(:,:,1),1),2) ./ nansum(nansum(TAREA2,1),2) 
% SST_POP_adj_annual = nanmean(SST_POP_adj,3);
% for i = 1:size(SST_POP_adj_annual,4)
%     II=find(isnan(SST_POP_adj_annual(:,:,:,i))==1);
%     TAREA2 = TAREA ;
%     TAREA2(II)=nan;
%     SST_global_annual(i) = 273.15 + nansum(nansum(TAREA2 .* SST_POP_adj_annual(:,:,:,i),1),2) ./ nansum(nansum(TAREA2,1),2) 
%     SST_global_annual_nanmean(i) = 273.15 + nanmean(nanmean(TAREA2 .* SST_POP_adj_annual(:,:,:,i),1),2) ./ nanmean(nanmean(TAREA2,1),2) 
% end
% plot(SST_global_annual)

SST_POP_adj_mean = nanmean(SST_POP_adj,4) ;

for i = 1:size(SST_POP_adj_mean,3)
    II=find(isnan(SST_POP_adj_mean(:,:,i))==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    SST_global_monthly(i) = 273.15 + nansum(nansum(TAREA2 .* SST_POP_adj_mean(:,:,i),1),2) ./ nansum(nansum(TAREA2,1),2) 
    SST_global_monthly_nanmean(i) = 273.15 + nanmean(nanmean(TAREA2 .* SST_POP_adj_mean(:,:,i),1),2) ./ nanmean(nanmean(TAREA2,1),2) 
end

% method 2
for i = 1:size(SST_POP_adj_mean,3)
    tmp = SST_POP_adj_mean(:,:,i) ;
    II=find(isnan(tmp)==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    SST_global_monthly_2(i) = 273.15 + nansum(nansum(TAREA2 .* tmp,1),2) ./ nansum(nansum(TAREA2,1),2) 
    SST_global_monthly_nanmean_2(i) = 273.15 + nanmean(nanmean(TAREA2 .* tmp,1),2) ./ nanmean(nanmean(TAREA2,1),2) 
end

% test = SST_POP_adj_mean(:,:,end) ;
%     SST_global_monthly_test = 273.15 + nansum(nansum(TAREA2 .* test,1),2) ./ nansum(nansum(TAREA2,1),2) 

%%%%%
month = 1:12 ;
        fig_name = strcat('SST_global_monthly');
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,10,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(month , SST_global_monthly,'k','linewidth',2)
hold on
plot(month , SST_global_monthly,'ob','linewidth',4)
    xlabel('Time (month)','fontsize',23,'fontweight','bold');    
    ylabel('Global Sea Surface Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
   % ylim([287.8 289])
    xlim([0.5 12.5])
  box on  
 cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);
