clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.cam.h0.*anmn.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
          land_frc=ncread(filename1,'LANDFRAC'); % Temp (K)
    sea_frc = 1 - land_frc ;
  gw=ncread(filename1,'gw'); % surface net Shortwave Radiation (W/m2)
    latitude =ncread(filename1,'lat');
    longitude =ncread(filename1,'lon');
[lon_fn_msh,lat_fn_msh] = meshgrid(longitude,latitude);

      I=length(longitude);
      GW=repmat(gw,[1 I])';

for tt1=1:length(aa1)
    filename1=aa1(tt1,1).name;
    T =ncread(filename1,'T'); % T
    T_sfc_all(:,:,tt1) = T(:,:,end);
end


for i = 1:length(T_sfc_all)
    T_sfc_Tseries(i) = nansum(nansum(GW .* T_sfc_all(:,:,i),1),2) ./ nansum(nansum(GW,1),2) ; 
    T_sfc_ocn_mean(i) = nansum(nansum(GW .* T_sfc_all(:,:,i) .* sea_frc,1),2) ./ nansum(nansum(GW .* sea_frc,1),2)     
end
T_sfc_average = nanmean(T_sfc_all,3);

%%%%%%
time = 1:500 ;
       fig_name = strcat('T_air_lowest_ctrl_TIME_SERIES_GLOBAL');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time,squeeze(T_sfc_Tseries),'k','linewidth',2)
hold on
% plot(time2,squeeze(SST_ajd_annual_m_10),'k','linewidth',3)
   % setm(gca,'fontsize',12);
 %   Title_1 = 'Time Series of Sea Surface Temperature  (deg C)';
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Global lowest level air Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
  ylim([284.2 286.7])
  box on
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);    

  %%%%%
       fig_name = strcat('T_air_lowest_ctrl_TIME_SERIES_OCEAN');%,num2str(tt));
        fig_dum = figure(30);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time,squeeze(T_sfc_ocn_mean),'k','linewidth',2)
hold on
% plot(time2,squeeze(SST_ajd_annual_m_10),'k','linewidth',3)
   % setm(gca,'fontsize',12);
 %   Title_1 = 'Time Series of Sea Surface Temperature  (deg C)';
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Ocean lowest level air Temperature (K)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)
   ylim([286 288.5])
  box on
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);   
  