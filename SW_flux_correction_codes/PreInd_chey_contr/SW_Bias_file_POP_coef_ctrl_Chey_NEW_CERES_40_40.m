    clc
    clear
path(path,'/homes/eerfani/Bias/m_map') 
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

cd /homes/eerfani/Bias
cd CERES
load('lat_fine.mat')
load('lon_fine.mat')
cd fields_NEW
load ('SW_S_d_mo_mean')
load ('SW_S_u_mo_mean')
SW_S_N_mo_mean = SW_S_d_mo_mean - SW_S_u_mo_mean ;
[lon_fn_msh,lat_fn_msh] = meshgrid(lon_fine,lat_fine);

%%%%
cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 

    aa1=dir('chey_ctrl_rhminl_PreInd_T31_gx3v7.pop.h.0471-0570._*_climo.nc');
    month = {'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'} ;
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
    lat_msh =ncread(filename1,'TLAT');
    lon_msh =ncread(filename1,'TLONG');

TAREA=ncread(filename1,'TAREA'); % surface net Shortwave Radiation (W/m2)
md = [15 46 74 105	135	166	196	227	258	288	319	349] ;

nn = 0 ;
for tt1=1:12%length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SW_S_N=ncread(filename1,'SHF_QSW'); 
    SW_S_N_all(:,:,nn) = SW_S_N;      
end
    
%%%%%

for tt = 1:12
    tmp = double(SW_S_N_mo_mean(:,:,tt)') ;
    tmp2 = griddata(lon_fn_msh,lat_fn_msh,tmp,lon_msh,lat_msh,'natural');
    SW_S_N_mo_mean_intrp_CAMgrid(:,:,tt) = tmp2 ; 
end

%%%%%% initial method %%%%%%%
SW_S_N_mo_mean_intrp_CAMgrid(SW_S_N_mo_mean_intrp_CAMgrid == 0) = NaN ;
Bias_S_d = SW_S_N_all ./ SW_S_N_mo_mean_intrp_CAMgrid ;
Bias_S_d(isnan(Bias_S_d) == 1) = 1

for t1 = 1:365
    for m = 1:11
        if ( t1 >= md(m) && t1 < md(m+1) )
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - md(m)) .* (Bias_S_d(i,j,m+1) - Bias_S_d(i,j,m))...
                                           ./ (md(m+1) - md(m)) + Bias_S_d(i,j,m)  ; 
                                       
            end
            end            
        end
    
    end
        if ( t1 < md(1) ) 
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - (-15)) .* (Bias_S_d(i,j,1) - Bias_S_d(i,j,12))...
                                           ./ (md(1) - (-15)) + Bias_S_d(i,j,12)  ; 
            end
            end
        end
        
        if ( t1 >= md(12) )
            for i = 1:size(Bias_S_d,1)
            for j = 1:size(Bias_S_d,2)
                Bias_S_d_dail_mea(i,j,t1) = (t1 - md(12)) .* (Bias_S_d(i,j,1) - Bias_S_d(i,j,12))...
                                           ./ (365+15 - md(12)) + Bias_S_d(i,j,12)  ; 
            end
            end
        end            
end

    Bias_S_d_mea = nanmean(nanmean(Bias_S_d_dail_mea,1),2) ;
    day = 1:365 ;
    figure(1)
    plot(day,permute(Bias_S_d_mea,[3 1 2]))
    Bias_S_d_month_mean = nanmean(nanmean(Bias_S_d,1),2) ;
    hold on
    plot(md,permute(Bias_S_d_month_mean,[3 1 2]),'ok')
    
    
