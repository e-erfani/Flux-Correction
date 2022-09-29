clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/8CHEY_rhminl_PreInd_T31_gx3v7
      aa1=dir('8CHEY_rhminl_PreInd_T31_gx3v7.pop.h.0481-01.nc');
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
    SST_Tseries2(i) = 273.15 + nansum(nansum(TAREA .* SST_POP_adj(:,:,i),1),2) ./ nansum(nansum(TAREA,1),2) 
end
  %  SST_Tseries2 = 273.15 + nansum(nansum(TAREA .* SST_POP_adj,1),2) ./ nansum(nansum(TAREA,1),2) 

SST_average_TEST = nanmean(SST_POP_adj,3);
  
SST_output = xlsread('7CHEY_fraction_T_glb_.xlsx');
time = 1 : 30/length(SST_output) : 31 ;

%%%%%
fig_name = strcat('SST_ctrl_TIME_SERIES');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
%h1 = plot(time(2:end),SST_output,'k','linewidth',2) ;
h1 = plot(SST_output,'k','linewidth',2) ;

    xlabel('Time','fontsize',23,'fontweight','bold');
    ylabel('SST (K)','fontsize',23,'fontweight','bold');
    %   hleg1 = legend([h1 h2 h3],'Instantaneous','CESM monthyl output','Mean of Instantaneous');
  %  set(hleg1,'Location','NorthWest','Fontsize',19)%h_legend-4)
  %  set(hleg1,'Interpreter','none')%,'box','Off')
    set(gca,'Fontsize',20,'linewidth',1.5)
  % ylim([285.5 287.5])
  % xlim([450 1100])
  box on
cd /shared/SWFluxCorr/CESM/8CHEY_rhminl_PreInd_T31_gx3v7
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   
  