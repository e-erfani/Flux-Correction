    clc
    clear
path(path,'/homes/eerfani/m_map2')
path(path,'/homes/eerfani/DrosteEffect-BrewerMap-04533de')
path(path,'/homes/eerfani/tight_subplot')
path(path,'/homes/eerfani/altmany-export_fig-cafc7c5')

address = '/shared/SWFluxCorr/CESM/OBS_pop_all_crrt_PreIn' ;
%%%%
cd (address)

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  lat_pop_zon = ncread(filename1,'lat_aux_grid');
  var = ncread(filename1,'N_HEAT');
  var_zonal = squeeze(var(:,1,1));    
%%%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr
    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
  var = ncread(filename1,'N_HEAT');
  var_zonal_ctrl = squeeze(var(:,1,1));    

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
cd /shared/SWFluxCorr/high_res/OBS_pop_all_crrt_PreIn

  aa1 = dir('tavg*.nc');
  filename1 = aa1(1,1).name;
  lat_pop_zon2 = ncread(filename1,'lat_aux_grid');
  var = ncread(filename1,'N_HEAT');
  var_zonal2 = squeeze(var(:,1,1));    
    
%%%%%%%%
cd /shared/SWFluxCorr/high_res/PreInd_f19_g16

    aa1 = dir('tavg*.nc');
    filename1 = aa1(1,1).name;
    var = ncread(filename1,'N_HEAT');
    var_zonal_ctrl2 = squeeze(var(:,1,1));    
   
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%
      fig_name = strcat('ocean_heat_transport_anomaly_zonal');
      fig_dum = figure(1);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_pop_zon, var_zonal - var_zonal_ctrl,'r','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon2, var_zonal2 - var_zonal_ctrl2,'b','linewidth',2) ;
hold on
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Ocean heat transport anomaly (PW)','fontsize',20,'fontweight','bold');
xlim([-80 80])
ylim([-0.6 0.15])
   hleg1 = legend([h1 h2],'GC-T31 - ctrl-T31','GC-f19 - ctrl-f19');
    set(hleg1,'Location','SouthEast','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)

%%%%%%%%%%%%%%
      fig_name = strcat('ocean_heat_transport_zonal');
      fig_dum = figure(2);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.5,0.5,9,8]);
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_pop_zon,var_zonal_ctrl,'r--','linewidth',2) ;
hold on
h2 = plot(lat_pop_zon,var_zonal,'r','linewidth',2) ;
hold on
h3 = plot(lat_pop_zon2,var_zonal_ctrl2,'b--','linewidth',2) ;
hold on
h4 = plot(lat_pop_zon2,var_zonal2,'b','linewidth',2) ;
    xlabel('Latitude (\circ)','fontsize',20,'fontweight','bold');
    ylabel('Ocean heat transport (PW)','fontsize',20,'fontweight','bold');
xlim([-80 80])
ylim([-1.5 2.05])
   hleg1 = legend([h1 h2 h3 h4],'ctrl-T31','GC-T31','ctrl-f19','GC-f19');
    set(hleg1,'Location','NorthWest','Fontsize',16)
    set(hleg1,'Interpreter','none')
set(gca,'Fontsize',16,'linewidth',1.5)
box on
set(gcf,'color','w');
set(gcf, 'PaperPositionMode', 'auto')
set(gcf,'renderer','Painters')
cd (address)
print ('-depsc','-tiff','-r600','-painters', fig_name)
