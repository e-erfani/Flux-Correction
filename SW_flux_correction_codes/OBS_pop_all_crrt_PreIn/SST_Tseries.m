clc 
clear
path(path,'/homes/eerfani/Bias/m_map') 
purple = [0.5 0 0.5] ;

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ; cd (address)
    aa=dir('*pop.h*anmn.nc');
     tt=1; % ncdisp(aa(tt,1).name)
    filename=aa(tt,1).name;
  TAREA=ncread(filename,'TAREA'); % surface net Shortwave Radiation (W/m2)
    lat_msh =ncread(filename,'TLAT');
    lon_msh =ncread(filename,'TLONG');

cases = {'OBS_pop_all_crrt_PreIn'} ;
cd ..
for i = 1:length(cases)
cd (char(cases(:,i)))
    aa=dir('*pop.h*anmn.nc');
for tt=1:length(aa)
    filename=aa(tt,1).name;
    var=ncread(filename,'TEMP'); % ocn temp
    var(var > 1E4) = NaN ;  
    var_all(:,:,tt) = var(:,:,1) ;   

    II=find(isnan(var_all(:,:,tt))==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    var_Tseries(i,tt) = nansum(nansum(TAREA2 .* var_all(:,:,tt),1),2) ./ nansum(nansum(TAREA2,1),2) ;     

end
cd ..
end
var_glob_mean = nanmean(var_Tseries(:,end-100:end),2)

var_Tseries_L100 = var_Tseries(:,end-99:end);
t = 1:100 ;
P = polyfit(t,var_Tseries_L100,1);
fit = P(1) .* t + P(2);
drift = fit(end) - fit(1)

%%%%%
smt = 20 ;
var_Tseries2(1:size(var_Tseries,1),1:size(var_Tseries,2)+2*smt) = NaN ;
for i = 1:size(var_Tseries2,1)
  for j=1:size(var_Tseries,2)
    var_Tseries2(i,j+smt) = var_Tseries(i,j) ;
  end
    var_Tseries_smooth(i,:) = smooth(var_Tseries2(i,:),smt);
end

var_Tseries_smooth(:,1:smt) = [] ;
var_Tseries_smooth(:,end-smt+1:end) = [] ;

%%%%%%%%%
time = 1:size(var_Tseries,2) ;
       fig_name = strcat('SST_T_SERIES_GLOBAL_smt');%,num2str(tt));
        fig_dum = figure(1);
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
     h(j)=plot(time,squeeze(var_Tseries(j,:)),'color',cl(j),'linewidth',1) ; hold on;
     h2=plot(time,squeeze(var_Tseries_smooth(j,:)),'color',cl(j),'linewidth',4) ; hold on;     
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
    ylabel('Global SST (\circC)','fontsize',23,'fontweight','bold');
%    hleg1 = legend([h(5) h(9) h(8) h(7) h(6) h(1) h(2) h(3) h(4)],'12',...
%          '13','14','15','16','17','18','19','20');% ,'SOM');
%     set(hleg1,'Location','NorthEast','Fontsize',17)%h_legend-4)
%     set(hleg1,'Interpreter','none')%,'box','Off')        
 set(gca,'FontSize',20,'linewidth',1.5)
  ylim([16.5 17.8])
  xlim([-20 820])
  box on
cd (address) 
print ('-r600', fig_name,'-depsc')     
 

%%%%%%%   tropics
idx = find(lat_msh >= -2 & lat_msh <= 2) ;
idy = find(lon_msh >= 150 & lon_msh <= 260) ;
mask1 = zeros(size(lat_msh));
mask2 = zeros(size(lat_msh));
mask1(idx) = 1;
mask2(idx) = 1;
mask = mask1 + mask2 ; 
ind = find (mask==2);

for tt=1:size(var_all,3)
    II=find(isnan(var_all(:,:,tt))==1);
    TAREA2 = TAREA ;
    TAREA2(II)=nan;
    tmp = var_all(:,:,tt) ;
    var_Tseries_trop(tt) = nansum(TAREA2(ind) .* tmp(ind)) ./ nansum(TAREA2(ind)) ;     
end

var_trop_mean = nanmean(var_Tseries_trop(:,end-100:end),2)

%%%%%
smt = 20 ;
var_Tseries_trop2(1:size(var_Tseries_trop,1),1:size(var_Tseries_trop,2)+2*smt) = NaN ;
for i = 1:size(var_Tseries_trop2,1)
  for j=1:size(var_Tseries_trop,2)
    var_Tseries_trop2(i,j+smt) = var_Tseries_trop(i,j) ;
  end
    var_Tseries_trop_smooth(i,:) = smooth(var_Tseries_trop2(i,:),smt);
end

var_Tseries_trop_smooth(:,1:smt) = [] ;
var_Tseries_trop_smooth(:,end-smt+1:end) = [] ;

%%%%%%%%%
time = 1:size(var_Tseries_trop,2) ;
       fig_name = strcat('SST_T_SERIES_TROP_smt');%,num2str(tt));
        fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
cl = ['b','r','m','g','k','b','r','m','g']; 
nb = [17:20 12 16:-1:13] ;
j = 1;
     h(j)=plot(time,squeeze(var_Tseries_trop(j,:)),'color',cl(j),'linewidth',1) ; hold on;
     h2=plot(time,squeeze(var_Tseries_trop_smooth(j,:)),'color',cl(j),'linewidth',4) ; hold on;     
    xlabel('Time (year)','fontsize',23,'fontweight','bold');
    ylabel('Global SST (\circC)','fontsize',23,'fontweight','bold');
 set(gca,'FontSize',20,'linewidth',1.5)
%  ylim([16.5 17.8])
  xlim([-20 820])
  box on
cd (address) 
print ('-r600', fig_name,'-depsc')     
 