%%%%% new method %%%%%%%%
SW_S_d_all_2 = SW_S_N_all ;
SW_S_d_mo_mean_intrp_CAMgrid_2 = SW_S_N_mo_mean_intrp_CAMgrid ;
for k = 1:size(SW_S_N_all,3)
    for i = 1:size(SW_S_N_all,1)
        for j = 1:size(SW_S_N_all,2)
            if (SW_S_N_all(i,j,k) <= 2)
                SW_S_d_all_2(i,j,k) = SW_S_N_mo_mean_intrp_CAMgrid(i,j,k) ;
            end
            if (SW_S_N_mo_mean_intrp_CAMgrid(i,j,k) <= 2)
                SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) = SW_S_d_all_2(i,j,k) ;
            end            
            if (SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) <= 2 && SW_S_d_all_2(i,j,k) <= 2)
                Bias_S_d_2(i,j,k) = 1.0000 ;
            else
                Bias_S_d_2(i,j,k) = SW_S_d_all_2(i,j,k) ./ SW_S_d_mo_mean_intrp_CAMgrid_2(i,j,k) ;                
            end            
        end
    end
end

Bias_S_d_2(isnan(Bias_S_d_2) == 1) = 1;



for t1 = 1:365
    for m = 1:11
        if ( t1 >= md(m) && t1 < md(m+1) )
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - md(m)) .* (Bias_S_d_2(i,j,m+1) - Bias_S_d_2(i,j,m))...
                                           ./ (md(m+1) - md(m)) + Bias_S_d_2(i,j,m)  ; 
                                       
            end
            end            
        end
    
    end
        if ( t1 < md(1) ) 
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - (-15)) .* (Bias_S_d_2(i,j,1) - Bias_S_d_2(i,j,12))...
                                           ./ (md(1) - (-15)) + Bias_S_d_2(i,j,12)  ; 
            end
            end
        end
        
        if ( t1 >= md(12) )
            for i = 1:size(Bias_S_d_2,1)
            for j = 1:size(Bias_S_d_2,2)
                Bias_S_d_2_dail_mea(i,j,t1) = (t1 - md(12)) .* (Bias_S_d_2(i,j,1) - Bias_S_d_2(i,j,12))...
                                           ./ (365+15 - md(12)) + Bias_S_d_2(i,j,12)  ; 
            end
            end
        end            
end

    Bias_S_d_2_mea = nanmean(nanmean(Bias_S_d_2_dail_mea,1),2) ;
    day = 1:365 ;
    figure(2)
    plot(day,permute(Bias_S_d_2_mea,[3 1 2]))
    Bias_S_d_2_month_mean = nanmean(nanmean(Bias_S_d_2,1),2) ;
    hold on
    plot(md,permute(Bias_S_d_2_month_mean,[3 1 2]),'ok')
    
    Bias_S_d_2_dail_mea(isnan(Bias_S_d_2_dail_mea)==1) = 1.0 ;

cd /shared/SWFluxCorr/CESM/PreInd_chey_contr 
    
    dbstop
    
Bias_zonal = nanmean(Bias_S_d_2_dail_mea,1);
Bias_zonal_mean = nanmean(Bias_zonal,3);
    
       fig_name = strcat('Line_bias_SW_coef');%,num2str(tt));
        fig_dum = figure(3100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_msh(50,:),Bias_zonal_mean','k','linewidth',2) ;
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Downward SW bias coefficient','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
    ylim([0.75 1.2001])
    xlim([-90 90])
  box on
      
   
i50_ = find(lat_msh(50,:) <= -50) ;
%i40_50_ = find(lat_msh(50,:) > -50 & lat_msh(50,:) <= -40) ;

Bias_S_d_2_dail_mea(:,i50_,:) = 1 ;

% for i = 19:22
%             Bias_S_d_2_dail_mea(:,i,:) = 1 + (Bias_S_d_2_dail_mea(:,i,:) - 1 )...
%                                             .* (0.1 .* lat_msh(50,i) + 5);
% end

% for i = 12:13
%     for j = 1:size(Bias_S_d_2_dail_mea,1)
%         for k = 1:size(Bias_S_d_2_dail_mea,3)
%             Bias_S_d_2_dail_mea(j,i,k) = 1 + (Bias_S_d_2_dail_mea(j,i,k) - 1 )...
%                                             .* (0.1 .* latitude(i) + 5);
%         end
%     end
% end

i45 = find(lat_msh(50,:) >= 45) ;
%i40_50 = find(lat_msh(50,:) < 50 & lat_msh(50,:) >= 40) ;

Bias_S_d_2_dail_mea(:,i45,:) = 1 ;

% for i = 76:78
%             Bias_S_d_2_dail_mea(:,i,:) = 1 + (Bias_S_d_2_dail_mea(:,i,:) - 1 )...
%                                             .* (0.1 .* lat_msh(50,i) - 5);
% end

% for i = 12:13
%     for j = 1:size(Bias_S_d_2_dail_mea,1)
%         for k = 1:size(Bias_S_d_2_dail_mea,3)
%             Bias_S_d_2_dail_mea(j,i,k) = 1 + (Bias_S_d_2_dail_mea(j,i,k) - 1 )...
%                                             .* (0.1 .* latitude(i) - 5);
%         end
%     end
% end


Bias_zonal = nanmean(Bias_S_d_2_dail_mea,1);
Bias_zonal_mean = nanmean(Bias_zonal,3);
Bias_S_d_2_ave = nanmean(Bias_S_d_2_dail_mea,3) ;
%%%
       fig_name = strcat('Line_bias_SW_coef');%,num2str(tt));
        fig_dum = figure(3180);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
