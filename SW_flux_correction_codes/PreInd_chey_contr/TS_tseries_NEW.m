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
    TS =double(ncread(filename1,'TS'));
    TS_all(:,:,tt1) = TS;
end

for i = 1:size(TS_all,3)
    TS_Tseries(i) = nansum(nansum(GW .* TS_all(:,:,i),1),2) ./ nansum(nansum(GW,1),2) ; 
end

%%%%%%
%time = 481:580 ;
time2 = 481:575 ;

       fig_name = strcat('TS_TIME_SERIES_GLOBAL');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
plot(time2,squeeze(TS_Tseries),'k','linewidth',2)
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Surface Temperature (\circC)','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',1.5)

  box on
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
  eval(['print -r600 -djpeg ', fig_name,'.jpg']);    
  