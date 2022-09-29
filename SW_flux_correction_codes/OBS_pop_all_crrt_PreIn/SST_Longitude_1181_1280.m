    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 
purple = [0.5 0 0.5] ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ; 
cd (address)

    aa1=dir('tavg.1181-1280.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
  TAREA=ncread(filename1,'TAREA'); % surface net Shortwave Radiation (W/m2)
    lat =ncread(filename1,'TLAT');
    lon =ncread(filename1,'TLONG');
    
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    sst=ncread(filename1,'TEMP'); 
    sst_all(:,:,nn) = sst(:,:,1);      
end
    sst_mean = nanmean(sst_all,3) ;

    II=find(isnan(sst_mean)==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    
%idx = find(lat(65,:) >= -2 & lat(65,:) <= 2) ;
%idx = find(lat(65,:) >= -3 & lat(65,:) <= 3) ;
%idx = find(lat(65,:) >= -8 & lat(65,:) <= 4) ;
idx = find(lat(65,:) >= -8 & lat(65,:) <= 8) ;
TAREA_trim = TAREA2(:,idx) ;
SST_ajd_trim_mean = nansum(TAREA2(:,idx) .* sst_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 

%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
load ('SST_POP_adj')
SST_ctrl_mean = nanmean(SST_POP_adj,3) ;
SST_ctrl_trim_mean = nansum(TAREA2(:,idx) .* SST_ctrl_mean(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 

%%%%%
cd /homes/eerfani/Bias
load ('SST_Hadley_interp.mat')

SST_hadley_trim_mean = nansum(TAREA2(:,idx) .* SST_mean_interp(:,idx),2) ./ nansum(TAREA2(:,idx),2) ; 

long = nansum(TAREA(:,idx) .* lon(:,idx),2) ./ nansum(TAREA(:,idx),2) ; 
idy = find(long > 130 & long < 280);
%%%%%%%%%%%%%
       fig_name = strcat('SST_Longitude_1181_1280_8_8');%,num2str(tt));
        fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,11,8]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(long(idy),SST_ajd_trim_mean(idy),'b','linewidth',3) ;
hold on
h2 = plot(long(idy),SST_ctrl_trim_mean(idy),'r','linewidth',3) ;
hold on
h3 = plot(long(idy),SST_hadley_trim_mean(idy),'k','linewidth',3) ;
   % setm(gca,'fontsize',12);
 %   Title_1 = 'Time Series of Sea Surface Temperature  (deg C)';
    xlabel('Longitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('SST (\circC)','fontsize',23,'fontweight','bold');
xlim([130 280])
%ylim([21.5 30]) % 2_2
%ylim([22 30]) % 3_3
%ylim([22.5 29.5]) % 4_4
ylim([23.5 29.5]) % 8_8
   hleg1 = legend([h2 h1 h3],'CESM control','CESM correction','Hadley SST');
    set(hleg1,'Location','NorthEast','Fontsize',19)%h_legend-4)
    set(hleg1,'Interpreter','none')%,'box','Off')
set(gca,'Fontsize',20,'linewidth',2)
box on
cd (address)
print ('-r600', fig_name,'-depsc')     