h1 = plot(lat_msh(50,:),Bias_zonal_mean','k','linewidth',2) ;
    xlabel('latitude (\circ)','fontsize',23,'fontweight','bold');
    ylabel('Downward SW bias coefficient','fontsize',23,'fontweight','bold');
    set(gca,'Fontsize',20,'linewidth',2)
    ylim([0.90 1.2001])
    xlim([-90 90])
  box on
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  

%%%%%%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(nanmean(Bias_S_d_2_dail_mea,3)) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_d_bias_annual_Chey_ctrl_FILE_POP_coef_NEW_CERES_50_50');%,num2str(tt));
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CESM(ctrl) / CERES, Downward SW Flux at Surface, Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0.6, 1.401])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      
%%%%
SW_S_d_CESM_month = nanmean(SW_S_N_all,3) ;

TAREA2 = TAREA ; 
II = find(isnan(SW_S_d_CESM_month) == 1) ;
TAREA2(II) = NaN ;

SW_S_d_CERES_intrp = nanmean(SW_S_N_mo_mean_intrp_CAMgrid,3) ;
SW_S_d_CERES_intrp_glb_mean = nansum(nansum(TAREA2 .* SW_S_d_CERES_intrp,1),2) ./ nansum(nansum(TAREA2,1),2)

SW_S_d_CESM_month_mean = nansum(nansum(TAREA2 .* SW_S_d_CESM_month,1),2) ./ nansum(nansum(TAREA2,1),2)

Bias_SW_S_d_mean = nanmean(SW_S_N_all - SW_S_N_mo_mean_intrp_CAMgrid,3) ;
Bias_SW_S_d_mean_ave = nansum(nansum(TAREA2 .* Bias_SW_S_d_mean,1),2) ./ nansum(nansum(TAREA2,1),2)

