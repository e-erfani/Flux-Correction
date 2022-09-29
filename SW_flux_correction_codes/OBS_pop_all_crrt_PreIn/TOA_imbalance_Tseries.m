clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 
purple = [0.5 0 0.5] ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ; cd (address)
    aa=dir('*anmn.nc');
    tt=1; % ncdisp(aa(tt,1).name)
    filename=aa(tt,1).name;
  gw=ncread(filename,'gw'); % surface net Shortwave Radiation (W/m2)
    lat =ncread(filename,'lat');
    lon =ncread(filename,'lon');
[lon_msh,lat_msh] = meshgrid(lon,lat);
      I=length(lon);
      GW=repmat(gw,[1 I])';

cases = {'OBS_pop_all_crrt_PreIn'} ;
cd ..
for i = 1:length(cases)
cd (char(cases(:,i)))
    aa=dir('*cam*anmn.nc');
for tt=1:length(aa)
    filename=aa(tt,1).name;
    fsnt =ncread(filename,'FSNT'); 
    flnt =ncread(filename,'FLNT'); 
    var_all(:,:,tt) = fsnt - flnt ;

    II=find(isnan(var_all(:,:,tt))==1);
    GW2 = GW ;
    GW2(II)=nan;
    var_glb(i,tt) = nansum(nansum(GW2 .* var_all(:,:,tt),1),2) ./ nansum(nansum(GW2,1),2) ;
end
cd ..
end
var_glob_mean = nanmean(var_glb(:,21:end),2)

%%%%%%%%%
time = 1:size(var_glb,2) ;
       fig_name = strcat('TOA_imblnc_T_SERIES_GLOBAL');%,num2str(tt));
        fig_dum = figure(3);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
cl = ['b','r','m','g','k','b','r','m','g']; 
%st = ['-','-','-','-','-','--','--','--','--'] ;
nb = [17:20 12 16:-1:13] ;
j = 1;
% for j = 1:5 
% if (j==3)
%     h(j)=plot(time,squeeze(var_Tseries_smooth(j,:)),'color',purple,'linewidth',2) ; hold on;
% else    
     h(j)=plot(time,squeeze(var_glb(j,:)),'color',cl(j),'linewidth',2) ; hold on;
% end
% end
% for j = 6:9
% if (j==8)
%     h(j)=plot(time,squeeze(var_Tseries_smooth(j,:)),'--','color',purple,'linewidth',2) ; hold on;
% else    
%     h(j)=plot(time,squeeze(var_Tseries_smooth(j,:)),'--','color',cl(j),'linewidth',2) ; hold on;
% end
% end
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Global TOA imbalance (Wm^-^2)','fontsize',23,'fontweight','bold');
%    hleg1 = legend([h(5) h(9) h(8) h(7) h(6) h(1) h(2) h(3) h(4)],'12',...
%          '13','14','15','16','17','18','19','20');% ,'SOM');
%     set(hleg1,'Location','NorthEast','Fontsize',17)%h_legend-4)
%     set(hleg1,'Interpreter','none')%,'box','Off')        
 set(gca,'FontSize',20,'linewidth',1.5)
 % ylim([156 158.6])
  xlim([-10 610])
  box on
cd (address) 
print ('-r600', fig_name,'-depsc')     
 