SW_S_d_CERES_intrp_glb_mean_trim = nansum(nansum(TAREA2(:,19:76) .* SW_S_d_CERES_intrp(:,19:76),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
SW_S_d_CESM_month_mean_trim = nansum(nansum(TAREA2(:,19:76) .* SW_S_d_CESM_month(:,19:76),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
Bias_SW_S_d_mean_ave_trim = nansum(nansum(TAREA2(:,19:76) .* Bias_SW_S_d_mean(:,19:76),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
ctrl_bias = nansum(nansum(TAREA2(:,19:76) .*SW_S_d_CESM_month(:,19:76) ./ Bias_S_d_2_ave(:,19:76),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
%%%%%
  cellsize = 0.5; 
SST_T31(:,:,1)  = double(nanmean(SW_S_N_all - SW_S_N_mo_mean_intrp_CAMgrid,3)) ;
lat_T31(:,:,1)  = lat_msh ;
lon_T31(:,:,1)  = lon_msh ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_S_d_bias_diff_annual_Chey_ctrl_POP_coef_NEW_CERES_40_40');%,num2str(tt));
        fig_dum = figure(144);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CESM(ctrl) - CERES, Downward SW Flux at Surface, Annual Mean';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([-60, 60])
      eval(['print -r600 -djpeg ', fig_name,'.jpg']);  
      
%%%%%
dbstop   
 nccreate('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','Bias_S_N_daily','Dimensions',{'lon',100,'lat',116,'day',365},'Format','classic');
 nccreate('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lat','Dimensions',{'lon',100,'lat',116},'Format','classic');
 nccreate('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lon','Dimensions',{'lon',100,'lat',116},'Format','classic'); 
 ncwrite('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','Bias_S_N_daily',Bias_S_d_2_dail_mea);
 ncwrite('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lat',lat_msh);
 ncwrite('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lon',lon_msh);
    
Test_SW = ncread('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','Bias_S_N_daily') ;
Test_lat = ncread('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lat') ;
Test_lon = ncread('Bias_S_N_POP_coef_Chey_ctrl_50_50.nc','lon') ;

clear SST_T31; clear lat_T31; clear lon_T31
  cellsize = 0.5;
SST_T31(:,:,1)  = double(nanmean(Test_SW,3)) ;
lat_T31(:,:,1)  = Test_lat ;
lon_T31(:,:,1)  = Test_lon ; 
[Z_adjust(:,:,1),refvec_bias(:,:,1)] = geoloc2grid(squeeze(lat_T31(:,:,1)),squeeze(lon_T31(:,:,1)),squeeze(SST_T31(:,:,1)), cellsize);   
 latlim = [-75 75];
 lonlim = [1 360];
 
        fig_name = strcat('SW_Surf_d_bias_annual_fromFILE_POP_diff_prescr_SST_NEW_CERES_50_50');%,num2str(tt));
        fig_dum = figure(100);
      set(fig_dum, 'name', fig_name,'numbertitle','on');
      set(fig_dum,'units','inches','position',[0.3,0.3,12,9]);%,'PaperOrientation','landscape');
      set(fig_dum,'paperpositionmode','auto');
       m_proj('miller','long',[0 358],'lat',[-75 75])       
    axesm('miller','MapLatLimit',latlim,'MapLonLimit',lonlim, ...
   'Frame','off','Grid','off')
AA=geoshow(squeeze(Z_adjust(:,:,1)), squeeze(refvec_bias(:,:,1)), 'DisplayType', 'texturemap','EdgeColor','flat');
    set(AA,'FaceColor','flat','Linestyle','-'); 
    setm(gca,'frame','on');
    setm(gca,'fontsize',12);
    setm(gca,'FEdgeColor',[1 1 1]);
  m_coast('linewidth',2,'color','black');
    Title_1 = 'Bias, CESM(ctrl) - CERES, Downward SW Flux at Surface, Annual Mean, CAM grid';
    title(Title_1,'fontsize',23,'fontweight','bold');
    cc = colorbar('peer',gca);
    set(gca,'Fontsize',20)
    m_grid('linewi',2,'linest','none','tickdir','in','fontsize',20);
    caxis([0.6 1.401])

dbstop

    cd /shared/SWFluxCorr/CESM/pop_1st_crrt_PreIn

    aa1=dir('tavg*.nc');
    tt1=1; % ncdisp(aa(tt,1).name)
    filename1=aa1(tt1,1).name;
nn = 0 ;
for tt1=length(aa1)
    nn = nn + 1 ;
    filename1=aa1(tt1,1).name;
    SW_N=ncread(filename1,'SHF_QSW'); 
    SW_N_all(:,:,nn) = SW_N;      
end

SW_S_d_CESM_month_corr = nanmean(SW_S_N_all,3) ;
SW_S_d_CESM_month_mean_corr_trim = nansum(nansum(TAREA2(:,19:76) .* SW_S_d_CESM_month_corr(:,19:76),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
ctrl_bias_corr = nansum(nansum(TAREA2(:,19:76) .* (SW_S_d_CESM_month_corr(:,19:76)...
    - SW_S_d_CESM_month(:,19:76) ./ Bias_S_d_2_ave(:,19:76)),1),2) ./ nansum(nansum(TAREA2(:,19:76),1),2)
